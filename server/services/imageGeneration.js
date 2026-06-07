// controllers/imageGeneration.controller.js

// const axios = require("axios");
// const fs = require("fs");
// const path = require("path");

// class ImageGenerationController {
//   async generateImage(req, res) {
//     try {
//       const { query } = req.query;

//       if (!query || query.trim().length === 0) {
//         return res.status(400).json({
//           success: false,
//           message: "Query parameter is required",
//         });
//       }

//       //* sanitize query
//       const cleanQuery = query
//         .trim()
//         .replace(/[^\w\s,.-]/g, "")
//         .substring(0, 500);

//       cleanQuery += "\n Generate a HD-Realistic Photo for the query.";

//       const medicalContext = "";
//       // "medical illustration, educational, professional, healthcare related";

//       const sanitizedPrompt = `${cleanQuery}, ${medicalContext}`;

//       //* 🔥 Azure FLUX request
//       const response = await axios.post(
//         process.env.AZURE_FLUX_ENDPOINT,
//         {
//           prompt: sanitizedPrompt,
//           width: 1024,
//           height: 1024,
//           n: 1,
//           model: "FLUX.2-pro",
//         },
//         {
//           headers: {
//             "Content-Type": "application/json",
//             Authorization: `Bearer ${process.env.AZURE_API_KEY}`,
//           },
//           timeout: 60000,
//         }
//       );

//       const imageObject = response.data.data[0];
//       const base64Image = imageObject.b64_json;

//       res.status(200).json({
//         success: true,
//         data: {
//           base64: base64Image,
//           prompt: sanitizedPrompt,
//         },
//       });
//     } catch (error) {
//       console.error(error.response?.data || error.message);

//       res.status(500).json({
//         success: false,
//         message:
//           error.response?.data?.error?.message ||
//           `Image generation failed: ${error.message}`,
//       });
//     }
//   }
// }

// module.exports = new ImageGenerationController();

const axios = require("axios");
const fs = require("fs");
const path = require("path");
const crypto = require("crypto");

class ImageGenerationController {
  constructor() {
    this.saveDir = path.join(__dirname, "../generated-images");

    // Ensure the directory exists on startup
    if (!fs.existsSync(this.saveDir)) {
      fs.mkdirSync(this.saveDir, { recursive: true });
    }

    this.generateImage = this.generateImage.bind(this);
    this._saveImageToDisk = this._saveImageToDisk.bind(this);
  }

  async generateImage(req, res) {
    try {
      const { query } = req.query;

      if (!query || query.trim().length === 0) {
        return res.status(400).json({
          success: false,
          message: "Query parameter is required",
        });
      }

      //* Sanitize query
      let cleanQuery = query
        .trim()
        .replace(/[^\w\s,.-]/g, "")
        .substring(0, 500);

      const medicalContext = "";
      const sanitizedPrompt = `${cleanQuery}, ${medicalContext}`;

      cleanQuery += "\n Generate a HD-Realistic Photo for the query.";

      //* 🔥 Azure FLUX request
      const response = await axios.post(
        process.env.AZURE_FLUX_ENDPOINT,
        {
          prompt: sanitizedPrompt,
          width: 1024,
          height: 1024,
          n: 1,
          model: "FLUX.2-pro",
        },
        {
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${process.env.AZURE_API_KEY}`,
          },
          timeout: 60000,
        }
      );

      const imageObject = response.data.data[0];
      const base64Image = imageObject.b64_json;

      //* 💾 Save image to disk
      const savedImage = await this._saveImageToDisk(base64Image, cleanQuery);

      res.status(200).json({
        success: true,
        data: {
          base64: base64Image,
          prompt: sanitizedPrompt,
          savedImage, // { filename, filepath, sizeKB }
        },
      });
    } catch (error) {
      console.error(error.response?.data || error.message);
      res.status(500).json({
        success: false,
        message:
          error.response?.data?.error?.message ||
          `Image generation failed: ${error.message}`,
      });
    }
  }

  //* ─── Private: Save base64 image to disk ────────────────────────────────────
  async _saveImageToDisk(base64Image, query) {
    // Build a readable filename: first 30 chars of query + unique hash + timestamp
    const querySlug = query
      .toLowerCase()
      .replace(/\s+/g, "-") // spaces → hyphens
      .replace(/[^\w-]/g, "") // strip anything else
      .substring(0, 30);

    const uniqueHash = crypto.randomBytes(4).toString("hex"); // e.g. "a1b2c3d4"
    const timestamp = Date.now();
    const filename = `${querySlug}_${timestamp}_${uniqueHash}.png`;
    const filepath = path.join(this.saveDir, filename);

    // Strip data URI prefix if present, then write buffer
    const base64Data = base64Image.replace(/^data:image\/\w+;base64,/, "");
    const imageBuffer = Buffer.from(base64Data, "base64");

    await fs.promises.writeFile(filepath, imageBuffer);

    const sizeKB = (imageBuffer.byteLength / 1024).toFixed(2);
    console.log(`[ImageGen] Saved → ${filename} (${sizeKB} KB)`);

    return { filename, filepath, sizeKB: parseFloat(sizeKB) };
  }
}

module.exports = new ImageGenerationController();
