from __future__ import annotations

import time
from pathlib import Path, PurePosixPath

from tools.guard.core.guard_result import GuardResult, GuardScope, Severity, Violation
from tools.guard.core.rule_schema import NormalizedRule, RuleType, parse_rules


class RuleExecutor:
    """Runs config-driven normalized rules from the policy rules: list.

    This class is the migration bridge: guards migrated to the normalized schema
    are executed here; unmigrated guards continue through GuardRegistry as before.
    GuardRegistry skips any legacy guard class whose GUARD_ID is in rule_ids.
    """

    def __init__(self, config: dict, paths: 'PathConstants') -> None:
        self.paths = paths
        raw_rules: list[dict] = config.get('rules', [])
        self._rules: list[NormalizedRule] = parse_rules(raw_rules) if raw_rules else []
        # Apply per-rule severity overrides from config
        overrides: dict[str, str] = config.get('severity_overrides', {})
        if overrides:
            self._rules = [
                _apply_severity_override(rule, overrides.get(rule.id))
                for rule in self._rules
            ]

    @property
    def rule_ids(self) -> frozenset[str]:
        """IDs of all rules handled by this executor (enabled or not)."""
        return frozenset(r.id for r in self._rules)

    def run(
        self,
        files: list[Path],
        family: str = 'all',
        guard_ids: set[str] | None = None,
    ) -> list[GuardResult]:
        results: list[GuardResult] = []

        for rule in self._rules:
            if not rule.enabled:
                continue

            if guard_ids is not None and rule.id not in guard_ids:
                continue

            rule_scope = GuardScope(rule.scope)

            if family == 'global' and rule_scope != GuardScope.GLOBAL:
                continue
            if family == 'local' and rule_scope != GuardScope.LOCAL:
                continue

            started_at = time.perf_counter()
            violations = self._run_rule(rule, files)
            duration_ms = (time.perf_counter() - started_at) * 1000

            results.append(GuardResult(
                guard_id=rule.id,
                guard_name=rule.name,
                description=rule.description,
                scope=rule_scope,
                violations=violations,
                files_scanned=len(files),
                duration_ms=duration_ms,
            ))

        return results

    # ------------------------------------------------------------------
    # Internal dispatch
    # ------------------------------------------------------------------

    def _run_rule(self, rule: NormalizedRule, files: list[Path]) -> list[Violation]:
        if rule.rule_type == RuleType.FORBIDDEN_PATTERN:
            return self._check_forbidden_pattern(rule, files)
        if rule.rule_type == RuleType.FILE_NAMING:
            return self._check_file_naming(rule, files)
        return []  # pragma: no cover — exhaustive with current RuleType values

    def _check_forbidden_pattern(
        self,
        rule: NormalizedRule,
        files: list[Path],
    ) -> list[Violation]:
        severity = Severity(rule.severity)
        scope = GuardScope(rule.scope)
        violations: list[Violation] = []

        for file_path in files:
            relative = self.paths.relative_path(file_path)

            if self._file_is_excluded(relative, rule):
                continue

            if rule.targets.include and not self._file_matches_include(relative, rule):
                continue

            try:
                lines = file_path.read_text(encoding='utf-8').splitlines()
            except OSError:
                continue

            for index, line in enumerate(lines, start=1):
                stripped = line.strip()

                if rule.skip_comments and (
                    stripped.startswith('//') or stripped.startswith('///')
                ):
                    continue

                if any(skip in line for skip in rule.literal_skip):
                    continue

                for pattern_entry in rule.patterns:
                    if not pattern_entry.compiled.search(line):
                        continue
                    violations.append(Violation(
                        file_path=relative,
                        line_number=index,
                        line_content=line,
                        message=pattern_entry.message,
                        guard_id=rule.id,
                        severity=severity,
                        scope=scope,
                    ))
                    break  # one violation per line per rule

        return violations

    def _check_file_naming(
        self,
        rule: NormalizedRule,
        files: list[Path],
    ) -> list[Violation]:
        assert rule.naming_pattern is not None
        severity = Severity(rule.severity)
        scope = GuardScope(rule.scope)
        violations: list[Violation] = []

        for file_path in files:
            relative = self.paths.relative_path(file_path)

            if self._file_is_excluded(relative, rule):
                continue

            if rule.targets.include and not self._file_matches_include(relative, rule):
                continue

            name = file_path.name
            if rule.naming_pattern.match(name):
                continue

            violations.append(Violation(
                file_path=relative,
                line_number=1,
                line_content=name,
                message=rule.naming_message,
                guard_id=rule.id,
                severity=severity,
                scope=scope,
            ))

        return violations

    # ------------------------------------------------------------------
    # Target helpers
    # ------------------------------------------------------------------

    def _file_is_excluded(self, relative: str, rule: NormalizedRule) -> bool:
        for pattern in rule.targets.exclude:
            if _path_matches(relative, pattern):
                return True
        return False

    def _file_matches_include(self, relative: str, rule: NormalizedRule) -> bool:
        for pattern in rule.targets.include:
            if _path_matches(relative, pattern):
                return True
        return False


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _path_matches(relative: str, pattern: str) -> bool:
    """True if `relative` (forward-slash path) matches `pattern`.

    Supports two matching modes:
    - Glob patterns (contain '*' or '?'): matched via PurePosixPath.full_match()
      (Python 3.13+).  Patterns that do not start with '/' or '**' are wrapped
      with '**/' so they can match anywhere in the path.
    - Substring patterns (no glob chars): matched via ``in``.
    """
    if '*' not in pattern and '?' not in pattern:
        return pattern in relative

    # Normalise relative patterns so full_match() can find them anywhere
    # in the path.  e.g. "*.g.dart" → "**/*.g.dart",
    #                     "features/**/screens/*.dart" → "**/features/**/screens/*.dart"
    if not pattern.startswith('/') and not pattern.startswith('**'):
        full_pattern = f'**/{pattern}'
    else:
        full_pattern = pattern

    return PurePosixPath(relative).full_match(full_pattern)


def _apply_severity_override(rule: NormalizedRule, override: str | None) -> NormalizedRule:
    if override is None or override == rule.severity:
        return rule
    # NormalizedRule is frozen — rebuild with new severity
    return NormalizedRule(
        id=rule.id,
        rule_type=rule.rule_type,
        name=rule.name,
        description=rule.description,
        severity=override,
        scope=rule.scope,
        enabled=rule.enabled,
        targets=rule.targets,
        patterns=rule.patterns,
        skip_comments=rule.skip_comments,
        literal_skip=rule.literal_skip,
        naming_pattern=rule.naming_pattern,
        naming_message=rule.naming_message,
    )
