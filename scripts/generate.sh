#!/usr/bin/env bash
set -euo pipefail

flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
