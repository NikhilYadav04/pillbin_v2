// words to remove from medicine names
const STOP_WORDS = [
  "tablet",
  "tablets",
  "tab",
  "capsule",
  "capsules",
  "cap",
  "syrup",
  "suspension",
  "mg",
  "ml",
  "strip",
  "bottle",
];

// clean and extract useful medicine name
function cleanMedicineName(name) {
  let cleaned = name.toLowerCase().replace(/[^a-z0-9\s]/g, ""); // remove symbols

  STOP_WORDS.forEach((word) => {
    const regex = new RegExp(`\\b${word}\\b`, "g");
    cleaned = cleaned.replace(regex, "");
  });

  return cleaned.replace(/\s+/g, " ").trim();
}

// generate default 3 pharmacy links
function generateMedicineLinks(medicineName) {
  const cleaned = cleanMedicineName(medicineName);
  const encoded = encodeURIComponent(cleaned);

  return {
    cleanedName: cleaned,

    buyLinks: {
      tata1mg: `https://www.1mg.com/search/all?name=${encoded}`,
      pharmeasy: `https://pharmeasy.in/search/all?name=${encoded}`,
      netmeds: `https://www.netmeds.com/catalogsearch/result?q=${encoded}`,
    },
  };
}

module.exports = { generateMedicineLinks };
