const axios = require("axios");

const OTP_API_KEY = process.env.OTP_API_KEY;
const OTP_URL = process.env.OTP_URL;

async function sendOTP(number, otp) {
  try {
    const body = {
      message: `Your OTP for Pillbin app is ${otp}`,
      language: "english",
      route: "q",
      numbers: number,
    };

    console.log(body)
    console.log(OTP_URL)
    console.log(OTP_API_KEY)

    const response = await axios.post(OTP_URL, body, {
      headers: {
        authorization: OTP_API_KEY,
        "Content-Type": "application/json",
      },
    });

    console.log("OTP API Response:", response);

    //* Fast2SMS success check
    if (response.data.return === true) {
      return true;
    } else {
      return false;
    }
  } catch (err) {
    console.error("Error sending OTP:", err.message);
    return false;
  }
}

module.exports = sendOTP;
