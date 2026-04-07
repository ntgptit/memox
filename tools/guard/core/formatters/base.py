from __future__ import annotations

from abc import ABC

from tools.guard.core.formatters.report_envelope import ReportEnvelope


class OutputFormatter(ABC):
    """Base formatter contract over the normalized report envelope."""

    def __init__(self, envelope: ReportEnvelope) -> None:
        self.envelope = envelope
