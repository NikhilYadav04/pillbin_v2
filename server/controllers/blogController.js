// controllers/blog.controller.js

const Like = require("../models/like.js");
const Comment = require("../models/comment.js");
const {
  uploadImageService,
  deleteImageService,
} = require("../services/clopudinaryService.js");
const Blog = require("../models/blog.js");

class BlogController {
  async createBlog(req, res) {
    try {
      const { content, role, experience, phone, email, name } = req.body;
      const userId = req.user.id;

      let images = [];

      if (req.files && req.files.length > 0) {
        if (req.files.length > 2) {
          return res.status(400).json({
            statusCode: 400,
            success: false,
            message: "Maximum 2 images allowed",
          });
        }

        for (const file of req.files) {
          const result = await uploadImageService(file, `blogs/${userId}`);
          images.push({ url: result.secure_url, publicId: result.public_id });
        }
      }

      const blog = new Blog({
        author: userId,
        content,
        role,
        experience,
        phone,
        email,
        images,
        name,
      });

      await blog.save();

      const blogResponse = blog.toObject();
      blogResponse.author = { email };
      blogResponse.liked = false;

      res
        .status(201)
        .json({ statusCode: 201, success: true, data: blogResponse });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  async getBlog(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user?.id;

      const [blog, liked] = await Promise.all([
        Blog.findById(id).populate("author", "name email").lean(),
        userId ? Like.exists({ blog: id, user: userId }) : false,
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
        data: { ...blog, liked: !!liked },
      });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  async getAllBlogs(req, res) {
    try {
      const { page = 1, limit = 10 } = req.query;
      const userId = req.user?.id;
      const skip = (page - 1) * limit;

      const query = userId ? { author: { $ne: userId } } : {};

      const [blogs, total] = await Promise.all([
        Blog.find(query)
          .populate("author", "name email")
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(Number(limit))
          .lean(),
        Blog.countDocuments(query),
      ]);

      // Hydrate liked status for the requesting user in one query
      let likedSet = new Set();
      if (userId && blogs.length > 0) {
        const blogIds = blogs.map((b) => b._id);
        const userLikes = await Like.find({
          blog: { $in: blogIds },
          user: userId,
        })
          .select("blog")
          .lean();
        likedSet = new Set(userLikes.map((l) => l.blog.toString()));
      }

      const blogsWithLiked = blogs.map((b) => ({
        ...b,
        liked: likedSet.has(b._id.toString()),
      }));

      res.status(200).json({
        statusCode: 200,
        success: true,
        data: {
          blogs: blogsWithLiked,
          total,
          page: Number(page),
          pages: Math.ceil(total / limit),
          hasMore: skip + blogs.length < total,
        },
      });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  async getUserBlogs(req, res) {
    try {
      const userId = req.user?.id;
      const { page = 1, limit = 10 } = req.query;
      const skip = (page - 1) * limit;

      const [blogs, total] = await Promise.all([
        Blog.find({ author: userId })
          .populate("author", "name email")
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(Number(limit))
          .lean(),
        Blog.countDocuments({ author: userId }),
      ]);

      // User's own blogs are always "liked" by themselves if they liked them
      let likedSet = new Set();
      if (blogs.length > 0) {
        const blogIds = blogs.map((b) => b._id);
        const userLikes = await Like.find({
          blog: { $in: blogIds },
          user: userId,
        })
          .select("blog")
          .lean();
        likedSet = new Set(userLikes.map((l) => l.blog.toString()));
      }

      const blogsWithLiked = blogs.map((b) => ({
        ...b,
        liked: likedSet.has(b._id.toString()),
      }));

      res.status(200).json({
        statusCode: 200,
        success: true,
        data: {
          blogs: blogsWithLiked,
          total,
          page: Number(page),
          pages: Math.ceil(total / limit),
          hasMore: skip + blogs.length < total,
        },
      });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  async updateBlog(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;
      const updateData = req.body;

      const blog = await Blog.findById(id);

      if (!blog) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Blog not found",
        });
      }

      if (blog.author.toString() !== userId.toString()) {
        return res.status(403).json({
          statusCode: 403,
          success: false,
          message: "Unauthorized",
        });
      }

      Object.assign(blog, updateData);
      await blog.save();

      const blogResponse = blog.toObject();
      blogResponse.author = { email: blogResponse.email };

      res
        .status(200)
        .json({ statusCode: 200, success: true, data: blogResponse });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }

  async deleteBlog(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      const blog = await Blog.findById(id);

      if (!blog) {
        return res.status(404).json({
          statusCode: 404,
          success: false,
          message: "Blog not found",
        });
      }

      if (blog.author.toString() !== userId.toString()) {
        return res.status(403).json({
          statusCode: 403,
          success: false,
          message: "Unauthorized",
        });
      }

      if (blog.images.length > 0) {
        const publicIds = blog.images.map((m) => m.publicId).filter(Boolean);
        for (const pid of publicIds) {
          try {
            await deleteImageService(pid);
          } catch (err) {
            console.error("Cloudinary deletion error:", err);
          }
        }
      }

      //* Clean up associated likes and comments in parallel
      await Promise.all([
        Blog.findByIdAndDelete(id),
        Like.deleteMany({ blog: id }),
        Comment.deleteMany({ blog: id }),
      ]);

      res.status(200).json({
        statusCode: 200,
        success: true,
        message: "Blog deleted successfully",
      });
    } catch (error) {
      res
        .status(500)
        .json({ statusCode: 500, success: false, message: error.message });
    }
  }
}

module.exports = new BlogController();
