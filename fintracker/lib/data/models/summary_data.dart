class SummaryData {
  final String label;
  final double total;

  SummaryData({required this.label, required this.total});

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    return SummaryData(
      label: json['label'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }
}
