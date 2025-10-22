const express = require("express");
const { GoogleGenAI } = require("@google/genai");
const dotenv = require("dotenv");

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const API = new GoogleGenAI({ apiKey: GEMINI_API_KEY });

const query = async (req, res) => {
  try {
    const { prompt } = req.body; // Destructure the string
    if (!prompt || typeof prompt !== "string") {
      return res.status(400).json({ error: "Prompt must be a string" });
    }

    const contents = [
      {
        role: "user",
        parts: [{ text: prompt }], // now prompt is a pure string
      },
    ];

    const response = await API.models.generateContent({
      model: "gemini-2.0-flash",
      contents,
      generationConfig: {
        maxOutputTokens: 80, // strict token cap (experiment: 50-300)
        temperature: 0.2, // less creative -> shorter responses
      },
    });

    res.json({
      data: {
        response,
      },
      statusCode: 200,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      message: e.message,
      statusCode: 500,
    });
  }
};

module.exports = { query };
