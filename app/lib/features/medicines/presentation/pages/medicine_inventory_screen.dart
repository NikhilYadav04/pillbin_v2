import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/inventoryShimmerCard.dart';
import 'package:pillbin/features/donation/data/repository/donation_provider.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';
import 'package:pillbin/features/medicines/data/repository/family_member_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_detail_display.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_inventory_widgets.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_item.dart';
import 'package:pillbin/network/models/medicine_model.dart';
import 'package:pillbin/network/utils/connectivity_banner.dart';
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
  bool _needsBannerDismissed = false;

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
        provider.getInventory();
      }
      Provider.of<FamilyMemberProvider>(context, listen: false).load();

      final user = Provider.of<UserProvider>(context, listen: false).user;
      final coords = user?.location?.coordinates;
      if (coords?.latitude != null && coords?.longitude != null) {
        Provider.of<MedicalCenterProvider>(context, listen: false)
            .getNearbyNeeds(
                latitude: coords!.latitude!, longitude: coords.longitude!);
      }
    });
  }

  List<Medicine> _filterByProfile(List<Medicine> medicines, String? profileId) {
    if (profileId == null) {
      return medicines.where((m) => m.familyMemberId == null).toList();
    }
    return medicines.where((m) => m.familyMemberId == profileId).toList();
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
    provider.getInventory(forceRefresh: true);
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
          child: Consumer2<MedicineProvider, FamilyMemberProvider>(
            builder: (context, provider, familyProvider, _) {
              final profileId = familyProvider.selectedId;
              final active =
                  _filterByProfile(provider.activeMedicinesInventory, profileId);
              final expiringSoon = _filterByProfile(
                  provider.expiringSoonMedicinesInventory, profileId);
              final expired = _filterByProfile(
                  provider.expiredMedicinesInventory, profileId);

              return Column(
                children: [
                  ConnectivityBanner(),
                  buildInventoryHeader(sw, sh, isTablet, context),
                  SizedBox(height: sh * 0.00),
                  _buildNeedsBanner(sw, sh, isTablet),
                  _buildProfileRow(sw, sh, isTablet, familyProvider),
                  SizedBox(height: sh * 0.012),
                  _buildFilters(sw, sh, isTablet, provider),
                  SizedBox(height: sh * 0.015),
                  buildInventoryTabBar(
                      sw,
                      sh,
                      isTablet,
                      _tabController,
                      active.length,
                      expiringSoon.length,
                      expired.length),
                  Expanded(
                    child: _buildTabBarView(sw, sh, isTablet, provider,
                        active, expiringSoon, expired),
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

  Widget _buildNeedsBanner(double sw, double sh, bool isTablet) {
    if (_needsBannerDismissed) return const SizedBox.shrink();

    return Consumer<MedicalCenterProvider>(
      builder: (context, centerProvider, _) {
        final categories = centerProvider.nearbyNeedsCategories;
        final centerCount = centerProvider.nearbyNeedsCenterCount;

        if (categories.isEmpty || centerCount == 0) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
              isTablet ? sw * 0.05 : sw * 0.04,
              sh * 0.01,
              isTablet ? sw * 0.05 : sw * 0.04,
              sh * 0.014),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.pushNamed(context, '/location-screen'),
            child: Container(
              padding: EdgeInsets.all(sw * 0.035),
              decoration: BoxDecoration(
                color: PillBinColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: PillBinColors.success.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(sw * 0.022),
                    decoration: BoxDecoration(
                      color: PillBinColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.campaign_outlined,
                        size: sw * 0.05, color: PillBinColors.success),
                  ),
                  SizedBox(width: sw * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '$centerCount ${centerCount == 1 ? 'center' : 'centers'} near you '
                            'accepting donations',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.034,
                                color: PillBinColors.textPrimary)),
                        SizedBox(height: sh * 0.003),
                        Text('In demand: ${categories.join(', ')}',
                            style: PillBinRegular.style(
                                fontSize: sw * 0.03,
                                color: PillBinColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: sw * 0.042, color: PillBinColors.textLight),
                    onPressed: () =>
                        setState(() => _needsBannerDismissed = true),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildDonateBanner(double sw, double sh, List<Medicine> expiring) {
    return Container(
      margin: EdgeInsets.fromLTRB(sw * 0.04, sh * 0.008, sw * 0.04, 0),
      padding: EdgeInsets.all(sw * 0.035),
      decoration: BoxDecoration(
        color: PillBinColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: PillBinColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.volunteer_activism_outlined,
              color: PillBinColors.warning, size: sw * 0.055),
          SizedBox(width: sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${expiring.length} medicine${expiring.length == 1 ? '' : 's'} expiring soon',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.035, color: PillBinColors.textPrimary),
                ),
                SizedBox(height: sh * 0.003),
                Text('Donate them before they expire',
                    style: PillBinRegular.style(
                        fontSize: sw * 0.029,
                        color: PillBinColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(width: sw * 0.02),
          ElevatedButton(
            onPressed: () => _startDonation(expiring),
            style: ElevatedButton.styleFrom(
              backgroundColor: PillBinColors.warning,
              padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.04, vertical: sh * 0.012),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Donate',
                style: PillBinMedium.style(
                    fontSize: sw * 0.032, color: PillBinColors.textWhite)),
          ),
        ],
      ),
    );
  }

  void _startDonation(List<Medicine> expiring) {
    context.read<DonationProvider>().stageMedicines(expiring);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Pick a center to donate ${expiring.length} medicine${expiring.length == 1 ? '' : 's'}'),
        backgroundColor: PillBinColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pushNamed(context, '/location-screen');
  }

  Widget _buildTabBarView(
      double sw,
      double sh,
      bool isTablet,
      MedicineProvider provider,
      List<Medicine> active,
      List<Medicine> expiringSoon,
      List<Medicine> expired) {
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
                child: _buildMedicinesList(
                    active, sw, sh, isTablet, 'No active medicines found'),
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
                child: Column(
                  children: [
                    if (expiringSoon.isNotEmpty)
                      _buildDonateBanner(sw, sh, expiringSoon),
                    Expanded(
                      child: _buildMedicinesList(expiringSoon, sw, sh,
                          isTablet, 'No medicines expiring soon'),
                    ),
                  ],
                ),
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
                child: _buildMedicinesList(
                    expired, sw, sh, isTablet, 'No expired medicines found'),
              ),
      ],
    );
  }

  Widget _buildProfileRow(
      double sw, double sh, bool isTablet, FamilyMemberProvider familyProvider) {
    return SizedBox(
      height: sh * 0.05,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        children: [
          _profileChip(sw, 'Self', familyProvider.selectedId == null,
              () => familyProvider.selectProfile(null)),
          ...familyProvider.members.map((member) => Padding(
                padding: EdgeInsets.only(left: sw * 0.02),
                child: _profileChip(
                    sw,
                    member.name,
                    familyProvider.selectedId == member.id,
                    () => familyProvider.selectProfile(member.id)),
              )),
          Padding(
            padding: EdgeInsets.only(left: sw * 0.02),
            child: ActionChip(
              avatar: Icon(Icons.add, size: sw * 0.04),
              label: Text('Add',
                  style: PillBinRegular.style(
                      fontSize: sw * 0.032, color: PillBinColors.textSecondary)),
              backgroundColor: PillBinColors.surface,
              side: BorderSide(color: PillBinColors.greyLight),
              onPressed: () =>
                  Navigator.pushNamed(context, '/manage-family-screen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileChip(
      double sw, String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label,
          style: PillBinMedium.style(
              fontSize: sw * 0.032,
              color: selected ? Colors.white : PillBinColors.textPrimary)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: PillBinColors.primary,
      backgroundColor: PillBinColors.surface,
      side: BorderSide(
          color: selected ? PillBinColors.primary : PillBinColors.greyLight),
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
                'notes': medicines[index].notes,
                'isRecurring': medicines[index].isRecurring,
                'refillIntervalDays': medicines[index].refillIntervalDays,
                'familyMemberId': medicines[index].familyMemberId,
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

                        await _provider.deleteMedicine(
                          medicineId: medicines[index].id,
                          userModel: context.read<UserProvider>().user,
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
