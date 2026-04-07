from __future__ import annotations

import time
from pathlib import Path, PurePosixPath

from tools.guard.core.classification import Severity, get_classification_policy
from tools.guard.core.guard_result import (
    GuardResult,
    GuardScope,
    Violation,
    ViolationSource,
)
from tools.guard.core.message_catalog import ResolvedCatalogMessage, get_message_catalog
from tools.guard.core.rule_schema import (
    ContentContractCase,
    ContentContractData,
    FileNamingData,
    ForbiddenPatternData,
    NormalizedRule,
    PathRequirementEntry,
    PathRequirementsData,
    RuleType,
    parse_rules,
)


class RuleExecutor:
    """Runs config-driven normalized rules from the policy rules: list.

    This class is the migration bridge: guards migrated to the normalized schema
    are executed here; unmigrated guards continue through GuardRegistry as before.
    GuardRegistry skips any legacy guard class whose GUARD_ID is in rule_ids.
    """

    def __init__(self, config: dict, paths: 'PathConstants') -> None:
        self.config = config
        self.paths = paths
        self.classification = get_classification_policy(config)
        self.message_catalog = get_message_catalog(config)
        raw_rules: list[dict] = config.get('rules', [])
        self._rules: list[NormalizedRule] = parse_rules(raw_rules) if raw_rules else []
        self._rules = [
            _apply_classification_overrides(
                rule,
                severity_override=self.classification.severity_overrides.get(rule.id),
                category_override=self.classification.category_overrides.get(rule.id),
            )
            for rule in self._rules
        ]

    @property
    def rule_ids(self) -> frozenset[str]:
        """IDs of all rules handled by this executor (enabled or not)."""
        return frozenset(r.id for r in self._rules)

    @property
    def rules(self) -> tuple[NormalizedRule, ...]:
        return tuple(self._rules)

    def run(
        self,
        files: list[Path],
        family: str = 'all',
        guard_ids: set[str] | None = None,
    ) -> list[GuardResult]:
        results: list[GuardResult] = []

        for rule in self._rules:
            if not self._is_rule_enabled(rule):
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

    def _is_rule_enabled(self, rule: NormalizedRule) -> bool:
        if not rule.enabled:
            return False

        family_key = f'{rule.scope}_guards'
        return self.config.get(family_key, {}).get(rule.id, True)

    # ------------------------------------------------------------------
    # Internal dispatch
    # ------------------------------------------------------------------

    def _run_rule(self, rule: NormalizedRule, files: list[Path]) -> list[Violation]:
        if rule.rule_type == RuleType.FORBIDDEN_PATTERN:
            return self._check_forbidden_pattern(rule, files)
        if rule.rule_type == RuleType.FILE_NAMING:
            return self._check_file_naming(rule, files)
        if rule.rule_type == RuleType.CONTENT_CONTRACT:
            return self._check_content_contract(rule, files)
        if rule.rule_type == RuleType.PATH_REQUIREMENTS:
            return self._check_path_requirements(rule)
        return []  # pragma: no cover — exhaustive with current RuleType values

    def _check_forbidden_pattern(
        self,
        rule: NormalizedRule,
        files: list[Path],
    ) -> list[Violation]:
        data = _require_rule_data(rule, ForbiddenPatternData)
        violations: list[Violation] = []

        for file_path in files:
            relative = self.paths.relative_path(file_path)

            if not self._path_matches_targets(relative, rule):
                continue

            try:
                lines = file_path.read_text(encoding='utf-8').splitlines()
            except OSError:
                continue

            for index, line in enumerate(lines, start=1):
                stripped = line.strip()

                if data.skip_comments and (
                    stripped.startswith('//') or stripped.startswith('///')
                ):
                    continue

                if any(skip in line for skip in data.literal_skip):
                    continue

                for pattern_entry in data.patterns:
                    if not pattern_entry.compiled.search(line):
                        continue
                    violations.append(
                        self._rule_violation(
                            rule=rule,
                            file_path=relative,
                            line_number=index,
                            line_content=line,
                            message=pattern_entry.message,
                            message_code=pattern_entry.message_code,
                            message_args={
                                'file': relative,
                                'file_path': relative,
                                'file_name': file_path.name,
                                'line_number': index,
                                'pattern': pattern_entry.regex_str,
                            },
                        ),
                    )
                    break  # one violation per line per rule

        return violations

    def _check_file_naming(
        self,
        rule: NormalizedRule,
        files: list[Path],
    ) -> list[Violation]:
        data = _require_rule_data(rule, FileNamingData)
        violations: list[Violation] = []

        for file_path in files:
            relative = self.paths.relative_path(file_path)

            if not self._path_matches_targets(relative, rule):
                continue

            name = file_path.name
            if data.naming_pattern.match(name):
                continue

            violations.append(
                self._rule_violation(
                    rule=rule,
                    file_path=relative,
                    line_number=1,
                    line_content=name,
                    message=data.naming_message,
                    message_code=data.naming_message_code,
                    message_args={
                        'file': relative,
                        'file_path': relative,
                        'file_name': name,
                        'naming_pattern': data.naming_pattern.pattern,
                    },
                    symbol=name,
                ),
            )

        return violations

    def _check_content_contract(
        self,
        rule: NormalizedRule,
        files: list[Path],
    ) -> list[Violation]:
        data = _require_rule_data(rule, ContentContractData)
        violations: list[Violation] = []

        for case in data.cases:
            if case.file:
                if not self._path_matches_targets(case.file, rule):
                    continue

                file_path = self.paths.root_dir / case.file

                if not file_path.exists():
                    if case.must_exist:
                        violations.append(
                            self._content_violation(
                                rule=rule,
                                file_path=case.file,
                                message_code=case.messages.missing_file_code,
                                message=_render_message(
                                    case.messages.missing_file,
                                    'Required file `{file}` is missing.',
                                    file=case.file,
                                    file_name=Path(case.file).name,
                                ),
                                message_args={
                                    'file': case.file,
                                    'file_path': case.file,
                                    'file_name': Path(case.file).name,
                                },
                            ),
                        )
                    continue

                violations.extend(self._evaluate_content_case(rule, case, file_path))
                continue

            for file_path in files:
                relative = self.paths.relative_path(file_path)

                if not self._path_matches_targets(relative, rule):
                    continue

                if not any(_path_matches(relative, pattern) for pattern in case.path_patterns):
                    continue

                violations.extend(self._evaluate_content_case(rule, case, file_path))

        return violations

    def _evaluate_content_case(
        self,
        rule: NormalizedRule,
        case: ContentContractCase,
        file_path: Path,
    ) -> list[Violation]:
        try:
            content = file_path.read_text(encoding='utf-8')
        except OSError:
            return []

        relative = self.paths.relative_path(file_path)
        violations: list[Violation] = []
        missing_required_tokens = [
            token for token in case.required_tokens if token not in content
        ]

        if missing_required_tokens:
            if case.aggregate_required_tokens:
                violations.append(
                    self._content_violation(
                        rule=rule,
                        file_path=relative,
                        message_code=case.messages.aggregate_missing_required_tokens_code,
                        message=_render_message(
                            case.messages.aggregate_missing_required_tokens,
                            '`{file_name}` is missing required tokens: {tokens}.',
                            file=relative,
                            file_name=file_path.name,
                            tokens=_format_token_list(missing_required_tokens),
                        ),
                        message_args={
                            'file': relative,
                            'file_path': relative,
                            'file_name': file_path.name,
                            'tokens': _format_token_list(missing_required_tokens),
                        },
                    ),
                )
            else:
                for token in missing_required_tokens:
                    violations.append(
                        self._content_violation(
                            rule=rule,
                            file_path=relative,
                            message_code=case.messages.missing_required_token_code,
                            message=_render_message(
                                case.messages.missing_required_token,
                                '`{file_name}` is missing required token `{token}`.',
                                file=relative,
                                file_name=file_path.name,
                                token=token,
                            ),
                            message_args={
                                'file': relative,
                                'file_path': relative,
                                'file_name': file_path.name,
                                'token': token,
                            },
                        ),
                    )

        if case.required_any_tokens and not any(
            token in content for token in case.required_any_tokens
        ):
            violations.append(
                self._content_violation(
                    rule=rule,
                    file_path=relative,
                    message_code=case.messages.missing_required_any_tokens_code,
                    message=_render_message(
                        case.messages.missing_required_any_tokens,
                        '`{file_name}` must contain at least one of {tokens}.',
                        file=relative,
                        file_name=file_path.name,
                        tokens=_format_token_list(case.required_any_tokens),
                    ),
                    message_args={
                        'file': relative,
                        'file_path': relative,
                        'file_name': file_path.name,
                        'tokens': _format_token_list(case.required_any_tokens),
                    },
                ),
            )

        for pattern_entry in case.required_patterns:
            if pattern_entry.compiled.search(content):
                continue
            violations.append(
                self._content_violation(
                    rule=rule,
                    file_path=relative,
                    message_code=case.messages.missing_required_pattern_code,
                    message=_render_message(
                        case.messages.missing_required_pattern,
                        '`{file_name}` is missing required pattern `{pattern}`.',
                        file=relative,
                        file_name=file_path.name,
                        pattern=pattern_entry.regex_str,
                    ),
                    message_args={
                        'file': relative,
                        'file_path': relative,
                        'file_name': file_path.name,
                        'pattern': pattern_entry.regex_str,
                    },
                ),
            )

        for token in case.forbidden_tokens:
            if token not in content:
                continue
            violations.append(
                self._content_violation(
                    rule=rule,
                    file_path=relative,
                    message_code=case.messages.forbidden_token_code,
                    message=_render_message(
                        case.messages.forbidden_token,
                        '`{file_name}` contains forbidden token `{token}`.',
                        file=relative,
                        file_name=file_path.name,
                        token=token,
                    ),
                    message_args={
                        'file': relative,
                        'file_path': relative,
                        'file_name': file_path.name,
                        'token': token,
                    },
                ),
            )

        for pattern_entry in case.forbidden_patterns:
            if not pattern_entry.compiled.search(content):
                continue
            violations.append(
                self._content_violation(
                    rule=rule,
                    file_path=relative,
                    message_code=case.messages.forbidden_pattern_code,
                    message=_render_message(
                        case.messages.forbidden_pattern,
                        pattern_entry.message,
                        file=relative,
                        file_name=file_path.name,
                        pattern=pattern_entry.regex_str,
                    ),
                    message_args={
                        'file': relative,
                        'file_path': relative,
                        'file_name': file_path.name,
                        'pattern': pattern_entry.regex_str,
                    },
                ),
            )

        return violations

    def _check_path_requirements(self, rule: NormalizedRule) -> list[Violation]:
        data = _require_rule_data(rule, PathRequirementsData)
        scope = self.config_scope
        violations: list[Violation] = []

        for entry in data.entries:
            if not self._path_matches_targets(entry.path, rule):
                continue

            if scope and not self.paths.path_is_within_scope(entry.path, scope):
                continue

            target = self.paths.root_dir / entry.path
            path_exists = target.exists() and self._path_kind_matches(target, entry)

            if not path_exists:
                if entry.must_exist:
                    violations.append(
                        self._content_violation(
                            rule=rule,
                            file_path=entry.path,
                            message_code=entry.messages.missing_path_code,
                            message=_render_message(
                                entry.messages.missing_path,
                                'Required path is missing: {path}',
                                path=entry.path,
                            ),
                            message_args={
                                'path': entry.path,
                                'file': entry.path,
                                'file_path': entry.path,
                            },
                        ),
                    )
                continue

            if not entry.contains_glob:
                continue

            if any(target.rglob(entry.contains_glob)):
                continue

            violations.append(
                self._content_violation(
                    rule=rule,
                    file_path=entry.path,
                    message_code=entry.messages.empty_path_code,
                    message=_render_message(
                        entry.messages.empty_path,
                        '`{path}` must contain at least one `{glob}` match.',
                        path=entry.path,
                        glob=entry.contains_glob,
                    ),
                    message_args={
                        'path': entry.path,
                        'file': entry.path,
                        'file_path': entry.path,
                        'glob': entry.contains_glob or '',
                    },
                ),
            )

        return violations

    @property
    def config_scope(self) -> str:
        return self.config.get('_runtime', {}).get('scope', 'all')

    def _content_violation(
        self,
        rule: NormalizedRule,
        file_path: str,
        message: str,
        message_code: str | None = None,
        message_args: dict[str, object] | None = None,
    ) -> Violation:
        return self._rule_violation(
            rule=rule,
            file_path=file_path,
            message=message,
            message_code=message_code,
            message_args=message_args,
            line_number=1,
            line_content='',
        )

    def _rule_violation(
        self,
        rule: NormalizedRule,
        *,
        file_path: str,
        message: str,
        message_code: str | None = None,
        message_args: dict[str, object] | None = None,
        line_number: int = 1,
        line_content: str = '',
        column_number: int | None = None,
        symbol: str | None = None,
        entity: str | None = None,
    ) -> Violation:
        resolved = self._resolve_message(
            code=message_code,
            params=message_args,
            fallback_message=message,
        )
        return Violation.create(
            file_path=file_path,
            line_number=line_number,
            line_content=line_content,
            message=resolved.message,
            guard_id=rule.id,
            severity=Severity(rule.severity),
            scope=GuardScope(rule.scope),
            violation_code=message_code or rule.id,
            category=rule.category,
            column_number=column_number,
            symbol=symbol,
            entity=entity,
            message_ref=resolved.code,
            message_args=resolved.params,
            suggestion=resolved.suggestion,
            remediation=resolved.remediation,
            docs_ref=resolved.docs_ref,
            source=ViolationSource.NORMALIZED,
        )

    def _resolve_message(
        self,
        *,
        code: str | None,
        params: dict[str, object] | None,
        fallback_message: str | None,
    ) -> ResolvedCatalogMessage:
        return self.message_catalog.resolve(
            code=code,
            params=params,
            fallback_message=fallback_message,
        )

    @staticmethod
    def _path_kind_matches(target: Path, entry: PathRequirementEntry) -> bool:
        if entry.path_kind == 'any':
            return True
        if entry.path_kind == 'dir':
            return target.is_dir()
        return target.is_file()

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

    def _path_matches_targets(self, relative: str, rule: NormalizedRule) -> bool:
        if self._file_is_excluded(relative, rule):
            return False

        if not rule.targets.include:
            return True

        return self._file_matches_include(relative, rule)


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


def _apply_classification_overrides(
    rule: NormalizedRule,
    *,
    severity_override: Severity | None,
    category_override: str | None,
) -> NormalizedRule:
    resolved_severity = severity_override.value if severity_override is not None else rule.severity
    resolved_category = category_override if category_override is not None else rule.category

    if resolved_severity == rule.severity and resolved_category == rule.category:
        return rule

    return NormalizedRule(
        id=rule.id,
        rule_type=rule.rule_type,
        name=rule.name,
        description=rule.description,
        severity=resolved_severity,
        category=resolved_category,
        scope=rule.scope,
        enabled=rule.enabled,
        targets=rule.targets,
        data=rule.data,
    )


def _require_rule_data(rule: NormalizedRule, expected_type: type) -> object:
    if isinstance(rule.data, expected_type):
        return rule.data
    raise TypeError(f'Rule {rule.id} is missing expected data for {expected_type.__name__}')


def _render_message(template: str | None, default: str, **context: str) -> str:
    message = template or default
    return message.format(**context)


def _format_token_list(tokens: list[str] | tuple[str, ...]) -> str:
    return ', '.join(f'`{token}`' for token in tokens)
