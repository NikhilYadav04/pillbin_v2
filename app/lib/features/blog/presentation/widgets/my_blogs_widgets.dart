import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/blog/data/repository/blog_provider.dart';
import 'package:pillbin/features/blog/presentation/pages/comment_sheet.dart';
import 'package:pillbin/features/blog/presentation/pages/like_sheet.dart';
import 'package:pillbin/network/models/blog_model.dart';
import 'package:provider/provider.dart';

/// Displays blogs in a 3-column grid layout
class BlogGrid extends StatelessWidget {
  final List<BlogModel> blogs;
  final double sw;
  final double sh;
  final bool isTablet;
  final Function(BlogModel) onBlogTap;
  final ScrollController? scrollController;

  const BlogGrid({
    Key? key,
    required this.blogs,
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.onBlogTap,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (blogs.isEmpty) {
      return BlogEmptyState(sw: sw, sh: sh, isTablet: isTablet);
    }

    return GridView.builder(
      // controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.05 : sw * 0.04,
        vertical: sh * 0.01,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: isTablet ? sw * 0.02 : sw * 0.02,
        mainAxisSpacing: isTablet ? sw * 0.02 : sw * 0.02,
        childAspectRatio: 0.75,
      ),
      itemCount: blogs.length,
      itemBuilder: (context, index) {
        return BlogCard(
          blog: blogs[index],
          sw: sw,
          sh: sh,
          isTablet: isTablet,
          onTap: () => onBlogTap(blogs[index]),
        );
      },
    );
  }
}

/// Blog Card Widget
/// Individual blog post card with image, overlay, and metadata
class BlogCard extends StatelessWidget {
  final BlogModel blog;
  final double sw;
  final double sh;
  final bool isTablet;
  final VoidCallback onTap;

