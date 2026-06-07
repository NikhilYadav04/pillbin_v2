import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/network/models/blog_model.dart';

/// Displays the feed title with icon
Widget buildAllBlogsHeader({
  required double sw,
  required double sh,
  required bool isTablet,
}) {
  return Container(
    margin: EdgeInsets.fromLTRB(
      isTablet ? sw * 0.05 : sw * 0.04,
      sh * 0.015,
      isTablet ? sw * 0.05 : sw * 0.04,
      sh * 0.01,
    ),
    padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.035),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          PillBinColors.primary.withOpacity(0.1),
          PillBinColors.primary.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
      border: Border.all(
        color: PillBinColors.primary.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: PillBinColors.primary.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        // Icon Container
        Container(
          padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.03),
          decoration: BoxDecoration(
            color: PillBinColors.primary,
            borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
            boxShadow: [
              BoxShadow(
                color: PillBinColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.dynamic_feed_rounded,
            color: Colors.white,
            size: isTablet ? sw * 0.035 : sw * 0.065,
          ),
        ),

        SizedBox(width: isTablet ? sw * 0.025 : sw * 0.035),

        // Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Community Feed',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.032 : sw * 0.05,
                  color: PillBinColors.textDark,
                ),
              ),
              SizedBox(height: sh * 0.003),
              Text(
                'Latest updates from the community',
                style: PillBinRegular.style(
                  fontSize: isTablet ? sw * 0.016 : sw * 0.026,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Notification Icon
        Container(
          padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
            border: Border.all(
              color: PillBinColors.greyLight,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: PillBinColors.textSecondary,
            size: isTablet ? sw * 0.025 : sw * 0.045,
          ),
        ),
      ],
    ),
  );
}

/// Blog Feed List Widget
/// Displays blogs in a vertical feed layout
class BlogFeedList extends StatelessWidget {
  final List<BlogModel> blogs;
  final double sw;
  final double sh;
  final bool isTablet;
  final Function(String blogId) onLikeTap;
  final Function(String blogId) onCommentTap;
  final Function(BlogModel blog) onBlogTap;
  final ScrollController? scrollController;

  const BlogFeedList({
    Key? key,
    required this.blogs,
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.onLikeTap,
    required this.onCommentTap,
    required this.onBlogTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blogs.isEmpty) {
      return BlogFeedEmptyState(sw: sw, sh: sh, isTablet: isTablet);
    }

    return ListView.builder(
      //controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.01,
      ),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return BlogFeedCard(
          blog: blogs[index],
          sw: sw,
          sh: sh,
          isTablet: isTablet,
          onLikeTap: () => onLikeTap(blogs[index].id),
          onCommentTap: () => onCommentTap(blogs[index].id),
          onTap: () => onBlogTap(blogs[index]),
        );
      },
    );
  }
}

/// Blog Feed Card Widget
/// Individual blog post card in feed view with swipeable images
class BlogFeedCard extends StatefulWidget {
  final BlogModel blog;
  final double sw;
  final double sh;
  final bool isTablet;
  final VoidCallback onLikeTap;
  final VoidCallback? onLikesCountTap;
  final VoidCallback onCommentTap;
  final VoidCallback onTap;

  const BlogFeedCard({
    Key? key,
    required this.blog,
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.onLikeTap,
    this.onLikesCountTap,
    required this.onCommentTap,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BlogFeedCard> createState() => _BlogFeedCardState();
}

class _BlogFeedCardState extends State<BlogFeedCard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentImageIndex = 0;
  bool _showLikeAnimation = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _likeScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() => _showLikeAnimation = true);
    _likeAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _likeAnimationController.reverse().then((_) {
            if (mounted) {
              setState(() => _showLikeAnimation = false);
            }
          });
        }
      });
    });
    widget.onLikeTap();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: widget.sh * 0.02),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(widget.isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          BlogFeedAuthorHeader(
            blog: widget.blog,
            sw: widget.sw,
            sh: widget.sh,
            isTablet: widget.isTablet,
          ),

          // Swipeable Images
          if (widget.blog.images.isNotEmpty)
            BlogFeedSwipeableImages(
              images: widget.blog.images,
              sw: widget.sw,
              sh: widget.sh,
              isTablet: widget.isTablet,
              pageController: _pageController,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              onDoubleTap: _handleDoubleTap,
              currentIndex: _currentImageIndex,
              showLikeAnimation: _showLikeAnimation,
              likeScaleAnimation: _likeScaleAnimation,
            ),

          // Content Section
          BlogFeedContent(
            blog: widget.blog,
            sw: widget.sw,
            sh: widget.sh,
            isTablet: widget.isTablet,
            onTap: widget.onTap,
          ),

          // Engagement Actions
          BlogFeedEngagementActions(
            blog: widget.blog,
            sw: widget.sw,
            sh: widget.sh,
            isTablet: widget.isTablet,
            onLikeTap: widget.onLikeTap,
            onLikesCountTap: widget.onLikesCountTap,
            onCommentTap: widget.onCommentTap,
          ),
        ],
      ),
    );
  }
}

