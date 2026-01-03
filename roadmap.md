# 6-Week Roadmap to Production

## Week 1: Foundation & Onboarding
- [ ] Implement robust Onboarding Screens with Design Tokens.
- [ ] Connect `ConsentCard` to User Preferences.
- [ ] Finalize local storage encryption integration.
- [ ] **Test**: Verify opt-in flow for Voice Persona.

## Week 2: Core Memories (Timeline & Capture)
- [ ] Build `HomeTimelineScreen` using `TimelineCard`.
- [ ] Integrate `CaptureModal` with `file_picker` and `record`.
- [ ] Implement `storage_service` for saving media locally.
- [ ] **Test**: Verify memory creation and persistence.

## Week 3: Playback & ElevenLabs
- [ ] Integrate `ReplayPlayer` with `audioplayers` and `video_player`.
- [ ] Hook up `ElevenLabsService` to `ReplayPlayer` specific events.
- [ ] Verify caching mechanism for audio files.
- [ ] **Test**: Verify audio playback and offline cache hits.

## Week 4: Digest & Insights (RAG)
- [ ] Implement `DigestDashboard` with real data aggregation.
- [ ] Integrate `VectorStore` (switching from Stub to implementation).
- [ ] Build local embedding pipeline.
- [ ] **Test**: Verify semantic search results.

## Week 5: Simulation & Polishing
- [ ] Implement `SimulatorGraph` with interactive state.
- [ ] Polishing: Transitions, Micro-animations (Flutter Animate).
- [ ] Accessibility audit (Screen reader testing).
- [ ] **Test**: Performance profiling on low-end devices.

## Week 6: Launch Prep
- [ ] Full security audit (Privacy, Encryption).
- [ ] Play Store & App Store compliance checks.
- [ ] Generate release builds (AAB/IPA).
- [ ] **Deploy**: Internal Testing Track.
