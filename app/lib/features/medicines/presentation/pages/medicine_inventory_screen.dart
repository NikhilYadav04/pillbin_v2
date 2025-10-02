import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/inventoryShimmerCard.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_detail_display.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_inventory_widgets.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_item.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:provider/provider.dart';

class MyInventoryScreen extends StatefulWidget {
  const MyInventoryScreen({Key? key}) : super(key: key);

  @override
  State<MyInventoryScreen> createState() => _MyInventoryScreenState();
}

class _MyInventoryScreenState extends State<MyInventoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final TextEditingController _searchController = TextEditingController();
  String _selectedDateFilter = 'All Time';

  final List<String> _dateFilters = [
    'All Time',
    'This Week',
    'This Month',
    'This Year'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    //_loadMedicines();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MedicineProvider>(context, listen: false);
      if (provider.activeMedicinesInventory.isEmpty) {
        provider.getInventory(context: context);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFiltersSearch() {
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final searchQuery = _searchController.text.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      provider.clearSearchFilter();
      return;
    }

    //* Filter active medicines
    final filteredActive = provider.activeMedicinesInventory.where((medicine) {
      return medicine.name.toLowerCase().contains(searchQuery) ||
          (medicine.batchNumber?.toLowerCase().contains(searchQuery) ??
              false) ||
          (medicine.manufacturer?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    //* Filter expiring soon medicines
    final filteredExpiringSoon =
        provider.expiringSoonMedicinesInventory.where((medicine) {
      return medicine.name.toLowerCase().contains(searchQuery) ||
          (medicine.batchNumber?.toLowerCase().contains(searchQuery) ??
              false) ||
          (medicine.manufacturer?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    //* Filter expired medicines
    final filteredExpired =
        provider.expiredMedicinesInventory.where((medicine) {
      return medicine.name.toLowerCase().contains(searchQuery) ||
          (medicine.batchNumber?.toLowerCase().contains(searchQuery) ??
              false) ||
          (medicine.manufacturer?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    //* Update provider with filtered results
    provider.updateFilteredInventory(
      activeMedicines: filteredActive,
      expiringSoonMedicines: filteredExpiringSoon,
      expiredMedicines: filteredExpired,
    );
  }

  void _applyFilterDropDown(String selectedDateFilter) {
    final provider = Provider.of<MedicineProvider>(context, listen: false);

    if (selectedDateFilter == 'All Time') {
      print('All time applied');
      provider.clearSearchFilter();
      return;
    }

    int days = 0;
    switch (selectedDateFilter) {
      case 'This Week':
        days = 7;
        break;
      case 'This Month':
        days = 30;
        break;
      case 'This Year':
        days = 365;
        break;
      default:
        print("No filters applied");
        provider.clearSearchFilter();
        return;
    }

    //* Get the cutoff date (medicines added after this date)
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final filteredActive = provider.activeMedicinesInventory.where((medicine) {
      return medicine.addedDate.isAfter(cutoffDate) ||
          medicine.addedDate.isAtSameMomentAs(cutoffDate);
    }).toList();

    final filteredExpiringSoon =
        provider.expiringSoonMedicinesInventory.where((medicine) {
      return medicine.addedDate.isAfter(cutoffDate) ||
          medicine.addedDate.isAtSameMomentAs(cutoffDate);
    }).toList();

    final filteredExpired =
        provider.expiredMedicinesInventory.where((medicine) {
      return medicine.addedDate.isAfter(cutoffDate) ||
          medicine.addedDate.isAtSameMomentAs(cutoffDate);
    }).toList();

    // * Update provider with filtered results
    provider.updateFilteredInventory(
      activeMedicines: filteredActive,
      expiringSoonMedicines: filteredExpiringSoon,
      expiredMedicines: filteredExpired,
    );
  }

  void _refresh() {
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    _searchController.clear();
    provider.clearSearchFilter();
    provider.getInventory(context: context);
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
                  buildInventoryHeader(sw, sh, isTablet, context),
                  SizedBox(height: sh * 0.00),
                  _buildFilters(sw, sh, isTablet, provider),
                  SizedBox(height: sh * 0.015),
                  buildInventoryTabBar(
                      sw,
                      sh,
                      isTablet,
                      _tabController,
                      provider.activeMedicinesInventory.length,
                      provider.expiringSoonMedicinesInventory.length,
                      provider.expiredMedicinesInventory.length),
                  Expanded(
                    child: _buildTabBarView(sw, sh, isTablet, provider),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PillBinColors.primary,
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-medicine-screen',
            arguments: {
              'transition': TransitionType.bottomToTop,
              'duration': 300,
            },
          );
        },
        child: Icon(
          Icons.add,
          color: PillBinColors.textWhite,
          size: isTablet ? sw * 0.03 : sw * 0.06,
        ),
      ),
    );
  }

  Widget _buildFilters(
      double sw, double sh, bool isTablet, MedicineProvider provider) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? sw * 0.05 : sw * 0.04),
      child: Column(
        children: [
          // Search Bar
          Container(
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
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _applyFiltersSearch(),
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                hintStyle: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                  color: PillBinColors.textLight,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: PillBinColors.textSecondary,
                  size: isTablet ? sw * 0.025 : sw * 0.05,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _applyFiltersSearch();
                        },
                        child: Icon(
                          Icons.clear,
                          color: PillBinColors.textSecondary,
                          size: isTablet ? sw * 0.025 : sw * 0.05,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
              ),
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                color: PillBinColors.textDark,
              ),
            ),
          ),
          SizedBox(height: sh * 0.015),
          // Date Filter and Clear Button
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: PillBinColors.surface,
                    borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                    border: Border.all(color: PillBinColors.greyLight),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDateFilter,
                    onChanged: (value) {
                      setState(() => _selectedDateFilter = value!);
                      print(_selectedDateFilter);
                      _applyFilterDropDown(_selectedDateFilter);
                    },
                    decoration: InputDecoration(
                      labelText: 'Added',
                      labelStyle: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                        color: PillBinColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.all(isTablet ? sw * 0.02 : sw * 0.03),
                    ),
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.textDark,
                    ),
                    items: _dateFilters.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(width: sw * 0.03),
              if (_selectedDateFilter != 'All Time' ||
                  _searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDateFilter = 'All Time';
                      _searchController.clear();
                      provider.clearSearchFilter();
                    });
                    //
                    //  _applyFilters();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                      vertical: isTablet ? sh * 0.015 : sh * 0.012,
                    ),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      border: Border.all(
                          color: PillBinColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Clear',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                        color: PillBinColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(
      double sw, double sh, bool isTablet, MedicineProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        provider.isFetching
            ? InventoryListShimmer(
                shimmerColor: PillBinColors.success,
              )
            : RefreshIndicator(
                color: PillBinColors.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  _refresh();
                },
                child: _buildMedicinesList(provider.activeMedicinesInventory,
                    sw, sh, isTablet, 'No active medicines found'),
              ),
        provider.isFetching
            ? InventoryListShimmer(
                shimmerColor: PillBinColors.warning,
              )
            : RefreshIndicator(
                color: PillBinColors.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  _refresh();
                },
                child: _buildMedicinesList(
                    provider.expiringSoonMedicinesInventory,
                    sw,
                    sh,
                    isTablet,
                    'No medicines expiring soon'),
              ),
        provider.isFetching
            ? InventoryListShimmer(
                shimmerColor: PillBinColors.error,
              )
            : RefreshIndicator(
                color: PillBinColors.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  _refresh();
                },
                child: _buildMedicinesList(provider.expiredMedicinesInventory,
                    sw, sh, isTablet, 'No expired medicines found'),
              ),
      ],
    );
  }

  Widget _buildMedicinesList(List<Medicine> medicines, double sw, double sh,
      bool isTablet, String emptyMessage) {
    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: isTablet ? sw * 0.08 : sw * 0.15,
              color: PillBinColors.textLight,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              emptyMessage,
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: PillBinColors.textSecondary,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              'Try adjusting your search or filters',
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                color: PillBinColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.02,
      ),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        return MedicineListItem(
          medicine: medicines[index],
          sw: sw,
          sh: sh,
          onTap: () => _showMedicineDetails(
            medicines[index],
          ),

          ///* Edit
          onEdit: () {
            Navigator.pushNamed(
              context,
              '/edit-medicine-screen',
              arguments: {
                'transition': TransitionType.rightToLeft,
                'duration': 300,
                'medicineId': medicines[index].id,
                'medicineName': medicines[index].name,
                'medicineType': medicines[index].type,
                'expiryDate': medicines[index].expiryDate,
                'purchaseDate': medicines[index].purchaseDate,
                'quantity': medicines[index].dosage,
                'manufacturer': medicines[index].manufacturer,
                'batchNumber': medicines[index].batchNumber,
                'notes': medicines[index].notes
              },
            );
          },

          //* Delete
          onDelete: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final double sw = MediaQuery.of(context).size.width;
                final bool isTablet = sw > 600;

                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.delete,
                        color: PillBinColors.error,
                        size: isTablet ? sw * 0.03 : sw * 0.05,
                      ),
                      SizedBox(width: sw * 0.02),
                      Text(
                        'Delete Medicine?',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'This action will permanently remove this medicine from your inventory.',
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                          color: PillBinColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        MedicineProvider _provider =
                            context.read<MedicineProvider>();
                        NotificationProvider _notificationProvider =
                            context.read<NotificationProvider>();

                        //* 1] First, delete the medicine
                        await _provider.deleteMedicine(
                          context: context,
                          medicineId: medicines[index].id,
                        );    

                        //* 2] Then, add notification BEFORE closing dialog
                        await _notificationProvider.addNotification(
                          context: context,
                          title: "${medicines[index].name.trim()} removed",
                          description:
                              "${medicines[index].name.trim()} has been removed from your tracker. No further reminders will be sent.",
                          status: 'alert',
                        );

                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                          color: PillBinColors.error,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showMedicineDetails(Medicine medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineDetailsModal(medicine: medicine),
    );
  }
}
