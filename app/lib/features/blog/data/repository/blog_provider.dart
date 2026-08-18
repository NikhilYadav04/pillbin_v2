import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pillbin/config/cache/cache_manager.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/blog/data/model/stats_model.dart';
import 'package:pillbin/features/blog/data/services/blog_service.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/models/blog_model.dart';
import 'package:pillbin/network/utils/http_client.dart';

class BlogProvider extends ChangeNotifier {
  //* ─── State ─────────────────────────────────────────────────────────────────

  //* List of Blogs
  List<BlogModel> _allBlogs = [];
  List<BlogModel> get allBlogs => _allBlogs;

  List<BlogModel> _userBlogs = [];
  List<BlogModel> get userBlogs => _userBlogs;

  BlogModel? _selectedBlog;
  BlogModel? get selectedBlog => _selectedBlog;

  String? _generatedImageUrl;
  String? get generatedImageUrl => _generatedImageUrl;

  final CacheManager _cacheManager = CacheManager();
  final HttpClient _httpClient = HttpClient();

  //* Pagination variables for all blogs
  int _allBlogsPage = 1;
  bool _allBlogsHasMore = true;
  bool get allBlogsHasMore => _allBlogsHasMore;

  //* Pagination variables for user blogs
  int _userBlogsPage = 1;
  bool _userBlogsHasMore = true;
  bool get userBlogsHasMore => _userBlogsHasMore;

  //* Loading states — now fully separated per list
  bool _isLoading = false; // generic (create/update/delete/getBlog)
  bool get isLoading => _isLoading;

  bool _isAllBlogsLoading = false;
  bool get isAllBlogsLoading => _isAllBlogsLoading;

  bool _isAllBlogsLoadingMore = false;
  bool get isAllBlogsLoadingMore => _isAllBlogsLoadingMore;

  bool _isUserBlogsLoading = false;
  bool get isUserBlogsLoading => _isUserBlogsLoading;

  bool _isUserBlogsLoadingMore = false;
  bool get isUserBlogsLoadingMore => _isUserBlogsLoadingMore;

  bool _isGeneratingImage = false;
  bool get isGeneratingImage => _isGeneratingImage;

  List<CommentModel> _blogComments = [];
  List<CommentModel> get blogComments => _blogComments;
  bool _isCommentsLoading = false;
  bool get isCommentsLoading => _isCommentsLoading;
  bool _isCommentsLoadingMore = false;
  bool get isCommentsLoadingMore => _isCommentsLoadingMore;
  int _commentsPage = 1;
  bool _commentsHasMore = true;
  bool get commentsHasMore => _commentsHasMore;

  List<LikeModel> _blogLikers = [];
  List<LikeModel> get blogLikers => _blogLikers;
  bool _isLikersLoading = false;
  bool get isLikersLoading => _isLikersLoading;

  //* ─── Blogs ─────────────────────────────────────────────────────────────────

  //* Services
  final BlogServices _blogService = BlogServices();

