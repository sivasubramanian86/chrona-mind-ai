# ChronaMindAI (EchoTwin)

**ChronaMindAI** is a Flutter-based application designed to help users relive past memories with cinematic flair and simulate future choices. It features a privacy-first architecture with AI-powered insights and a comprehensive backend API for data persistence and processing.

## Features
- **Cinematic Timeline**: Visualize memories with a beautiful, Mobbin-inspired UI.
- **AI-Powered Digests**: Generate insightful summaries and flashcards from your memories using advanced AI.
- **Future Simulation**: Visualize potential life paths with interactive simulation graphs.
- **Voice Synthesis**: Optional ElevenLabs integration for memory narration (requires opt-in).
- **Privacy First**: Secure data storage with encryption and user-controlled data sharing.
- **Offline-First**: App works without backend connection using local storage fallback.
- **Cross-Platform**: Runs on iOS, Android, Web, Windows, macOS, and Linux.

## Tech Stack

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **GoRouter**: Declarative routing
- **Provider**: State management
- **Material Design 3**: Modern UI components

### Backend
- **Node.js**: Runtime environment
- **Express.js**: Web framework
- **MongoDB**: Document database
- **JWT**: Authentication
- **OpenAI API**: AI-powered content generation
- **ElevenLabs API**: Voice synthesis

## Getting Started

### Prerequisites
- Flutter SDK 3.6.0+
- Dart SDK 3.3.0+
- Node.js 18+
- MongoDB (local or cloud instance)
- OpenAI API key (for AI features)

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

   Or use the setup script:
   ```bash
   ./setup.sh
   ```

3. **Environment configuration:**
   Copy the example environment file and configure it:
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your actual values (MongoDB URI, API keys, etc.)

4. **Start MongoDB:**
   ```bash
   # Using local MongoDB
   mongod

   # Or using Docker
   docker run -d -p 27017:27017 --name mongodb mongo:latest
   ```

5. **Start the backend server:**
   ```bash
   npm start
   ```

   For development with auto-restart:
   ```bash
   npm run dev
   ```

### Frontend Setup

1. **Setup Flutter app:**
   ```bash
   cd ../ # Go back to root directory
   flutter pub get
   ```

2. **Environment configuration:**
   Create a `.env` file in the root directory:
   ```env
   API_BASE_URL=http://localhost:3000/api
   ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## API Documentation

The backend provides RESTful APIs for:

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile

### Memories
- `GET /api/memories` - Get all user memories
- `POST /api/memories` - Create new memory
- `GET /api/memories/:id` - Get specific memory
- `PUT /api/memories/:id` - Update memory
- `DELETE /api/memories/:id` - Delete memory

### Digests
- `GET /api/digests` - Get all user digests
- `POST /api/digests` - Generate new digest
- `GET /api/digests/:id` - Get specific digest
- `PUT /api/digests/:id` - Update digest
- `DELETE /api/digests/:id` - Delete digest

### Simulations
- `GET /api/simulations` - Get all user simulations
- `POST /api/simulations` - Create new simulation
- `GET /api/simulations/:id` - Get specific simulation
- `PUT /api/simulations/:id` - Update simulation
- `DELETE /api/simulations/:id` - Delete simulation

## Architecture

### Frontend Architecture
- **State Management**: Provider pattern with service layer
- **Navigation**: GoRouter with shell routes and nested navigation
- **UI Components**: Custom widgets with Material Design 3
- **Services**: API client services with caching and error handling

### Backend Architecture
- **MVC Pattern**: Models, Views, Controllers separation
- **Middleware**: Authentication, validation, error handling
- **Database**: MongoDB with Mongoose ODM
- **AI Integration**: OpenAI for content generation and analysis

## Development

### Project Structure
```
chrona-mind-ai/
├── lib/                    # Flutter frontend
│   ├── components/         # Reusable UI components
│   ├── models/            # Data models
│   ├── screens/           # App screens/pages
│   ├── services/          # API and business logic
│   ├── theme/             # App theming
│   └── utils/             # Utility functions
├── backend/               # Node.js backend
│   ├── controllers/       # Route controllers
│   ├── models/           # Database models
│   ├── routes/           # API routes
│   ├── middleware/       # Express middleware
│   ├── services/         # Business logic services
│   └── utils/            # Backend utilities
├── assets/               # Static assets
└── test/                # Tests
```

### Running Tests
```bash
# Backend tests
cd backend && npm test

# Frontend tests
flutter test
```

## Security
This project follows strict security guidelines including:
- JWT-based authentication
- Data encryption at rest
- Input validation and sanitization
- Rate limiting
- CORS configuration

See [SECURITY.md](SECURITY.md) for detailed security information.

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License
MIT License. See [LICENSE](LICENSE) for more information.
