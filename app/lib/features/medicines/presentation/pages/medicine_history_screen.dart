import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/inventoryShimmerCard.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:intl/intl.dart';
import 'package:pillbin/network/utils/connectivity_banner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicineHistoryScreen extends StatefulWidget {
  const MedicineHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MedicineHistoryScreen> createState() => _MedicineHistoryScreenState();
}

class _MedicineHistoryScreenState extends State<MedicineHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MedicineProvider>(context, listen: false);
      if (provider.deletedMedicinesInventory.isEmpty) {
        provider.getDeletedMedicinesInventory();
      }
    });
  }

  void _refresh() {
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    provider.getDeletedMedicinesInventory(forceRefresh: true);
  }

  void _applyFiltersSearch() {
    final provider = context.read<MedicineProvider>();
    final searchQuery = _searchController.text.trim().toLowerCase();

    if (searchQuery.isEmpty) {
      provider.clearSearchFilter();
      return;
    }

    //* Filter medicines
    List<Medicine> _filteredMedicines =
        provider.deletedMedicinesInventory.where((medicine) {
      return medicine.name.toLowerCase().contains(searchQuery) ||
          (medicine.batchNumber?.toLowerCase().contains(searchQuery) ??
              false) ||
          (medicine.manufacturer?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    provider.updateHistoryFilteredInventory(medicine: _filteredMedicines);
  }

  void _showClearAllDialog(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: PillBinColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: PillBinColors.error,
                size: isTablet ? sw * 0.03 : sw * 0.06,
              ),
              SizedBox(width: sw * 0.03),
              Expanded(
                child: Text(
                  'Clear All History?',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                    color: PillBinColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'This will permanently delete all medicine records from your history. This action cannot be undone.',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.038,
              color: PillBinColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.03 : sw * 0.05,
                  vertical: isTablet ? sh * 0.015 : sh * 0.012,
                ),
              ),
              child: Text(
                'Cancel',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _clearAllHistory();

                NotificationProvider _notificationProvider =
                    context.read<NotificationProvider>();
                _notificationProvider.addNotification(
                  context: context,
                  title: "Inventory Cleared",
                  description:
                      "Your medicine history has been successfully cleared.",
                  status: "normal",
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: PillBinColors.error,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.03 : sw * 0.05,
                  vertical: isTablet ? sh * 0.015 : sh * 0.012,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear All',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearAllHistory() {
    MedicineProvider _medicineProvide = context.read<MedicineProvider>();
    _medicineProvide.deleteAllHardMedicines();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    MedicineProvider _medicineProvide = context.read<MedicineProvider>();

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: PillBinColors.textPrimary,
            size: isTablet ? sw * 0.025 : sw * 0.055,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<MedicineProvider>(builder: (context, provider, _) {
          return FittedBox(
            child: Text(
              'Medicines History (${_medicineProvide.deletedMedicinesInventory.length})',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.028 : sw * 0.048,
                color: PillBinColors.textPrimary,
              ),
            ),
          );
        }),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: PillBinColors.textPrimary,
              size: isTablet ? sw * 0.025 : sw * 0.055,
            ),
            onPressed: _refresh,
          ),
          Consumer<MedicineProvider>(
            builder: (context, provider, _) {
              if (provider.deletedMedicinesInventory.isNotEmpty) {
                return IconButton(
                  icon: Icon(
                    Icons.delete_sweep,
                    color: PillBinColors.error,
                    size: isTablet ? sw * 0.025 : sw * 0.055,
                  ),
                  onPressed: () => _showClearAllDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              ConnectivityBanner(),
              //* Search Field
              Container(
                margin: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.045),
                decoration: BoxDecoration(
                  color: PillBinColors.surface,
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                    color: PillBinColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search deleted medicines...',
                    hintStyle: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                      color: PillBinColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: PillBinColors.textSecondary,
                      size: isTablet ? sw * 0.025 : sw * 0.055,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: PillBinColors.textSecondary,
                              size: isTablet ? sw * 0.025 : sw * 0.055,
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.02 : sw * 0.04,
                      vertical: isTablet ? sh * 0.02 : sh * 0.018,
                    ),
                  ),
                  onChanged: (value) {
                    _applyFiltersSearch();
                  },
                ),
              ),

              //* Medicine History List
              Expanded(
                child: provider.isFetchingDelete
                    ? InventoryListShimmer(
                        shimmerColor: PillBinColors.primary,
                      )
                    : provider.deletedMedicinesInventory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: isTablet ? sw * 0.15 : sw * 0.25,
                                  color: PillBinColors.textSecondary
                                      .withOpacity(0.5),
                                ),
                                SizedBox(height: sh * 0.02),
                                Text(
                                  'No Deleted Medicines',
                                  style: PillBinMedium.style(
                                    fontSize:
                                        isTablet ? sw * 0.025 : sw * 0.045,
                                    color: PillBinColors.textSecondary,
                                  ),
                                ),
                                SizedBox(height: sh * 0.01),
                                Text(
                                  'Your deleted medicines will appear here',
                                  style: PillBinRegular.style(
                                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                                    color: PillBinColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? sw * 0.025 : sw * 0.045,
                            ),
                            itemCount:
                                provider.deletedMedicinesInventory.length,
                            itemBuilder: (context, index) {
                              final medicine =
                                  provider.deletedMedicinesInventory[index];
                              return DeletedMedicineItem(
                                medicine: medicine,
                                sw: sw,
                                sh: sh,
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DeletedMedicineItem extends StatelessWidget {
  final Medicine medicine;
  final double sw;
  final double sh;

  const DeletedMedicineItem({
    Key? key,
    required this.medicine,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  bool _shouldShowRebuyLinks() {
    return medicine.productLinks != null &&
        (medicine.productLinks!.tata1mg != null ||
            medicine.productLinks!.pharmeasy != null ||
            medicine.productLinks!.netmeds != null);
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SafeArea(
                child: Positioned(
                  top: 16,
                  right: 16,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = sw > 600;
    final bool showRebuyLinks = _shouldShowRebuyLinks();

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.02),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        child: Container(
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: PillBinColors.error,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.045),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (medicine.image?.url != null) ...[
                          InkWell(
                            onTap: () => _showFullScreenImage(
                                context, medicine.image!.url!),
                            borderRadius:
                                BorderRadius.circular(isTablet ? 16 : 12),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 16 : 12),
                              child: Container(
                                width: isTablet ? sw * 0.12 : sw * 0.18,
                                height: isTablet ? sw * 0.12 : sw * 0.18,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: PillBinColors.error.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(isTablet ? 16 : 12),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: medicine.image!.url!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color:
                                        PillBinColors.error.withOpacity(0.08),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: PillBinColors.error,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          PillBinColors.error.withOpacity(0.15),
                                          PillBinColors.error.withOpacity(0.08),
                                        ],
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.medication,
                                      color:
                                          PillBinColors.error.withOpacity(0.5),
                                      size: isTablet ? sw * 0.05 : sw * 0.08,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: sw * 0.035),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.all(
                                isTablet ? sw * 0.025 : sw * 0.035),
                            decoration: BoxDecoration(
                              color: PillBinColors.error.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(isTablet ? 16 : 12),
                              border: Border.all(
                                color: PillBinColors.error.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.medication,
                              color: PillBinColors.error,
                              size: isTablet ? sw * 0.03 : sw * 0.055,
                            ),
                          ),
                          SizedBox(width: sw * 0.04),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine.name,
                                style: PillBinMedium.style(
                                  fontSize: isTablet ? sw * 0.025 : sw * 0.042,
                                  color: PillBinColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: sh * 0.005),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? sw * 0.015 : sw * 0.02,
                                  vertical: isTablet ? sh * 0.003 : sh * 0.005,
                                ),
                                decoration: BoxDecoration(
                                  color: PillBinColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'DELETED',
                                  style: PillBinMedium.style(
                                    fontSize:
                                        isTablet ? sw * 0.018 : sw * 0.028,
                                    color: PillBinColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.02),

                    // Dosage
                    if (medicine.dosage != null && medicine.dosage!.isNotEmpty)
                      _buildInfoRow(
                        'Dosage',
                        medicine.dosage!,
                        Icons.medical_services,
                        isTablet,
                      ),

                    // Type
                    if (medicine.type != null && medicine.type!.isNotEmpty)
                      _buildInfoRow(
                        'Type',
                        medicine.type!,
                        Icons.category,
                        isTablet,
                      ),

                    // Manufacturer
                    if (medicine.manufacturer != null &&
                        medicine.manufacturer!.isNotEmpty)
                      _buildInfoRow(
                        'Manufacturer',
                        medicine.manufacturer!,
                        Icons.business,
                        isTablet,
                      ),

                    // Batch Number
                    if (medicine.batchNumber != null &&
                        medicine.batchNumber!.isNotEmpty)
                      _buildInfoRow(
                        'Batch Number',
                        medicine.batchNumber!,
                        Icons.qr_code,
                        isTablet,
                      ),

                    if (showRebuyLinks) ...[
                      SizedBox(height: sh * 0.015),
                      Container(
                        padding:
                            EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              PillBinColors.primary.withOpacity(0.08),
                              PillBinColors.primaryLight.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PillBinColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: PillBinColors.primary,
                                  size: isTablet ? sw * 0.02 : sw * 0.038,
                                ),
                                SizedBox(width: sw * 0.015),
                                Text(
                                  'Rebuy Medicine',
                                  style: PillBinMedium.style(
                                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                                    color: PillBinColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sh * 0.01),
                            Wrap(
                              spacing: sw * 0.015,
                              runSpacing: sh * 0.008,
                              children: [
                                if (medicine.productLinks?.tata1mg != null)
                                  _buildCompactStoreButton(
                                    '1mg',
                                    medicine.productLinks!.tata1mg!,
                                    Colors.orange,
                                    isTablet,
                                  ),
                                if (medicine.productLinks?.pharmeasy != null)
                                  _buildCompactStoreButton(
                                    'PharmEasy',
                                    medicine.productLinks!.pharmeasy!,
                                    Colors.teal,
                                    isTablet,
                                  ),
                                if (medicine.productLinks?.netmeds != null)
                                  _buildCompactStoreButton(
                                    'Netmeds',
                                    medicine.productLinks!.netmeds!,
                                    Colors.blue,
                                    isTablet,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: sh * 0.015),
                    Container(
                      height: 1,
                      color: PillBinColors.greyLight.withOpacity(0.3),
                    ),
                    SizedBox(height: sh * 0.015),

                    // Dates Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateCard(
                            'Purchase Date',
                            DateFormat('dd MMMM yyyy')
                                .format(medicine.purchaseDate),
                            Icons.shopping_cart,
                            isTablet,
                          ),
                        ),
                        SizedBox(width: sw * 0.03),
                        Expanded(
                          child: _buildDateCard(
                            'Expiry Date',
                            DateFormat('dd MMMM yyyy')
                                .format(medicine.expiryDate),
                            Icons.event,
                            isTablet,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sh * 0.015),
                    _buildDateCard(
                      'Added Date',
                      DateFormat('dd MMMM yyyy').format(medicine.addedDate),
                      Icons.add_circle,
                      isTablet,
                      fullWidth: true,
                    ),

                    // Notes
                    if (medicine.notes != null &&
                        medicine.notes!.isNotEmpty) ...[
                      SizedBox(height: sh * 0.015),
                      Container(
                        padding:
                            EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                        decoration: BoxDecoration(
                          color: PillBinColors.greyLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PillBinColors.greyLight.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notes,
                                  size: isTablet ? sw * 0.02 : sw * 0.04,
                                  color: PillBinColors.textSecondary,
                                ),
                                SizedBox(width: sw * 0.02),
                                Text(
                                  'Notes',
                                  style: PillBinMedium.style(
                                    fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                                    color: PillBinColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: sh * 0.008),
                            Text(
                              medicine.notes!,
                              style: PillBinRegular.style(
                                fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                                color: PillBinColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
      try {
        final Uri url = Uri.parse(urlString);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch $url');
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    }


  Widget _buildCompactStoreButton(
    String storeName,
    String url,
    Color color,
    bool isTablet,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _launchURL(url),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? sw * 0.015 : sw * 0.02,
            vertical: isTablet ? sh * 0.006 : sh * 0.008,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new,
                size: isTablet ? sw * 0.015 : sw * 0.028,
                color: color,
              ),
              SizedBox(width: sw * 0.01),
              Text(
                storeName,
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.012),
      child: Row(
        children: [
          Icon(
            icon,
            size: isTablet ? sw * 0.02 : sw * 0.04,
            color: PillBinColors.textSecondary,
          ),
          SizedBox(width: sw * 0.03),
          Text(
            '$label: ',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.036,
              color: PillBinColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                color: PillBinColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label, String date, IconData icon, bool isTablet,
      {bool fullWidth = false}) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
      decoration: BoxDecoration(
        color: PillBinColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: PillBinColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: isTablet ? sw * 0.018 : sw * 0.035,
                color: PillBinColors.primary,
              ),
              SizedBox(width: sw * 0.02),
              Text(
                label,
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.005),
          Text(
            date,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.036,
              color: PillBinColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
