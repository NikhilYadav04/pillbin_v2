import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:provider/provider.dart';

class VendorDonatedMedicinesScreen extends StatefulWidget {
  const VendorDonatedMedicinesScreen({Key? key}) : super(key: key);

  @override
  State<VendorDonatedMedicinesScreen> createState() =>
      _VendorDonatedMedicinesScreenState();
}

class _VendorDonatedMedicinesScreenState
    extends State<VendorDonatedMedicinesScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProvider>().loadDonatedMedicines(reset: true);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<VendorProvider>();
        if (provider.hasMoreMedicines && !provider.isLoadingMedicines) {
          provider.loadDonatedMedicines();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final provider = context.watch<VendorProvider>();

    final all = provider.donatedMedicines;
    final visible = _query.isEmpty
        ? all
        : all
            .where((m) =>
                (m['name'] as String? ?? '').toLowerCase().contains(_query))
            .toList();
    final peak = all.isEmpty
        ? 0
        : all.fold<int>(
            0, (m, e) => (e['count'] as int? ?? 0) > m ? e['count'] as int : m);

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
        title: Text('Donated Medicines',
            style: PillBinBold.style(
                fontSize: sw * 0.046, color: PillBinColors.textPrimary)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.04, 0, sw * 0.04, sh * 0.012),
            child: TextField(
              controller: _searchController,
              onChanged: (v) =>
                  setState(() => _query = v.trim().toLowerCase()),
              style: PillBinRegular.style(
                  fontSize: sw * 0.035, color: PillBinColors.textDark),
              decoration: InputDecoration(
                hintText: 'Search medicine',
                hintStyle: PillBinRegular.style(
                    fontSize: sw * 0.033, color: PillBinColors.textLight),
                prefixIcon: Icon(Icons.search_rounded,
                    size: sw * 0.05, color: PillBinColors.textSecondary),
                filled: true,
                fillColor: PillBinColors.surface,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04, vertical: sh * 0.015),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: PillBinColors.greyLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: PillBinColors.greyLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: PillBinColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: PillBinColors.primary,
              onRefresh: () async => context
                  .read<VendorProvider>()
                  .loadDonatedMedicines(reset: true),
              child: visible.isEmpty && !provider.isLoadingMedicines
                  ? LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.medication_outlined,
                                    size: sw * 0.14,
                                    color: PillBinColors.greyLight),
                                SizedBox(height: sh * 0.015),
                                Text(
                                    _query.isEmpty
                                        ? 'No medicines donated yet'
                                        : 'No match for "$_query"',
                                    style: PillBinMedium.style(
                                        fontSize: sw * 0.038,
                                        color: PillBinColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                          sw * 0.04, 0, sw * 0.04, sh * 0.04),
                      itemCount: visible.length + 1,
                      itemBuilder: (_, i) {
                        if (i == visible.length) {
                          if (provider.isLoadingMedicines) {
                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: sh * 0.025),
                              child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: PillBinColors.primary),
                              ),
                            );
                          }
                          if (!provider.hasMoreMedicines && all.isNotEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: sh * 0.02),
                              child: Center(
                                child: Text(
                                    '${all.length} distinct medicines',
                                    style: PillBinRegular.style(
                                        fontSize: sw * 0.03,
                                        color: PillBinColors.textLight)),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        return _medicineRow(
                            sw, sh, visible[i], all.indexOf(visible[i]), peak);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineRow(double sw, double sh, Map<String, dynamic> medicine,
      int rank, int peak) {
    final name = medicine['name'] as String? ?? '';
    final count = medicine['count'] as int? ?? 0;
    final fraction = peak == 0 ? 0.0 : count / peak;

    return Container(
      margin: EdgeInsets.only(bottom: sh * 0.01),
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04, vertical: sh * 0.015),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Row(
        children: [
          SizedBox(
            width: sw * 0.07,
            child: Text('${rank + 1}',
                style: PillBinMedium.style(
                    fontSize: sw * 0.032, color: PillBinColors.textLight)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty
                      ? 'Unnamed'
                      : name
                          .split(' ')
                          .where((w) => w.isNotEmpty)
                          .map((w) => w[0].toUpperCase() + w.substring(1))
                          .join(' '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PillBinMedium.style(
                      fontSize: sw * 0.035, color: PillBinColors.textDark),
                ),
                SizedBox(height: sh * 0.008),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: sh * 0.009,
                    backgroundColor:
                        PillBinColors.greyLight.withValues(alpha: 0.5),
                    valueColor:
                        AlwaysStoppedAnimation(PillBinColors.primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sw * 0.035),
          Text('$count',
              style: PillBinBold.style(
                  fontSize: sw * 0.04, color: PillBinColors.primary)),
        ],
      ),
    );
  }
}
