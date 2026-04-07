from __future__ import annotations

import json

from tools.guard.core.formatters.base import OutputFormatter


class JsonFormatter(OutputFormatter):
    def render(self) -> str:
        return json.dumps(self.envelope.to_dict(), indent=2)
