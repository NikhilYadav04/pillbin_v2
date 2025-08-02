import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_detail_display.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_inventory_widgets.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_item.dart';

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
  List<Medicine> _allMedicines = [];
  List<Medicine> _activeMedicines = [];
  List<Medicine> _expiringSoonMedicines = [];
  List<Medicine> _expiredMedicines = [];

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
    _loadMedicines();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadMedicines() {
    // Sample data - replace with actual data loading
    _allMedicines = [
      Medicine(
        name: 'Paracetamol',
        quantity: '20 tablets',
        expiryDate: DateTime.now().add(const Duration(days: 145)),
        status: 'Active',
        notes: 'For fever and pain relief',
        addedDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medicine(
        name: 'Vitamin D3',
        quantity: '30 capsules',
        expiryDate: DateTime.now().add(const Duration(days: 200)),
        status: 'Active',
        notes: 'Daily supplement',
        addedDate: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Medicine(
        name: 'Crocin',
        quantity: '10 tablets',
        expiryDate: DateTime.now().add(const Duration(days: 38)),
        status: 'Expiring Soon',
        notes: 'Pain reliever',
        addedDate: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Medicine(
        name: 'Aspirin',
        quantity: '25 tablets',
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        status: 'Expiring Soon',
        notes: 'Blood thinner',
        addedDate: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Medicine(
        name: 'Amoxicillin',
        quantity: '14 capsules',
        expiryDate: DateTime.now().add(const Duration(days: 25)),
        status: 'Expiring Soon',
        notes: 'Antibiotic course',
        addedDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Medicine(
        name: 'Ibuprofen',
        quantity: '15 tablets',
        expiryDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Expired',
        notes: 'Anti-inflammatory',
        addedDate: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Medicine(
        name: 'Cough Syrup',
        quantity: '100ml',
        expiryDate: DateTime.now().subtract(const Duration(days: 13)),
        status: 'Expired',
        notes: 'Opened 2 months ago',
        addedDate: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      List<Medicine> filteredByDate = _allMedicines.where((medicine) {
        // Search filter
        bool matchesSearch = _searchController.text.isEmpty ||
            medicine.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            medicine.notes
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

        // Date filter
        bool matchesDate = true;
        if (_selectedDateFilter != 'All Time') {
          DateTime now = DateTime.now();
          switch (_selectedDateFilter) {
            case 'This Week':
              matchesDate = medicine.addedDate
                  .isAfter(now.subtract(const Duration(days: 7)));
              break;
            case 'This Month':
              matchesDate = medicine.addedDate
                  .isAfter(now.subtract(const Duration(days: 30)));
              break;
            case 'This Year':
              matchesDate = medicine.addedDate
                  .isAfter(now.subtract(const Duration(days: 365)));
              break;
          }
        }

        return matchesSearch && matchesDate;
      }).toList();

      // Separate by status
      _activeMedicines =
          filteredByDate.where((m) => m.status == 'Active').toList();
      _expiringSoonMedicines =
          filteredByDate.where((m) => m.status == 'Expiring Soon').toList();
      _expiredMedicines =
          filteredByDate.where((m) => m.status == 'Expired').toList();

      // Sort each list by expiry date
      _activeMedicines.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      _expiringSoonMedicines
          .sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      _expiredMedicines.sort((a, b) =>
          b.expiryDate.compareTo(a.expiryDate)); // Most recently expired first
    });
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
              buildInventoryHeader(sw, sh, isTablet,context),
              SizedBox(height: sh * 0.00),
              _buildFilters(sw, sh, isTablet),
              SizedBox(height: sh * 0.015),
              buildInventoryTabBar(
                  sw,
                  sh,
                  isTablet,
                  _tabController,
                  _activeMedicines.length,
                  _expiringSoonMedicines.length,
                  _expiredMedicines.length),
              Expanded(
                child: _buildTabBarView(sw, sh, isTablet),
              ),
            ],
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

  Widget _buildFilters(double sw, double sh, bool isTablet) {
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
              onChanged: (value) => _applyFilters(),
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
                          _applyFilters();
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
                      _applyFilters();
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
                    });
                    _applyFilters();
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

  Widget _buildTabBarView(double sw, double sh, bool isTablet) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMedicinesList(
            _activeMedicines, sw, sh, isTablet, 'No active medicines found'),
        _buildMedicinesList(_expiringSoonMedicines, sw, sh, isTablet,
            'No medicines expiring soon'),
        _buildMedicinesList(
            _expiredMedicines, sw, sh, isTablet, 'No expired medicines found'),
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
          onTap: () => _showMedicineDetails(medicines[index]),
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
