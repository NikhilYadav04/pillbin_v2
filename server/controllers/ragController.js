const HealthRAG = require("../models/rag.js");
const {
  createRAGDocument,
  deleteRAGById,
  clearRAGHistory,
  fetchRAGDocuments,
} = require("../services/ragService.js");

//* Create RAG Document
const createRAG = async (req, res) => {
  try {
    const userId = req.user.id;

    const { pdfName, pdfDescription, queries } = req.body;

    //* count for rag docs limit
    const docs = await HealthRAG.find({ userId })
      .limit(10)
      .select("_id")
      .lean();

    if (docs.length >= 10) {
      return res.status(429).json({
        statusCode: 429,
        success: false,
        message:
          "You’ve reached the maximum saved document limit (10 documents).",
      });
    }

    const result = await createRAGDocument({
      userId,
      pdfName,
      pdfDescription,
      queries,
    });

    return res.status(201).json({
      statusCode: 201,
      success: true,
      message: "RAG Document created successfully",
      data: result,
    });
  } catch (error) {
    return res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to create RAG Document",
      error: error.message,
    });
  }
};

//* Delete specific RAG Document
const deleteRAG = async (req, res) => {
  try {
    const userId = req.user.id;
    const ragId = req.params.id;

    const deleted = await deleteRAGById(ragId, userId);

    if (!deleted) {
      return res.status(404).json({
        statusCode: 404,
        message: "RAG Document not found",
      });
    }

    return res.status(200).json({
      statusCode: 200,
      success: true,
      message: "RAG Document deleted successfully",
    });
  } catch (error) {
    return res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to delete RAG Document",
      error: error.message,
    });
  }
};

//* Clear all RAG history
const clearRAGHistoryAll = async (req, res) => {
  try {
    const userId = req.user.id;

    const deletedCount = await clearRAGHistory(userId);

    return res.status(200).json({
      statusCode: 200,
      success: true,
      message: "RAG history cleared",
      data: {
        count: deletedCount.toString(),
      },
    });
  } catch (error) {
    return res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to clear RAG history",
      error: error.message,
    });
  }
};

//* Fetch RAG Documents
const fetchRAGs = async (req, res) => {
  try {
    const userId = req.user.id;
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 10;

    const result = await fetchRAGDocuments({
      userId,
      page,
      limit,
    });

    return res.status(200).json({
      statusCode: 200,
      success: true,
      data: result,
    });
  } catch (error) {
    console.log(error);
    return res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to fetch RAG documents",
      error: error.message,
    });
  }
};

module.exports = {
  createRAG,
  deleteRAG,
  clearRAGHistoryAll,
  fetchRAGs,
};