  const BlogCard({
    Key? key,
    required this.blog,
    required this.sw,
    required this.sh,
    required this.isTablet,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String previewImage = blog.images.isNotEmpty
        ? blog.images.first.url
        : 'https://via.placeholder.com/300';

    final String contentPreview = blog.content.length > 50
        ? '${blog.content.substring(0, 50)}...'
        : blog.content;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              BlogCardImage(imageUrl: previewImage, sw: sw, isTablet: isTablet),

              // Photo Count Badge (Top Right)
              if (blog.images.length > 1)
                BlogPhotoCountBadge(
                  count: blog.images.length,
                  sw: sw,
                  isTablet: isTablet,
                ),

              // Bottom Gradient Overlay with Content
              BlogCardOverlay(
                blog: blog,
                contentPreview: contentPreview,
                sw: sw,
                sh: sh,
                isTablet: isTablet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blog Card Image Widget
/// Displays the blog's preview image with error handling
class BlogCardImage extends StatelessWidget {
  final String imageUrl;
  final double sw;
  final bool isTablet;

  const BlogCardImage({
    Key? key,
    required this.imageUrl,
    required this.sw,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
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
    );
  }
}

/// Blog Photo Count Badge Widget
/// Shows the number of images in the blog post
class BlogPhotoCountBadge extends StatelessWidget {
  final int count;
  final double sw;
  final bool isTablet;

  const BlogPhotoCountBadge({
    Key? key,
    required this.count,
    required this.sw,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isTablet ? sw * 0.015 : sw * 0.02,
      right: isTablet ? sw * 0.015 : sw * 0.02,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? sw * 0.01 : sw * 0.015,
          vertical: isTablet ? sw * 0.005 : sw * 0.008,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.collections,
              color: Colors.white,
              size: isTablet ? sw * 0.018 : sw * 0.025,
            ),
            SizedBox(width: sw * 0.005),
            Text(
              '$count',
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.016 : sw * 0.022,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Blog Card Overlay Widget
/// Bottom gradient overlay with author info, content, and engagement stats
class BlogCardOverlay extends StatelessWidget {
  final BlogModel blog;
  final String contentPreview;
  final double sw;
  final double sh;
  final bool isTablet;
  final bool showDeleteOption;

  const BlogCardOverlay({
    Key? key,
    required this.blog,
    required this.contentPreview,
    required this.sw,
    required this.sh,
    required this.isTablet,
    this.showDeleteOption = true,
  }) : super(key: key);

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: PillBinColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: PillBinColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PillBinColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: PillBinColors.error,
                  size: isTablet ? sw * 0.025 : sw * 0.05,
                ),
              ),
              SizedBox(width: sw * 0.02),
              Text(
                'Delete Post',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.022 : sw * 0.045,
                  color: PillBinColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
            style: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.018 : sw * 0.035,
              color: PillBinColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.035,
                  color: PillBinColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await context.read<BlogProvider>().deleteBlog(
                      context: context,
                      blogId: blog.id,
                    );
              },
              style: TextButton.styleFrom(
                backgroundColor: PillBinColors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Delete',
                style: PillBinMedium.style(
                  fontSize: isTablet ? sw * 0.018 : sw * 0.035,
                  color: PillBinColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        padding: EdgeInsets.all(isTablet ? sw * 0.015 : sw * 0.02),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author Info Row + Delete Button
            Row(
              children: [
                Expanded(
                  child: BlogAuthorRow(
                    author: (blog.name?.isEmpty ?? true)
                        ? blog.author["email"].toString().split("@")[0]
                        : blog.name!,
                    sw: sw,
                    isTablet: isTablet,
                  ),
                ),
                if (showDeleteOption) ...[
                  SizedBox(width: sw * 0.02),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: isTablet ? sw * 0.018 : sw * 0.038,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: sh * 0.005),
            Text(
              contentPreview,
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.012 : sw * 0.02,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: sh * 0.005),
            BlogEngagementRow(
              likesCount: blog.likesCount,
              commentsCount: blog.commentsCount,
              isLiked: blog.isLiked,
              sw: sw,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }
}

/// Blog Author Row Widget
/// Displays author avatar and name
class BlogAuthorRow extends StatelessWidget {
  final String author;
  final double sw;
  final bool isTablet;

  const BlogAuthorRow({
    Key? key,
    required this.author,
    required this.sw,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isTablet ? sw * 0.025 : sw * 0.045,
          height: isTablet ? sw * 0.025 : sw * 0.045,
          decoration: BoxDecoration(
            color: PillBinColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              author[0].toUpperCase(),
              style: PillBinBold.style(
                fontSize: isTablet ? sw * 0.012 : sw * 0.022,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: sw * 0.01),
        Expanded(
          child: Text(
            author,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.014 : sw * 0.025,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Blog Engagement Row Widget
/// Displays likes and comments count
class BlogEngagementRow extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final double sw;
  final bool isTablet;

  const BlogEngagementRow({
    Key? key,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.sw,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? PillBinColors.error : Colors.white.withOpacity(0.8),
          size: isTablet ? sw * 0.015 : sw * 0.025,
        ),
        SizedBox(width: sw * 0.005),
        Text(
          '$likesCount',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.012 : sw * 0.02,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(width: sw * 0.02),
        Icon(
          Icons.comment_outlined,
          color: Colors.white.withOpacity(0.8),
          size: isTablet ? sw * 0.015 : sw * 0.025,
        ),
        SizedBox(width: sw * 0.005),
        Text(
          '$commentsCount',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.012 : sw * 0.02,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

/// Blog Empty State Widget
/// Displays when no blogs are found
class BlogEmptyState extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const BlogEmptyState({
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
            Icons.article_outlined,
            size: isTablet ? sw * 0.08 : sw * 0.15,
            color: PillBinColors.textLight,
          ),
          SizedBox(height: sh * 0.02),
          Text(
            'No blogs found',
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.025 : sw * 0.04,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.01),
          Text(
            'Try adjusting your search',
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

/// Blog Details Modal Widget
/// Full blog post details in a bottom sheet
class BlogDetailsModal extends StatelessWidget {
  final BlogModel blog;

  const BlogDetailsModal({Key? key, required this.blog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Container(
      height: sh * 0.85,
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 24 : 20),
          topRight: Radius.circular(isTablet ? 24 : 20),
        ),
      ),
      child: Column(
        children: [
          BlogModalHandle(sw: sw, sh: sh),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? sw * 0.05 : sw * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlogDetailsAuthorInfo(
                      blog: blog, sw: sw, sh: sh, isTablet: isTablet),
                  SizedBox(height: sh * 0.02),

                  if (blog.images.isNotEmpty) ...[
                    BlogDetailsImageCarousel(
                        images: blog.images, sw: sw, sh: sh),
                    SizedBox(height: sh * 0.02),
                  ],
                  BlogDetailsContent(
                      content: blog.content, sw: sw, isTablet: isTablet),
                  SizedBox(height: sh * 0.02),

                  Consumer<BlogProvider>(
                    builder: (context, provider, _) {
                      final liveBlog = provider.userBlogs
                              .where((b) => b.id == blog.id)
                              .followedBy(
                                  provider.allBlogs.where((b) => b.id == blog.id))
                              .firstOrNull ??
                          blog;
                      return BlogDetailsEngagement(
                        blogId: blog.id,
                        likesCount: liveBlog.likesCount,
                        commentsCount: liveBlog.commentsCount,
                        isLiked: liveBlog.isLiked,
                        sw: sw,
                        isTablet: isTablet,
                      );
                    },
                  ),

                  SizedBox(height: sh * 0.02),

                  BlogDetailsMetaInfo(
                      blog: blog, sw: sw, sh: sh, isTablet: isTablet),
                  SizedBox(height: sh * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlogDetailsMetaInfo extends StatelessWidget {
  final BlogModel blog;
  final double sw, sh;
  final bool isTablet;

  const BlogDetailsMetaInfo({
    Key? key,
    required this.blog,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = <_MetaEntry>[
      _MetaEntry(Icons.work_outline_rounded, 'Role', blog.role),
      if (blog.experience?.isNotEmpty == true)
        _MetaEntry(Icons.timeline_rounded, 'Experience', blog.experience!),
      if (blog.phone?.isNotEmpty == true)
        _MetaEntry(Icons.phone_outlined, 'Phone', blog.phone!),
      if (blog.email?.isNotEmpty == true)
        _MetaEntry(Icons.email_outlined, 'Email', blog.email!),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isTablet ? sw * 0.03 : sw * 0.035),
      decoration: BoxDecoration(
        color: PillBinColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: PillBinColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MetaRow(item: items[i], sw: sw, sh: sh, isTablet: isTablet),
            if (i < items.length - 1) ...[
              SizedBox(height: sh * 0.012),
              Divider(color: PillBinColors.greyLight, height: 1),
              SizedBox(height: sh * 0.012),
            ],
          ],
        ],
      ),
    );
  }
}

class _MetaEntry {
  final IconData icon;
  final String label, value;
  const _MetaEntry(this.icon, this.label, this.value);
}

class _MetaRow extends StatelessWidget {
  final _MetaEntry item;
  final double sw, sh;
  final bool isTablet;

  const _MetaRow(
      {Key? key,
      required this.item,
      required this.sw,
      required this.sh,
      required this.isTablet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon,
            size: isTablet ? sw * 0.022 : sw * 0.04,
            color: PillBinColors.primary),
        SizedBox(width: sw * 0.025),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.label,
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.016 : sw * 0.028,
                    color: PillBinColors.textSecondary,
                  )),
              SizedBox(height: sh * 0.003),
              Text(item.value,
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                    color: PillBinColors.textDark,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

/// Blog Modal Handle Widget
/// Draggable handle for bottom sheet
class BlogModalHandle extends StatelessWidget {
  final double sw;
  final double sh;

  const BlogModalHandle({
    Key? key,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: sh * 0.015),
      width: sw * 0.12,
      height: 4,
      decoration: BoxDecoration(
        color: PillBinColors.greyLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Blog Details Author Info Widget
/// Author profile section in details modal
class BlogDetailsAuthorInfo extends StatelessWidget {
  final BlogModel blog;
  final double sw;
  final double sh;
  final bool isTablet;

  const BlogDetailsAuthorInfo({
    Key? key,
    required this.blog,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: isTablet ? sw * 0.06 : sw * 0.1,
          height: isTablet ? sw * 0.06 : sw * 0.1,
          decoration: BoxDecoration(
            color: PillBinColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              (blog.name?.trim().isEmpty ?? true)
                  ? blog.author["email"]
                      .toString()
                      .split("@")[0]
                      .substring(0, 1)
                      .toUpperCase()
                  : blog.name!.trim().substring(0, 1).toUpperCase(),
              style: PillBinBold.style(
                fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (blog.name?.isEmpty ?? true)
                        ? blog.author["email"].toString().split("@")[0]
                        : blog.name!,
                    style: PillBinBold.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.04,
                      color: PillBinColors.textDark,
                    ),
                  ),
                  Text(
                    blog.role,
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/update-blog-post-screen',
                      arguments: {
                        'transition': TransitionType.fade,
                        'duration': 300,
                        'blog': blog
                      },
                    );
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Colors.black,
                    size: sh * 0.025,
                  ))
            ],
          ),
        ),
      ],
    );
  }
}

/// Displays the title and blog count with enhanced styling
Widget buildBlogHeader({
  required double sw,
  required double sh,
  required bool isTablet,
  required int blogCount,
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
            Icons.article_rounded,
            color: Colors.white,
            size: isTablet ? sw * 0.035 : sw * 0.065,
          ),
        ),

        SizedBox(width: isTablet ? sw * 0.025 : sw * 0.035),

        // Title and Count
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My Blogs',
                style: PillBinBold.style(
                  fontSize: isTablet ? sw * 0.032 : sw * 0.048,
                  color: PillBinColors.textDark,
                ),
              ),
              SizedBox(height: sh * 0.008),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.015 : sw * 0.02,
                      vertical: isTablet ? sh * 0.004 : sh * 0.003,
                    ),
                    decoration: BoxDecoration(
                      color: PillBinColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                    ),
                    child: Text(
                      '$blogCount ${blogCount == 1 ? 'post' : 'posts'}',
                      style: PillBinMedium.style(
                        fontSize: isTablet ? sw * 0.018 : sw * 0.028,
                        color: PillBinColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: sw * 0.015),
                ],
              ),
            ],
          ),
        ),

        // Action Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                Icons.filter_list_rounded,
                color: PillBinColors.textSecondary,
                size: isTablet ? sw * 0.025 : sw * 0.045,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Blog Search Bar Widget
/// Displays search input with clear functionality
class BlogSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final double sw;
  final double sh;
  final bool isTablet;

  const BlogSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.sw,
    required this.sh,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isTablet ? sw * 0.05 : sw * 0.04),
      child: Container(
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
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search blogs...',
            hintStyle: PillBinRegular.style(
              fontSize: isTablet ? sw * 0.022 : sw * 0.035,
              color: PillBinColors.textLight,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: PillBinColors.textSecondary,
              size: isTablet ? sw * 0.025 : sw * 0.05,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.clear,
                      color: PillBinColors.textSecondary,
                      size: isTablet ? sw * 0.025 : sw * 0.05,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
          ),
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.022 : sw * 0.035,
            color: PillBinColors.textDark,
          ),
        ),
      ),
    );
  }
}

/// Blog Details Image Carousel Widget
/// Horizontal scrollable image gallery
class BlogDetailsImageCarousel extends StatelessWidget {
  final List<BlogImage> images;
  final double sw;
  final double sh;

  const BlogDetailsImageCarousel({
    Key? key,
    required this.images,
    required this.sw,
    required this.sh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sh * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: sw * 0.7,
            margin: EdgeInsets.only(right: sw * 0.03),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
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
                      size: sw * 0.08,
                    ),
                  ),
                )),
          );
        },
      ),
    );
  }
}

/// Blog Details Content Widget
/// Main blog content text
class BlogDetailsContent extends StatelessWidget {
  final String content;
  final double sw;
  final bool isTablet;

