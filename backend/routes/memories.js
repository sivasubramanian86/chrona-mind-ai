const express = require('express');
const { body, validationResult } = require('express-validator');
const Memory = require('../models/Memory');
const auth = require('../middleware/auth');

const router = express.Router();

// Get all memories for user
router.get('/', auth, async (req, res) => {
  try {
    const { type, limit = 50, offset = 0, search } = req.query;

    let query = { userId: req.user._id };

    if (type) {
      query.type = type;
    }

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } }
      ];
    }

    const memories = await Memory.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .populate('userId', 'name email');

    const total = await Memory.countDocuments(query);

    res.json({
      memories: memories.map(memory => ({
        id: memory._id,
        type: memory.type,
        title: memory.title,
        content: memory.content,
        attachments: memory.attachments,
        voicePath: memory.voicePath,
        tags: memory.tags,
        location: memory.location,
        mood: memory.mood,
        importance: memory.importance,
        isPrivate: memory.isPrivate,
        createdAt: memory.createdAt,
        updatedAt: memory.updatedAt
      })),
      total,
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
  } catch (error) {
    console.error('Get memories error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get single memory
router.get('/:id', auth, async (req, res) => {
  try {
    const memory = await Memory.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!memory) {
      return res.status(404).json({ error: 'Memory not found' });
    }

    res.json({
      memory: {
        id: memory._id,
        type: memory.type,
        title: memory.title,
        content: memory.content,
        attachments: memory.attachments,
        voicePath: memory.voicePath,
        tags: memory.tags,
        location: memory.location,
        mood: memory.mood,
        importance: memory.importance,
        isPrivate: memory.isPrivate,
        createdAt: memory.createdAt,
        updatedAt: memory.updatedAt
      }
    });
  } catch (error) {
    console.error('Get memory error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Create new memory
router.post('/', auth, [
  body('type').isIn(['text', 'voice', 'image', 'video']),
  body('title').trim().isLength({ min: 1 }),
  body('content').trim().isLength({ min: 1 }),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const memoryData = {
      ...req.body,
      userId: req.user._id
    };

    const memory = new Memory(memoryData);
    await memory.save();

    res.status(201).json({
      memory: {
        id: memory._id,
        type: memory.type,
        title: memory.title,
        content: memory.content,
        attachments: memory.attachments,
        voicePath: memory.voicePath,
        tags: memory.tags,
        location: memory.location,
        mood: memory.mood,
        importance: memory.importance,
        isPrivate: memory.isPrivate,
        createdAt: memory.createdAt,
        updatedAt: memory.updatedAt
      }
    });
  } catch (error) {
    console.error('Create memory error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update memory
router.put('/:id', auth, async (req, res) => {
  try {
    const memory = await Memory.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!memory) {
      return res.status(404).json({ error: 'Memory not found' });
    }

    res.json({
      memory: {
        id: memory._id,
        type: memory.type,
        title: memory.title,
        content: memory.content,
        attachments: memory.attachments,
        voicePath: memory.voicePath,
        tags: memory.tags,
        location: memory.location,
        mood: memory.mood,
        importance: memory.importance,
        isPrivate: memory.isPrivate,
        createdAt: memory.createdAt,
        updatedAt: memory.updatedAt
      }
    });
  } catch (error) {
    console.error('Update memory error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete memory
router.delete('/:id', auth, async (req, res) => {
  try {
    const memory = await Memory.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!memory) {
      return res.status(404).json({ error: 'Memory not found' });
    }

    res.json({ message: 'Memory deleted successfully' });
  } catch (error) {
    console.error('Delete memory error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;