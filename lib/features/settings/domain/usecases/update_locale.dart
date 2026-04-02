import 'package:memox/features/settings/domain/repositories/settings_repository.dart';

final class UpdateLocaleUseCase {
  const UpdateLocaleUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String? localeCode) {
    return _repository.updateLocaleCode(localeCode);
  }
}
