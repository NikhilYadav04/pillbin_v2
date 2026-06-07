import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
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

void showCommentsSheet(BuildContext context, {required String blogId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<BlogProvider>(),
      child: CommentsBottomSheet(blogId: blogId),
    ),
  );
}

class CommentsBottomSheet extends StatefulWidget {
  final String blogId;

  const CommentsBottomSheet({Key? key, required this.blogId}) : super(key: key);

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final provider = context.read<BlogProvider>();
      if (provider.commentsHasMore && !provider.isCommentsLoadingMore) {
        provider.fetchComments(
          context: context,
          blogId: widget.blogId,
          loadMore: true,
        );
      }
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await context.read<BlogProvider>().addComment(
            context: context,
            blogId: widget.blogId,
            content: text,
          );
      _controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Consumer<BlogProvider>(
        builder: (context, provider, _) {
          final comments = provider.blogComments;
          final isLoading = provider.isCommentsLoading;

          return BottomSheetScaffold(
            title: 'Comments',
            countLabel: isLoading
                ? '...'
                : comments.isEmpty
                    ? '0 comments'
                    : '${comments.length} comment${comments.length == 1 ? '' : 's'}',
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? _CommentsEmptyState()
                    : ListView.separated(
                        controller: _scrollController,
                        padding:
                            const EdgeInsets.only(top: 8, bottom: 12),
                        itemCount: comments.length +
                            (provider.isCommentsLoadingMore ? 1 : 0),
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: sw * 0.18,
                          endIndent: sw * 0.05,
                          color:
                              PillBinColors.greyLight.withOpacity(0.4),
                        ),
                        itemBuilder: (context, index) {
                          if (index == comments.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: sh * 0.015),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: PillBinColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          return _CommentTile(
                            comment: comments[index],
                            index: index,
                            blogId: widget.blogId,
                          );
                        },
                      ),
            footer: _CommentInputBar(
              controller: _controller,
              isSending: _isSending,
              onSubmit: _submit,
              sw: sw,
              sh: sh,
            ),
          );
        },
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final dynamic comment;
  final int index;
  final String blogId;

  const _CommentTile(
      {required this.comment, required this.index, required this.blogId});

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final String initials =
        _initials(comment.author.email, comment.author.name);
    final String displayName =
        _displayName(comment.author.email, comment.author.name);

    final List<List<Color>> gradients = [
      [PillBinColors.primary, PillBinColors.primary.withOpacity(0.6)],
      [PillBinColors.success, PillBinColors.success.withOpacity(0.6)],
      [Colors.deepOrange, Colors.deepOrange.withOpacity(0.6)],
      [Colors.indigo, Colors.indigo.withOpacity(0.6)],
      [Colors.teal, Colors.teal.withOpacity(0.6)],
    ];
    final gradient = gradients[index % gradients.length];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sw * 0.05,
        vertical: sh * 0.01,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: sw * 0.1,
            height: sw * 0.1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: PillBinBold.style(
                  fontSize: sw * 0.036,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: sw * 0.03),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayName,
                      style: PillBinBold.style(
                        fontSize: sw * 0.034,
                        color: PillBinColors.textDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeAgo(comment.createdAt),
                      style: PillBinRegular.style(
                        fontSize: sw * 0.028,
                        color: PillBinColors.textLight,
                      ),
                    ),
                    SizedBox(width: sw * 0.02),
                    GestureDetector(
                      onTap: () async {
                        await context.read<BlogProvider>().deleteComment(
                              context: context,
                              blogId: blogId,
                              commentId: comment.id,
                            );
                      },
                      child: Icon(
                        Icons.delete_outline,
                        size: sw * 0.038,
                        color: PillBinColors.textLight,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: sh * 0.005),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sw * 0.035,
                    vertical: sh * 0.009,
                  ),
                  decoration: BoxDecoration(
                    color: PillBinColors.background,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: PillBinColors.greyLight.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    comment.content,
                    style: PillBinRegular.style(
                      fontSize: sw * 0.033,
                      color: PillBinColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSubmit;
  final double sw;
  final double sh;

  const _CommentInputBar({
    required this.controller,
    required this.isSending,
    required this.onSubmit,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        sw * 0.04,
        sh * 0.012,
        sw * 0.04,
        sh * 0.016,
      ),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        border: Border(
          top: BorderSide(
            color: PillBinColors.greyLight.withOpacity(0.5),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: PillBinColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: PillBinColors.greyLight,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                style: PillBinRegular.style(
                  fontSize: sw * 0.035,
                  color: PillBinColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a comment…',
                  hintStyle: PillBinRegular.style(
                    fontSize: sw * 0.034,
                    color: PillBinColors.textLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: sw * 0.04,
                    vertical: sh * 0.01,
                  ),
                ),
                onSubmitted: (_) => onSubmit(),
              ),
            ),
          ),

          SizedBox(width: sw * 0.025),

          GestureDetector(
            onTap: isSending ? null : onSubmit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: sw * 0.11,
              height: sw * 0.11,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSending
                      ? [
                          PillBinColors.primary.withOpacity(0.4),
                          PillBinColors.primary.withOpacity(0.3),
                        ]
                      : [
                          PillBinColors.primary,
                          PillBinColors.primary.withOpacity(0.8),
                        ],
                ),
                shape: BoxShape.circle,
                boxShadow: isSending
                    ? []
                    : [
                        BoxShadow(
                          color: PillBinColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: sw * 0.045,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: sw * 0.18,
            color: PillBinColors.greyLight,
          ),
          SizedBox(height: sh * 0.015),
          Text(
            'No comments yet',
            style: PillBinMedium.style(
              fontSize: sw * 0.042,
              color: PillBinColors.textSecondary,
            ),
          ),
          SizedBox(height: sh * 0.006),
          Text(
            'Start the conversation!',
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
