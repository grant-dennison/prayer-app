class PrayerItem {
  final String id;
  final String description;
  final int timesPrayed;
  final DateTime created;
  final DateTime? lastPrayed;
  final DateTime? answered;

  const PrayerItem({
    required this.id,
    required this.description,
    this.timesPrayed = 0,
    required this.created,
    this.lastPrayed,
    this.answered,
  });
}
