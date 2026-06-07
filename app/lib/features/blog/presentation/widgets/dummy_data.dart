// // ─── Dummy Data ─────────────────────────────────────────────────────────────

// import 'package:pillbin/features/blog/data/model/stats_model.dart';

// final List<LikeModel> dummyLikes = [
//   LikeModel(
//     id: 'like_001',
//     blogId: 'blog_abc',
//     user: LikeAuthor(
//       id: 'u1',
//       name: 'Priya Sharma',
//       email: 'priya.sharma@gmail.com',
//     ),
//     createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
//   ),
//   LikeModel(
//     id: 'like_002',
//     blogId: 'blog_abc',
//     user: LikeAuthor(
//       id: 'u2',
//       name: 'Rahul Mehta',
//       email: 'rahul.mehta@outlook.com',
//     ),
//     createdAt: DateTime.now().subtract(const Duration(hours: 1)),
//   ),
//   LikeModel(
//     id: 'like_003',
//     blogId: 'blog_abc',
//     user: LikeAuthor(
//       id: 'u3',
//       name: '',
//       email: 'doctor.ananya@pillbin.health',
//     ),
//     createdAt: DateTime.now().subtract(const Duration(hours: 3)),
//   ),
//   LikeModel(
//     id: 'like_004',
//     blogId: 'blog_abc',
//     user: LikeAuthor(
//       id: 'u4',
//       name: 'Karan Joshi',
//       email: 'karan.j@yahoo.com',
//     ),
//     createdAt: DateTime.now().subtract(const Duration(days: 1)),
//   ),
//   LikeModel(
//     id: 'like_005',
//     blogId: 'blog_abc',
//     user: LikeAuthor(
//       id: 'u5',
//       name: 'Sneha Patil',
//       email: 'sneha.patil@gmail.com',
//     ),
//     createdAt: DateTime.now().subtract(const Duration(days: 2)),
//   ),
//   LikeModel(
//     id: 'like_006',
//     blogId: 'blog_abc',
//     user: LikeAuthor(
//       id: 'u6',
//       name: 'Arjun Nair',
//       email: 'arjun.nair@pillbin.health',
//     ),
//     createdAt: DateTime.now().subtract(const Duration(days: 3)),
//   ),
// ];

// final List<CommentModel> dummyComments = [
//   CommentModel(
//     id: 'cmt_001',
//     blogId: 'blog_abc',
//     author: CommentAuthor(
//       id: 'u2',
//       name: 'Rahul Mehta',
//       email: 'rahul.mehta@outlook.com',
//     ),
//     content:
//         'Really helpful post! I had no idea about these medication interactions. Thanks for sharing.',
//     createdAt: DateTime.now().subtract(const Duration(hours: 2)),
//     updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
//   ),
//   CommentModel(
//     id: 'cmt_002',
//     blogId: 'blog_abc',
//     author: CommentAuthor(
//       id: 'u3',
//       name: '',
//       email: 'doctor.ananya@pillbin.health',
//     ),
//     content:
//         'As a healthcare professional, I can confirm this is accurate. Always consult your doctor before making changes.',
//     createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
//     updatedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
//   ),
//   CommentModel(
//     id: 'cmt_003',
//     blogId: 'blog_abc',
//     author: CommentAuthor(
//       id: 'u4',
//       name: 'Karan Joshi',
//       email: 'karan.j@yahoo.com',
//     ),
//     content: 'Bookmarked this. Very well written!',
//     createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
//     updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
//   ),
//   CommentModel(
//     id: 'cmt_004',
//     blogId: 'blog_abc',
//     author: CommentAuthor(
//       id: 'u1',
//       name: 'Priya Sharma',
//       email: 'priya.sharma@gmail.com',
//     ),
//     content:
//         'Could you write a follow-up about managing side effects? Would love to read more.',
//     createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
//     updatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
//   ),
//   CommentModel(
//     id: 'cmt_005',
//     blogId: 'blog_abc',
//     author: CommentAuthor(
//       id: 'u5',
//       name: 'Sneha Patil',
//       email: 'sneha.patil@gmail.com',
//     ),
//     content: 'Shared this with my family. Everyone should know about this!',
//     createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
//     updatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
//   ),
// ];