  const BlogDetailsContent({
    Key? key,
    required this.content,
    required this.sw,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: PillBinRegular.style(
        fontSize: isTablet ? sw * 0.02 : sw * 0.035,
        color: PillBinColors.textDark,
      ),
    );
  }
}

class BlogDetailsEngagement extends StatelessWidget {
  final String blogId;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final double sw;
  final bool isTablet;

  const BlogDetailsEngagement({
    Key? key,
    required this.blogId,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.sw,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.read<BlogProvider>().toggleLike(
                context: context,
                blogId: blogId,
              ),
          onLongPress: () async {
            await context.read<BlogProvider>().fetchBlogLikers(
                  context: context,
                  blogId: blogId,
                );
            if (context.mounted) showLikesSheet(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? sw * 0.025 : sw * 0.03,
              vertical: isTablet ? sw * 0.015 : sw * 0.02,
            ),
            decoration: BoxDecoration(
              color: isLiked
                  ? PillBinColors.error.withOpacity(0.12)
                  : PillBinColors.greyLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              border: isLiked
                  ? Border.all(
                      color: PillBinColors.error.withOpacity(0.4), width: 1)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked
                      ? PillBinColors.error
                      : PillBinColors.textSecondary,
                  size: isTablet ? sw * 0.022 : sw * 0.04,
                ),
                SizedBox(width: sw * 0.01),
                Text(
                  '$likesCount',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                    color: isLiked
                        ? PillBinColors.error
                        : PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: sw * 0.03),
        GestureDetector(
          onTap: () async {
            await context.read<BlogProvider>().fetchComments(
                  context: context,
                  blogId: blogId,
                );
            if (context.mounted) showCommentsSheet(context, blogId: blogId);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? sw * 0.025 : sw * 0.03,
              vertical: isTablet ? sw * 0.015 : sw * 0.02,
            ),
            decoration: BoxDecoration(
              color: PillBinColors.greyLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.comment_outlined,
                  color: PillBinColors.textSecondary,
                  size: isTablet ? sw * 0.022 : sw * 0.04,
                ),
                SizedBox(width: sw * 0.01),
                Text(
                  '$commentsCount',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.018 : sw * 0.032,
                    color: PillBinColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Blog Engagement Button Widget
/// Individual engagement button (like/comment)
class BlogEngagementButton extends StatelessWidget {
  final IconData icon;
  final String count;
  final double sw;
  final bool isTablet;

  const BlogEngagementButton({
    Key? key,
    required this.icon,
    required this.count,
    required this.sw,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? sw * 0.025 : sw * 0.03,
        vertical: isTablet ? sw * 0.015 : sw * 0.02,
      ),
      decoration: BoxDecoration(
        color: PillBinColors.greyLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: PillBinColors.textSecondary,
            size: isTablet ? sw * 0.022 : sw * 0.04,
          ),
          SizedBox(width: sw * 0.01),
          Text(
            count,
            style: PillBinMedium.style(
              fontSize: isTablet ? sw * 0.018 : sw * 0.032,
              color: PillBinColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
