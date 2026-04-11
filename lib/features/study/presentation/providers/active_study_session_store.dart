import 'dart:async';
import 'dart:convert';

import 'package:memox/core/design/study_mode.dart';
import 'package:memox/core/providers/storage_providers.dart';
import 'package:memox/features/study/domain/entities/study_session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'active_study_session_store.g.dart';

const String _activeStudySessionKey = 'active_study_session_v1';

@Riverpod(keepAlive: true)
Future<ActiveStudySessionStore> activeStudySessionStore(Ref ref) async {
  try {
    final preferences = await ref.watch(sharedPreferencesProvider.future);
    return ActiveStudySessionStore.shared(preferences);
  } catch (_) {
    return ActiveStudySessionStore.memory();
  }
}

final class ActiveStudySessionSnapshot {
  const ActiveStudySessionSnapshot({
    required this.deckId,
    required this.mode,
    required this.payload,
    this.session,
    this.modePlan = const <StudyMode>[],
    this.modeState = StudySessionModeState.initialized,
    this.allowedActions = const <StudySessionAllowedAction>[],
    this.currentItem,
    this.progress = const ActiveStudySessionProgress(),
    this.sessionCompleted = false,
  });

  factory ActiveStudySessionSnapshot.fromJson(Map<String, dynamic> json) =>
      ActiveStudySessionSnapshot(
        deckId: json['deckId'] as int? ?? 0,
        mode: _studyModeFromJson(json['activeMode'] ?? json['mode']),
        session: _sessionFromJson(json['session']),
        modePlan: _studyModeListFromJson(json['modePlan']),
        modeState: _modeStateFromJson(json['modeState']),
        allowedActions: _allowedActionsFromJson(json['allowedActions']),
        currentItem: _currentItemFromJson(json['currentItem']),
        progress: _progressFromJson(json['progress']),
        sessionCompleted: json['sessionCompleted'] as bool? ?? false,
        payload: _payloadFromJson(json['payload']),
      );

  final int deckId;
  final StudyMode mode;
  final StudySession? session;
  final List<StudyMode> modePlan;
  final StudySessionModeState modeState;
  final List<StudySessionAllowedAction> allowedActions;
  final ActiveStudySessionCurrentItem? currentItem;
  final ActiveStudySessionProgress progress;
  final bool sessionCompleted;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'deckId': deckId,
    'mode': mode.name,
    'activeMode': mode.name,
    'session': session?.toJson(),
    'modePlan': modePlan.map((entry) => entry.name).toList(growable: false),
    'modeState': modeState.wireValue,
    'allowedActions': allowedActions
        .map((entry) => entry.wireValue)
        .toList(growable: false),
    'currentItem': currentItem?.toJson(),
    'progress': progress.toJson(),
    'sessionCompleted': sessionCompleted,
    'payload': payload,
  };
}

bool isActiveStudySessionResumable(ActiveStudySessionSnapshot? snapshot) {
  if (snapshot == null) {
    return false;
  }

  if (snapshot.sessionCompleted) {
    return false;
  }

  return snapshot.modeState != StudySessionModeState.completed;
}

enum StudySessionModeState {
  initialized('INITIALIZED'),
  inProgress('IN_PROGRESS'),
  waitingFeedback('WAITING_FEEDBACK'),
  retryPending('RETRY_PENDING'),
  completed('COMPLETED');

  const StudySessionModeState(this.wireValue);

  final String wireValue;
}

enum StudySessionAllowedAction {
  submitAnswer('SUBMIT_ANSWER'),
  revealAnswer('REVEAL_ANSWER'),
  markRemembered('MARK_REMEMBERED'),
  retryItem('RETRY_ITEM'),
  goNext('GO_NEXT'),
  resetCurrentMode('RESET_CURRENT_MODE');

  const StudySessionAllowedAction(this.wireValue);

  final String wireValue;
}

final class ActiveStudySessionCurrentItem {
  const ActiveStudySessionCurrentItem({required this.position, this.cardId});

  factory ActiveStudySessionCurrentItem.fromJson(Map<String, dynamic> json) =>
      ActiveStudySessionCurrentItem(
        position: json['position'] as int? ?? 0,
        cardId: json['cardId'] as int?,
      );

  final int position;
  final int? cardId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'position': position,
    'cardId': cardId,
  };
}

final class ActiveStudySessionProgress {
  const ActiveStudySessionProgress({
    this.completedCount = 0,
    this.totalCount = 0,
  });

  factory ActiveStudySessionProgress.fromJson(Map<String, dynamic> json) =>
      ActiveStudySessionProgress(
        completedCount: json['completedCount'] as int? ?? 0,
        totalCount: json['totalCount'] as int? ?? 0,
      );

  final int completedCount;
  final int totalCount;

  bool get hasValues => totalCount > 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'completedCount': completedCount,
    'totalCount': totalCount,
  };
}

