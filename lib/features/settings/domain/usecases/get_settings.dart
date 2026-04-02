import 'package:memox/features/settings/domain/entities/app_setting.dart';
import 'package:memox/features/settings/domain/repositories/settings_repository.dart';

final class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call() => _repository.getSettings();
}
