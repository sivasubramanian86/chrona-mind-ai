const express = require('express');
const { body, validationResult } = require('express-validator');
const Digest = require('../models/Digest');
const Memory = require('../models/Memory');
const auth = require('../middleware/auth');
const aiService = require('../services/aiService');

const router = express.Router();

// Get all digests for user
router.get('/', auth, async (req, res) => {
  try {
    const { limit = 50, offset = 0, isRead } = req.query;

    let query = { userId: req.user._id };

    if (isRead !== undefined) {
      query.isRead = isRead === 'true';
    }

    const digests = await Digest.find(query)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));

    const total = await Digest.countDocuments(query);

    res.json({
      digests: digests.map(digest => ({
        id: digest._id,
        sourceType: digest.sourceType,
        sourceRef: digest.sourceRef,
        title: digest.title,
        paretoSummary: digest.paretoSummary,
        keyTakeaways: digest.keyTakeaways,
        flashcards: digest.flashcards,
        estimatedReadTime: digest.estimatedReadTime,
        aiGenerated: digest.aiGenerated,
        tags: digest.tags,
        isRead: digest.isRead,
        readAt: digest.readAt,
        createdAt: digest.createdAt,
        updatedAt: digest.updatedAt
      })),
      total,
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
  } catch (error) {
    console.error('Get digests error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Get single digest
router.get('/:id', auth, async (req, res) => {
  try {
    const digest = await Digest.findOne({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!digest) {
      return res.status(404).json({ error: 'Digest not found' });
    }

    res.json({
      digest: {
        id: digest._id,
        sourceType: digest.sourceType,
        sourceRef: digest.sourceRef,
        title: digest.title,
        paretoSummary: digest.paretoSummary,
        keyTakeaways: digest.keyTakeaways,
        flashcards: digest.flashcards,
        estimatedReadTime: digest.estimatedReadTime,
        aiGenerated: digest.aiGenerated,
        tags: digest.tags,
        isRead: digest.isRead,
        readAt: digest.readAt,
        createdAt: digest.createdAt,
        updatedAt: digest.updatedAt
      }
    });
  } catch (error) {
    console.error('Get digest error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Generate new digest
router.post('/', auth, [
  body('sourceType').isIn(['text', 'voice', 'image', 'video', 'web', 'pdf']),
  body('sourceRef').trim().isLength({ min: 1 }),
  body('content').optional().trim(),
  body('memoryId').optional().isMongoId(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { sourceType, sourceRef, content, memoryId } = req.body;

    let finalContent = content;

    // If memoryId is provided, get content from memory
    if (memoryId) {
      const memory = await Memory.findOne({
        _id: memoryId,
        userId: req.user._id
      });

      if (!memory) {
        return res.status(404).json({ error: 'Memory not found' });
      }

      finalContent = memory.content;
    }

    if (!finalContent) {
      return res.status(400).json({ error: 'Content is required' });
    }

    // Generate digest using AI
    const aiResult = await aiService.generateDigest(finalContent, sourceType, sourceRef);

    // Create digest
    const digest = new Digest({
      userId: req.user._id,
      sourceType,
      sourceRef,
      title: aiResult.title,
      paretoSummary: aiResult.paretoSummary,
      keyTakeaways: aiResult.keyTakeaways,
      flashcards: aiResult.flashcards,
      estimatedReadTime: aiResult.estimatedReadTime,
      aiGenerated: true
    });

    await digest.save();

    res.status(201).json({
      digest: {
        id: digest._id,
        sourceType: digest.sourceType,
        sourceRef: digest.sourceRef,
        title: digest.title,
        paretoSummary: digest.paretoSummary,
        keyTakeaways: digest.keyTakeaways,
        flashcards: digest.flashcards,
        estimatedReadTime: digest.estimatedReadTime,
        aiGenerated: digest.aiGenerated,
        tags: digest.tags,
        isRead: digest.isRead,
        readAt: digest.readAt,
        createdAt: digest.createdAt,
        updatedAt: digest.updatedAt
      }
    });
  } catch (error) {
    console.error('Create digest error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Update digest
router.put('/:id', auth, async (req, res) => {
  try {
    const digest = await Digest.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!digest) {
      return res.status(404).json({ error: 'Digest not found' });
    }

    res.json({
      digest: {
        id: digest._id,
        sourceType: digest.sourceType,
        sourceRef: digest.sourceRef,
        title: digest.title,
        paretoSummary: digest.paretoSummary,
        keyTakeaways: digest.keyTakeaways,
        flashcards: digest.flashcards,
        estimatedReadTime: digest.estimatedReadTime,
        aiGenerated: digest.aiGenerated,
        tags: digest.tags,
        isRead: digest.isRead,
        readAt: digest.readAt,
        createdAt: digest.createdAt,
        updatedAt: digest.updatedAt
      }
    });
  } catch (error) {
    console.error('Update digest error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Mark digest as read
router.patch('/:id/read', auth, async (req, res) => {
  try {
    const digest = await Digest.findOneAndUpdate(
      { _id: req.params.id, userId: req.user._id },
      {
        isRead: true,
        readAt: new Date()
      },
      { new: true }
    );

    if (!digest) {
      return res.status(404).json({ error: 'Digest not found' });
    }

    res.json({
      digest: {
        id: digest._id,
        isRead: digest.isRead,
        readAt: digest.readAt
      }
    });
  } catch (error) {
    console.error('Mark digest read error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

// Delete digest
router.delete('/:id', auth, async (req, res) => {
  try {
    const digest = await Digest.findOneAndDelete({
      _id: req.params.id,
      userId: req.user._id
    });

    if (!digest) {
      return res.status(404).json({ error: 'Digest not found' });
    }

    res.json({ message: 'Digest deleted successfully' });
  } catch (error) {
    console.error('Delete digest error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;