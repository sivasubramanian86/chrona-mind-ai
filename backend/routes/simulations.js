const express = require('express');
const { body, validationResult } = require('express-validator');
const Simulation = require('../models/Simulation');
const auth = require('../middleware/auth');
const aiService = require('../services/aiService');

const router = express.Router();

// Get all simulations for user
router.get('/', auth, async (req, res) => {
  try {
    const { status, limit = 50, offset = 0 } = req.query;

    let query = { userId: req.user._id };

    if (status) {
      query.status = status;
    }

    const simulations = await Simulation.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    const total = await Simulation.countDocuments(query);

    res.json({
      simulations: simulations.map(simulation => ({
        id: simulation._id,
        title: simulation.title,
        description: simulation.description,
        optionA: simulation.optionA,
        optionB: simulation.optionB,
        status: simulation.status,
        selectedOption: simulation.selectedOption,
        actualOutcome: simulation.actualOutcome,
        reflection: simulation.reflection,
        tags: simulation.tags,
        createdAt: simulation.createdAt,
        updatedAt: simulation.updatedAt
      })),
      total,
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
  } catch (error) {
    console.error('Get simulations error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get single simulation
router.get('/:id', auth, async (req, res) => {
  try {
    const simulation = await Simulation.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!simulation) {
      return res.status(404).json({ error: 'Simulation not found' });
    }

    res.json({
      simulation: {
        id: simulation._id,
        title: simulation.title,
        description: simulation.description,
        optionA: simulation.optionA,
        optionB: simulation.optionB,
        status: simulation.status,
        selectedOption: simulation.selectedOption,
        actualOutcome: simulation.actualOutcome,
        reflection: simulation.reflection,
        tags: simulation.tags,
        createdAt: simulation.createdAt,
        updatedAt: simulation.updatedAt
      }
    });
  } catch (error) {
    console.error('Get simulation error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create new simulation
router.post('/', auth, [
  body('title').trim().isLength({ min: 1 }),
  body('description').trim().isLength({ min: 1 }),
  body('optionA').trim().isLength({ min: 1 }),
  body('optionB').trim().isLength({ min: 1 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, description, optionA, optionB } = req.body;

    // Generate AI-powered outcomes
    const aiOutcomes = await aiService.generateSimulationOutcomes(
      title,
      description,
      optionA,
      optionB
    );

    // Create simulation
    const simulation = new Simulation({
      userId: req.user._id,
      title,
      description,
      optionA: {
        text: optionA,
        outcomes: aiOutcomes.optionA.outcomes
      },
      optionB: {
        text: optionB,
        outcomes: aiOutcomes.optionB.outcomes
      }
    });

    await simulation.save();

    res.status(201).json({
      simulation: {
        id: simulation._id,
        title: simulation.title,
        description: simulation.description,
        optionA: simulation.optionA,
        optionB: simulation.optionB,
        status: simulation.status,
        selectedOption: simulation.selectedOption,
        actualOutcome: simulation.actualOutcome,
        reflection: simulation.reflection,
        tags: simulation.tags,
        createdAt: simulation.createdAt,
        updatedAt: simulation.updatedAt
      }
    });
  } catch (error) {
    console.error('Create simulation error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update simulation
router.put('/:id', auth, async (req, res) => {
  try {
    const simulation = await Simulation.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!simulation) {
      return res.status(404).json({ error: 'Simulation not found' });
    }

    res.json({
      simulation: {
        id: simulation._id,
        title: simulation.title,
        description: simulation.description,
        optionA: simulation.optionA,
        optionB: simulation.optionB,
        status: simulation.status,
        selectedOption: simulation.selectedOption,
        actualOutcome: simulation.actualOutcome,
        reflection: simulation.reflection,
        tags: simulation.tags,
        createdAt: simulation.createdAt,
        updatedAt: simulation.updatedAt
      }
    });
  } catch (error) {
    console.error('Update simulation error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Select option in simulation
router.patch('/:id/select', auth, [
  body('selectedOption').isIn(['A', 'B']),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { selectedOption } = req.body;

    const simulation = await Simulation.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      { selectedOption },
      { new: true }
    );

    if (!simulation) {
      return res.status(404).json({ error: 'Simulation not found' });
    }

    res.json({
      simulation: {
        id: simulation._id,
        selectedOption: simulation.selectedOption
      }
    });
  } catch (error) {
    console.error('Select option error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Complete simulation with outcome
router.patch('/:id/complete', auth, [
  body('actualOutcome').trim().isLength({ min: 1 }),
  body('reflection').optional().trim(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { actualOutcome, reflection } = req.body;

    const simulation = await Simulation.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      {
        status: 'completed',
        actualOutcome,
        reflection
      },
      { new: true }
    );

    if (!simulation) {
      return res.status(404).json({ error: 'Simulation not found' });
    }

    res.json({
      simulation: {
        id: simulation._id,
        status: simulation.status,
        actualOutcome: simulation.actualOutcome,
        reflection: simulation.reflection
      }
    });
  } catch (error) {
    console.error('Complete simulation error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete simulation
router.delete('/:id', auth, async (req, res) => {
  try {
    const simulation = await Simulation.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!simulation) {
      return res.status(404).json({ error: 'Simulation not found' });
    }

    res.json({ message: 'Simulation deleted successfully' });
  } catch (error) {
    console.error('Delete simulation error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;