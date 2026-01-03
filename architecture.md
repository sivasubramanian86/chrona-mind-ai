# ChronaMindAI - EchoTwin Architecture

## Overview
ChronaMindAI - EchoTwin is a multimodal memory and future simulation app that allows users to capture, relive, and analyze their past through cinematic replays while simulating potential futures through branching scenario visualization.

**Target**: Responsive Web + Mobile PWA  
**Tech Stack**: Flutter, Local Storage (MVP - no backend), Mock AI integrations  
**Timeline**: MVP prototype for demo in under 5 minutes

---

## Core Features (MVP Scope)

### 1. Multimodal Capture System
- **Text**: Rich text notes with tags
- **Voice**: Audio recording (simulated transcription for MVP)
- **Image**: Photo upload with metadata
- Quick capture floating action button on home timeline

### 2. Memory Timeline & Retrieval
- Unified feed of all captured memories
- Filter by type, tags, date range
- Semantic search simulation (keyword-based for MVP)
- Cinematic card design with preview

### 3. Cinematic Memory Replay
- Video-style player interface
- Highlight extraction (mock for MVP)
- Simulated ElevenLabs narration (pre-generated audio samples)
- Progress scrubber and playback controls

### 4. Pareto Digest Generator
- Upload PDF or paste URL/text
- Generate 10-minute summary (mock AI response)
- Create flashcards from content
- Mind map visualization placeholder

### 5. Future Simulator
- Interactive branching scenario graph
- Two-choice decision trees
- Visual comparison of outcomes
- Confidence bands and metrics display

### 6. Privacy & Data Management
- Local-first storage with SharedPreferences + local JSON
- Opt-in consent for features
- Export all data as JSON
- Delete account and all data

---

## Design System