  //* Create Blog (without images)
  Future<String> createBlog(
      {required BuildContext context,
      required String content,
      required String role,
      required String experience,
      required String phone,
      required String email,
      required String name}) async {
    try {
      _isLoading = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _blogService.createBlog(
              content: content,
              role: role,
              experience: experience,
              phone: phone,
              email: email,
              name: name);

      if (response.statusCode == 201) {
        Logger().d(response.data);
        Map<String, dynamic> blogData = response.data!;

        BlogModel blog = BlogModel.fromJson(blogData);
        _userBlogs.insert(0, blog);

        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.check_circle,
            title: "Blog created successfully",
          );
        }

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: response.message,
          );
        }
        return 'error';
      } else {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to create blog. Please try again later.",
          );
        }
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Unable to create blog. Please try again later.",
        );
      }

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Create Blog (with images)
  Future<String> createBlogWithImages({
    required BuildContext context,
    required String content,
    required String role,
    required String experience,
    required String phone,
    required String email,
    required String name,
    required List<File> images,
  }) async {
    try {
      if (images.length > 2) {
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Maximum 2 images allowed",
          );
        }
        return 'error';
      }

      _isLoading = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _blogService.createBlogWithImages(
              content: content,
              role: role,
              experience: experience,
              phone: phone,
              email: email,
              images: images,
              name: name);

      if (response.statusCode == 201) {
        Logger().d(response);
        Map<String, dynamic> blogData = response.data!;

        BlogModel blog = BlogModel.fromJson(blogData);
        _userBlogs.insert(0, blog);

        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.check_circle,
            title: "Blog created successfully",
          );
        }

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: response.message,
          );
        }
        return 'error';
      } else {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to create blog. Please try again later.",
          );
        }
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Unable to create blog. Please try again later.",
        );
      }

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Get Single Blog
  Future<String> getBlog({
    required BuildContext context,
    required String blogId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response = await _blogService.getBlog(
        blogId: blogId,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> blogData = response.data!;
        _selectedBlog = BlogModel.fromJson(blogData);

        _isLoading = false;
        notifyListeners();

        return 'success';
      } else if (response.statusCode == 404) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Blog not found",
          );
        }
        return 'error';
      } else {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to fetch blog. Please try again later.",
          );
        }
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Fetch All Blogs (with pagination)
  Future<String> fetchAllBlogs({
    required BuildContext context,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        if (!_allBlogsHasMore || _isAllBlogsLoadingMore) return 'success';
        _isAllBlogsLoadingMore = true;
        _allBlogsPage++;
      } else {
        _isAllBlogsLoading = true;
        _allBlogsPage = 1;
        _allBlogsHasMore = true;
      }
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      // Try cache first (only for initial load, not pagination)
      if (!forceRefresh &&
          !loadMore &&
          (!isOnline || await _cacheManager.hasValidBlogsCache())) {
        final cachedData = await _cacheManager.getCachedBlogs();

        if (cachedData != null) {
          _allBlogs =
              cachedData.map((element) => BlogModel.fromJson(element)).toList();

          _isAllBlogsLoading = false;
          notifyListeners();

          if (!isOnline && context.mounted) {
            CustomSnackBar.show(
              context: context,
              icon: Icons.cloud_off,
              title: "Offline - Showing cached data",
            );
          }

          return 'success';
        }
      }

      if (isOnline || forceRefresh) {
        ApiResponse<Map<String, dynamic>> response =
            await _blogService.getAllBlogs(
          page: _allBlogsPage,
          limit: 12,
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = response.data!;

          List<BlogModel> blogsData = (responseData['blogs'] as List<dynamic>)
              .map((element) => BlogModel.fromJson(element))
              .toList();

          _allBlogsHasMore = responseData['hasMore'] as bool;

          if (loadMore) {
            _allBlogs.addAll(blogsData);
            _isAllBlogsLoadingMore = false;
          } else {
            _allBlogs = blogsData;
            if (_allBlogsPage == 1) {
              await _cacheManager.cacheBlogs(responseData['blogs']);
            }
            _isAllBlogsLoading = false;
          }

          notifyListeners();
          return 'success';
        } else {
          if (loadMore) {
            _allBlogsPage--;
            _isAllBlogsLoadingMore = false;
          } else {
            _isAllBlogsLoading = false;
          }
          notifyListeners();
          return 'error';
        }
      } else {
        if (loadMore) {
          _allBlogsPage--;
          _isAllBlogsLoadingMore = false;
        } else {
          _isAllBlogsLoading = false;
        }
        notifyListeners();

        if (!loadMore && context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.cloud_off,
            title: "No internet connection",
          );
        }
        return 'error';
      }
    } catch (e) {
      if (loadMore) {
        _allBlogsPage--;
        _isAllBlogsLoadingMore = false;
      } else {
        _isAllBlogsLoading = false;
      }
      notifyListeners();

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Fetch User Blogs (with pagination)
  Future<String> fetchUserBlogs({
    required BuildContext context,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        if (!_userBlogsHasMore || _isUserBlogsLoadingMore) return 'success';
        _isUserBlogsLoadingMore = true;
        _userBlogsPage++;
      } else {
        _isUserBlogsLoading = true;
        _userBlogsPage = 1;
        _userBlogsHasMore = true;
      }
      notifyListeners();

      final isOnline = _httpClient.isOnline;

      // Try cache first (only for initial load, not pagination)
      if (!forceRefresh &&
          !loadMore &&
          (!isOnline || await _cacheManager.hasValidUserBlogsCache())) {
        final cachedData = await _cacheManager.getCachedUserBlogs();

        if (cachedData != null) {
          _userBlogs =
              cachedData.map((element) => BlogModel.fromJson(element)).toList();

          _isUserBlogsLoading = false;
          notifyListeners();

          if (!isOnline && context.mounted) {
            CustomSnackBar.show(
              context: context,
              icon: Icons.cloud_off,
              title: "Offline - Showing cached data",
            );
          }

          return 'success';
        }
      }

      if (isOnline || forceRefresh) {
        ApiResponse<Map<String, dynamic>> response =
            await _blogService.getUserBlogs(
          page: _userBlogsPage,
          limit: 10,
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> responseData = response.data!;

          Logger().d(responseData["blogs"]);

          List<BlogModel> blogsData = (responseData['blogs'] as List<dynamic>)
              .map((element) => BlogModel.fromJson(element))
              .toList();

          _userBlogsHasMore = responseData['hasMore'] as bool;

          if (loadMore) {
            _userBlogs.addAll(blogsData);
            _isUserBlogsLoadingMore = false;
          } else {
            _userBlogs = blogsData;
            if (_userBlogsPage == 1) {
              await _cacheManager.cacheUserBlogs(responseData['blogs']);
            }
            _isUserBlogsLoading = false;
          }

          notifyListeners();
          return 'success';
        } else {
          if (loadMore) {
            _userBlogsPage--;
            _isUserBlogsLoadingMore = false;
          } else {
            _isUserBlogsLoading = false;
          }
          notifyListeners();
          return 'error';
        }
      } else {
        if (loadMore) {
          _userBlogsPage--;
          _isUserBlogsLoadingMore = false;
        } else {
          _isUserBlogsLoading = false;
        }
        notifyListeners();

        if (!loadMore && context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.cloud_off,
            title: "No internet connection",
          );
        }
        return 'error';
      }
    } catch (e) {
      if (loadMore) {
        _userBlogsPage--;
        _isUserBlogsLoadingMore = false;
      } else {
        _isUserBlogsLoading = false;
      }
      notifyListeners();

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Update Blog
  Future<String> updateBlog({
    required BuildContext context,
    required String blogId,
    String? content,
    String? role,
    String? experience,
    String? phone,
    String? email,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _blogService.updateBlog(
        blogId: blogId,
        content: content,
        role: role,
        experience: experience,
        phone: phone,
        email: email,
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> blogData = response.data!;
        BlogModel updatedBlog = BlogModel.fromJson(blogData);

        int userIndex = _userBlogs.indexWhere((b) => b.id == blogId);
        if (userIndex != -1) _userBlogs[userIndex] = updatedBlog;

        int allIndex = _allBlogs.indexWhere((b) => b.id == blogId);
        if (allIndex != -1) _allBlogs[allIndex] = updatedBlog;

        if (_selectedBlog?.id == blogId) _selectedBlog = updatedBlog;

        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.check_circle,
            title: "Blog updated successfully",
          );
        }

        return 'success';
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: response.message,
          );
        }
        return 'error';
      } else if (response.statusCode == 403) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unauthorized to update this blog",
          );
        }
        return 'error';
      } else {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to update blog. Please try again later.",
          );
        }
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Unable to update blog. Please try again later.",
        );
      }

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Delete Blog
  Future<String> deleteBlog({
    required BuildContext context,
    required String blogId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.check_circle,
          title: "Deleting Blog..........",
        );
      }

      ApiResponse<Map<String, dynamic>> response =
          await _blogService.deleteBlog(
        blogId: blogId,
      );

      if (response.statusCode == 200) {
        _userBlogs.removeWhere((b) => b.id == blogId);
        _allBlogs.removeWhere((b) => b.id == blogId);

        if (_selectedBlog?.id == blogId) _selectedBlog = null;

        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.check_circle,
            title: "Blog deleted successfully",
          );
        }

        return 'success';
      } else if (response.statusCode == 404) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Blog not found",
          );
        }
        return 'error';
      } else if (response.statusCode == 403) {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unauthorized to delete this blog",
          );
        }
        return 'error';
      } else {
        _isLoading = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to delete blog. Please try again later.",
          );
        }
        return 'error';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Unable to delete blog. Please try again later.",
        );
      }

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Generate AI Image
  Future<String> generateBlogImage({
    required BuildContext context,
    required String query,
  }) async {
    try {
      _isGeneratingImage = true;
      _generatedImageUrl = null;
      notifyListeners();

      ApiResponse<Map<String, dynamic>> response =
          await _blogService.generateImage(
        query: query,
      );

      if (response.statusCode == 200) {
        _generatedImageUrl = response.data!['imageUrl'] as String?;

        _isGeneratingImage = false;
        notifyListeners();

        if (_generatedImageUrl != null) {
          if (context.mounted) {
            CustomSnackBar.show(
              context: context,
              icon: Icons.check_circle,
              title: "Image generated successfully",
            );
          }
          return 'success';
        } else {
          if (context.mounted) {
            CustomSnackBar.show(
              context: context,
              icon: Icons.error,
              title: "Unable to generate image",
            );
          }
          return 'error';
        }
      } else {
        _isGeneratingImage = false;
        notifyListeners();

        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to generate image. Please try again later.",
          );
        }
        return 'error';
      }
    } catch (e) {
      _isGeneratingImage = false;
      notifyListeners();

      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Unable to generate image. Please try again later.",
        );
      }

      Logger().e(e.toString());
      return 'error';
    }
  }

  //* Clear generated image
  void clearGeneratedImage() {
    _generatedImageUrl = null;
    notifyListeners();
  }

  //* ─── Likes ─────────────────────────────────────────────────────────────────

  Future<void> toggleLike({
    required BuildContext context,
    required String blogId,
  }) async {
    final allIdx = _allBlogs.indexWhere((b) => b.id == blogId);
    final userIdx = _userBlogs.indexWhere((b) => b.id == blogId);

    final current = allIdx != -1
        ? _allBlogs[allIdx]
        : userIdx != -1
            ? _userBlogs[userIdx]
            : null;
    if (current == null) return;

    final optimistic = current.copyWith(
      isLiked: !current.isLiked,
      likesCount:
          current.isLiked ? current.likesCount - 1 : current.likesCount + 1,
    );
    if (allIdx != -1) _allBlogs[allIdx] = optimistic;
    if (userIdx != -1) _userBlogs[userIdx] = optimistic;
    if (_selectedBlog?.id == blogId) _selectedBlog = optimistic;
    notifyListeners();

    try {
      final response = await _blogService.toggleLike(blogId: blogId);
      if (response.statusCode != 200) {
        if (allIdx != -1) _allBlogs[allIdx] = current;
        if (userIdx != -1) _userBlogs[userIdx] = current;
        if (_selectedBlog?.id == blogId) _selectedBlog = current;
        notifyListeners();
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Failed to update like. Please try again.",
          );
        }
      }
    } catch (e) {
      if (allIdx != -1) _allBlogs[allIdx] = current;
      if (userIdx != -1) _userBlogs[userIdx] = current;
      if (_selectedBlog?.id == blogId) _selectedBlog = current;
      notifyListeners();
      Logger().e(e.toString());
    }
  }

  Future<void> fetchBlogLikers({
    required BuildContext context,
    required String blogId,
  }) async {
    try {
      _isLikersLoading = true;
      _blogLikers = [];
      notifyListeners();

      final response = await _blogService.getBlogLikers(blogId: blogId);

      if (response.statusCode == 200) {
        _blogLikers = (response.data!['likers'] as List)
            .map((e) => LikeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Unable to fetch likers.",
        );
      }
    } catch (e) {
      Logger().e(e.toString());
    } finally {
      _isLikersLoading = false;
      notifyListeners();
    }
  }

  //* ─── Comments ─────────────────────────────────────────────────────────────────

  Future<void> fetchComments({
    required BuildContext context,
    required String blogId,
    bool loadMore = false,
  }) async {
    try {
      if (loadMore) {
        if (!_commentsHasMore || _isCommentsLoadingMore) return;
        _isCommentsLoadingMore = true;
        _commentsPage++;
      } else {
        _isCommentsLoading = true;
        _commentsPage = 1;
        _commentsHasMore = true;
        _blogComments = [];
      }
      notifyListeners();

      final response = await _blogService.getBlogComments(
        blogId: blogId,
        page: _commentsPage,
        limit: 20,
      );

      if (response.statusCode == 200) {
        final incoming = (response.data!['comments'] as List)
            .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _commentsHasMore = response.data!['hasMore'] as bool;
        loadMore ? _blogComments.addAll(incoming) : _blogComments = incoming;
      } else {
        if (loadMore) _commentsPage--;
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to fetch comments.",
          );
        }
      }
    } catch (e) {
      if (loadMore) _commentsPage--;
      Logger().e(e.toString());
    } finally {
      _isCommentsLoading = false;
      _isCommentsLoadingMore = false;
      notifyListeners();
    }
  }

  Future<String> addComment({
    required BuildContext context,
    required String blogId,
    required String content,
  }) async {
    try {
      final response =
          await _blogService.addComment(blogId: blogId, content: content);

      if (response.statusCode == 201) {
        _blogComments.insert(0, CommentModel.fromJson(response.data!));
        _updateCommentsCount(blogId, 1);
        notifyListeners();
        return 'success';
      } else {
        if (context.mounted) {
          CustomSnackBar.show(
              context: context, icon: Icons.error, title: response.message);
        }
        return 'error';
      }
    } catch (e) {
      Logger().e(e.toString());
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error,
          title: "Unable to post comment. Please try again.",
        );
      }
      return 'error';
    }
  }

  Future<String> deleteComment({
    required BuildContext context,
    required String blogId,
    required String commentId,
  }) async {
    try {
      final response = await _blogService.deleteComment(
          blogId: blogId, commentId: commentId);

      if (response.statusCode == 200) {
        _blogComments.removeWhere((c) => c.id == commentId);
        _updateCommentsCount(blogId, -1);
        notifyListeners();
        return 'success';
      } else if (response.statusCode == 403) {
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "You can only delete your own comments.",
          );
        }
        return 'error';
      } else {
        if (context.mounted) {
          CustomSnackBar.show(
            context: context,
            icon: Icons.error,
            title: "Unable to delete comment. Please try again.",
          );
        }
        return 'error';
      }
    } catch (e) {
      Logger().e(e.toString());
      return 'error';
    }
  }

  //* ─── Helpers ───────────────────────────────────────────────────────────────

  void _updateCommentsCount(String blogId, int delta) {
    final allIdx = _allBlogs.indexWhere((b) => b.id == blogId);
    if (allIdx != -1) {
      _allBlogs[allIdx] = _allBlogs[allIdx]
          .copyWith(commentsCount: _allBlogs[allIdx].commentsCount + delta);
    }
    final userIdx = _userBlogs.indexWhere((b) => b.id == blogId);
    if (userIdx != -1) {
      _userBlogs[userIdx] = _userBlogs[userIdx]
          .copyWith(commentsCount: _userBlogs[userIdx].commentsCount + delta);
    }
    if (_selectedBlog?.id == blogId) {
      _selectedBlog = _selectedBlog!
          .copyWith(commentsCount: _selectedBlog!.commentsCount + delta);
    }
  }

  //* ─── Unified Clear ─────────────────────────────────────────────────────────

  Future<void> reset() async {
    _allBlogs.clear();
    _userBlogs.clear();
    _selectedBlog = null;
    _generatedImageUrl = null;
    _blogComments = [];
    _blogLikers = [];
    _isLoading = false;
    _isAllBlogsLoading = false;
    _isAllBlogsLoadingMore = false;
    _isUserBlogsLoading = false;
    _isUserBlogsLoadingMore = false;
    _isGeneratingImage = false;
    _isCommentsLoading = false;
    _isCommentsLoadingMore = false;
    _isLikersLoading = false;
    _allBlogsPage = 1;
    _allBlogsHasMore = true;
    _userBlogsPage = 1;
    _userBlogsHasMore = true;
    _commentsPage = 1;
    _commentsHasMore = true;
    notifyListeners();
  }
}
