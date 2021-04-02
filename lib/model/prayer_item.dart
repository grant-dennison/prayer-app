class PrayerItem {
  final String id;
  final String description;
  final DateTime? lastPrayed;

  const PrayerItem(
      {required this.id, required this.description, this.lastPrayed});
}
