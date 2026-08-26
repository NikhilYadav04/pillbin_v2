const express = require("express");
const router = express.Router();
const { authenticateToken } = require("../middleware/auth");
const familyMemberController = require("../controllers/familyMemberController");

router.use(authenticateToken);

router.get("/", familyMemberController.listFamilyMembers);
router.post("/", familyMemberController.addFamilyMember);
router.delete("/:memberId", familyMemberController.deleteFamilyMember);

module.exports = router;
