const mongoose = require("mongoose");

//* Runs `work` inside a MongoDB transaction so a multi-collection write either
//* lands completely or not at all.
//*
//* withTransaction retries `work` on transient errors, so anything that is not
//* safe to repeat — sending a notification, charging, emailing — must run after
//* this resolves, never inside it. Every read and write inside must be passed
//* the session, or it runs outside the transaction and sees stale data.
const runInTransaction = async (work) => {
  const session = await mongoose.startSession();

  try {
    let result;
    await session.withTransaction(async () => {
      result = await work(session);
    });
    return result;
  } finally {
    await session.endSession();
  }
};

module.exports = { runInTransaction };
