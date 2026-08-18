import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/user_model.dart';
import 'package:provider/provider.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({Key? key}) : super(key: key);

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

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
        title: Text('My Impact',
            style: PillBinBold.style(
                fontSize: sw * 0.048, color: PillBinColors.textPrimary)),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, _) {
          final user = provider.user;
          final disposed = user?.stats.medicinesDisposedCount ?? 0;
          final tracked = user?.stats.totalMedicinesTracked ?? 0;
          final expiringSoon = user?.stats.expiringSoonCount ?? 0;
          final campaigns = user?.stats.campaignsJoinedCount ?? 0;

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                  sw * 0.05, sh * 0.01, sw * 0.05, sh * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headline(sw, sh, disposed),
                  SizedBox(height: sh * 0.03),
                  Text('Your Numbers',
                      style: PillBinBold.style(
                          fontSize: sw * 0.042,
                          color: PillBinColors.textPrimary)),
                  SizedBox(height: sh * 0.015),
                  Row(
                    children: [
                      Expanded(
                        child: _statTile(sw, sh, '$tracked', 'Medicines\nTracked',
                            Icons.medication_outlined, PillBinColors.primary),
                      ),
                      SizedBox(width: sw * 0.035),
                      Expanded(
                        child: _statTile(sw, sh, '$disposed', 'Safely\nDisposed',
                            Icons.eco_outlined, PillBinColors.success),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.018),
                  Row(
                    children: [
                      Expanded(
                        child: _statTile(
                            sw,
                            sh,
                            '$expiringSoon',
                            'Expiring\nSoon',
                            Icons.schedule_outlined,
                            PillBinColors.warning),
                      ),
                      SizedBox(width: sw * 0.035),
                      Expanded(
                        child: _statTile(
                            sw,
                            sh,
                            '$campaigns',
                            'Campaigns\nJoined',
                            Icons.campaign_outlined,
                            PillBinColors.info),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.035),
                  Text('Achievements',
                      style: PillBinBold.style(
                          fontSize: sw * 0.042,
                          color: PillBinColors.textPrimary)),
                  SizedBox(height: sh * 0.015),
                  _badges(sw, sh, user, tracked),
                  SizedBox(height: sh * 0.03),
                  _footerNote(sw, sh, disposed),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _headline(double sw, double sh, int disposed) {
    final hasImpact = disposed > 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sw * 0.06),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PillBinColors.success.withValues(alpha: 0.16),
            PillBinColors.primary.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: PillBinColors.success.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.03),
            decoration: BoxDecoration(
              color: PillBinColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.volunteer_activism_rounded,
                size: sw * 0.07, color: PillBinColors.success),
          ),
          SizedBox(height: sh * 0.02),
          if (hasImpact) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$disposed',
                    style: PillBinBold.style(
                        fontSize: sw * 0.13,
                        color: PillBinColors.textPrimary)),
                SizedBox(width: sw * 0.02),
                Padding(
                  padding: EdgeInsets.only(bottom: sh * 0.008),
                  child: Text(disposed == 1 ? 'medicine' : 'medicines',
                      style: PillBinMedium.style(
                          fontSize: sw * 0.042,
                          color: PillBinColors.textSecondary)),
                ),
              ],
            ),
            SizedBox(height: sh * 0.006),
            Text('kept out of landfill and water supply',
                style: PillBinRegular.style(
                    fontSize: sw * 0.036,
                    color: PillBinColors.textSecondary)),
          ] else ...[
            Text('Your impact starts here',
                style: PillBinBold.style(
                    fontSize: sw * 0.055, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.008),
            Text(
                'Donate medicines you no longer need and watch this number grow.',
                style: PillBinRegular.style(
                    fontSize: sw * 0.035,
                    color: PillBinColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  Widget _statTile(double sw, double sh, String value, String label,
      IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sw * 0.022),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: sw * 0.045, color: color),
          ),
          SizedBox(height: sh * 0.014),
          Text(value,
              style: PillBinBold.style(
                  fontSize: sw * 0.065, color: PillBinColors.textPrimary)),
          SizedBox(height: sh * 0.004),
          Text(label,
              style: PillBinRegular.style(
                  fontSize: sw * 0.031,
                  color: PillBinColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _badges(double sw, double sh, UserModel? user, int tracked) {
    final items = [
      (
        'First Timer',
        'Track your 1st medicine',
        Icons.track_changes_rounded,
        user?.badges.firstTimer.achieved ?? false,
        1,
      ),
      (
        'Eco Helper',
        'Track 5 medicines',
        Icons.eco_rounded,
        user?.badges.ecoHelper.achieved ?? false,
        5,
      ),
      (
        'Green Champion',
        'Track 20 medicines',
        Icons.military_tech_rounded,
        user?.badges.greenChampion.achieved ?? false,
        20,
      ),
    ];

    return Column(
      children: items.map((item) {
        final achieved = item.$4;
        final target = item.$5;
        final progress = (tracked / target).clamp(0.0, 1.0);

        return Container(
          margin: EdgeInsets.only(bottom: sh * 0.014),
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: achieved
                  ? PillBinColors.success.withValues(alpha: 0.4)
                  : PillBinColors.greyLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sw * 0.028),
                decoration: BoxDecoration(
                  color: achieved
                      ? PillBinColors.success.withValues(alpha: 0.12)
                      : PillBinColors.greyLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.$3,
                    size: sw * 0.052,
                    color: achieved
                        ? PillBinColors.success
                        : PillBinColors.textLight),
              ),
              SizedBox(width: sw * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1,
                        style: PillBinMedium.style(
                            fontSize: sw * 0.037,
                            color: achieved
                                ? PillBinColors.textPrimary
                                : PillBinColors.textSecondary)),
                    SizedBox(height: sh * 0.004),
                    Text(item.$2,
                        style: PillBinRegular.style(
                            fontSize: sw * 0.03,
                            color: PillBinColors.textSecondary)),
                    if (!achieved) ...[
                      SizedBox(height: sh * 0.008),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: PillBinColors.greyLight,
                          valueColor: AlwaysStoppedAnimation(
                              PillBinColors.primary.withValues(alpha: 0.6)),
                        ),
                      ),
                      SizedBox(height: sh * 0.004),
                      Text('$tracked / $target',
                          style: PillBinRegular.style(
                              fontSize: sw * 0.027,
                              color: PillBinColors.textLight)),
                    ],
                  ],
                ),
              ),
              if (achieved)
                Icon(Icons.check_circle_rounded,
                    size: sw * 0.05, color: PillBinColors.success),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _footerNote(double sw, double sh, int disposed) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.info.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PillBinColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: sw * 0.042, color: PillBinColors.info),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Text(
              disposed > 0
                  ? 'Every medicine handed to a verified center is one that never reaches a landfill or water supply.'
                  : 'Medicines thrown in household waste can leak into groundwater. Donating them to a verified center prevents that.',
              style: PillBinRegular.style(
                  fontSize: sw * 0.031, color: PillBinColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
