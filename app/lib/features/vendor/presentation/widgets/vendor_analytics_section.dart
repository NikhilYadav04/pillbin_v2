import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/vendor/data/models/vendor_models.dart';

class VendorAnalyticsSection extends StatelessWidget {
  final VendorAnalytics? analytics;
  final bool isLoading;

  const VendorAnalyticsSection({
    Key? key,
    required this.analytics,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final data = analytics;

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
              Icon(Icons.insights_rounded,
                  size: sw * 0.05, color: PillBinColors.primary),
              SizedBox(width: sw * 0.025),
              Text('Analytics',
                  style: PillBinBold.style(
                      fontSize: sw * 0.042, color: PillBinColors.textPrimary)),
              const Spacer(),
              if (data != null && data.hasData)
                Text('Last ${data.timeline.length} ${data.periodNoun}',
                    style: PillBinRegular.style(
                        fontSize: sw * 0.029,
                        color: PillBinColors.textLight)),
            ],
          ),
          SizedBox(height: sh * 0.02),
          if (isLoading && data == null)
            _loading(sw, sh)
          else if (data == null || !data.hasData)
            _empty(sw, sh)
          else ...[
            _kpiRow(sw, sh, data),
            SizedBox(height: sh * 0.022),
            _trend(sw, sh, data),
            SizedBox(height: sh * 0.02),
            _viewAll(context, sw, sh),
          ],
        ],
      ),
    );
  }

  Widget _loading(double sw, double sh) => SizedBox(
        height: sh * 0.14,
        child: Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: PillBinColors.primary),
        ),
      );

  Widget _empty(double sw, double sh) => Padding(
        padding: EdgeInsets.symmetric(vertical: sh * 0.03),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded,
                size: sw * 0.11, color: PillBinColors.greyLight),
            SizedBox(height: sh * 0.012),
            Text('No donation data yet',
                style: PillBinMedium.style(
                    fontSize: sw * 0.036,
                    color: PillBinColors.textSecondary)),
            SizedBox(height: sh * 0.005),
            Text('Charts appear once you receive your first request',
                textAlign: TextAlign.center,
                style: PillBinRegular.style(
                    fontSize: sw * 0.031, color: PillBinColors.textLight)),
          ],
        ),
      );

  Widget _kpiRow(double sw, double sh, VendorAnalytics d) => Row(
        children: [
          Expanded(
              child: _kpi(
                  sw, sh, '${d.total}', 'Requests', PillBinColors.primary)),
          SizedBox(width: sw * 0.025),
          Expanded(
              child: _kpi(sw, sh, '${d.fulfilmentRate}%', 'Fulfilled',
                  PillBinColors.success)),
          SizedBox(width: sw * 0.025),
          Expanded(
              child: _kpi(
                  sw, sh, d.avgReplyLabel, 'Avg reply', PillBinColors.info)),
        ],
      );

  Widget _kpi(double sw, double sh, String value, String label, Color color) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: sh * 0.014, horizontal: sw * 0.02),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: PillBinBold.style(fontSize: sw * 0.052, color: color)),
          ),
          SizedBox(height: sh * 0.004),
          Text(label,
              style: PillBinRegular.style(
                  fontSize: sw * 0.028, color: PillBinColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _trend(double sw, double sh, VendorAnalytics d) {
    final points = d.timeline.length > 6
        ? d.timeline.sublist(d.timeline.length - 6)
        : d.timeline;
    if (points.isEmpty) return const SizedBox.shrink();

    final peak = points.fold<int>(0, (m, p) => p.total > m ? p.total : m);
    final barHeight = sh * 0.085;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _legendDot(
                sw, PillBinColors.primary.withValues(alpha: 0.25), 'Received'),
            SizedBox(width: sw * 0.04),
            _legendDot(sw, PillBinColors.success, 'Completed'),
          ],
        ),
        SizedBox(height: sh * 0.014),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: points
              .map((p) => _sparkBar(sw, sh, p, peak, barHeight))
              .toList(),
        ),
      ],
    );
  }

  Widget _sparkBar(
      double sw, double sh, MonthPoint p, int peak, double height) {
    final totalH = peak == 0 ? 0.0 : height * (p.total / peak);
    final doneH = peak == 0 ? 0.0 : height * (p.completed / peak);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.012),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: totalH.clamp(3.0, height),
                      decoration: BoxDecoration(
                        color: PillBinColors.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  if (p.completed > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: doneH.clamp(3.0, height),
                        decoration: BoxDecoration(
                          color: PillBinColors.success,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: sh * 0.008),
            Text(p.axisLabel,
                style: PillBinRegular.style(
                    fontSize: sw * 0.026, color: PillBinColors.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(double sw, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: sw * 0.02,
            height: sw * 0.02,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
          SizedBox(width: sw * 0.012),
          Text(label,
              style: PillBinRegular.style(
                  fontSize: sw * 0.027, color: PillBinColors.textLight)),
        ],
      );

  Widget _viewAll(BuildContext context, double sw, double sh) => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/vendor-analytics-screen'),
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
              Text('View full analytics',
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
