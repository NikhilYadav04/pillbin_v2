//* Display-only identifier printed on the shared receipt. Derived from the
//* request id so the app and the server always show the same string without
//* either of them storing it.
const buildReceiptNumber = (requestId, createdAt) => {
  const year = new Date(createdAt || Date.now()).getFullYear();
  const tail = String(requestId).slice(-8).toUpperCase();
  return `PB-${year}-${tail}`;
};

//* Count actual units where quantity is numeric, else one per entry
const countUnits = (medicines) =>
  (medicines || []).reduce((sum, m) => {
    const parsed = parseInt(m.quantity, 10);
    return sum + (Number.isNaN(parsed) || parsed < 1 ? 1 : parsed);
  }, 0);

module.exports = { buildReceiptNumber, countUnits };