final class ActiveStudySessionStore {
  ActiveStudySessionStore.memory() : _preferences = null;

  ActiveStudySessionStore.shared(SharedPreferences preferences)
    : _preferences = preferences;

  final SharedPreferences? _preferences;
  final _changes = StreamController<ActiveStudySessionSnapshot?>.broadcast();
  String? _memoryValue;

  Future<void> clear() async {
    final preferences = _preferences;

    if (preferences == null) {
      _memoryValue = null;
      _emit(null);
      return;
    }

    await preferences.remove(_activeStudySessionKey);
    _emit(null);
  }

  Future<void> clearIfMatches({
    required int deckId,
    required StudyMode mode,
  }) async {
    final snapshot = load();

    if (snapshot == null) {
      return;
    }

    if (snapshot.deckId != deckId || snapshot.mode != mode) {
      return;
    }

    await clear();
  }

  ActiveStudySessionSnapshot? load() {
    final raw = _preferences?.getString(_activeStudySessionKey) ?? _memoryValue;

    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) {
        _scheduleCorruptedSnapshotClear();
        return null;
      }

      final snapshot = ActiveStudySessionSnapshot.fromJson(
        Map<String, dynamic>.from(decoded),
      );

      if (snapshot.deckId <= 0) {
        _scheduleCorruptedSnapshotClear();
        return null;
      }

      return snapshot;
    } catch (_) {
      _scheduleCorruptedSnapshotClear();
      return null;
    }
  }

  Future<void> save(ActiveStudySessionSnapshot snapshot) async {
    final nextValue = jsonEncode(snapshot.toJson());
    final preferences = _preferences;

    if (preferences == null) {
      _memoryValue = nextValue;
      _emit(snapshot);
      return;
    }

    await preferences.setString(_activeStudySessionKey, nextValue);
    _emit(snapshot);
  }

  Stream<ActiveStudySessionSnapshot?> watch() async* {
    yield load();
    yield* _changes.stream;
  }

  Future<T?> restoreMatching<T>({
    required int deckId,
    required StudyMode mode,
    required FutureOr<T> Function(ActiveStudySessionSnapshot snapshot) decode,
  }) async {
    final snapshot = load();

    if (snapshot == null) {
      return null;
    }

    if (snapshot.deckId != deckId || snapshot.mode != mode) {
      return null;
    }

    try {
      return await decode(snapshot);
    } catch (_) {
      await clearIfMatches(deckId: deckId, mode: mode);
      return null;
    }
  }

  void _scheduleCorruptedSnapshotClear() {
    final preferences = _preferences;
    _emit(null);

    if (preferences == null) {
      _memoryValue = null;
      return;
    }

    unawaited(preferences.remove(_activeStudySessionKey));
  }

  void _emit(ActiveStudySessionSnapshot? snapshot) {
    if (_changes.isClosed) {
      return;
    }

    _changes.add(snapshot);
  }
}

Map<String, dynamic> _payloadFromJson(Object? value) {
  if (value is! Map) {
    return const <String, dynamic>{};
  }

  return Map<String, dynamic>.from(value);
}

StudySession? _sessionFromJson(Object? value) {
  if (value is! Map) {
    return null;
  }

  return StudySession.fromJson(Map<String, dynamic>.from(value));
}

List<StudyMode> _studyModeListFromJson(Object? value) {
  if (value is! List) {
    return const <StudyMode>[];
  }

  return value.map(_studyModeFromJson).toList(growable: false);
}

StudyMode _studyModeFromJson(Object? value) {
  final rawMode = value as String?;

  for (final mode in StudyMode.values) {
    if (mode.name == rawMode) {
      return mode;
    }
  }

  throw const FormatException('Invalid study mode.');
}

List<StudySessionAllowedAction> _allowedActionsFromJson(Object? value) {
  if (value is! List) {
    return const <StudySessionAllowedAction>[];
  }

  return value.map(_studyActionFromJson).toList(growable: false);
}

StudySessionAllowedAction _studyActionFromJson(Object? value) {
  final rawAction = value as String?;

  for (final action in StudySessionAllowedAction.values) {
    if (action.wireValue == rawAction) {
      return action;
    }
  }

  throw const FormatException('Invalid study action.');
}

StudySessionModeState _modeStateFromJson(Object? value) {
  final rawState = value as String?;

  for (final state in StudySessionModeState.values) {
    if (state.wireValue == rawState) {
      return state;
    }
  }

  return StudySessionModeState.initialized;
}

ActiveStudySessionCurrentItem? _currentItemFromJson(Object? value) {
  if (value is! Map) {
    return null;
  }

  return ActiveStudySessionCurrentItem.fromJson(
    Map<String, dynamic>.from(value),
  );
}

ActiveStudySessionProgress _progressFromJson(Object? value) {
  if (value is! Map) {
    return const ActiveStudySessionProgress();
  }

  return ActiveStudySessionProgress.fromJson(Map<String, dynamic>.from(value));
}
