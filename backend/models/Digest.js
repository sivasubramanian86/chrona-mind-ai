const mongoose = require('mongoose');

const digestSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  sourceType: {
    type: String,
    enum: ['text', 'voice', 'image', 'video', 'web', 'pdf'],
    required: true
  },
  sourceRef: {
    type: String,
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  paretoSummary: {
    type: String,
    required: true
  },
  keyTakeaways: [{
    type: String,
    required: true
  }],
  flashcards: [{
    question: {
      type: String,
      required: true
    },
    answer: {
      type: String,
      required: true
    },
    difficulty: {
      type: String,
      enum: ['easy', 'medium', 'hard'],
      default: 'medium'
    }
  }],
  estimatedReadTime: {
    type: Number,
    default: 10
  },
  aiGenerated: {
    type: Boolean,
    default: true
  },
  tags: [{
    type: String,
    trim: true
  }],
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: {
    type: Date,
    default: null
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

// Index for efficient queries
digestSchema.index({ userId: 1, createdAt: -1 });
digestSchema.index({ userId: 1, sourceType: 1 });
digestSchema.index({ userId: 1, isRead: 1 });

// Update updatedAt on save
digestSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Digest', digestSchema);