/// Blog Feed Author Header Widget
/// Author info at the top of the card
class BlogFeedAuthorHeader extends StatelessWidget {
  final BlogModel blog;
  final double sw;
  final double sh;
  final bool isTablet;

  const BlogFeedAuthorHeader({
    Key? key,
    required this.blog,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.03),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isTablet ? sw * 0.05 : sw * 0.1,
            height: isTablet ? sw * 0.05 : sw * 0.1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  PillBinColors.primary,
                  PillBinColors.primary.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: PillBinColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                blog.author["email"].toString().split("@")[0][0].toUpperCase(),
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: sw * 0.025),

          // Author Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blog.author["email"].toString().split("@")[0],
                  style: PillBinBold.style(
                    fontSize: isTablet ? sw * 0.02 : sw * 0.038,
                    color: PillBinColors.textDark,
                  ),
                ),
                SizedBox(height: sh * 0.002),
                Text(
                  '${blog.role} • ${_getTimeAgo(blog.createdAt)}',
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.016 : sw * 0.03,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // More Icon
          Icon(
            Icons.more_horiz,
            color: PillBinColors.textSecondary,
            size: isTablet ? sw * 0.025 : sw * 0.05,
          ),
        ],
      ),
    );
  }
}

/// Blog Feed Swipeable Images Widget
/// PageView with image indicator and photo count badge
class BlogFeedSwipeableImages extends StatelessWidget {
  final List<BlogImage> images;
  final double sw;
  final double sh;
  final bool isTablet;
  final PageController pageController;
  final Function(int) onPageChanged;
  final VoidCallback onDoubleTap;
  final int currentIndex;
  final bool showLikeAnimation;
  final Animation<double> likeScaleAnimation;

  const BlogFeedSwipeableImages({
    Key? key,
    required this.images,
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.pageController,
    required this.onPageChanged,
    required this.onDoubleTap,
    required this.currentIndex,
    required this.showLikeAnimation,
    required this.likeScaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sh * 0.35,
      child: Stack(
        children: [
          // PageView for images
          GestureDetector(
            onDoubleTap: onDoubleTap,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: CachedNetworkImage(
                      imageUrl: images[index].url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: PillBinColors.greyLight,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: PillBinColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: PillBinColors.greyLight,
                        child: Icon(
                          Icons.image_not_supported,
                          color: PillBinColors.textLight,
                          size: isTablet ? sw * 0.06 : sw * 0.08,
                        ),
                      ),
                    ));
              },
            ),
          ),

