import 'package:flutter/material.dart';
import 'package:pillbin/features/blog/data/repository/blog_provider.dart';
import 'package:pillbin/network/utils/connectivity_banner.dart';
import 'package:provider/provider.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/features/blog/presentation/widgets/my_blog_shimmer.dart';
import 'package:pillbin/features/blog/presentation/widgets/my_blogs_widgets.dart';
import 'package:pillbin/network/models/blog_model.dart';

class MyBlogsScreen extends StatefulWidget {
  const MyBlogsScreen({Key? key}) : super(key: key);

  @override
  State<MyBlogsScreen> createState() => _MyBlogsScreenState();
}

class _MyBlogsScreenState extends State<MyBlogsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Local filtered list derived from provider data
  List<BlogModel> _filteredBlogs = [];

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

    //* Attach infinite-scroll listener
    _scrollController.addListener(_onScroll);

    //* Fetch user blogs on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BlogProvider>();
      // Only fetch if we have no data yet
      if (provider.userBlogs.isEmpty) {
        _loadBlogs();
      } else {
        _syncFilteredBlogs(); // just sync UI from existing data
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Data fetching ──────────────────────────────────────────────────────────

  Future<void> _loadBlogs({bool forceRefresh = false}) async {
    final provider = context.read<BlogProvider>();
    await provider.fetchUserBlogs(
      context: context,
      forceRefresh: forceRefresh,
    );
    _syncFilteredBlogs();
  }

  Future<void> _loadMore() async {
    final provider = context.read<BlogProvider>();
    await provider.fetchUserBlogs(
      context: context,
      loadMore: true,
    );
    _syncFilteredBlogs();
  }

  void _onScroll() {
    // Trigger load-more when 200 px from the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<BlogProvider>();
      if (provider.userBlogsHasMore && !provider.isUserBlogsLoadingMore) {
        _loadMore();
      }
    }
  }

  // ─── Search ─────────────────────────────────────────────────────────────────

  /// Re-derives _filteredBlogs from the provider list + current search query.
  void _syncFilteredBlogs() {
    final blogs = context.read<BlogProvider>().userBlogs;
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredBlogs = query.isEmpty
          ? List.of(blogs)
          : blogs.where((blog) {
              return blog.content.toLowerCase().contains(query) ||
                  blog.author["email"].contains(query) ||
                  blog.role.toLowerCase().contains(query);
            }).toList();
    });
  }

  void _applySearch(String value) => _syncFilteredBlogs();

  void _clearSearch() {
    _searchController.clear();
    _syncFilteredBlogs();
  }

  // ─── Pull-to-refresh ────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    _searchController.clear();
    await _loadBlogs(forceRefresh: true);
  }

  // ─── Blog detail ────────────────────────────────────────────────────────────

  void _showBlogDetails(BlogModel blog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlogDetailsModal(blog: blog),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

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
              ConnectivityBanner(),

              // Header — reacts to filtered count
              Consumer<BlogProvider>(
                builder: (context, provider, _) => buildBlogHeader(
                  sw: sw,
                  sh: sh,
                  isTablet: isTablet,
                  blogCount: _filteredBlogs.length,
                ),
              ),

              SizedBox(height: sh * 0.02),

              // Search Bar
              BlogSearchBar(
                controller: _searchController,
                onChanged: _applySearch,
                onClear: _clearSearch,
                sw: sw,
                sh: sh,
                isTablet: isTablet,
              ),

              SizedBox(height: sh * 0.02),

              // Content
              Expanded(
                child: Consumer<BlogProvider>(
                  builder: (context, provider, _) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _syncFilteredBlogs();
                    });

                    // Initial loading skeleton
                    if (provider.isUserBlogsLoading) {
                      return BlogShimmerGrid(
                        sw: sw,
                        sh: sh,
                        isTablet: isTablet,
                      );
                    }

                    return RefreshIndicator(
                      color: PillBinColors.primary,
                      backgroundColor: Colors.white,
                      onRefresh: _refresh,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            //* gives the grid all remaining space
                            hasScrollBody: true,
                            child: Column(
                              children: [
                                Expanded(
                                  child: BlogGrid(
                                    blogs: _filteredBlogs,
                                    sw: sw,
                                    sh: sh,
                                    isTablet: isTablet,
                                    onBlogTap: _showBlogDetails,
                                  ),
                                ),
                                if (provider.isUserBlogsLoadingMore)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: sh * 0.015),
                                    child: CircularProgressIndicator(
                                      color: PillBinColors.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                if (!provider.userBlogsHasMore &&
                                    _filteredBlogs.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: sh * 0.015),
                                    child: Text(
                                      "You've reached the end",
                                      style: TextStyle(
                                        color: PillBinColors.textSecondary,
                                        fontSize: isTablet ? 14 : 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
            '/add-blog-post-screen',
            arguments: {
              'transition': TransitionType.bottomToTop,
              'duration': 300,
            },
          ).then((_) {
            // Re-sync after returning from create screen in case a new blog
            // was inserted into the provider list by BlogProvider.createBlog.
            _syncFilteredBlogs();
          });
        },
        child: Icon(
          Icons.add,
          color: PillBinColors.textWhite,
          size: isTablet ? sw * 0.03 : sw * 0.06,
        ),
      ),
    );
  }

  // ─── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(double sw, double sh, bool isTablet) {
    final bool isSearchActive = _searchController.text.trim().isNotEmpty;
    return ListView(
      // ListView so pull-to-refresh still works on an empty screen
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: sh * 0.15),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSearchActive ? Icons.search_off : Icons.article_outlined,
                size: isTablet ? sw * 0.1 : sw * 0.18,
                color: PillBinColors.textSecondary,
              ),
              SizedBox(height: sh * 0.02),
              Text(
                isSearchActive
                    ? 'No blogs match your search'
                    : 'No blogs yet\nTap + to write your first post',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: PillBinColors.textSecondary,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              if (isSearchActive) ...[
                SizedBox(height: sh * 0.02),
                TextButton(
                  onPressed: _clearSearch,
                  child: Text(
                    'Clear search',
                    style: TextStyle(color: PillBinColors.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
