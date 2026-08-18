import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/vendor/data/models/vendor_models.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:provider/provider.dart';

class VendorAnalyticsScreen extends StatefulWidget {
  const VendorAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<VendorAnalyticsScreen> createState() => _VendorAnalyticsScreenState();
}

class _VendorAnalyticsScreenState extends State<VendorAnalyticsScreen> {
  late int _months;

  @override
  void initState() {
    super.initState();
    _months = context.read<VendorProvider>().analyticsMonths;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().fetchAnalytics(months: _months);
    });
  }

  void _selectPeriod(int months) {
    if (months == _months) return;
    setState(() => _months = months);
    context.read<VendorProvider>().fetchAnalytics(months: months);
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final provider = context.watch<VendorProvider>();
    final data = provider.analytics;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: sw * 0.05, color: PillBinColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Analytics',
            style: PillBinBold.style(
                fontSize: sw * 0.046, color: PillBinColors.textPrimary)),
      ),
      body: RefreshIndicator(
        color: PillBinColors.primary,
        onRefresh: () async => context
            .read<VendorProvider>()
            .fetchAnalytics(months: _months, forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sh * 0.04),
          children: [
            _periodRow(sw, sh),
            SizedBox(height: sh * 0.02),
            if (provider.isLoadingAnalytics && data == null)
              _loading(sh)
            else if (data == null || !data.hasData)
              _empty(sw, sh)
            else ...[
              _kpiGrid(sw, sh, data),
              SizedBox(height: sh * 0.02),
              _trendCard(sw, sh, data),
              SizedBox(height: sh * 0.02),
              _statusCard(sw, sh, data),
              if (data.topMedicines.isNotEmpty) ...[
                SizedBox(height: sh * 0.02),
                _medicinesCard(context, sw, sh, data),
              ],
              SizedBox(height: sh * 0.02),
              _ratingCard(context, sw, sh, data),
            ],
          ],
        ),
      ),
    );
  }

  static const Map<int, String> _periods = {
    6: '6M',
    12: '1Y',
    24: '2Y',
    60: '5Y',
  };

  Widget _card(double sw, String title, IconData icon, Color iconColor,
      double sh, Widget child) {
    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PillBinColors.greyLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: sw * 0.05, color: iconColor),
              SizedBox(width: sw * 0.025),
              Text(title,
                  style: PillBinBold.style(
                      fontSize: sw * 0.04, color: PillBinColors.textPrimary)),
            ],
          ),
          SizedBox(height: sh * 0.02),
          child,
        ],
      ),
    );
  }

  Widget _periodRow(double sw, double sh) {
    return Row(
      children: _periods.entries.map((entry) {
        final m = entry.key;
        final selected = _months == m;
        return Padding(
          padding: EdgeInsets.only(right: sw * 0.025),
          child: GestureDetector(
            onTap: () => _selectPeriod(m),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.055, vertical: sh * 0.009),
              decoration: BoxDecoration(
                color:
                    selected ? PillBinColors.primary : PillBinColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      selected ? Colors.transparent : PillBinColors.greyLight,
                  width: 1.5,
                ),
              ),
              child: Text(entry.value,
                  style: PillBinMedium.style(
                    fontSize: sw * 0.031,
                    color: selected
                        ? Colors.white
                        : PillBinColors.textSecondary,
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _loading(double sh) => Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.2),
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: PillBinColors.primary),
        ),
      );

  Widget _empty(double sw, double sh) => Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.15),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded,
                size: sw * 0.16, color: PillBinColors.greyLight),
            SizedBox(height: sh * 0.018),
            Text('No donation data yet',
                style: PillBinMedium.style(
                    fontSize: sw * 0.04,
                    color: PillBinColors.textSecondary)),
            SizedBox(height: sh * 0.006),
            Text('Analytics build up as donors send you requests',
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                    fontSize: sw * 0.032, color: PillBinColors.textLight)),
          ],
        ),
      );

  Widget _kpiGrid(double sw, double sh, VendorAnalytics d) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _kpi(sw, sh, '${d.total}', 'Requests',
                    Icons.inbox_rounded, PillBinColors.primary)),
            SizedBox(width: sw * 0.03),
            Expanded(
                child: _kpi(sw, sh, '${d.fulfilmentRate}%', 'Fulfilled',
                    Icons.task_alt_rounded, PillBinColors.success)),
          ],
        ),
        SizedBox(height: sh * 0.014),
        Row(
          children: [
            Expanded(
                child: _kpi(sw, sh, d.avgReplyLabel, 'Avg reply',
                    Icons.schedule_rounded, PillBinColors.info)),
            SizedBox(width: sw * 0.03),
            Expanded(
                child: _kpi(sw, sh, '${d.pending}', 'Awaiting you',
                    Icons.pending_actions_rounded, PillBinColors.warning)),
          ],
        ),
      ],
    );
  }

  Widget _kpi(double sw, double sh, String value, String label, IconData icon,
      Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: sh * 0.018, horizontal: sw * 0.035),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.022),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: sw * 0.045, color: color),
          ),
          SizedBox(width: sw * 0.028),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: PillBinBold.style(
                          fontSize: sw * 0.05, color: PillBinColors.textDark)),
                ),
                SizedBox(height: sh * 0.002),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PillBinRegular.style(
                        fontSize: sw * 0.028,
                        color: PillBinColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendCard(double sw, double sh, VendorAnalytics d) {
    final busiest = d.busiestPeriod;

    return _card(
      sw,
      'Requests per month',
      Icons.show_chart_rounded,
      PillBinColors.primary,
      sh,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _legendDot(
                  sw, PillBinColors.primary.withValues(alpha: 0.35), 'Received'),
              SizedBox(width: sw * 0.04),
              _legendDot(sw, PillBinColors.success, 'Completed'),
            ],
          ),
          SizedBox(height: sh * 0.02),
          SizedBox(height: sh * 0.26, child: _barChart(sw, d)),
          if (busiest != null) ...[
            SizedBox(height: sh * 0.018),
            _insight(
                sw,
                sh,
                Icons.trending_up_rounded,
                'Busiest ${d.periodUnit} was ${busiest.axisLabel} with '
                    '${busiest.total} '
                    '${busiest.total == 1 ? 'request' : 'requests'}'),
          ],
        ],
      ),
    );
  }

  Widget _insight(double sw, double sh, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.035, vertical: sh * 0.012),
      decoration: BoxDecoration(
        color: PillBinColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: sw * 0.042, color: PillBinColors.primary),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Text(text,
                style: PillBinRegular.style(
                    fontSize: sw * 0.031,
                    color: PillBinColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(double sw, double sh, VendorAnalytics d) {
    final slices = <_Slice>[
      _Slice('Pending', d.pending, PillBinColors.warning),
      _Slice('Approved', d.approved, PillBinColors.info),
      _Slice('Completed', d.completed, PillBinColors.success),
      _Slice('Rejected', d.rejected, PillBinColors.error),
      _Slice('Cancelled', d.cancelled, PillBinColors.grey),
    ].where((s) => s.count > 0).toList();

    return _card(
      sw,
      'Status breakdown',
      Icons.donut_large_rounded,
      PillBinColors.info,
      sh,
      Row(
        children: [
          SizedBox(
            width: sw * 0.34,
            height: sw * 0.34,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: sw * 0.1,
                    startDegreeOffset: -90,
                    sections: slices
                        .map((s) => PieChartSectionData(
                              value: s.count.toDouble(),
                              color: s.color,
                              radius: sw * 0.06,
                              showTitle: false,
                            ))
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${d.total}',
                        style: PillBinBold.style(
                            fontSize: sw * 0.055,
                            color: PillBinColors.textDark)),
                    Text('total',
                        style: PillBinRegular.style(
                            fontSize: sw * 0.026,
                            color: PillBinColors.textLight)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.04),
          Expanded(
            child: Column(
              children: slices
                  .map((s) => _statusRow(sw, sh, s, d.total))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusRow(double sw, double sh, _Slice s, int total) {
    final percent = total == 0 ? 0 : (s.count * 100 / total).round();
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.01),
      child: Row(
        children: [
          Container(
            width: sw * 0.022,
            height: sw * 0.022,
            decoration: BoxDecoration(
                color: s.color, borderRadius: BorderRadius.circular(3)),
          ),
          SizedBox(width: sw * 0.022),
          Expanded(
            child: Text(s.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PillBinRegular.style(
                    fontSize: sw * 0.031, color: PillBinColors.textDark)),
          ),
          Text('${s.count}',
              style: PillBinMedium.style(
                  fontSize: sw * 0.031, color: PillBinColors.textDark)),
          SizedBox(width: sw * 0.015),
          SizedBox(
            width: sw * 0.1,
            child: Text('$percent%',
                textAlign: TextAlign.end,
                style: PillBinRegular.style(
                    fontSize: sw * 0.029, color: PillBinColors.textLight)),
          ),
        ],
      ),
    );
  }

  Widget _medicinesCard(
      BuildContext context, double sw, double sh, VendorAnalytics d) {
    final top = d.topMedicines.take(5).toList();
    return _card(
      sw,
      'Most donated',
      Icons.medication_rounded,
      PillBinColors.success,
      sh,
      Column(
        children: [
          ...top.map((m) => _medicineBar(sw, sh, m, top.first.count)),
          SizedBox(height: sh * 0.008),
          _linkButton(context, sw, sh, 'View all medicines',
              '/vendor-donated-medicines-screen'),
        ],
      ),
    );
  }

  Widget _medicineBar(double sw, double sh, TopMedicine m, int maxCount) {
    final fraction = maxCount == 0 ? 0.0 : m.count / maxCount;
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.014),
      child: Row(
        children: [
          SizedBox(
            width: sw * 0.28,
            child: Text(
              m.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PillBinRegular.style(
                  fontSize: sw * 0.031, color: PillBinColors.textDark),
            ),
          ),
          SizedBox(width: sw * 0.02),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: sh * 0.011,
                backgroundColor:
                    PillBinColors.greyLight.withValues(alpha: 0.5),
                valueColor:
                    const AlwaysStoppedAnimation(PillBinColors.primary),
              ),
            ),
          ),
          SizedBox(width: sw * 0.025),
          SizedBox(
            width: sw * 0.06,
            child: Text('${m.count}',
                textAlign: TextAlign.end,
                style: PillBinMedium.style(
                    fontSize: sw * 0.031,
                    color: PillBinColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _ratingCard(
      BuildContext context, double sw, double sh, VendorAnalytics d) {
    return _card(
      sw,
      'Ratings',
      Icons.star_rounded,
      Colors.amber,
      sh,
      Column(
        children: [
          if (d.totalReviews == 0)
            Padding(
              padding: EdgeInsets.symmetric(vertical: sh * 0.015),
              child: Text('No reviews yet',
                  style: PillBinRegular.style(
                      fontSize: sw * 0.033,
                      color: PillBinColors.textSecondary)),
            )
          else ...[
            Row(
              children: [
                Text(d.rating.toStringAsFixed(1),
                    style: PillBinBold.style(
                        fontSize: sw * 0.1, color: PillBinColors.textDark)),
                SizedBox(width: sw * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          final filled = d.rating >= i + 1;
                          final half = !filled && d.rating > i;
                          return Icon(
                            half
                                ? Icons.star_half_rounded
                                : filled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                            size: sw * 0.045,
                            color: filled || half
                                ? Colors.amber
                                : PillBinColors.greyLight,
                          );
                        }),
                      ),
                      SizedBox(height: sh * 0.006),
                      Text(
                          '${d.totalReviews} '
                          '${d.totalReviews == 1 ? 'review' : 'reviews'} from donors',
                          style: PillBinRegular.style(
                              fontSize: sw * 0.031,
                              color: PillBinColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.02),
            _linkButton(context, sw, sh, 'View all reviews',
                '/vendor-reviews-screen'),
          ],
        ],
      ),
    );
  }

  Widget _linkButton(BuildContext context, double sw, double sh, String label,
      String route) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: sh * 0.014),
          side:
              BorderSide(color: PillBinColors.primary.withValues(alpha: 0.4)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: PillBinMedium.style(
                    fontSize: sw * 0.033, color: PillBinColors.primary)),
            SizedBox(width: sw * 0.015),
            Icon(Icons.arrow_forward_rounded,
                size: sw * 0.04, color: PillBinColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(double sw, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.022,
            height: sw * 0.022,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
          SizedBox(width: sw * 0.015),
          Text(label,
              style: PillBinRegular.style(
                  fontSize: sw * 0.028, color: PillBinColors.textSecondary)),
        ],
      );

  Widget _barChart(double sw, VendorAnalytics d) {
    final maxTotal =
        d.timeline.fold<int>(0, (m, p) => p.total > m ? p.total : m);
    final peak = maxTotal == 0 ? 1 : maxTotal;
    final step = peak <= 4 ? 1 : (peak / 4).ceil();
    final topTick = ((peak / step).ceil()) * step;
    final maxY = (topTick + step).toDouble();
    final interval = step.toDouble();
    final barWidth = d.timeline.length > 8 ? sw * 0.028 : sw * 0.045;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: PillBinColors.greyLight.withValues(alpha: 0.6),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: sw * 0.07,
              interval: interval,
              getTitlesWidget: (value, _) {
                if (value > topTick) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: PillBinRegular.style(
                      fontSize: sw * 0.026, color: PillBinColors.textLight),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= d.timeline.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    d.timeline[i].axisLabel,
                    style: PillBinRegular.style(
                        fontSize: sw * 0.025,
                        color: PillBinColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => PillBinColors.textDark,
            getTooltipItem: (group, _, __, ___) {
              final point = d.timeline[group.x];
              return BarTooltipItem(
                '${point.total} received\n${point.completed} completed',
                PillBinRegular.style(
                    fontSize: sw * 0.028, color: Colors.white),
              );
            },
          ),
        ),
        barGroups: List.generate(d.timeline.length, (i) {
          final point = d.timeline[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: point.total.toDouble(),
                width: barWidth,
                borderRadius: BorderRadius.circular(4),
                color: PillBinColors.primary.withValues(alpha: 0.35),
                rodStackItems: [
                  BarChartRodStackItem(
                      0, point.completed.toDouble(), PillBinColors.success),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Slice {
  final String label;
  final int count;
  final Color color;

  const _Slice(this.label, this.count, this.color);
}
