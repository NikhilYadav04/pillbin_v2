import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/donation/data/repository/donation_provider.dart';
import 'package:pillbin/features/locations/data/repository/saved_centers_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/network/models/medical_center_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalCenterDetailScreen extends StatefulWidget {
  final MedicalCenter center;
  final double sw;
  final double sh;

  const MedicalCenterDetailScreen({
    Key? key,
    required this.center,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  State<MedicalCenterDetailScreen> createState() =>
      _MedicalCenterDetailScreenState();
}

class _MedicalCenterDetailScreenState
    extends State<MedicalCenterDetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.center.isVendorManaged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DonationProvider>().loadCenterInventory(widget.center.id);
      });
    }
  }

  MedicalCenter get center => widget.center;
  double get sw => widget.sw;
  double get sh => widget.sh;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;
    final String currentDay = _getCurrentDay();
    final bool isOpen = _checkIfOpen(currentDay);
    final provider = context.watch<DonationProvider>();
    final inventory =
        provider.centerInventory?['inventory'] as List? ?? [];

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(isTablet, context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(isTablet),
                  if (center.imageUrls.isNotEmpty) ...[
                    SizedBox(height: sh * 0.02),
                    _buildPhotosSection(isTablet),
                  ],
                  SizedBox(height: sh * 0.02),
                  _buildInfoSection(isTablet),
                  SizedBox(height: sh * 0.02),
                  _buildAcceptedMedicinesSection(isTablet),
                  if (center.isVendorManaged && inventory.isNotEmpty) ...[
                    SizedBox(height: sh * 0.02),
                    _buildInventorySection(isTablet, inventory),
                  ],
                  if (center.operatingHours != null) ...[
                    SizedBox(height: sh * 0.02),
                    _buildOperatingHoursSection(isTablet, currentDay, isOpen),
                  ],
                  if (center.website != null || center.email != null) ...[
                    SizedBox(height: sh * 0.02),
                    _buildContactSection(isTablet),
                  ],
                  SizedBox(height: sh * 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(isTablet),
    );
  }

  Widget _buildAppBar(bool isTablet, BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final savedIds = userProvider.user?.savedMedicalCenters ?? [];
    final isSaved = savedIds.contains(center.id);

    return SliverAppBar(
      expandedHeight: sh * 0.08,
      pinned: true,
      backgroundColor: PillBinColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          center.name,
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.035,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        titlePadding: EdgeInsets.only(
          left: isTablet ? sw * 0.08 : sw * 0.12,
          bottom: sh * 0.015,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.white,
          ),
          tooltip: isSaved ? 'Remove from saved' : 'Save center',
          onPressed: () async {
            final savedProvider = context.read<SavedCentersProvider>();
            final userProvider = context.read<UserProvider>();
            if (isSaved) {
              final result = await savedProvider.removeSavedMedicalCenter(
                  medicalCenterId: center.id);
              if (result == 'success') userProvider.removeSavedId(center.id);
            } else {
              final result = await savedProvider.saveMedicalCenter(
                  medicalCenterId: center.id);
              if (result == 'success') userProvider.addSavedId(center.id);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPhotosSection(bool isTablet) {
    final images = center.imageUrls;
    final pageController = PageController();

    return StatefulBuilder(
      builder: (context, setLocal) {
        int currentIndex = 0;
        return StatefulBuilder(
          builder: (context, setPage) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: sh * 0.25,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setPage(() => currentIndex = i),
                      itemBuilder: (_, i) => CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => Container(
                          color: PillBinColors.greyLight,
                          child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: PillBinColors.greyLight,
                          child: Icon(Icons.broken_image_outlined,
                              color: PillBinColors.textSecondary,
                              size: sw * 0.08),
                        ),
                      ),
                    ),
                  ),
                ),
                if (images.length > 1) ...[
                  SizedBox(height: sh * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: sw * 0.008),
                        width: currentIndex == i ? sw * 0.04 : sw * 0.018,
                        height: sw * 0.018,
                        decoration: BoxDecoration(
                          color: currentIndex == i
                              ? PillBinColors.primary
                              : PillBinColors.greyLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PillBinColors.primary.withOpacity(0.1),
            PillBinColors.primaryLight.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PillBinColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.035),
            decoration: BoxDecoration(
              color: PillBinColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getFacilityIcon(),
              color: Colors.white,
              size: isTablet ? sw * 0.035 : sw * 0.06,
            ),
          ),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFacilityTypeName(),
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.036,
                    color: PillBinColors.primary,
                  ),
                ),
                SizedBox(height: sh * 0.004),
                _buildRatingRow(isTablet),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.025,
              vertical: sh * 0.006,
            ),
            decoration: BoxDecoration(
              color: center.isActive
                  ? PillBinColors.success.withOpacity(0.15)
                  : PillBinColors.error.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: center.isActive
                    ? PillBinColors.success.withOpacity(0.3)
                    : PillBinColors.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              center.isActive ? 'Active' : 'Inactive',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                color: center.isActive
                    ? PillBinColors.success
                    : PillBinColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(bool isTablet) {
    final starSize = isTablet ? sw * 0.022 : sw * 0.035;
    final textSize = isTablet ? sw * 0.019 : sw * 0.029;

    if (center.totalReviews == 0) {
      return Text(
        'No reviews yet',
        style: PillBinRegular.style(
          fontSize: textSize,
          color: PillBinColors.textLight,
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/center-reviews-screen',
        arguments: {
          'centerId': center.id,
          'centerName': center.name,
          'transition': TransitionType.rightToLeft,
        },
      ),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ...List.generate(5, (i) {
            final filled = center.rating >= i + 1;
            final half = !filled && center.rating > i;
            return Icon(
              half
                  ? Icons.star_half_rounded
                  : filled
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
              size: starSize,
              color: filled || half ? Colors.amber : PillBinColors.greyLight,
            );
          }),
          SizedBox(width: sw * 0.015),
          Text(
            '${center.rating.toStringAsFixed(1)} (${center.totalReviews})',
            style: PillBinMedium.style(
              fontSize: textSize,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(width: sw * 0.008),
          Icon(Icons.chevron_right_rounded,
              size: starSize * 1.15, color: PillBinColors.primary),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PillBinColors.greyLight.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.042,
              color: PillBinColors.textPrimary,
            ),
          ),
          SizedBox(height: sh * 0.015),
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Address',
            value: center.address,
            isTablet: isTablet,
          ),
          SizedBox(height: sh * 0.012),
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: center.phoneNumber,
            isTablet: isTablet,
            isClickable: true,
          ),
          SizedBox(height: sh * 0.012),
          _buildInfoRow(
            icon: Icons.navigation,
            label: 'Distance',
            value: '${center.distance.toStringAsFixed(2)} km away',
            isTablet: isTablet,
            valueColor: PillBinColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
    bool isClickable = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? sw * 0.012 : sw * 0.02),
          decoration: BoxDecoration(
            color: PillBinColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: PillBinColors.primary,
            size: isTablet ? sw * 0.02 : sw * 0.035,
          ),
        ),
        SizedBox(width: sw * 0.025),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                  color: PillBinColors.textSecondary,
                ),
              ),
              SizedBox(height: sh * 0.003),
              Text(
                value,
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.034,
                  color: valueColor ?? PillBinColors.textPrimary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedMedicinesSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PillBinColors.greyLight.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medication,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.025 : sw * 0.04,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Accepted Medicine Types',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.042,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),
          Wrap(
            spacing: sw * 0.02,
            runSpacing: sh * 0.01,
            children: center.acceptedMedicineTypes.map((type) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.03,
                  vertical: sh * 0.008,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PillBinColors.primary.withOpacity(0.1),
                      PillBinColors.primaryLight.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PillBinColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _formatMedicineType(type),
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                    color: PillBinColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingHoursSection(
      bool isTablet, String currentDay, bool isOpen) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PillBinColors.greyLight.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: PillBinColors.primary,
                size: isTablet ? sw * 0.025 : sw * 0.04,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Operating Hours',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.025 : sw * 0.042,
                  color: PillBinColors.textPrimary,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.025,
                  vertical: sh * 0.005,
                ),
                decoration: BoxDecoration(
                  color: isOpen
                      ? PillBinColors.success.withOpacity(0.15)
                      : PillBinColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOpen ? 'Open Now' : 'Closed Now',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.028,
                    color: isOpen ? PillBinColors.success : PillBinColors.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.015),
          ...center.operatingHours!.entries.map((entry) {
            final isCurrentDay = entry.key.toLowerCase() ==
                currentDay.substring(0, 3).toLowerCase();
            return Container(
              margin: EdgeInsets.only(bottom: sh * 0.008),
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.03,
                vertical: sh * 0.01,
              ),
              decoration: BoxDecoration(
                color: isCurrentDay
                    ? PillBinColors.primary.withOpacity(0.1)
                    : PillBinColors.greyLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: isCurrentDay
                    ? Border.all(
                        color: PillBinColors.primary.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDay(entry.key),
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.034,
                      color: isCurrentDay
                          ? PillBinColors.primary
                          : PillBinColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${entry.value.open} - ${entry.value.close}',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: PillBinColors.greyLight.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Contact',
            style: PillBinBold.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.042,
              color: PillBinColors.textPrimary,
            ),
          ),
          SizedBox(height: sh * 0.015),
          if (center.website != null) ...[
            _buildContactItem(
                icon: Icons.language,
                label: 'Website',
                value: center.website!,
                isTablet: isTablet,
                onTap: () async {
                  final Uri url = Uri.parse(
                    center.website!,
                  );

                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    print(e.toString());
                  }
                }),
            if (center.email != null) SizedBox(height: sh * 0.012),
          ],
          if (center.email != null)
            _buildContactItem(
                icon: Icons.email,
                label: 'Email',
                value: center.email!,
                isTablet: isTablet,
                onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      {required IconData icon,
      required String label,
      required String value,
      required bool isTablet,
      required void Function() onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.012 : sw * 0.02),
            decoration: BoxDecoration(
              color: PillBinColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: PillBinColors.primary,
              size: isTablet ? sw * 0.02 : sw * 0.035,
            ),
          ),
          SizedBox(width: sw * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.03,
                    color: PillBinColors.textSecondary,
                  ),
                ),
                SizedBox(height: sh * 0.003),
                Text(
                  value,
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.032,
                    color: PillBinColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (center.isVendorManaged) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/donation-request-screen',
                      arguments: {
                        'centerId': center.id,
                        'centerName': center.name,
                        'transition': TransitionType.bottomToTop,
                        'duration': 300,
                      },
                    );
                  },
                  icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                  label: Text('Donate Medicines',
                      style: PillBinBold.style(
                          fontSize: sw * 0.04, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: sh * 0.012),
            ],
            Row(
              children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PillBinColors.primary,
                      PillBinColors.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: PillBinColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final String rawNumber = center.phoneNumber;
                      final String cleanedNumber =
                          rawNumber.replaceAll(RegExp(r'[^\d+]'), '');

                      try {
                        await launchUrl(
                          Uri.parse('tel:$cleanedNumber'),
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sh * 0.015,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: isTablet ? sw * 0.022 : sw * 0.04,
                          ),
                          SizedBox(width: sw * 0.015),
                          Text(
                            'Call',
                            style: PillBinBold.style(
                              fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: sw * 0.025),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PillBinColors.primary,
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      // coordinates: [longitude, latitude] — GeoJSON order
                      final lng = center.coordinates.isNotEmpty ? center.coordinates[0] : 0.0;
                      final lat = center.coordinates.length > 1 ? center.coordinates[1] : 0.0;
                      final Uri mapsUri = Uri.parse(
                          "https://www.google.com/maps/search/?api=1&query=$lat,$lng");

                      try {
                        await launchUrl(mapsUri,
                            mode: LaunchMode.externalApplication);
                      } catch (e) {
                        print(e.toString());
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: sh * 0.015,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions,
                            color: PillBinColors.primary,
                            size: isTablet ? sw * 0.022 : sw * 0.04,
                          ),
                          SizedBox(width: sw * 0.015),
                          Text(
                            'Directions',
                            style: PillBinBold.style(
                              fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                              color: PillBinColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySection(bool isTablet, List inventory) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PillBinColors.greyLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined,
                  color: PillBinColors.primary,
                  size: isTablet ? sw * 0.025 : sw * 0.04),
              SizedBox(width: sw * 0.02),
              Text('Accepted Inventory',
                  style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.042,
                      color: PillBinColors.textPrimary)),
            ],
          ),
          SizedBox(height: sh * 0.015),
          ...inventory.map<Widget>((inv) {
            final status = inv['acceptanceStatus'] as String? ?? 'accepting';
            final color = status == 'accepting'
                ? Colors.green
                : status == 'full'
                    ? Colors.orange
                    : Colors.red;
            final names = (inv['specificNames'] as List?)
                    ?.map((n) => n as String)
                    .where((n) => n.isNotEmpty)
                    .toList() ??
                [];
            final notes = inv['notes'] as String?;
            return Container(
              margin: EdgeInsets.only(bottom: sh * 0.01),
              padding: EdgeInsets.all(sw * 0.035),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(inv['category'] as String? ?? '',
                          style: PillBinMedium.style(
                              fontSize: sw * 0.036,
                              color: PillBinColors.textPrimary)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(status,
                            style: PillBinMedium.style(
                                fontSize: sw * 0.026, color: color)),
                      ),
                    ],
                  ),
                  if (names.isNotEmpty) ...[
                    SizedBox(height: sh * 0.006),
                    Text(names.join(' · '),
                        style: PillBinRegular.style(
                            fontSize: sw * 0.03,
                            color: PillBinColors.textSecondary)),
                  ],
                  if (notes != null && notes.isNotEmpty) ...[
                    SizedBox(height: sh * 0.004),
                    Text(notes,
                        style: PillBinRegular.style(
                            fontSize: sw * 0.028,
                            color: PillBinColors.textLight)),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[now.weekday - 1];
  }

  bool _checkIfOpen(String currentDay) {
    if (center.operatingHours == null) return false;

    final dayKey = currentDay.toLowerCase();
    final hours = center.operatingHours![dayKey];
    if (hours == null) return false;

    final now = TimeOfDay.now();
    final openTime = _parseTime(hours.open);
    final closeTime = _parseTime(hours.close);

    if (openTime == null || closeTime == null) return false;

    final nowMinutes = now.hour * 60 + now.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  String _formatDay(String day) {
    return day[0].toUpperCase() + day.substring(1);
  }

  String _formatMedicineType(MedicineType type) {
    return type.value[0].toUpperCase() + type.value.substring(1);
  }

  IconData _getFacilityIcon() {
    switch (center.facilityType) {
      case FacilityType.hospital:
        return Icons.local_hospital;
      case FacilityType.clinic:
        return Icons.medical_services;
      case FacilityType.pharmacy:
        return Icons.medication;
      case FacilityType.healthCenter:
        return Icons.health_and_safety;
    }
  }

  String _getFacilityTypeName() {
    switch (center.facilityType) {
      case FacilityType.hospital:
        return 'Hospital';
      case FacilityType.clinic:
        return 'Clinic';
      case FacilityType.pharmacy:
        return 'Pharmacy';
      case FacilityType.healthCenter:
        return 'Health Center';
    }
  }
}
