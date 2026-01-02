const chat = require("../models/chat");

//* add message
const addMessage = async (data) => {
  //* Batch insert
  if (Array.isArray(data)) {
    return await chat.insertMany(
      data.map(({ userId, message, isUser }) => ({
        userId,
        message,
        isUser,
      }))
    );
  }

  const { userId, message, isUser } = data;
  return await chat.create({ userId, message, isUser });
};

//* delete message
const deleteMessageById = async (messageId, userId) => {
  const deleted = await chat.findOneAndDelete({
    _id: messageId,
    userId,
  });

  return deleted;
};

//* clear history
const clearHistory = async (userId) => {
  const result = await chat.deleteMany({ userId });
  return result.deletedCount;
};

//* fetch message
const fetchMessages = async ({ userId, page = 1, limit = 20 }) => {
  const skip = (page - 1) * limit;

  const messages = await chat
    .find({ userId })
    .sort({ timestamp: -1 })
    .skip(skip)
    .limit(limit);

  const total = await chat.countDocuments({ userId });

  return {
    data: messages,
    pagination: {
      page,
      limit,
      total,
      hasMore: skip + messages.length < total,
    },
  };
};

module.exports = {
  addMessage,
  deleteMessageById,
  clearHistory,
  fetchMessages,
};
