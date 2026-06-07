const cloudinary = require("../config/cloudinary");
const streamifier = require("streamifier");

const uploadImageService = async (file,name) => {
  try {
    const base64 = file.buffer.toString("base64");
    const dataUri = `data:${file.mimetype};base64,${base64}`;

    return await cloudinary.uploader.upload(dataUri, {
      resource_type: "auto",
      folder: name,
      quality: "auto:good",
      fetch_format: "auto",
    });
  } catch (error) {
    console.error("Cloudinary upload error:", error);
    throw error;
  }
};

const deleteImageService = async (publicId) => {
  return await cloudinary.uploader.destroy(publicId);
};

const uploadMediaService = (file) => {
  return new Promise((resolve, reject) => {
    const uploadOptions = {
      resource_type: "auto",
      folder: "chat_media",
      quality: "auto:good",
      fetch_format: "auto",
    };

    const cld_upload_stream = cloudinary.uploader.upload_stream(
      uploadOptions,
      (error, result) => {
        if (result) {
          resolve(result);
        } else {
          reject(error || new Error("Cloudinary upload failed."));
        }
      }
    );

    streamifier.createReadStream(file.buffer).pipe(cld_upload_stream);
  });
};

const uploadFileWrapper = async (file) => {
  try {
    return await uploadMediaService(file);
  } catch (error) {
    console.error("Cloudinary upload error:", error);
    throw error;
  }
};

module.exports = {
  uploadImageService,
  deleteImageService,
  uploadFileWrapper,
};
