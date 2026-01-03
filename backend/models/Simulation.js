const mongoose = require('mongoose');

const simulationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true
  },
  optionA: {
    text: {
      type: String,
      required: true
    },
    outcomes: [{
      description: String,
      probability: {
        type: Number,
        min: 0,
        max: 1,
        default: 0.5
      },
      impact: {
        type: Number,
        min: -10,
        max: 10,
        default: 0
      }
    }],
    totalProbability: {
      type: Number,
      default: 0
    }
  },
  optionB: {
    text: {
      type: String,
      required: true
    },
    outcomes: [{
      description: String,
      probability: {
        type: Number,
        min: 0,
        max: 1,
        default: 0.5
      },
      impact: {
        type: Number,
        min: -10,
        max: 10,
        default: 0
      }
    }],
    totalProbability: {
      type: Number,
      default: 0
    }
  },
  status: {
    type: String,
    enum: ['active', 'completed', 'archived'],
    default: 'active'
  },
  selectedOption: {
    type: String,
    enum: ['A', 'B', null],
    default: null
  },
  actualOutcome: {
    type: String,
    default: null
  },
  reflection: {
    type: String,
    default: null
  },
  tags: [{
    type: String,
    trim: true
  }],
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
simulationSchema.index({ userId: 1, createdAt: -1 });
simulationSchema.index({ userId: 1, status: 1 });

// Calculate total probabilities before saving
simulationSchema.pre('save', function(next) {
  if (this.optionA.outcomes && this.optionA.outcomes.length > 0) {
    this.optionA.totalProbability = this.optionA.outcomes.reduce((sum, outcome) => sum + outcome.probability, 0);
  }
  if (this.optionB.outcomes && this.optionB.outcomes.length > 0) {
    this.optionB.totalProbability = this.optionB.outcomes.reduce((sum, outcome) => sum + outcome.probability, 0);
  }
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Simulation', simulationSchema);