const Blog = require("../models/blog");
const Like = require("../models/like");

class LikeController {
  /**
   * POST /blogs/:id/likes
   * Toggle like on a blog. Returns the new like state and updated count.
   */
  async toggleLike(req, res) {
    try {
      const { id: blogId } = req.params;
      const userId = req.user.id;

      const blog = await Blog.findById(blogId).select("_id likesCount");
      if (!blog) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Blog not found",
        });
      }

      const existingLike = await Like.findOne({ blog: blogId, user: userId });

      let liked;
      if (existingLike) {
        // Unlike
        await existingLike.deleteOne();
        await Blog.findByIdAndUpdate(blogId, {
          $inc: { likesCount: -1 },
        });
        liked = false;
      } else {
        // Like
        await Like.create({ blog: blogId, user: userId });
        await Blog.findByIdAndUpdate(blogId, {
          $inc: { likesCount: 1 },
        });
        liked = true;
      }

      // Return fresh count
      const updated = await Blog.findById(blogId).select("likesCount");

      res.status(200).json({
        statusCode: 200,
        success: true,
        data: {
          liked,
          likesCount: updated.likesCount,
        },
      });
    } catch (error) {
      res.status(500).json({
        statusCode: 500,
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * GET /blogs/:id/likes/status
   * Check if the authenticated user has liked a specific blog.
   */
  async getLikeStatus(req, res) {
    try {
      const { id: blogId } = req.params;
      const userId = req.user.id;

      const [like, blog] = await Promise.all([
        Like.findOne({ blog: blogId, user: userId }).select("_id").lean(),
        Blog.findById(blogId).select("likesCount").lean(),
      ]);

      if (!blog) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Blog not found",
        });
      }

      res.status(200).json({
        statusCode: 200,
        success: true,
        data: {
          liked: !!like,
          likesCount: blog.likesCount,
        },
      });
    } catch (error) {
      res.status(500).json({
        statusCode: 500,
        success: false,
        message: error.message,
      });
    }
  }

  /**
   * GET /blogs/:id/likes
   * Paginated list of users who liked a blog.
   */
  async getBlogLikers(req, res) {
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

      const [likes, total] = await Promise.all([
        Like.find({ blog: blogId })
          .populate("user", "fullName email")
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(Number(limit))
          .lean(),
        Like.countDocuments({ blog: blogId }),
      ]);

      res.status(200).json({
        statusCode: 200,
        success: true,
        data: {
          likers: likes.map((l) => l.user),
          total,
          page: Number(page),
          pages: Math.ceil(total / limit),
          hasMore: skip + likes.length < total,
        },
      });
    } catch (error) {
      res.status(500).json({
        statusCode: 500,
        success: false,
        message: error.message,
      });
    }
  }
}

module.exports = new LikeController();
