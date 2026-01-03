# ChronaMindAI (EchoTwin)

**ChronaMindAI** is a Flutter-based application designed to help users relive past memories with cinematic flair and simulate future choices. It features a privacy-first, local-first architecture with optional AI integration.

## Features
- **Cinematic Timeline**: Visualize memories with a beautiful, Mobbin-inspired UI.
- **Privacy First**: All data is stored locally by default.
- **Voice Synthesis**: Optional ElevenLabs integration for memory narration (requires opt-in).
- **Future Simulation**: Visualize potential life paths with the Simulator Graph.
- **Digest Dashboard**: Weekly insights and flashcards generated from your memories.

## Getting Started

### Prerequisites
- Flutter SDK 3.6.0+
- Dart SDK 3.3.0+

### Setup
1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/chrona-mind-ai.git
    cd chrona-mind-ai
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Set up environment variables (create a `.env` file - **DO NOT COMMIT THIS**):
    ```
    ELEVENLABS_API_KEY=your_api_key_here
    ```

### Running the App
```bash
flutter run
```

## Architecture
- **State Management**: Provider / Riverpod (Transitioning)
- **Navigation**: GoRouter
- **Design System**: Custom `AppTheme` with `design_tokens.json`
- **Services**:
    - `ElevenLabsService`: API wrapper with local caching.
    - `StorageService`: Local encryption hooks.

## Security
This project follows strict security guidelines. See [SECURITY.md](SECURITY.md) for details.

## License
MIT License. See [LICENSE](LICENSE) for more information.
