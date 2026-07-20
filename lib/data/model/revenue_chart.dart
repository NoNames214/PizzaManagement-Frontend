class RevenueChart {
  final int month;
  final double revenue;

  RevenueChart({
    required this.month,
    required this.revenue,
  });

  factory RevenueChart.fromJson(Map<String, dynamic> json) {
    return RevenueChart(
      month: json["month"],
      revenue: (json["revenue"] as num).toDouble(),
    );
  }
}