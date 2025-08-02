import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              _buildHeader(sw, sh, isTablet),
              Expanded(
                child: isTablet
                    ? _buildTabletLayout(sw, sh)
                    : _buildMobileLayout(sw, sh),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(double sw, double sh) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: sh * 0.02),
          _buildStatsCards(sw, sh, false),
          SizedBox(height: sh * 0.025),
          _buildClearExpiredButton(sw, sh, false),
          SizedBox(height: sh * 0.025),
          _buildMedicinesList(sw, sh, false),
          SizedBox(height: sh * 0.02),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(double sw, double sh) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
        child: Column(
          children: [
            SizedBox(height: sh * 0.02),
            _buildStatsCards(sw, sh, true),
            SizedBox(height: sh * 0.025),
            _buildClearExpiredButton(sw, sh, true),
            SizedBox(height: sh * 0.025),
            _buildMedicinesList(sw, sh, true),
            SizedBox(height: sh * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double sw, double sh, bool isTablet) {
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
                      '4 medicines tracked',
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                        color: PillBinColors.textWhite.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: isTablet
          ? _buildTabletStatsGrid(sw, sh)
          : _buildMobileStatsRow(sw, sh),
    );
  }

  Widget _buildMobileStatsRow(double sw, double sh) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            count: '1',
            label: 'Active',
            color: PillBinColors.primary,
            sw: sw,
            sh: sh,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: StatCard(
            count: '1',
            label: 'Expiring',
            color: PillBinColors.warning,
            sw: sw,
            sh: sh,
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: StatCard(
            count: '2',
            label: 'Expired',
            color: PillBinColors.error,
            sw: sw,
            sh: sh,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletStatsGrid(double sw, double sh) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatCard(
          count: '1',
          label: 'Active',
          color: PillBinColors.primary,
          sw: sw,
          sh: sh,
        ),
        SizedBox(width: sw * 0.03),
        StatCard(
          count: '1',
          label: 'Expiring',
          color: PillBinColors.warning,
          sw: sw,
          sh: sh,
        ),
        SizedBox(width: sw * 0.03),
        StatCard(
          count: '2',
          label: 'Expired',
          color: PillBinColors.error,
          sw: sw,
          sh: sh,
        ),
      ],
    );
  }

  Widget _buildClearExpiredButton(double sw, double sh, bool isTablet) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? sw * 0 : sw * 0.04),
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
            onTap: () {},
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
                    'Clear All Expired (2)',
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

  Widget _buildMedicinesList(double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 0 : sw * 0.04),
      child: Column(
        children: [
          _buildExpiredSection(sw, sh, isTablet),
          SizedBox(height: sh * 0.03),
          _buildExpiringSoonSection(sw, sh, isTablet),
          SizedBox(height: sh * 0.03),
          _buildActiveSection(sw, sh, isTablet),
        ],
      ),
    );
  }

  Widget _buildExpiredSection(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        SectionHeader(
          icon: Icons.warning,
          title: 'Expired Medicines (2)',
          color: PillBinColors.error,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.015),
        MedicineCard(
          name: 'Ibuprofen',
          status: 'Expired 3 days ago',
          quantity: '15 tablets',
          category: 'Anti-inflammatory',
          statusColor: PillBinColors.error,
          actionText: 'Dispose',
          actionColor: PillBinColors.error,
          sw: sw,
          sh: sh,
          showViewMore: true,
          onViewMore: () => _showMedicineDetails(context, 'Ibuprofen'),
        ),
        SizedBox(height: sh * 0.01),
        MedicineCard(
          name: 'Cough Syrup',
          status: 'Expired 13 days ago',
          quantity: '100ml',
          category: 'Opened 2 months ago',
          statusColor: PillBinColors.error,
          actionText: 'Dispose',
          actionColor: PillBinColors.error,
          sw: sw,
          sh: sh,
          showViewMore: true,
          onViewMore: () => _showMedicineDetails(context, 'Cough Syrup'),
        ),
      ],
    );
  }

  Widget _buildExpiringSoonSection(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        SectionHeader(
          icon: Icons.schedule,
          title: 'Expiring Soon (1)',
          color: PillBinColors.warning,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.015),
        MedicineCard(
          name: 'Crocin',
          status: 'Expires in 38 days',
          quantity: '10 tablets',
          category: 'Pain reliever',
          statusColor: PillBinColors.warning,
          actionText: '38d',
          actionColor: PillBinColors.primary,
          isCountdown: true,
          sw: sw,
          sh: sh,
          showViewMore: true,
          onViewMore: () => _showMedicineDetails(context, 'Crocin'),
        ),
      ],
    );
  }

  Widget _buildActiveSection(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        SectionHeader(
          icon: Icons.check_circle,
          title: 'Active Medicines (1)',
          color: PillBinColors.primary,
          sw: sw,
          sh: sh,
        ),
        SizedBox(height: sh * 0.015),
        MedicineCard(
          name: 'Paracetamol',
          status: 'Expires in 145 days',
          quantity: '20 tablets',
          category: 'For fever and pain relief',
          statusColor: PillBinColors.success,
          actionText: 'Active',
          actionColor: PillBinColors.success,
          sw: sw,
          sh: sh,
          showViewMore: true,
          onViewMore: () => _showMedicineDetails(context, 'Paracetamol'),
        ),
      ],
    );
  }

  void _showMedicineDetails(BuildContext context, String medicineName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineDetailsModal(medicineName: medicineName),
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
      width: isTablet ? sw * 0.15 : null,
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
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(height: sh * 0.003),
                    Text(
                      quantity,
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                        color: PillBinColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: sh * 0.003),
                    Text(
                      category,
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                        color: PillBinColors.textSecondary,
                      ),
                    ),
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
  final String medicineName;

  const MedicineDetailsModal({Key? key, required this.medicineName})
      : super(key: key);

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
          Container(
            width: sw * 0.12,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: sh * 0.015),
            decoration: BoxDecoration(
              color: PillBinColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
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
                _buildDetailRow('Medicine Type', 'Tablet', sw, sh, isTablet),
                _buildDetailRow('Dosage', '200mg', sw, sh, isTablet),
                _buildDetailRow(
                    'Manufacturer', 'Generic Pharma', sw, sh, isTablet),
                _buildDetailRow('Batch Number', 'BP2024001', sw, sh, isTablet),
                _buildDetailRow(
                    'Purchase Date', '15 Jan 2024', sw, sh, isTablet),
                _buildDetailRow('Expiry Date', '15 Jan 2025', sw, sh, isTablet),
                _buildDetailRow(
                    'Storage', 'Room temperature', sw, sh, isTablet),
                SizedBox(height: sh * 0.03),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                  decoration: BoxDecoration(
                    color: PillBinColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: PillBinColors.warning.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Note: This medicine has expired. Please dispose of it safely at a designated collection point.',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}
