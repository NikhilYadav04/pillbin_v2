import 'package:flutter/material.dart';
import 'package:pillbin/features/blog/data/repository/blog_provider.dart';
import 'package:pillbin/features/blog/presentation/pages/comment_sheet.dart';
import 'package:pillbin/features/blog/presentation/pages/like_sheet.dart';
import 'package:pillbin/network/utils/connectivity_banner.dart';
import 'package:provider/provider.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';

import 'package:pillbin/features/blog/presentation/widgets/all_blog_widgets.dart';
import 'package:pillbin/features/blog/presentation/widgets/blog_post_shimmer.dart';
import 'package:pillbin/network/models/blog_model.dart';

class AllBlogsScreen extends StatefulWidget {
  const AllBlogsScreen({Key? key}) : super(key: key);

  @override
  State<AllBlogsScreen> createState() => _AllBlogsScreenState();
}

class _AllBlogsScreenState extends State<AllBlogsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

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

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BlogProvider>();
      if (provider.allBlogs.isEmpty) {
        _loadBlogs();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBlogs({bool forceRefresh = false}) async {
    await context.read<BlogProvider>().fetchAllBlogs(
          context: context,
          forceRefresh: forceRefresh,
        );
  }

  Future<void> _loadMore() async {
    await context.read<BlogProvider>().fetchAllBlogs(
          context: context,
          loadMore: true,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<BlogProvider>();
      if (provider.allBlogsHasMore && !provider.isAllBlogsLoadingMore) {
        _loadMore();
      }
    }
  }

  Future<void> _refresh() async {
    await _loadBlogs(forceRefresh: true);
  }

  Future<void> _handleLikeTap(String blogId) async {
    await context.read<BlogProvider>().toggleLike(
          context: context,
          blogId: blogId,
        );
  }

  Future<void> _handleLikesCountTap(String blogId) async {
    final provider = context.read<BlogProvider>();
    await provider.fetchBlogLikers(context: context, blogId: blogId);
    if (mounted) showLikesSheet(context);
  }

  Future<void> _handleCommentTap(String blogId) async {
    final provider = context.read<BlogProvider>();
    await provider.fetchComments(context: context, blogId: blogId);
    if (mounted) showCommentsSheet(context, blogId: blogId);
  }

  void _handleBlogTap(BlogModel blog) {}

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

              buildAllBlogsHeader(sw: sw, sh: sh, isTablet: isTablet),

              SizedBox(height: sh * 0.015),

              Expanded(
                child: Consumer<BlogProvider>(
                  builder: (context, provider, _) {
                    if (provider.isAllBlogsLoading) {
                      return BlogFeedShimmer(
                          sw: sw, sh: sh, isTablet: isTablet);
                    }

                    return RefreshIndicator(
                      color: PillBinColors.primary,
                      backgroundColor: Colors.white,
                      onRefresh: _refresh,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (!provider.isAllBlogsLoading &&
                              provider.allBlogs.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(sw, sh, isTablet),
                            ),

                          if (provider.allBlogs.isNotEmpty) ...[
                            SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? sw * 0.05 : sw * 0.04,
                                vertical: sh * 0.01,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final blog = provider.allBlogs[index];
                                    return BlogFeedCard(
                                      blog: blog,
                                      sw: sw,
                                      sh: sh,
                                      isTablet: isTablet,
                                      onLikeTap: () => _handleLikeTap(blog.id),
                                      onLikesCountTap: () =>
                                          _handleLikesCountTap(blog.id),
                                      onCommentTap: () =>
                                          _handleCommentTap(blog.id),
                                      onTap: () => _handleBlogTap(blog),
                                    );
                                  },
                                  childCount: provider.allBlogs.length,
                                ),
                              ),
                            ),

                            if (provider.isAllBlogsLoadingMore)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: sh * 0.015),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: PillBinColors.primary,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              ),

                            if (!provider.allBlogsHasMore &&
                                provider.allBlogs.isNotEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: sh * 0.015),
                                  child: Center(
                                    child: Text(
                                      "You're all caught up",
                                      style: TextStyle(
                                        color: PillBinColors.textSecondary,
                                        fontSize: isTablet ? 14 : 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
        tooltip: "Create New Blog",
        backgroundColor: PillBinColors.primary,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-blog-post-screen',
            arguments: {
              'transition': TransitionType.bottomToTop,
              'duration': 300,
            },
          );
        },
        child: Builder(builder: (context) {
          final double sw = MediaQuery.of(context).size.width;
          final bool isTablet = sw > 600;
          return Icon(
            Icons.add,
            color: PillBinColors.textWhite,
            size: isTablet ? sw * 0.025 : sw * 0.08,
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(double sw, double sh, bool isTablet) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.article_outlined,
            size: isTablet ? sw * 0.1 : sw * 0.18,
            color: PillBinColors.textSecondary,
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No posts yet\nPull down to refresh',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PillBinColors.textSecondary,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
