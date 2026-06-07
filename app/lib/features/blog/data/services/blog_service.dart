import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pillbin/network/models/api_response.dart';
import 'package:pillbin/network/services/api_service.dart';
import 'package:pillbin/network/utils/api_endpoint.dart';

class BlogServices extends ApiService {
  //* Create Blog (without images)
  Future<ApiResponse<Map<String, dynamic>>> createBlog({
    required String content,
    required String role,
    required String experience,
    required String phone,
    required String email,
    required String name,
  }) async {
    return post(
      ApiEndpoints.createBlog,
      data: {
        "content": content,
        "role": role,
        "experience": experience,
        "phone": phone,
        "email": email,
        "name": name,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Create Blog (with images - FormData)
  Future<ApiResponse<Map<String, dynamic>>> createBlogWithImages({
    required String content,
    required String role,
    required String experience,
    required String phone,
    required String email,
    required String name,
    required List<File> images,
  }) async {
    if (images.length > 2) {
      throw Exception("Maximum 2 images allowed");
    }

    FormData formData = FormData.fromMap({
      "content": content,
      "role": role,
      "experience": experience,
      "phone": phone,
      "email": email,
      "name": name,
    });

    for (final image in images) {
      formData.files.add(MapEntry(
        "media",
        await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      ));
    }

    return post(
      ApiEndpoints.createBlog,
      data: formData,
      fromJson: (data) => data as Map<String, dynamic>,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  //* Get All Blogs (excluding user's own)
  Future<ApiResponse<Map<String, dynamic>>> getAllBlogs({
    int page = 1,
    int limit = 10,
  }) async {
    return get(
      ApiEndpoints.getAllBlogs(page: page, limit: limit),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Get User's Blogs
  Future<ApiResponse<Map<String, dynamic>>> getUserBlogs({
    int page = 1,
    int limit = 10,
  }) async {
    return get(
      ApiEndpoints.getUserBlogs(page: page, limit: limit),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Get Single Blog
  Future<ApiResponse<Map<String, dynamic>>> getBlog({
    required String blogId,
  }) async {
    return get(
      ApiEndpoints.getBlog(blogId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Update Blog
  Future<ApiResponse<Map<String, dynamic>>> updateBlog({
    required String blogId,
    String? content,
    String? role,
    String? experience,
    String? phone,
    String? email,
  }) async {
    final Map<String, dynamic> updateData = {
      if (content != null) "content": content,
      if (role != null) "role": role,
      if (experience != null) "experience": experience,
      if (phone != null) "phone": phone,
      if (email != null) "email": email,
    };

    return put(
      ApiEndpoints.updateBlog(blogId),
      data: updateData,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Delete Blog
  Future<ApiResponse<Map<String, dynamic>>> deleteBlog({
    required String blogId,
  }) async {
    return delete(
      ApiEndpoints.deleteBlog(blogId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Generate AI Image
  Future<ApiResponse<Map<String, dynamic>>> generateImage({
    required String query,
  }) async {
    return get(
      ApiEndpoints.generateBlogImage(query: query),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ─── Likes ─────────────────────────────────────────────────────────────────

  //* Toggle Like (like / unlike)
  Future<ApiResponse<Map<String, dynamic>>> toggleLike({
    required String blogId,
  }) async {
    return post(
      ApiEndpoints.toggleLike(blogId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Get Like Status + Count for current user
  Future<ApiResponse<Map<String, dynamic>>> getLikeStatus({
    required String blogId,
  }) async {
    return get(
      ApiEndpoints.getLikeStatus(blogId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Get Paginated List of Users Who Liked a Blog
  Future<ApiResponse<Map<String, dynamic>>> getBlogLikers({
    required String blogId,
    int page = 1,
    int limit = 20,
  }) async {
    return get(
      ApiEndpoints.getBlogLikers(blogId, page: page, limit: limit),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  // ─── Comments ──────────────────────────────────────────────────────────────

  //* Add a Comment
  Future<ApiResponse<Map<String, dynamic>>> addComment({
    required String blogId,
    required String content,
  }) async {
    return post(
      ApiEndpoints.addComment(blogId),
      data: {"content": content},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Get Paginated Comments for a Blog
  Future<ApiResponse<Map<String, dynamic>>> getBlogComments({
    required String blogId,
    int page = 1,
    int limit = 20,
  }) async {
    return get(
      ApiEndpoints.getBlogComments(blogId, page: page, limit: limit),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Edit a Comment
  Future<ApiResponse<Map<String, dynamic>>> updateComment({
    required String blogId,
    required String commentId,
    required String content,
  }) async {
    return put(
      ApiEndpoints.updateComment(blogId, commentId),
      data: {"content": content},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  //* Delete a Comment
  Future<ApiResponse<Map<String, dynamic>>> deleteComment({
    required String blogId,
    required String commentId,
  }) async {
    return delete(
      ApiEndpoints.deleteComment(blogId, commentId),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
