// controllers/comment.controller.js
const Comment = require("../models/comment.js");
const Blog = require("../models/blog.js");

class CommentController {
  /**
   * POST /blogs/:id/comments
   * Body: { content }
   */
  async addComment(req, res) {
    try {
      const { id: blogId } = req.params;
      const userId = req.user.id;
      const { content } = req.body;

      if (!content || !content.trim()) {
        return res.status(400).json({
          statusCode: 400,
          success: false,
          message: "Comment content is required",
        });
      }

      const blog = await Blog.findById(blogId).select("_id");
      if (!blog) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Blog not found",
        });
      }

      const comment = await Comment.create({
        blog: blogId,
        author: userId,
        content: content.trim(),
      });

      await Blog.findByIdAndUpdate(blogId, { $inc: { commentsCount: 1 } });

      const populated = await comment.populate("author", "name email");

      res.status(201).json({ statusCode: 201, success: true, data: populated });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  /**
   * GET /blogs/:id/comments
   * Query: { page, limit }
   */
  async getBlogComments(req, res) {
    try {
      const { id: blogId } = req.params;
      const { page = 1, limit = 20 } = req.query;
      const skip = (page - 1) * limit;

      const blogExists = await Blog.exists({ _id: blogId });
      if (!blogExists) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Blog not found",
        });
      }

      const query = { blog: blogId };

      const [comments, total] = await Promise.all([
        Comment.find(query)
          .populate("author", "name email")
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(Number(limit))
          .lean(),
        Comment.countDocuments(query),
      ]);

      res.status(200).json({
        statusCode: 200,
        success: true,
        data: {
          comments,
          total,
          page: Number(page),
          pages: Math.ceil(total / limit),
          hasMore: skip + comments.length < total,
        },
      });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  /**
   * PUT /blogs/:id/comments/:commentId
   * Edit your own comment.
   */
  async updateComment(req, res) {
    try {
      const { commentId } = req.params;
      const userId = req.user.id;
      const { content } = req.body;

      if (!content || !content.trim()) {
        return res.status(400).json({
          statusCode: 400,
          success: false,
          message: "Comment content is required",
        });
      }

      const comment = await Comment.findOne({ _id: commentId });

      if (!comment) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Comment not found",
        });
      }

      if (comment.author.toString() !== userId.toString()) {
        return res
          .status(403)
          .json({ statusCode: 403, success: false, message: "Unauthorized" });
      }

      comment.content = content.trim();
      await comment.save();

      const populated = await comment.populate("author", "name email");

      res.status(200).json({ statusCode: 200, success: true, data: populated });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  /**
   * DELETE /blogs/:id/comments/:commentId
   * Soft-delete (author only). Decrements blog commentsCount.
   */
  async deleteComment(req, res) {
    try {
      const { id: blogId, commentId } = req.params;
      const userId = req.user.id;

      const comment = await Comment.findOne({ _id: commentId, blog: blogId });

      if (!comment) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Comment not found",
        });
      }

      if (comment.author.toString() !== userId.toString()) {
        return res
          .status(403)
          .json({ statusCode: 403, success: false, message: "Unauthorized" });
      }

      await Promise.all([
        comment.deleteOne(),
        Blog.findByIdAndUpdate(blogId, { $inc: { commentsCount: -1 } }),
      ]);

      res.status(200).json({
        statusCode: 200,
        success: true,
        message: "Comment deleted successfully",
      });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }
}

module.exports = new CommentController();
