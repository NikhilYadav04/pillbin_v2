const express = require("express");
const medicineController = require("../controllers/medicineController");
const { authenticateToken } = require("../middleware/auth");
const router = express.Router();

//* Protected Medicine Routes (JWT Required) - Using req.user.id from token
router.post("/add", authenticateToken, medicineController.addMedicine);

router.get("/inventory", authenticateToken, medicineController.getInventory);

router.get("/deleted-inventory",authenticateToken,medicineController.getDeletedMedicines);

//* soft-delete
router.delete(
  "/delete/:medicineId",
  authenticateToken,
  medicineController.deleteMedicine
);
router.delete(
  "/delete-all-expired",
  authenticateToken,
  medicineController.deleteAllExpiredMedicines
);

//* hard delete
router.delete(
  "/delete/:medicineId/hard",
  authenticateToken,
  medicineController.deleteMedicineHard
);
router.delete(
  "/delete-all-hard",
  authenticateToken,
  medicineController.hardDeleteAllDeletedMedicines
);

router.put(
  "/update/:medicineId",
  authenticateToken,
  medicineController.updateMedicine
);

//* Admin/System Routes (JWT Required)
router.post(
  "/update-statuses",
  authenticateToken,
  medicineController.updateAllStatuses
);
router.post(
  "/cleanup-expired",
  authenticateToken,
  medicineController.cleanupExpiredMedicines
);

module.exports = router;
