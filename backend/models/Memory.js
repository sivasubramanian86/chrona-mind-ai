const mongoose = require('mongoose');

const memorySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: ['text', 'voice', 'image', 'video'],
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  content: {
    type: String,
    required: true
  },
  attachments: [{
    filename: String,
    url: String,
    type: String,
    size: Number
  }],
  voicePath: {
    type: String,
    default: null
  },
  tags: [{
    type: String,
    trim: true
  }],
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  mood: {
    type: String,
    enum: ['happy', 'sad', 'neutral', 'excited', 'anxious', 'peaceful'],
    default: 'neutral'
  },
  importance: {
    type: Number,
    min: 1,
    max: 5,
    default: 3
  },
  isPrivate: {
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

// Index for efficient queries
memorySchema.index({ userId: 1, createdAt: -1 });
memorySchema.index({ userId: 1, type: 1 });
memorySchema.index({ userId: 1, tags: 1 });

// Update updatedAt on save
memorySchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Memory', memorySchema);