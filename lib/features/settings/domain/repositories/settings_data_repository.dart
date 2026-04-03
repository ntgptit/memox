typedef SettingsHistoryClearSummary = ({int sessionCount, int reviewCount});

typedef SettingsImportSummary = ({
  int folderCount,
  int deckCount,
  int cardCount,
});

abstract interface class SettingsDataRepository {
  Future<SettingsHistoryClearSummary> clearStudyHistory();

  Future<String> exportCardsJson();

  Future<SettingsImportSummary> importCardsJson(String rawJson);
}
