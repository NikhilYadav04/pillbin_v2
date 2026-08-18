const mongoose = require("mongoose");
const { connectDB } = require("../config/database");
const CenterReview = require("../models/CenterReview");
const MedicalCenter = require("../models/MedicalCenter");

const RATING_CONFIDENCE = 5;
const NEUTRAL_PRIOR = 3.5;

(async () => {
  await connectDB();

  const grouped = await CenterReview.aggregate([
    {
      $group: {
        _id: "$medicalCenterId",
        sum: { $sum: "$rating" },
        count: { $sum: 1 },
        ratings: { $push: "$rating" },
      },
    },
  ]);

  const byCenter = new Map(grouped.map((g) => [String(g._id), g]));
  const centers = await MedicalCenter.find({}).select("_id");

  let touched = 0;

  for (const center of centers) {
    const g = byCenter.get(String(center._id));
    const sum = g ? g.sum : 0;
    const count = g ? g.count : 0;

    const breakdown = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    if (g) {
      for (const r of g.ratings) {
        if (breakdown[r] !== undefined) breakdown[r] += 1;
      }
    }

    const average = count > 0 ? sum / count : 0;
    const weighted =
      (RATING_CONFIDENCE * NEUTRAL_PRIOR + sum) / (RATING_CONFIDENCE + count);

    await MedicalCenter.findByIdAndUpdate(center._id, {
      ratingSum: sum,
      totalReviews: count,
      ratingBreakdown: breakdown,
      rating: Math.round(average * 10) / 10,
      weightedRating: Math.round(weighted * 100) / 100,
    });

    touched += 1;
  }

  console.log(`backfilled rating counters on ${touched} centers`);
  console.log(`${grouped.length} of them have at least one review`);

  await mongoose.connection.close();
  process.exit(0);
})();
