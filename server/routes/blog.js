// routes/blog.routes.js
const express = require("express");
const router = express.Router();

const imageGenerationController = require("../services/imageGeneration");

const { authenticateToken: authMiddleware } = require("../middleware/auth");
const { upload } = require("../middleware/multer");
const blogController = require("../controllers/blogController");
const likeController = require("../controllers/likeController");
const commentController = require("../controllers/commentController");

// ─── Blog CRUD ────────────────────────────────────────────────────────────────

router.post(
  "/",
  authMiddleware,
  upload.array("media", 2),
  blogController.createBlog
);

router.get("/user", authMiddleware, blogController.getUserBlogs);
router.get("/", authMiddleware, blogController.getAllBlogs);
router.get("/:id", authMiddleware, blogController.getBlog);
router.put("/:id", authMiddleware, blogController.updateBlog);
router.delete("/:id", authMiddleware, blogController.deleteBlog);

// ─── Image Generation ────────────────────────────────────────────────────────

router.get(
  "/generate/image",
  authMiddleware,
  imageGenerationController.generateImage
);

// ─── Likes ───────────────────────────────────────────────────────────────────

router.post("/:id/likes", authMiddleware, likeController.toggleLike);

router.get("/:id/likes/status", authMiddleware, likeController.getLikeStatus);

router.get("/:id/likes", authMiddleware, likeController.getBlogLikers);

// ─── Comments ────────────────────────────────────────────────────────────────

router.post("/:id/comments", authMiddleware, commentController.addComment);
router.get("/:id/comments", authMiddleware, commentController.getBlogComments);
router.put(
  "/:id/comments/:commentId",
  authMiddleware,
  commentController.updateComment
);
router.delete(
  "/:id/comments/:commentId",
  authMiddleware,
  commentController.deleteComment
);

module.exports = router;
