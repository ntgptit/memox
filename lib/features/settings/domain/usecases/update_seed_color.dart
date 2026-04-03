import 'package:memox/features/settings/domain/repositories/settings_repository.dart';

final class UpdateSeedColorUseCase {
  const UpdateSeedColorUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call(int seedColorValue) => _repository.updateSeedColorValue(seedColorValue);
}
