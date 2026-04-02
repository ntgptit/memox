from __future__ import annotations

from abc import ABC, abstractmethod
import importlib
import inspect
from pathlib import Path
from typing import Type

from tools.guard.core.base_guard import BaseGuard
from tools.guard.core.guard_result import GuardScope


class GuardFamily(ABC):
    FAMILY_ID = ''
    FAMILY_NAME = ''
    SCOPE = GuardScope.GLOBAL
    GUARDS_DIR = ''

    def __init__(
        self,
        config: dict,
        path_constants: 'PathConstants',
        project_rules: dict | None = None,
    ) -> None:
        self.config = config
        self.path_constants = path_constants
        self.project_rules = project_rules

    @abstractmethod
    def create_guards(self) -> list[BaseGuard]:
        raise NotImplementedError

    def _discover_classes(self) -> list[Type[BaseGuard]]:
        guard_root = Path(__file__).resolve().parents[1] / self.GUARDS_DIR
        classes: list[Type[BaseGuard]] = []

        for file_path in sorted(guard_root.glob('*.py')):
            if file_path.name.startswith('_'):
                continue

            if file_path.name == 'family.py':
                continue

            module_name = f'tools.guard.{self.GUARDS_DIR}.{file_path.stem}'
            module = importlib.import_module(module_name)

            for _, value in inspect.getmembers(module, inspect.isclass):
                if not issubclass(value, BaseGuard):
                    continue

                if value is BaseGuard:
                    continue

                if not value.GUARD_ID:
                    continue

                classes.append(value)

        return classes
