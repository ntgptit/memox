# MemoX

This branch is a clean reset of the previous MemoX codebase.

The repository now contains only a fresh Flutter starter baseline so the app can
be rebuilt from scratch without legacy feature code, docs, or guard rules.

## Current status

- Flutter project recreated with package name `memox`
- Android namespace and application ID set to `com.memox.memox`
- Default counter demo replaced with a rebuild placeholder screen
- Widget test updated to verify the new baseline

## Verify

```bash
flutter analyze
flutter test
```
