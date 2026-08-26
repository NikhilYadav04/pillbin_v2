const FamilyMember = require("../models/FamilyMember");
const Medicine = require("../models/Medicine");

const MAX_FAMILY_MEMBERS = 10;

const listFamilyMembers = async (req, res) => {
  try {
    const members = await FamilyMember.find({ userId: req.user.id }).sort({
      createdAt: 1,
    });

    res.status(200).json({
      statusCode: 200,
      data: { familyMembers: members },
    });
  } catch (error) {
    console.error("List family members error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

const addFamilyMember = async (req, res) => {
  try {
    const { name, relation } = req.body;

    if (!name || !name.trim()) {
      return res
        .status(400)
        .json({ statusCode: 400, message: "Name is required" });
    }

    const count = await FamilyMember.countDocuments({ userId: req.user.id });
    if (count >= MAX_FAMILY_MEMBERS) {
      return res.status(400).json({
        statusCode: 400,
        message: `You can add up to ${MAX_FAMILY_MEMBERS} family members`,
      });
    }

    const member = await FamilyMember.create({
      userId: req.user.id,
      name: name.trim(),
      relation: relation ? relation.trim() : undefined,
    });

    res.status(201).json({
      statusCode: 201,
      message: "Family member added",
      data: { familyMember: member },
    });
  } catch (error) {
    console.error("Add family member error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

//* Medicines already tagged to this person fall back to the account owner
//* rather than being deleted or left pointing at a member that no longer exists
const deleteFamilyMember = async (req, res) => {
  try {
    const { memberId } = req.params;

    const member = await FamilyMember.findById(memberId);
    if (!member) {
      return res
        .status(404)
        .json({ statusCode: 404, message: "Family member not found" });
    }

    if (member.userId.toString() !== req.user.id.toString()) {
      return res
        .status(403)
        .json({ statusCode: 403, message: "Not authorized" });
    }

    await Medicine.updateMany(
      { familyMemberId: memberId },
      { $set: { familyMemberId: null } }
    );
    await FamilyMember.findByIdAndDelete(memberId);

    res.status(200).json({
      statusCode: 200,
      message: "Family member removed",
    });
  } catch (error) {
    console.error("Delete family member error:", error);
    res.status(500).json({ statusCode: 500, message: "Server error" });
  }
};

module.exports = { listFamilyMembers, addFamilyMember, deleteFamilyMember };
