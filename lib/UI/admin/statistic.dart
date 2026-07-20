import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../data/model/revenue_chart.dart';
import '../../data/repository/admin_repository.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  final AdminRepository _adminsRepository = AdminRepository();
  final logger = Logger();
  late DateTime startDate = DateTime(DateTime.now().year, DateTime.june, 1);
  late DateTime endDate = DateTime.now();
  bool isLoading = true;
  List<RevenueChart> revenueChart = [];

  Future<void> loadData() async {
    try {
      if(!mounted) return;
      final data = await _adminsRepository.getRevenue(startDate, endDate);
      setState(() {
        isLoading = false;
        startDate = data.fromDate!;
        endDate = data.toDate!;
        revenueChart = data.chart;
      });
    }
    catch(e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      logger.e(e);
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget _buildChart() {
    return Container(
      height: 400,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
          )
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: 300000,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            drawHorizontalLine: true,
          ),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      "Month ${value.toInt()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    "${(value / 1000).toInt()}\$",
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),

          barGroups: revenueChart.map((e) {
            return BarChartGroupData(
              x: e.month,
              barRods: [
                BarChartRodData(
                  toY: e.revenue,
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.deepOrange,
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Statistics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Revenue Statistics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Revenue by Month",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
            _buildChart(),
          ],
        ),
      ),
    );
  }
}
