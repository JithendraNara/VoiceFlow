# VoiceFlow

A macOS menu bar application — an AI-powered teleprompter for remote interviews.

VoiceFlow listens to your interviewer's questions in real time using on-device speech recognition, then quietly surfaces AI-generated talking points in a transparent floating overlay so you can stay focused and confident throughout the conversation.

> macOS only. Requires **macOS 14 Sonoma** or later.

---

## Features

**Core**
- Real-time speech recognition — on-device via Apple Speech framework, or cloud via Whisper API
- AI-generated response suggestions triggered by interviewer questions
- Transparent floating teleprompter overlay (always-on-top, non-intrusive)
- Conversation memory within sessions for context-aware suggestions

**Interview Modes**
- Interview Coach — general guidance and talking points
- Q&A Generator — draft direct answers to common questions
- STAR Method — structure responses using Situation, Task, Action, Result
- Keyword Booster — surface relevant keywords and phrases

**Teleprompter Controls**
- Adjustable opacity, font size, and scroll speed
- Mirror mode for external display setups
- Keyboard shortcuts: `⌥P` Play/Pause · `⌥H` Hide/Show · `⌥R` Reset

**Multi-LLM Support**
- OpenAI (GPT-4 and later)
- Anthropic (Claude)
- Google (Gemini)
- Provider is selectable from Settings; API keys stored securely in Keychain

---

## Architecture

VoiceFlow follows an **MVVM** architecture with a clean separation between UI, logic, and services.

```
VoiceFlow/
├── Models/                    # Data models and session state
├── Views/
│   ├── Components/            # Reusable SwiftUI components
│   ├── Overlay/               # Transparent NSPanel teleprompter layer
│   └── Settings/              # Settings window (AI tab, appearance, etc.)
├── ViewModels/                # Business logic, state management
└── Services/
    ├── AIService.swift        # Provider abstraction protocol
    ├── OpenAIProvider.swift
    ├── AnthropicProvider.swift
    ├── GoogleProvider.swift
    └── KeychainService.swift  # Secure API key storage
```

**UI layer** — SwiftUI + AppKit. The app runs as an `NSStatusItem` (menu bar only, no dock icon). The overlay is an `NSPanel` configured to float above all windows with adjustable transparency.

**Design language** — Liquid Glass (macOS Tahoe style), consistent with the system aesthetic.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift |
| UI Framework | SwiftUI + AppKit |
| Speech Recognition | Apple Speech framework + OpenAI Whisper (cloud fallback) |
| LLM Integration | OpenAI, Anthropic, Google — streaming responses |
| Secure Storage | Keychain Services |
| Project Generation | XcodeGen (`project.yml`) |

---

## Setup

**Requirements:** Xcode 15+, macOS 14+

```bash
# 1. Clone the repository
git clone https://github.com/JithendraNara/VoiceFlow.git
cd VoiceFlow

# 2. Generate the Xcode project (requires XcodeGen)
brew install xcodegen
xcodegen generate

# 3. Open in Xcode
open VoiceFlow.xcodeproj
```

**Add your API keys:**
1. Build and run the app (`⌘R`)
2. Click the VoiceFlow icon in the menu bar
3. Open **Settings > AI**
4. Enter your API key for whichever provider you want to use (OpenAI, Anthropic, or Google)
5. Keys are stored securely in your system Keychain — never written to disk

---

## Privacy

All speech processing happens on-device by default using Apple's Speech framework. Cloud Whisper transcription is opt-in. API keys are stored in Keychain and never leave your machine.
