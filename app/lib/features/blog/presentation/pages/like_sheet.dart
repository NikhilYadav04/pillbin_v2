import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/blog/data/model/stats_model.dart';
import 'package:pillbin/features/blog/data/repository/blog_provider.dart';
import 'package:pillbin/features/blog/presentation/widgets/bottom_card_helpers.dart';
import 'package:provider/provider.dart';

String _initials(String email, String name) {
  if (name.isNotEmpty) return name[0].toUpperCase();
  return email.split('@')[0][0].toUpperCase();
}

String _displayName(String email, String name) {
  if (name.isNotEmpty) return name;
  return email.split('@')[0];
}

void showLikesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<BlogProvider>(),
      child: const LikesBottomSheet(),
    ),
  );
}

class LikesBottomSheet extends StatelessWidget {
  const LikesBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BlogProvider>(
      builder: (context, provider, _) {
        final likes = provider.blogLikers;
        final isLoading = provider.isLikersLoading;

        return BottomSheetScaffold(
          title: 'Liked by',
          countLabel: isLoading
              ? '...'
              : likes.isEmpty
                  ? '0 likes'
                  : '${likes.length} like${likes.length == 1 ? '' : 's'}',
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : likes.isEmpty
                  ? _LikesEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: likes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 0),
                      itemBuilder: (context, index) =>
                          _LikeTile(like: likes[index], index: index),
                    ),
        );
      },
    );
  }
}

class _LikeTile extends StatelessWidget {
  final LikeModel like;
  final int index;

  const _LikeTile({required this.like, required this.index});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final String initials = _initials(like.email, like.fullName);
    final String displayName = _displayName(like.email, like.fullName);

    final List<List<Color>> gradients = [
      [PillBinColors.primary, PillBinColors.primary.withOpacity(0.6)],
      [PillBinColors.success, PillBinColors.success.withOpacity(0.6)],
      [PillBinColors.error, PillBinColors.error.withOpacity(0.6)],
      [Colors.deepPurple, Colors.deepPurple.withOpacity(0.6)],
      [Colors.teal, Colors.teal.withOpacity(0.6)],
    ];
    final gradient = gradients[index % gradients.length];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.05,
        vertical: sh * 0.008,
      ),
      child: Row(
        children: [
          Container(
            width: sw * 0.11,
            height: sw * 0.11,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: PillBinBold.style(
                  fontSize: sw * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: PillBinBold.style(
                    fontSize: sw * 0.037,
                    color: PillBinColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  like.email,
                  style: PillBinRegular.style(
                    fontSize: sw * 0.03,
                    color: PillBinColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: PillBinColors.error,
                size: sw * 0.045,
              ),
              const SizedBox(height: 2),
              Text(
                timeAgo(like.createdAt),
                style: PillBinRegular.style(
                  fontSize: sw * 0.028,
                  color: PillBinColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LikesEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: sw * 0.18,
            color: PillBinColors.greyLight,
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'No likes yet',
            style: PillBinMedium.style(
              fontSize: sw * 0.042,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.006),
          Text(
            'Be the first to show some love!',
            style: PillBinRegular.style(
              fontSize: sw * 0.032,
              color: PillBinColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