### Visual Language
- **Style**: Cinematic, modern, sleek
- **Colors**: Deep purple-to-blue gradient palette (cosmic/neural theme)
  - Primary: Deep space purple (#6B46C1)
  - Secondary: Electric blue (#4C9AFF)
  - Accent: Neon cyan (#00D9FF)
  - Backgrounds: Dark gradients with subtle transparency
- **Typography**: Inter for body, Space Grotesk for headlines (cinematic feel)
- **Spacing**: Generous (24-32px between major sections)
- **Components**: Glass-morphic cards, floating elements, micro-animations

### Key UI Patterns (Mobbin-inspired)
- **Timeline**: Pinterest-style masonry cards with staggered heights
- **Capture Modal**: Bottom sheet with tab switcher (text/voice/image)
- **Memory Replay**: Full-screen immersive player (like Instagram Stories)
- **Simulator Graph**: Interactive node-based flow (like Miro/FigJam)

---

## Data Models

All models stored locally using SharedPreferences + JSON serialization.

### UserProfile
```dart
{
  id: String (UUID)
  name: String
  email: String
  voicePersonaOptIn: bool
  encryptionEnabled: bool (mock for MVP)
  createdAt: DateTime
  updatedAt: DateTime
}
```

### MemoryItem
```dart
{
  id: String (UUID)
  userId: String
  type: enum (text, voice, image, video)
  title: String
  contentText: String? (for text type)
  audioPath: String? (for voice type)
  imagePath: String? (for image type)
  timestamp: DateTime
  tags: List<String>
  summary: String (auto-generated or manual)
  highlightTimestamps: List<double> (for replay)
  duration: int? (seconds, for audio/video)
  createdAt: DateTime
  updatedAt: DateTime
}
```

### Digest
```dart
{
  id: String (UUID)
  userId: String
  sourceType: enum (pdf, url, text)
  sourceRef: String (file path or URL)
  title: String
  paretoSummary: String (10-min read)
  keyTakeaways: List<String>
  flashcards: List<Flashcard>
  estimatedReadTime: int (minutes)
  createdAt: DateTime
  updatedAt: DateTime
}
```

### Flashcard
```dart
{
  id: String (UUID)
  question: String
  answer: String
  category: String
}
```

### Simulation
```dart
{
  id: String (UUID)
  userId: String
  title: String
  description: String
  rootChoice: SimulationNode
  createdAt: DateTime
  updatedAt: DateTime
}
```

### SimulationNode
```dart
{
  id: String (UUID)
  label: String
  description: String
  outcomes: List<String>
  confidence: double (0-1)
  childChoices: List<SimulationNode> (max 2 for MVP)
}
```

---

## Service Classes (lib/services/)

### UserService
- CRUD operations for UserProfile
- Store in SharedPreferences as JSON
- Mock sample user on first launch

### MemoryService
- CRUD for MemoryItem
- Filter and search methods
- Generate mock highlights and summaries
- Store as JSON array in SharedPreferences
- Pre-populate with 5-7 sample memories

### DigestService
- Create digest from text/URL/PDF
- Mock AI summary generation (pre-written templates)
- Generate flashcards (extract key phrases)
- Store digests as JSON array

### SimulationService
- Create and manage simulation trees
- Traverse branching choices
- Calculate mock confidence scores
- Store simulations as JSON

### StorageService
- Wrapper for SharedPreferences
- Export all data as JSON file (web download)
- Delete all user data
- Handle mock encryption flag

---

## Screen Structure (lib/screens/)

### 1. OnboardingScreen (/onboarding)
**Components:**
- Progress stepper (3 steps)
- Welcome message with app tagline
- Goal capture input
- Consent toggles (voice persona, analytics)
- Sample voice recorder for opt-in
- Elegant CTA button

**Flow:**
1. Welcome → 2. Set goals → 3. Consent & voice sample → Home

### 2. HomeTimelineScreen (/)
**Components:**
- App bar with logo + search icon
- Filter chips (All, Text, Voice, Image)
- Timeline card list (staggered masonry layout)
- Floating action button for quick capture
- Bottom navigation (Home, Digest, Simulator, Settings)

**Interactions:**
- Tap card → Memory detail
- Tap FAB → Capture modal
- Swipe to refresh

### 3. CaptureModal (bottom sheet)
**Components:**
- Tab switcher (Text / Voice / Image)
- Text input with rich formatting
- Voice recorder with waveform animation
- Image picker with preview
- Tag input (chips)
- Save button

**Actions:**
- Record audio (show timer + waveform)
- Pick image from gallery (file picker)
- Add tags (autocomplete from existing)
- Save → creates MemoryItem

### 4. MemoryDetailScreen (/memory/:id)
**Components:**
- Hero image/icon based on type
- Title and timestamp
- Cinematic player controls (play/pause/scrub)
- Highlight strip (timeline with markers)
- Narration toggle switch
- Full content display
- Tags displayed as chips

**Interactions:**
- Play → show mock cinematic replay with fade transitions
- Scrub timeline → jump to highlights
- Toggle narration → play mock audio

### 5. ParetoDigestScreen (/digest)
**Components:**
- Upload area (PDF or text input)
- Recent digests list
- Create new digest button

**Sub-screen: DigestDetailScreen (/digest/:id)**
- Source info banner
- 10-minute summary (scrollable text)
- Key takeaways (bullet list)
- Flashcards carousel
- Mind map placeholder (image)
- Export button

**Interactions:**
- Upload PDF → show loading → generate digest (2-3 sec mock delay)
- Swipe flashcards
- Tap export → download JSON

### 6. FutureSimulatorScreen (/simulator)
**Components:**
- New simulation button
- Saved simulations list

**Sub-screen: SimulatorBuilderScreen (/simulator/new)**
- Decision input form
- Branch graph canvas
- Two-choice nodes
- Outcome descriptions
- Confidence slider per branch
- Visual comparison table

**Interactions:**
- Add decision → create root node
- Add two choices → create child nodes
- Adjust confidence sliders → update visual
- Run simulation → animate branching paths

### 7. SettingsScreen (/settings)
**Components:**
- Profile section (name, email)
- Privacy toggles (voice persona, encryption mock)
- Export data button
- Delete account button (with confirmation)
- About section with version

**Actions:**
- Export → download JSON file
- Delete → confirm dialog → clear all data → logout

---

## Navigation Structure (go_router)

```
/ (HomeTimelineScreen)
├── /onboarding (OnboardingScreen) - first time only
├── /memory/:id (MemoryDetailScreen)
├── /digest (ParetoDigestScreen)
│   └── /digest/:id (DigestDetailScreen)
├── /simulator (FutureSimulatorScreen)
│   ├── /simulator/new (SimulatorBuilderScreen)
│   └── /simulator/:id (SimulatorDetailScreen)
└── /settings (SettingsScreen)
```

Bottom navigation:
- Home (/)
- Digest (/digest)
- Simulator (/simulator)
- Settings (/settings)

---

## Mock AI Integration Strategy

Since we're using local storage only for MVP:

### Mock Services (lib/services/mock/)

**MockNarrationService**
- Pre-recorded 3-5 sample audio files
- Map memory type → audio file
- Simulate "generating narration" with 2s delay

**MockSummaryService**
- Template-based summaries
- Extract key sentences from input
- Return pre-formatted summary with 3s delay

**MockRAGService**
- Simple keyword matching for search
- Return top 5 memories by relevance score
- No actual vector embeddings

**MockHighlightService**
- Generate random highlight timestamps
- Extract key phrases from text
- Return 3-5 highlights per memory

---

## Implementation Steps (Prioritized)

### Phase 1: Foundation (Days 1-2)
1. ✅ Set up theme with cinematic color palette
2. ✅ Create data models (UserProfile, MemoryItem, Digest, Simulation)
3. ✅ Implement service classes with local storage
4. ✅ Create sample data generator

### Phase 2: Core Screens (Days 3-4)
5. ✅ Build OnboardingScreen with stepper
6. ✅ Build HomeTimelineScreen with timeline cards
7. ✅ Implement CaptureModal (bottom sheet)
8. ✅ Build MemoryDetailScreen with mock player

### Phase 3: Advanced Features (Days 5-6)
9. ✅ Build ParetoDigestScreen and detail view
10. ✅ Implement FutureSimulatorScreen with graph
11. ✅ Build SettingsScreen with export/delete
12. ✅ Add search and filter functionality

### Phase 4: Polish (Day 7)
13. ✅ Add micro-animations (fade, slide, scale)
14. ✅ Implement mock AI delays and loading states
15. ✅ Add sample audio files for narration
16. ✅ Test responsive layouts (mobile + web)

### Phase 5: Testing & Demo (Day 8)
17. ✅ Full flow testing
18. ✅ Fix compilation errors
19. ✅ Create demo script and sample data
20. ✅ Record 90-second demo video

---

## Demo Script (Under 5 Minutes)

**Act 1: Capture** (60s)
1. Open app → skip onboarding
2. Tap FAB → record 20s voice note about career decision
3. Show instant save with animation
4. Tap card → open memory detail
5. Tap play → show cinematic replay with mock narration

**Act 2: Digest** (90s)
6. Navigate to Digest tab
7. Tap "New Digest" → paste sample text (1-hour course summary)
8. Show loading (3s) → display 10-min summary
9. Swipe through flashcards
10. Show mind map placeholder

**Act 3: Simulate** (90s)
11. Navigate to Simulator tab
12. Tap "New Simulation" → enter "Should I change careers?"
13. Add two choices: "Stay" vs "Switch"
14. Show branching graph with outcomes
15. Adjust confidence sliders → update visual comparison

**Act 4: Privacy** (30s)
16. Navigate to Settings
17. Show export data button
18. Demonstrate delete account flow

---

## Performance Targets

- **Capture save**: < 500ms
- **Memory list load**: < 1s (for 100 memories)
- **Mock replay generation**: 2-3s with progress indicator
- **Digest generation**: 3-5s with progress UI
- **Simulation graph render**: < 1s
- **App cold start**: < 3s

---

## Privacy & Security (Mock for MVP)

- ✅ All data stored locally (SharedPreferences + JSON)
- ✅ Opt-in consent for voice persona
- ✅ Export data as JSON file
- ✅ Delete account removes all local data
- ⚠️ Encryption flag (mock - not actually encrypted for MVP)
- ⚠️ Voice cloning (mock - pre-recorded samples only)

---

## Dependencies Required

```yaml
dependencies:
  flutter_animate: ^4.5.0  # Micro-animations
  file_picker: ^8.0.0  # PDF and file uploads
  record: ^5.0.0  # Audio recording
  audioplayers: ^6.0.0  # Audio playback
  image_picker: ^1.0.0  # Image selection
  shared_preferences: ^2.2.0  # Local storage
  uuid: ^4.0.0  # ID generation
  intl: ^0.19.0  # Date formatting
  fl_chart: ^0.69.0  # Simulator graph visualization
  shimmer: ^3.0.0  # Loading states
```

---

## Success Criteria

✅ **Functional**: Capture → Store → Retrieve → Display working end-to-end  
✅ **Performance**: Mock AI responses feel realistic (2-5s delays)  
✅ **UX**: Demo flow completes in under 5 minutes  
✅ **Privacy**: User can export and delete all data  
✅ **Polish**: Cinematic animations and transitions throughout  

---

## Future Enhancements (Post-MVP)

- Real backend with Firebase/Supabase
- Actual ElevenLabs TTS integration
- Real RAG with vector embeddings (Pinecone/Weaviate)
- PDF parsing with text extraction
- Video capture and keyframe extraction
- Advanced simulation with multi-level branching
- Collaborative features (share memories)
- Mobile native features (background recording, widgets)