          // Photo Count Badge (Top Right)
          if (images.length > 1)
            Positioned(
              top: isTablet ? sw * 0.02 : sw * 0.025,
              right: isTablet ? sw * 0.02 : sw * 0.025,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.015 : sw * 0.02,
                  vertical: isTablet ? sw * 0.008 : sw * 0.01,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.collections_rounded,
                      color: Colors.white,
                      size: isTablet ? sw * 0.02 : sw * 0.03,
                    ),
                    SizedBox(width: sw * 0.008),
                    Text(
                      '${currentIndex + 1}/${images.length}',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.028,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Page Indicators (Bottom Center)
          if (images.length > 1)
            Positioned(
              bottom: isTablet ? sw * 0.015 : sw * 0.02,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: currentIndex == index
                        ? isTablet
                            ? sw * 0.025
                            : sw * 0.035
                        : isTablet
                            ? sw * 0.01
                            : sw * 0.015,
                    height: isTablet ? sw * 0.01 : sw * 0.015,
                    margin: EdgeInsets.symmetric(horizontal: sw * 0.005),
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(isTablet ? 5 : 4),
                    ),
                  ),
                ),
              ),
            ),

          // Like Animation
          if (showLikeAnimation)
            Center(
              child: ScaleTransition(
                scale: likeScaleAnimation,
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: isTablet ? sw * 0.15 : sw * 0.25,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Blog Feed Content Widget
/// Displays experience badge, content, and type field
class BlogFeedContent extends StatelessWidget {
  final BlogModel blog;
  final double sw;
  final double sh;
  final bool isTablet;
  final VoidCallback onTap;

  const BlogFeedContent({
    Key? key,
    required this.blog,
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final span = TextSpan(
                  text: blog.content,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                    color: PillBinColors.textDark,
                  ),
                );
                final tp = TextPainter(
                  text: span,
                  maxLines: 3,
                  textDirection: TextDirection.ltr,
                );
                tp.layout(maxWidth: constraints.maxWidth);
                final overflows = tp.didExceedMaxLines;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.content,
                      style: PillBinRegular.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.034,
                        color: PillBinColors.textDark,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (overflows) ...[
                      SizedBox(height: sh * 0.008),
                      Text(
                        'Read more',
                        style: PillBinMedium.style(
                          fontSize: isTablet ? sw * 0.016 : sw * 0.03,
                          color: PillBinColors.primary,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Blog Feed Engagement Actions Widget
/// Like and comment buttons with counts
class BlogFeedEngagementActions extends StatelessWidget {
  final BlogModel blog;
  final double sw;
  final double sh;
  final bool isTablet;
  final VoidCallback onLikeTap;
  final VoidCallback? onLikesCountTap;
  final VoidCallback onCommentTap;

  const BlogFeedEngagementActions({
    Key? key,
    required this.blog,
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.onLikeTap,
    this.onLikesCountTap,
    required this.onCommentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isTablet ? sw * 0.025 : sw * 0.03,
        0,
        isTablet ? sw * 0.025 : sw * 0.03,
        isTablet ? sw * 0.025 : sw * 0.03,
      ),
      child: Row(
        children: [
          // Heart icon → toggle like
          GestureDetector(
            onTap: onLikeTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.015 : sw * 0.018,
                vertical: isTablet ? sw * 0.012 : sw * 0.015,
              ),
              decoration: BoxDecoration(
                color: blog.isLiked
                    ? PillBinColors.error.withOpacity(0.15)
                    : PillBinColors.error.withOpacity(0.07),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isTablet ? 12 : 10),
                  bottomLeft: Radius.circular(isTablet ? 12 : 10),
                ),
                border: Border.all(
                  color: blog.isLiked
                      ? PillBinColors.error.withOpacity(0.5)
                      : PillBinColors.error.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                blog.isLiked ? Icons.favorite : Icons.favorite_border,
                color: PillBinColors.error,
                size: isTablet ? sw * 0.022 : sw * 0.04,
              ),
            ),
          ),

          // Count label → open likers sheet
          GestureDetector(
            onTap: onLikesCountTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.015 : sw * 0.018,
                vertical: isTablet ? sw * 0.012 : sw * 0.015,
              ),
              decoration: BoxDecoration(
                color: blog.isLiked
                    ? PillBinColors.error.withOpacity(0.08)
                    : PillBinColors.error.withOpacity(0.04),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(isTablet ? 12 : 10),
                  bottomRight: Radius.circular(isTablet ? 12 : 10),
                ),
                border: Border(
                  top: BorderSide(
                    color: blog.isLiked
                        ? PillBinColors.error.withOpacity(0.5)
                        : PillBinColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                  right: BorderSide(
                    color: blog.isLiked
                        ? PillBinColors.error.withOpacity(0.5)
                        : PillBinColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: blog.isLiked
                        ? PillBinColors.error.withOpacity(0.5)
                        : PillBinColors.error.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                '${blog.likesCount} likes',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                  color: PillBinColors.error,
                ),
              ),
            ),
          ),

          SizedBox(width: sw * 0.025),

          // Comment Button
          GestureDetector(
            onTap: onCommentTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? sw * 0.02 : sw * 0.025,
                vertical: isTablet ? sw * 0.012 : sw * 0.015,
              ),
              decoration: BoxDecoration(
                color: PillBinColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                border: Border.all(
                  color: PillBinColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: PillBinColors.primary,
                    size: isTablet ? sw * 0.022 : sw * 0.04,
                  ),
                  SizedBox(width: sw * 0.01),
                  Text(
                    '${blog.commentsCount}',
                    style: PillBinMedium.style(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                      color: PillBinColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          // Share Button
          Container(
            padding: EdgeInsets.all(isTablet ? sw * 0.012 : sw * 0.015),
            decoration: BoxDecoration(
              color: PillBinColors.greyLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
            ),
            child: Icon(
              Icons.share_outlined,
              color: PillBinColors.textSecondary,
              size: isTablet ? sw * 0.022 : sw * 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

/// Blog Feed Empty State Widget
/// Displays when no blogs are available
class BlogFeedEmptyState extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const BlogFeedEmptyState({
    Key? key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dynamic_feed_outlined,
            size: isTablet ? sw * 0.1 : sw * 0.2,
            color: PillBinColors.textLight,
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No posts yet',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.028 : sw * 0.045,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Be the first to share something!',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.02 : sw * 0.035,
              color: PillBinColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
