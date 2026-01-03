const OpenAI = require('openai');

class AIService {
  constructor() {
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });
  }

  async generateDigest(content, sourceType, sourceRef) {
    try {
      const prompt = this.buildDigestPrompt(content, sourceType, sourceRef);

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          {
            role: 'system',
            content: 'You are an expert at creating insightful, actionable digests using the Pareto Principle (80/20 rule). Focus on the most important 20% of information that delivers 80% of the value.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 2000,
        temperature: 0.7,
      });

      const aiResponse = response.choices[0].message.content;
      return this.parseDigestResponse(aiResponse);
    } catch (error) {
      console.error('AI Service Error:', error);
      throw new Error('Failed to generate digest');
    }
  }

  buildDigestPrompt(content, sourceType, sourceRef) {
    return `
Please analyze the following content and create a comprehensive digest using the Pareto Principle (80/20 rule). Focus on the most valuable insights that provide the greatest impact.

Content Type: ${sourceType}
Source Reference: ${sourceRef}

Content:
${content}

Please provide a response in the following JSON format:
{
  "title": "A compelling title for this digest",
  "paretoSummary": "A comprehensive summary focusing on the 20% of information that delivers 80% of the value",
  "keyTakeaways": [
    "Key takeaway 1",
    "Key takeaway 2",
    "Key takeaway 3",
    "Key takeaway 4",
    "Key takeaway 5"
  ],
  "flashcards": [
    {
      "question": "Question 1?",
      "answer": "Answer 1",
      "difficulty": "easy|medium|hard"
    },
    {
      "question": "Question 2?",
      "answer": "Answer 2",
      "difficulty": "easy|medium|hard"
    }
  ],
  "estimatedReadTime": 10
}

Make the digest actionable, insightful, and focused on high-impact information.`;
  }

  parseDigestResponse(aiResponse) {
    try {
      // Try to extract JSON from the response
      const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        throw new Error('No JSON found in AI response');
      }

      const parsed = JSON.parse(jsonMatch[0]);

      // Validate required fields
      if (!parsed.title || !parsed.paretoSummary || !parsed.keyTakeaways || !parsed.flashcards) {
        throw new Error('Missing required fields in AI response');
      }

      return {
        title: parsed.title,
        paretoSummary: parsed.paretoSummary,
        keyTakeaways: parsed.keyTakeaways,
        flashcards: parsed.flashcards.map(card => ({
          question: card.question,
          answer: card.answer,
          difficulty: card.difficulty || 'medium'
        })),
        estimatedReadTime: parsed.estimatedReadTime || 10
      };
    } catch (error) {
      console.error('Error parsing AI response:', error);
      // Return a fallback digest if parsing fails
      return this.createFallbackDigest(aiResponse);
    }
  }

  createFallbackDigest(content) {
    const words = content.split(' ').length;
    const readTime = Math.max(5, Math.min(30, Math.ceil(words / 200)));

    return {
      title: 'Content Digest',
      paretoSummary: 'This digest contains key insights extracted from the provided content using AI analysis.',
      keyTakeaways: [
        'Focus on the most important information',
        'Apply the Pareto Principle to maximize impact',
        'Take consistent action on key insights'
      ],
      flashcards: [
        {
          question: 'What is the Pareto Principle?',
          answer: 'The 80/20 rule - 80% of results come from 20% of efforts',
          difficulty: 'easy'
        }
      ],
      estimatedReadTime: readTime
    };
  }

  async generateSimulationOutcomes(title, description, optionA, optionB) {
    try {
      const prompt = `
Analyze this decision scenario and generate realistic outcomes for both options.

Decision: ${title}
Context: ${description}

Option A: ${optionA}
Option B: ${optionB}

For each option, generate 3-5 possible outcomes with realistic probabilities and impact scores (-10 to +10, where -10 is very negative and +10 is very positive).

Return the response as JSON:
{
  "optionA": {
    "outcomes": [
      {
        "description": "Description of outcome",
        "probability": 0.3,
        "impact": 5
      }
    ]
  },
  "optionB": {
    "outcomes": [
      {
        "description": "Description of outcome",
        "probability": 0.4,
        "impact": -2
      }
    ]
  }
}
`;

      const response = await this.openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          {
            role: 'system',
            content: 'You are an expert decision analyst. Generate realistic, balanced outcomes for decision scenarios.'
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 1500,
        temperature: 0.8,
      });

      const aiResponse = response.choices[0].message.content;
      const parsed = JSON.parse(aiResponse.match(/\{[\s\S]*\}/)[0]);

      return parsed;
    } catch (error) {
      console.error('Error generating simulation outcomes:', error);
      // Return default outcomes
      return {
        optionA: {
          outcomes: [
            { description: 'Positive outcome', probability: 0.6, impact: 4 },
            { description: 'Neutral outcome', probability: 0.3, impact: 0 },
            { description: 'Negative outcome', probability: 0.1, impact: -3 }
          ]
        },
        optionB: {
          outcomes: [
            { description: 'Positive outcome', probability: 0.5, impact: 3 },
            { description: 'Neutral outcome', probability: 0.4, impact: 1 },
            { description: 'Negative outcome', probability: 0.1, impact: -2 }
          ]
        }
      };
    }
  }
}

module.exports = new AIService();