from __future__ import annotations

from dataclasses import dataclass

from tools.guard.core.guard_result import GuardResult


@dataclass(slots=True, frozen=True)
class ReportSummary:
    guards: int
    errors: int
    warnings: int
    infos: int

    @classmethod
    def from_results(cls, results: tuple[GuardResult, ...]) -> 'ReportSummary':
        return cls(
            guards=len(results),
            errors=sum(result.error_count for result in results),
            warnings=sum(result.warning_count for result in results),
            infos=sum(result.info_count for result in results),
        )

    def to_dict(self) -> dict[str, int]:
        return {
            'guards': self.guards,
            'errors': self.errors,
            'warnings': self.warnings,
            'infos': self.infos,
        }


@dataclass(slots=True, frozen=True)
class ReportEnvelope:
    results: tuple[GuardResult, ...]
    summary: ReportSummary
    project_name: str | None = None

    @classmethod
    def from_results(
        cls,
        results: list[GuardResult],
        *,
        project_name: str | None = None,
    ) -> 'ReportEnvelope':
        normalized_results = tuple(results)
        return cls(
            results=normalized_results,
            summary=ReportSummary.from_results(normalized_results),
            project_name=project_name,
        )

    @property
    def report_title(self) -> str:
        if self.project_name:
            return f'{self.project_name} Guard Report'

        return 'Guard Report'

    @property
    def summary_title(self) -> str:
        if self.project_name:
            return f'{self.project_name} Guard Summary'

        return 'Guard Summary'

    def to_dict(self) -> dict[str, object]:
        return {
            'summary': self.summary.to_dict(),
            'results': [result.to_dict() for result in self.results],
        }
