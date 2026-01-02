import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/notifications/notification_config.dart';
import 'package:pillbin/config/notifications/notification_model.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/dateFormatter.dart';
import 'package:pillbin/core/utils/medicineDescriptionShimmer.dart';
import 'package:pillbin/core/utils/medicineShimmerCard.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:provider/provider.dart';
import 'package:pillbin/network/models/medicine_model.dart' as medicine;
import 'package:intl/intl.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MedicineProvider>(context, listen: false);
      if (provider.activeMedicinesInventory.isEmpty) {}

      provider.getInventory(context: context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void refresh() {
    final provider = Provider.of<MedicineProvider>(context, listen: false);

    if (provider.isFetching) {
      return;
    }

    provider.getInventory(context: context,forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Consumer<MedicineProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  _buildHeader(sw, sh, isTablet, provider, () {
                    refresh();
                  }),
                  Expanded(
                    child: isTablet
                        ? _buildTabletLayout(sw, sh, provider)
                        : _buildMobileLayout(sw, sh, provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
      double sw, double sh, MedicineProvider medicineProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sh * 0.02),
          _buildStatsCards(sw, sh, false, medicineProvider),
          SizedBox(height: sh * 0.025),
          _buildClearExpiredButton(sw, sh, false, medicineProvider),
          SizedBox(height: sh * 0.025),
          _buildMedicinesList(sw, sh, false, medicineProvider),
          SizedBox(height: sh * 0.02),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
      double sw, double sh, MedicineProvider medicineProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
        child: Column(
          children: [
            SizedBox(height: sh * 0.02),
            _buildStatsCards(sw, sh, true, medicineProvider),
            SizedBox(height: sh * 0.025),
            _buildClearExpiredButton(sw, sh, true, medicineProvider),
            SizedBox(height: sh * 0.025),
            _buildMedicinesList(sw, sh, true, medicineProvider),
            SizedBox(height: sh * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double sw, double sh, bool isTablet,
      MedicineProvider provider, void Function() onTap) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: PillBinColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(isTablet ? 32 : 24),
          bottomRight: Radius.circular(isTablet ? 32 : 24),
        ),
      ),
      padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medicine Inventory',
                      style: PillBinBold.style(
                        fontSize: isTablet ? sw * 0.035 : sw * 0.06,
                        color: PillBinColors.textWhite,
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Text(
                      '${provider.countInventory()} medicines tracked',
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        color: PillBinColors.textWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              //* Refresh icon on the right
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: isTablet ? sw * 0.03 : sw * 0.05,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(
      double sw, double sh, bool isTablet, MedicineProvider medicineProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: isTablet
          ? _buildTabletStatsGrid(sw, sh, medicineProvider)
          : _buildMobileStatsRow(sw, sh, medicineProvider),
    );
  }

  Widget _buildMobileStatsRow(
      double sw, double sh, MedicineProvider medicineProvider) {
    return medicineProvider.isFetching
        ? MedicineStatCardShimmerRow(sw: sw, sh: sh)
        : Row(
            children: [
              Expanded(
                child: StatCard(
                  count: medicineProvider.activeMedicinesInventory.length
                      .toString(),
                  label: 'Active',
                  color: PillBinColors.primary,
                  sw: sw,
                  sh: sh,
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: StatCard(
                  count: medicineProvider.expiringSoonMedicinesInventory.length
                      .toString(),
                  label: 'Expiring',
                  color: PillBinColors.warning,
                  sw: sw,
                  sh: sh,
                ),
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: StatCard(
                  count: medicineProvider.expiredMedicinesInventory.length
                      .toString(),
                  label: 'Expired',
                  color: PillBinColors.error,
                  sw: sw,
                  sh: sh,
                ),
              ),
            ],
          );
  }

  Widget _buildTabletStatsGrid(
      double sw, double sh, MedicineProvider medicineProvider) {
    return medicineProvider.isFetching
        ? MedicineStatCardShimmerRow(sw: sw, sh: sh)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatCard(
                count:
                    medicineProvider.activeMedicinesInventory.length.toString(),
                label: 'Active',
                color: PillBinColors.primary,
                sw: sw,
                sh: sh,
              ),
              SizedBox(width: sw * 0.03),
              StatCard(
                count: medicineProvider.expiringSoonMedicinesInventory.length
                    .toString(),
                label: 'Expiring',
                color: PillBinColors.warning,
                sw: sw,
                sh: sh,
              ),
              SizedBox(width: sw * 0.03),
              StatCard(
                count: medicineProvider.expiredMedicinesInventory.length
                    .toString(),
                label: 'Expired',
                color: PillBinColors.error,
                sw: sw,
                sh: sh,
              ),
            ],
          );
  }

  Widget _buildClearExpiredButton(
      double sw, double sh, bool isTablet, MedicineProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: PillBinColors.error,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: PillBinColors.error.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            onTap: () async {
              String response =
                  await provider.deleteAllExpiredMedicines(context: context);

              if (response == 'success') {
                NotificationProvider _notificationProvider =
                    context.read<NotificationProvider>();
                _notificationProvider.addNotification(
                    context: context,
                    title: "Expired Medicines Cleared",
                    description:
                        "✅ All expired medicines have been successfully removed from your tracker. Your list is now up-to-date and clutter-free!",
                    status: "important");

                //* send instant notification to user
                final random = Random();

                PushNotificationModel _notify = PushNotificationModel(
                  id: random.nextInt(100).toString(),
                  title: "All expired meds removed successfully.",
                  body: "✅ Expired medicines removed. Your list is now clean!",
                );

                NotificationConfig().showInstantNotification(notify: _notify);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? sh * 0.02 : sh * 0.015,
                horizontal: isTablet ? sw * 0.03 : sw * 0.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: PillBinColors.textWhite,
                    size: isTablet ? sw * 0.025 : sw * 0.05,
                  ),
                  SizedBox(width: sw * 0.02),
                  Text(
                    'Clear All Expired (${provider.expiredMedicinesInventory.length})',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                      color: PillBinColors.textWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicinesList(
      double sw, double sh, bool isTablet, MedicineProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: Column(
        children: [
          _buildExpiredSection(sw, sh, isTablet, provider),
          SizedBox(height: sh * 0.03),
          _buildExpiringSoonSection(sw, sh, isTablet, provider),
          SizedBox(height: sh * 0.03),
          _buildActiveSection(sw, sh, isTablet, provider),
        ],
      ),
    );
  }

  Widget _buildExpiredSection(
      double sw, double sh, bool isTablet, MedicineProvider provider) {
    return provider.isFetching
        ? medicineShimmerList(
            sw: sw, sh: sh, baseColor: const Color.fromARGB(255, 237, 132, 125))
        : Column(
            children: [
              SectionHeader(
                icon: Icons.warning,
                title:
                    'Expired Medicines (${provider.expiredMedicinesInventory.length})',
                color: PillBinColors.error,
                sw: sw,
                sh: sh,
              ),
              SizedBox(height: sh * 0.015),
              if (provider.expiredMedicinesInventory.isNotEmpty)
                ...provider.expiredMedicinesInventory
                    .take(2)
                    .map((meds) => Padding(
                          padding: EdgeInsets.only(bottom: sh * 0.01),
                          child: MedicineCard(
                            name: meds.name,
                            status:
                                'Expired ${Dateformatter.customDateDifference(DateTime.now(), meds.expiryDate)} ago',
                            quantity: '${meds.dosage} tablets',
                            category: meds.type ?? '',
                            statusColor: PillBinColors.error,
                            actionText: 'Dispose',
                            actionColor: PillBinColors.error,
                            sw: sw,
                            sh: sh,
                            showViewMore: true,
                            onViewMore: () =>
                                _showMedicineDetails(context, meds.name, meds),
                          ),
                        ))
                    .toList()
              else
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  child: Text(
                    'No expired medicines',
                    style: PillBinRegular.style(
                      fontSize: sw * 0.035,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ),
            ],
          );
  }

  Widget _buildExpiringSoonSection(
      double sw, double sh, bool isTablet, MedicineProvider provider) {
    return provider.isFetching
        ? medicineShimmerList(
            sw: sw,
            sh: sh,
            baseColor: const Color.fromARGB(255, 235, 186, 112),
          )
        : Column(
            children: [
              SectionHeader(
                icon: Icons.schedule,
                title:
                    'Expiring Soon (${provider.expiringSoonMedicinesInventory.length})',
                color: PillBinColors.warning,
                sw: sw,
                sh: sh,
              ),
              SizedBox(height: sh * 0.015),
              if (provider.expiringSoonMedicinesInventory.isNotEmpty)
                ...provider.expiringSoonMedicinesInventory
                    .take(2)
                    .map((meds) => Padding(
                          padding: EdgeInsets.only(bottom: sh * 0.01),
                          child: MedicineCard(
                            name: meds.name,
                            status:
                                'Expires in ${Dateformatter.customDateDifference(DateTime.now(), meds.expiryDate)}',
                            quantity: '${meds.dosage} tablets',
                            category: meds.type ?? '',
                            statusColor: PillBinColors.warning,
                            actionText: 'Reorder',
                            actionColor: PillBinColors.warning,
                            sw: sw,
                            sh: sh,
                            showViewMore: true,
                            onViewMore: () =>
                                _showMedicineDetails(context, meds.name, meds),
                          ),
                        ))
                    .toList()
              else
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  child: Text(
                    'No medicines expiring soon',
                    style: PillBinRegular.style(
                      fontSize: sw * 0.035,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ),
            ],
          );
  }

  Widget _buildActiveSection(
      double sw, double sh, bool isTablet, MedicineProvider provider) {
    return provider.isFetching
        ? medicineShimmerList(
            sw: sw,
            sh: sh,
            baseColor: const Color.fromARGB(255, 117, 232, 121),
          )
        : Column(
            children: [
              SectionHeader(
                icon: Icons.check_circle,
                title:
                    'Active Medicines (${provider.activeMedicinesInventory.length})',
                color: PillBinColors.primary,
                sw: sw,
                sh: sh,
              ),
              SizedBox(height: sh * 0.015),
              if (provider.activeMedicinesInventory.isNotEmpty)
                ...provider.activeMedicinesInventory
                    .take(2)
                    .map((meds) => Padding(
                          padding: EdgeInsets.only(bottom: sh * 0.01),
                          child: MedicineCard(
                            name: meds.name,
                            status:
                                'Active - ${Dateformatter.customDateDifference(DateTime.now(), meds.expiryDate)} remaining',
                            quantity: '${meds.dosage} tablets',
                            category: meds.type ?? '',
                            statusColor: PillBinColors.primary,
                            actionText: 'Details',
                            actionColor: PillBinColors.primary,
                            sw: sw,
                            sh: sh,
                            showViewMore: true,
                            onViewMore: () =>
                                _showMedicineDetails(context, meds.name, meds),
                          ),
                        ))
                    .toList()
              else
                Container(
                  padding: EdgeInsets.all(sw * 0.04),
                  child: Text(
                    'No active medicines',
                    style: PillBinRegular.style(
                      fontSize: sw * 0.035,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ),
            ],
          );
  }

  void _showMedicineDetails(
      BuildContext context, String medicineName, medicine.Medicine medicine) {
    Logger().d(medicine.status.toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineDetailsModal(
        status: medicine.status.toString(),
        medicineName: medicineName,
        medicineItem: medicine,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final double sw;
  final double sh;

  const StatCard({
    Key? key,
    required this.count,
    required this.label,
    required this.color,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      width: isTablet ? sw * 0.28 : null,
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.04 : sw * 0.06,
              color: color,
            ),
          ),
          SizedBox(height: sh * 0.005),
          Text(
            label,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.03,
              color: PillBinColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final double sw;
  final double sh;

  const SectionHeader({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: sh * 0.01,
        horizontal: isTablet ? sw * 0.02 : sw * 0.03,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: isTablet ? sw * 0.025 : sw * 0.045,
          ),
          SizedBox(width: sw * 0.02),
          Text(
            title,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.04,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final String name;
  final String status;
  final String quantity;
  final String category;
  final Color statusColor;
  final String actionText;
  final Color actionColor;
  final bool isCountdown;
  final double sw;
  final double sh;
  final bool showViewMore;
  final VoidCallback? onViewMore;

  const MedicineCard({
    Key? key,
    required this.name,
    required this.status,
    required this.quantity,
    required this.category,
    required this.statusColor,
    required this.actionText,
    required this.actionColor,
    this.isCountdown = false,
    required this.sw,
    required this.sh,
    this.showViewMore = false,
    this.onViewMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                        color: PillBinColors.textDark,
                      ),
                    ),
                    SizedBox(height: sh * 0.005),
                    Text(
                      status,
                      maxLines: 2,
                      softWrap: true,
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                        color: statusColor,
                      ),
                    ),
                    if (quantity.isNotEmpty) ...[
                      SizedBox(height: sh * 0.003),
                      Text(
                        quantity.trim(),
                        style: PillBinRegular.style(
                          fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                          color: PillBinColors.textSecondary,
                        ),
                      ),
                    ],
                    if (category.isNotEmpty) ...[
                      SizedBox(height: sh * 0.003),
                      Text(
                        category.trim(),
                        style: PillBinRegular.style(
                          fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                          color: PillBinColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.02 : sw * 0.03,
                  vertical: isTablet ? sh * 0.008 : sh * 0.01,
                ),
                decoration: BoxDecoration(
                  color:
                      isCountdown ? actionColor : actionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionText,
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                    color: isCountdown ? PillBinColors.textWhite : actionColor,
                  ),
                ),
              ),
            ],
          ),
          if (showViewMore) ...[
            SizedBox(height: sh * 0.015),
            Row(
              children: [
                if (actionText == 'Dispose') ...[
                  Expanded(
                    child: _buildActionButton(
                      'Dispose',
                      Icons.delete_outline,
                      PillBinColors.error,
                      true,
                      isTablet,
                    ),
                  ),
                  SizedBox(width: sw * 0.02),
                ],
                Expanded(
                  child: _buildActionButton(
                    'View More',
                    Icons.info_outline,
                    PillBinColors.primary,
                    false,
                    isTablet,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color color, bool filled, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: text == 'View More' ? onViewMore : () {},
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? sh * 0.01 : sh * 0.008,
              horizontal: isTablet ? sw * 0.02 : sw * 0.03,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: filled ? PillBinColors.textWhite : color,
                  size: isTablet ? sw * 0.02 : sw * 0.035,
                ),
                SizedBox(width: sw * 0.01),
                Text(
                  text,
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                    color: filled ? PillBinColors.textWhite : color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MedicineDetailsModal extends StatelessWidget {
  final medicine.Medicine medicineItem;
  final String medicineName;
  final String status;

  const MedicineDetailsModal({
    Key? key,
    required this.medicineName,
    required this.medicineItem,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Container(
      height: sh * 0.7,
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 32 : 24),
          topRight: Radius.circular(isTablet ? 32 : 24),
        ),
      ),
      child: Column(
        children: [
          // top drag indicator
          Container(
            width: sw * 0.12,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: sh * 0.015),
            decoration: BoxDecoration(
              color: PillBinColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineName,
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.035 : sw * 0.06,
                      color: PillBinColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: sh * 0.02),
                  _buildDetailRow(
                      'Medicine Type',
                      medicineItem.type == null || medicineItem.type!.isEmpty
                          ? "Not Mentioned"
                          : medicineItem.type!.trim(),
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Dosage',
                      medicineItem.dosage == null ||
                              medicineItem.dosage!.isEmpty
                          ? "Not Mentioned"
                          : medicineItem.dosage!.trim(),
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Manufacturer',
                      medicineItem.manufacturer == null ||
                              medicineItem.manufacturer!.isEmpty
                          ? "Not Mentioned"
                          : medicineItem.manufacturer!.trim(),
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Batch Number',
                      medicineItem.batchNumber == null ||
                              medicineItem.batchNumber!.isEmpty
                          ? "Not Mentioned"
                          : medicineItem.batchNumber!.trim(),
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Purchase Date',
                      DateFormat('d MMMM yyyy')
                          .format(medicineItem.purchaseDate),
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Expiry Date',
                      DateFormat('d MMMM yyyy').format(medicineItem.expiryDate),
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow(
                      'Notes',
                      medicineItem.notes == null || medicineItem.notes!.isEmpty
                          ? "Not Mentioned"
                          : medicineItem.notes!.trim(),
                      sw,
                      sh,
                      isTablet),
                  SizedBox(height: sh * 0.03),

                  /// 🔥 Dynamic Status Container
                  _buildStatusContainer(status, sw, isTablet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the colored note container depending on medicine status
  Widget _buildStatusContainer(String status, double sw, bool isTablet) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    String message;

    switch (status) {
      case 'MedicineStatus.active':
        bgColor = PillBinColors.success.withOpacity(0.1);
        borderColor = PillBinColors.success.withOpacity(0.3);
        textColor = PillBinColors.success;
        message = 'Great! This medicine is active and safe to use.';
        break;
      case 'MedicineStatus.expiringSoon':
        bgColor = PillBinColors.warning.withOpacity(0.1);
        borderColor = PillBinColors.warning.withOpacity(0.3);
        textColor = PillBinColors.warning;
        message =
            'Alert: This medicine is expiring soon. Please plan for safe disposal or replacement.';
        break;
      case 'MedicineStatus.expired':
      default:
        bgColor = PillBinColors.error.withOpacity(0.1);
        borderColor = PillBinColors.error.withOpacity(0.3);
        textColor = PillBinColors.error;
        message =
            'Note: This medicine has expired. Please dispose of it safely at a designated collection point.';
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        message,
        style: PillBinRegular.style(
          fontSize: isTablet ? sw * 0.02 : sw * 0.035,
          color: textColor,
        ),
      ),
    );
  }

  // Keep your _buildDetailRow function as is
}

Widget _buildDetailRow(
    String label, String value, double sw, double sh, bool isTablet) {
  return Padding(
    padding: EdgeInsets.only(bottom: sh * 0.015),
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.038,
              color: PillBinColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.038,
              color: PillBinColors.textDark,
            ),
          ),
        ),
      ],
    ),
  );
}
