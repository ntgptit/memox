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
  });

  factory ActiveStudySessionSnapshot.fromJson(Map<String, dynamic> json) =>
      ActiveStudySessionSnapshot(
        deckId: json['deckId'] as int? ?? 0,
        mode: StudyMode.values.byName(json['mode'] as String? ?? 'review'),
        session: _sessionFromJson(json['session']),
        payload: _payloadFromJson(json['payload']),
      );

  final int deckId;
  final StudyMode mode;
  final StudySession? session;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'deckId': deckId,
    'mode': mode.name,
    'session': session?.toJson(),
    'payload': payload,
  };
}

final class ActiveStudySessionStore {
  ActiveStudySessionStore.memory() : _preferences = null;

  ActiveStudySessionStore.shared(SharedPreferences preferences)
    : _preferences = preferences;

  final SharedPreferences? _preferences;
  String? _memoryValue;

  Future<void> clear() async {
    final preferences = _preferences;

    if (preferences == null) {
      _memoryValue = null;
      return;
    }

    await preferences.remove(_activeStudySessionKey);
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

    final decoded = jsonDecode(raw);

    if (decoded is! Map) {
      return null;
    }

    return ActiveStudySessionSnapshot.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }

  Future<void> save(ActiveStudySessionSnapshot snapshot) async {
    final nextValue = jsonEncode(snapshot.toJson());
    final preferences = _preferences;

    if (preferences == null) {
      _memoryValue = nextValue;
      return;
    }

    await preferences.setString(_activeStudySessionKey, nextValue);
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
