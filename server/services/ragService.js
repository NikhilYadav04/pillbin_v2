const HealthRAG = require("../models/rag.js");

//* Create new RAG Document
const createRAGDocument = async (data) => {
  const { userId, pdfName, pdfDescription, queries = [] } = data;
  return await HealthRAG.create({ userId, pdfName, pdfDescription, queries });
};

//* Delete specific RAG Document
const deleteRAGById = async (ragId, userId) => {
  return await HealthRAG.findOneAndDelete({ _id: ragId, userId });
};

//* Clear all RAG history
const clearRAGHistory = async (userId) => {
  const result = await HealthRAG.deleteMany({ userId });
  return result.deletedCount;
};

//* Fetch RAG Documents
const fetchRAGDocuments = async ({ userId, page = 1, limit = 10 }) => {
  const skip = (page - 1) * limit;

  const docs = await HealthRAG.find({ userId })
    .sort({ uploadedAt: -1 })
    .skip(skip)
    .limit(limit);

  const total = await HealthRAG.countDocuments({ userId });

  return {
    data: docs,
    pagination: {
      page,
      limit,
      total,
      hasMore: skip + docs.length < total,
    },
  };
};

module.exports = {
  createRAGDocument,
  deleteRAGById,
  clearRAGHistory,
  fetchRAGDocuments,
};
