import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/health_ai/data/model/rag_model.dart';
import 'package:pillbin/features/health_ai/data/repository/rag_provider.dart';
import 'package:pillbin/features/health_ai/presentation/widgets/health_ai_history_widgets.dart';
import 'package:provider/provider.dart';

class RagHistoryScreen extends StatefulWidget {
  const RagHistoryScreen({super.key});

  @override
  State<RagHistoryScreen> createState() => _RagHistoryScreenState();
}

class _RagHistoryScreenState extends State<RagHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  Timer? _debounce;

  List<HealthRagModel> _filteredDocuments = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final provider = context.read<RagProvider>();

        if (provider.hasMore && !provider.isFetching) {
          provider.fetchRagHistory();
        }
      }
    });

    final provider = context.read<RagProvider>();
    if (provider.ragDocuments.isEmpty && !provider.isFetching) {
      provider.fetchRagHistory(refresh: true);
    }
  }

  void _refresh() {
    final provider = context.read<RagProvider>();
    if (!provider.isFetching) {
      _searchController.clear();
      _isSearching = false;
      _filteredDocuments.clear();
      provider.fetchRagHistory(refresh: true,forceRefresh: true);
    }
  }

  void _applySearch() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = context.read<RagProvider>();
      final searchQuery = _searchController.text.trim();

      if (searchQuery.isEmpty) {
        setState(() {
          _isSearching = false;
          _filteredDocuments.clear();
        });
        return;
      }

      setState(() {
        _isSearching = true;
        _filteredDocuments = provider.ragDocuments.where((doc) {
          return doc.pdfName
                  .trim()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              (doc.pdfDescription
                      ?.trim()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ??
                  false);
        }).toList();
      });
    });
  }

  void _showClearHistoryDialog(double sw, double sh, bool isTablet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PillBinColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Clear History',
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.045,
            color: PillBinColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all RAG history? This action cannot be undone.',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.02 : sw * 0.036,
            color: PillBinColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                color: PillBinColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = context.read<RagProvider>();
              provider.clearRagHistory(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Clear All',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.02 : sw * 0.036,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: PillBinColors.textPrimary,
            size: isTablet ? sw * 0.025 : sw * 0.05,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Reports History',
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.03 : sw * 0.045,
            color: PillBinColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: PillBinColors.greyLight.withOpacity(0.3),
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _refresh(),
            icon: Icon(
              Icons.refresh,
              color: PillBinColors.primary,
            ),
          ),
          IconButton(
            onPressed: () => _showClearHistoryDialog(sw, sh, isTablet),
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          ),
          SizedBox(width: 5),
        ],
      ),
      body: Consumer<RagProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildSearchBar(sw, sh, isTablet),
              _buildResultsCount(sw, sh, isTablet, provider),
              Expanded(
                child: provider.isFetching && provider.ragDocuments.isEmpty
                    ? _buildLoadingShimmer(sw, sh)
                    : _buildDocumentsList(sw, sh, provider, isTablet),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(double sw, double sh, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
      color: PillBinColors.surface,
      child: Container(
        decoration: BoxDecoration(
          color: PillBinColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: PillBinColors.greyLight.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => _applySearch(),
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.022 : sw * 0.036,
            color: PillBinColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search documents...',
            hintStyle: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.036,
              color: PillBinColors.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: PillBinColors.textSecondary,
              size: isTablet ? sw * 0.025 : sw * 0.045,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: PillBinColors.textSecondary,
                      size: isTablet ? sw * 0.025 : sw * 0.045,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _applySearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: sw * 0.04,
              vertical: sh * 0.015,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCount(
      double sw, double sh, bool isTablet, RagProvider provider) {
    final displayList =
        _isSearching ? _filteredDocuments : provider.ragDocuments;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.025 : sw * 0.04,
        vertical: sh * 0.01,
      ),
      child: Row(
        children: [
          Text(
            '${displayList.length} ${displayList.length == 1 ? 'document' : 'documents'} found',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (_isSearching)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.025,
                vertical: sh * 0.005,
              ),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: PillBinColors.primary,
                    size: isTablet ? sw * 0.02 : sw * 0.035,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    'Filtered',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                      color: PillBinColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(double sw, double sh) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.04,
        vertical: sh * 0.01,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: sh * 0.015),
          padding: EdgeInsets.all(sw * 0.04),
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: sw * 0.6,
                decoration: BoxDecoration(
                  color: PillBinColors.greyLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(height: sh * 0.01),
              Container(
                height: 14,
                width: sw * 0.8,
                decoration: BoxDecoration(
                  color: PillBinColors.greyLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentsList(
      double sw, double sh, RagProvider provider, bool isTablet) {
    final displayList =
        _isSearching ? _filteredDocuments : provider.ragDocuments;

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.description_outlined,
              size: sw * 0.15,
              color: PillBinColors.greyLight,
            ),
            SizedBox(height: sh * 0.02),
            Text(
              _isSearching ? 'No documents found' : 'No history yet',
              style: PillBinMedium.style(
                fontSize: sw * 0.04,
                color: PillBinColors.textSecondary,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              _isSearching
                  ? 'Try a different search term'
                  : 'Upload a PDF to get started',
              style: PillBinRegular.style(
                fontSize: sw * 0.032,
                color: PillBinColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: PillBinColors.primary,
      onRefresh: () async {
        _refresh();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.01,
        ),
        itemCount:
            displayList.length + (provider.hasMore && !_isSearching ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayList.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: sh * 0.02),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final doc = displayList[index];
          return buildDocumentCard(doc, sw, sh, isTablet, context);
        },
      ),
    );
  }
}
