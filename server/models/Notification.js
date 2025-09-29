const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  description: {
    type: String,
    required: true,
    trim: true,
    maxlength: 1000
  },
  status: {
    type: String,
    enum: ['important', 'normal', 'urgent', 'alert'],
    default: 'normal',
    required: true
  },
  isRead: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

//* Index for efficient querying
notificationSchema.index({ userId: 1, createdAt: -1 });

//* Update the updatedAt field before saving
notificationSchema.pre('save', function(next) {
  this.updatedAt = new Date();
  next();
});


module.exports = mongoose.model('Notification', notificationSchema);