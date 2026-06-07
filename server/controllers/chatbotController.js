const express = require("express");
const { GoogleGenAI } = require("@google/genai");
const dotenv = require("dotenv");
const {
  clearHistory,
  fetchMessages,
  addMessage,
  deleteMessageById,
} = require("../services/chatService");
const chat = require("../models/chat.js");
const { test } = require("./userController.js");

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const API = new GoogleGenAI({ apiKey: GEMINI_API_KEY });

const query = async (req, res) => {
  try {
    const { prompt, input } = req.body;

    if (!prompt || typeof prompt !== "string") {
      return res.status(400).json({
        success: false,
        message: "Prompt must be a non-empty string",
      });
    }

    const userId = req.user.id;

    //* count for user messages limit
    const docs = await chat.find({ userId }).limit(101).select("_id").lean();

    if (docs.length >= 100) {
      return res.status(429).json({
        statusCode: 429,
        success: false,
        message: "You’ve reached the maximum chat limit (100 messages).",
      });
    }

    const contents = [
      {
        role: "user",
        parts: [{ text: prompt }],
      },
    ];

    const response = await API.models.generateContent({
      model: "gemini-2.5-flash",
      contents,
      generationConfig: {
        maxOutputTokens: 80,
        temperature: 0.2,
      },
    });

    const aiText = response?.candidates?.[0]?.content?.parts?.[0]?.text?.trim();

    if (!aiText) {
      return res.status(500).json({
        success: false,
        statusCode: 500,
        message: "AI did not return a valid response",
      });
    }

    //* Batch DB write (2)
    await addMessage([
      { userId: userId, message: input, isUser: true },
      { userId: userId, message: aiText, isUser: false },
    ]);

    //* Send minimal response
    return res.status(200).json({
      statusCode: 200,
      success: true,
      data: {
        reply: aiText,
      },
    });
  } catch (err) {
    console.error("Query Error:", err);

    return res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Internal server error",
    });
  }
};

// //* add message
// const addMessageChat = async (req, res) => {
//   try {
//     const userId = req.user.id;
//     const { message, isUser } = req.body;

//     if (!message) {
//       return res
//         .status(400)
//         .json({ message: "Message is required", statusCode: 400 });
//     }

//     const count = await chat.countDocuments({ userId });

//     if (count > 100) {
//       return res.status(429).json({
//         statusCode: 429,
//         success: true,
//         message: "You’ve reached the maximum chat limit (100 messages).",
//       });
//     }

//     const chatCreated = await addMessage({
//       userId,
//       message,
//       isUser,
//     });

//     return res.status(201).json({
//       statusCode: 201,
//       success: true,
//       data: chatCreated,
//     });
//   } catch (error) {
//     console.log(error);
//     return res.status(500).json({
//       statusCode: 500,
//       success: false,
//       message: "Failed to add message",
//       error: error.message,
//     });
//   }
// };

const deleteMessage = async (req, res) => {
  try {
    const userId = req.user.id;
    const messageId = req.params.id;

    const deleted = await deleteMessageById(messageId, userId);

    if (!deleted) {
      return res.status(404).json({
        statusCode: 404,
        message: "Message not found",
      });
    }

    return res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Message deleted successfully",
    });
  } catch (error) {
    return res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to delete message",
      error: error.message,
    });
  }
};

const clearHistoryChat = async (req, res) => {
  try {
    const userId = req.user.id;

    const deletedCount = await clearHistory(userId);

    return res.status(200).json({
      statusCode: 200,
      success: true,
      message: "Chat history cleared",
      data: deletedCount,
    });
  } catch (error) {
    return res.status(500).json({
      statusCode: 500,
      success: false,
      message: "Failed to clear chat history",
      error: error.message,
    });
  }
};

const fetchMessagesChat = async (req, res) => {
  try {
    const userId = req.user.id;
    const page = Number(req.query.page) || 1;
    const limit = Number(req.query.limit) || 20;

    console.log(req.body);

    const result = await fetchMessages({
      userId,
      page,
      limit,
    });

    console.log(result);

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
      message: "Failed to fetch messages",
      error: error.message,
    });
  }
};

module.exports = {
  query,
  deleteMessage,
  clearHistoryChat,
  fetchMessagesChat,
};
