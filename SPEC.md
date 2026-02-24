# VoiceFlow - AI Interview Copilot

## 1. Project Overview

**Project Name:** VoiceFlow
**Project Type:** macOS Menu Bar Application
**Core Functionality:** Real-time AI-powered teleprompter for remote interviews that listens to interviewer questions and provides intelligent response suggestions displayed in a transparent overlay.
**Target Users:** Job seekers, professionals preparing for interviews, anyone doing remote video interviews

---

## 2. UI/UX Specification

### Window Structure

| Window | Type | Purpose |
|--------|------|---------|
| Menu Bar | NSStatusItem | App entry point, quick controls |
| Settings Popover | NSPopover + SwiftUI | Main configuration |
| Teleprompter Overlay | NSPanel (floating) | Transparent overlay for reading |
| AI Suggestion Card | SwiftUI View | Display AI responses |

### Navigation Structure

```
Menu Bar Icon
    │
    ├── Click → Settings Popover
    │               ├── Voice Tab
    │               ├── Script Tab
    │               ├── AI Tab
    │               └── Display Tab
    │
    └── Toggle Overlay (⌥H)
```

### Visual Design - Liquid Glass (macOS Tahoe)

#### Color Palette

| Name | Light Mode | Dark Mode | Usage |
|------|------------|-----------|-------|
| Primary | #007AFF | #0A84FF | Buttons, highlights |
| Secondary | #5856D6 | #5E5CE6 | AI suggestions |
| Accent | #FF9500 | #FF9F0A | Warnings, attention |
| Success | #34C759 | #30D158 | Recording active |
| Error | #FF3B30 | #FF453A | Errors |
| Background | .ultraThinMaterial | .ultraThinMaterial | Liquid glass |
| Surface | .thinMaterial | .thinMaterial | Cards, panels |

#### Text Colors (Overlay)

| Element | Color | Hex |
|---------|-------|-----|
| Script Text | White | #FFFFFF |
| AI Suggestion | Yellow | #FFD60A |
| Follow-up Prompt | Cyan | #64D2FF |
| Center Guide | White (50% opacity) | #FFFFFF80 |

#### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Script | SF Pro Rounded | 48-72pt | Medium |
| AI Suggestion | SF Pro Rounded | 24-32pt | Medium |
| Settings Headers | SF Pro | 17pt | Semibold |
| Settings Body | SF Pro | 13pt | Regular |
| Status Text | SF Pro | 11pt | Regular |

#### Spacing System (8pt Grid)

| Element | Value |
|---------|-------|
| Section Padding | 16pt |
| Item Spacing | 8pt |
| Card Padding | 12pt |
| Button Padding | 8pt horizontal, 6pt vertical |
| Overlay Margin | 48pt from camera area |

### Views & Components

#### Menu Bar
- Template icon (works in dark/light)
- Status indicator: idle (gray), recording (green pulse), processing (blue)
- Click toggles settings popover

#### Settings Popover (Liquid Glass)

**Voice Tab:**
- Microphone selector dropdown
- Speech mode toggle (On-Device / Cloud)
- Live transcription view with waveform
- Recording controls

**Script Tab:**
- Large TextEditor for script
- Load/Save/Paste/Clear buttons
- Word count display

**AI Tab:**
- Provider dropdown (OpenAI, Anthropic, Google, DeepSeek, xAI, Minimax)
- Model dropdown per provider
- API key secure input with Test button
- Mode selector (Interview Coach, Q&A Generator, STAR Method, Keyword Booster, Custom)
- Style dropdown (Professional, Casual, Concise, Detailed)
- Length slider (50-200 words)
- Checkboxes: Auto-scroll, Highlight keywords, Show confidence

**Display Tab:**
- Speed slider (0.2-5.0x)
- Font size slider (24-96pt)
- Mirror toggle
- Guide line toggle
- Opacity slider (30-100%)
- Playback controls

#### Teleprompter Overlay Panel

- NSPanel with .floating level
- Transparent background (adjustable opacity)
- Script text scrolls vertically
- AI suggestion appears as highlighted overlay
- Center guide line for eye contact alignment
- Camera area at bottom (clear space)

#### AI Suggestion Card

- Slides in from bottom
- Semi-transparent glass background
- Suggested response text
- Accept (⌥A) / Dismiss (⌥D) buttons
- Confidence indicator bar

---

## 3. Functionality Specification

### Core Features

#### P0 - Critical

1. **Menu Bar App**
   - LSUIElement (no dock icon)
   - Click to show settings
   - Status indicator

2. **Teleprompter Overlay**
   - Transparent floating panel
   - Adjustable opacity (30-100%)
   - Script text with smooth scroll
   - Mirror/flip mode for teleprompter hardware

3. **Script Management**
   - Load from file (.txt, .rtf, .md)
   - Save to file
   - Paste from clipboard
   - Persist last script

4. **Playback Controls**
   - Play/Pause scroll
   - Speed adjustment (0.2x - 5.0x)
   - Jump back (10 seconds)
   - Reset to top

5. **Keyboard Shortcuts**
   - ⌥P: Play/Pause
   - ⌥R: Reset
   - ⌥J: Jump back
   - ⌥H: Hide/Show overlay
   - ⌥M: Mirror toggle

#### P1 - Important

6. **Speech Recognition**
   - On-device (Apple SpeechAnalyzer)
   - Cloud (OpenAI Whisper API)
   - Real-time transcription
   - Question detection

7. **AI Response Generation**
   - Multi-provider support (OpenAI, Anthropic, Google, DeepSeek, xAI, Minimax)
   - Streaming responses
   - Conversation memory

8. **AI Suggestions Display**
   - Yellow highlighted text in overlay
   - Follow-up prompt suggestions
   - Accept/Dismiss controls

#### P2 - Nice to Have

9. **Interview Modes**
   - Interview Coach
   - Q&A Generator
   - STAR Method
   - Keyword Booster

10. **Conversation Memory**
    - Remember Q&A within session
    - Context-aware suggestions

### User Interactions & Flows

#### Flow 1: Basic Teleprompter Use

1. User clicks menu bar icon
2. Settings popover appears
3. User enters/pastes script in Script tab
4. User adjusts display settings
5. User clicks "Show Overlay" or presses ⌥H
6. Overlay appears, user positions it
7. User presses ⌥P to start scrolling
8. Script scrolls, user reads while maintaining eye contact

#### Flow 2: AI-Assisted Interview

1. User configures AI in AI tab (provider, API key)
2. User enables AI suggestions
3. User starts interview (external video call)
4. User clicks "Start Listening"
5. App transcribes interviewer's questions in real-time
6. When question ends, AI generates suggested response
7. Suggestion appears as yellow highlight in overlay
8. User can accept (⌥A) to insert into script or dismiss (⌥D)
9. Follow-up prompts appear for deeper answers

### Data Handling

| Data | Storage | Encryption |
|------|---------|------------|
| Script text | UserDefaults | None |
| Settings | UserDefaults | None |
| API keys | macOS Keychain | AES-256 |
| Session memory | In-memory | None |

### Architecture Pattern

**MVVM (Model-View-ViewModel)**

```
┌─────────────────────────────────────────────────────────────┐
│                         Views                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────┐  │
│  │ SettingsView│ │ OverlayView │ │ AISuggestionView    │  │
│  └──────┬──────┘ └──────┬──────┘ └──────────┬──────────┘  │
└─────────┼───────────────┼──────────────────┼──────────────┘
          │               │                  │
┌─────────▼───────────────▼──────────────────▼──────────────┐
│                      ViewModels                            │
│  ┌─────────────────┐ ┌───────────────────────────────┐   │
│  │TeleprompterVM  │ │ SpeechRecognitionViewModel     │   │
│  └────────┬────────┘ └───────────────┬───────────────┘   │
└───────────┼─────────────────────────┼───────────────────┘
            │                         │
┌───────────▼─────────────────────────▼───────────────────┐
│                       Services                             │
│  ┌───────────────┐ ┌───────────────┐ ┌────────────────┐  │
│  │ SpeechService │ │ AIService     │ │ KeychainService│  │
│  └───────────────┘ └───────────────┘ └────────────────┘  │
└───────────────────────────────────────────────────────────┘
```

### Error Handling

| Error | User Feedback | Recovery |
|-------|--------------|----------|
| No microphone permission | Alert with "Open System Preferences" button | Guide to Settings |
| No speech recognition permission | Alert with instructions | Guide to Settings |
| API key invalid | "Invalid API key" toast | Re-enter key |
| API rate limit | "Rate limited, retrying..." toast | Auto-retry after delay |
| Network offline | "Offline mode" indicator | Disable AI features |
| API error | "AI unavailable" in overlay | Fallback to local |

---

## 4. Technical Specification

### Dependencies

#### Swift Package Manager

| Package | Version | Purpose |
|---------|---------|---------|
| None required | - | Using native frameworks |

### Frameworks Used

| Framework | Purpose |
|-----------|---------|
| SwiftUI | UI development |
| AppKit | Window management, menu bar |
| Speech | On-device speech recognition |
| AVFoundation | Audio capture |
| Security | Keychain access |
| Combine | Reactive data flow |
| WebSocket | Real-time AI streaming |

### Third-Party APIs

| Provider | API | Purpose |
|----------|-----|---------|
| OpenAI | Whisper API | Cloud speech-to-text |
| OpenAI | Chat Completions | AI response generation |
| Anthropic | Claude API | AI response generation |
| Google | Gemini API | AI response generation |
| DeepSeek | Chat API | AI response generation |
| xAI | Grok API | AI response generation |
| Minimax | Text API | AI response generation |

### Asset Requirements

| Asset | Type | Sizes |
|-------|------|-------|
| MenuBarIcon | SF Symbol | template |
| AppIcon | AppIcon | 16, 32, 128, 256, 512 |

### System Requirements

| Requirement | Value |
|-------------|-------|
| Minimum macOS | macOS Tahoe (26) |
| Architecture | Apple Silicon + Intel |
| Permissions | Microphone, Speech Recognition |

---

## 5. File Structure

```
VoiceFlow/
├── VoiceFlow/
│   ├── App/
│   │   ├── VoiceFlowApp.swift
│   │   └── AppDelegate.swift
│   ├── Views/
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift
│   │   │   ├── VoiceSettingsView.swift
│   │   │   ├── ScriptSettingsView.swift
│   │   │   ├── AISettingsView.swift
│   │   │   └── DisplaySettingsView.swift
│   │   ├── Overlay/
│   │   │   ├── TeleprompterOverlayView.swift
│   │   │   ├── ScriptTextView.swift
│   │   │   └── AISuggestionCardView.swift
│   │   └── Components/
│   │       ├── LiquidGlassContainer.swift
│   │       └── StatusIndicator.swift
│   ├── ViewModels/
│   │   ├── TeleprompterViewModel.swift
│   │   ├── SpeechRecognitionViewModel.swift
│   │   └── AISettingsViewModel.swift
│   ├── Services/
│   │   ├── SpeechRecognitionService.swift
│   │   ├── AIService.swift
│   │   ├── OpenAIProvider.swift
│   │   ├── AnthropicProvider.swift
│   │   ├── GoogleProvider.swift
│   │   ├── DeepSeekProvider.swift
│   │   ├── xAIProvider.swift
│   │   ├── MinimaxProvider.swift
│   │   └── KeychainService.swift
│   ├── Models/
│   │   ├── Script.swift
│   │   ├── AIProvider.swift
│   │   ├── AIResponse.swift
│   │   └── InterviewQuestion.swift
│   └── Resources/
│       └── Assets.xcassets
├── project.yml
├── SPEC.md
└── README.md
```

---

## 6. Keyboard Shortcuts

| Shortcut | Action | Context |
|----------|--------|---------|
| ⌥P | Play/Pause scroll | Global |
| ⌥R | Reset to top | Global |
| ⌥J | Jump back 10 seconds | Global |
| ⌥H | Hide/Show overlay | Global |
| ⌥M | Toggle mirror mode | Global |
| ⌥A | Accept AI suggestion | Overlay visible |
| ⌥D | Dismiss AI suggestion | Overlay visible |
| ⌥L | Load script file | Global |
| ⌥S | Save script file | Global |
| ⌥␣ | Push-to-talk | Global (hold) |
| Space | Play/Pause | When overlay focused |
| Esc | Hide overlay | Overlay focused |

---

## 7. Acceptance Criteria

- [ ] App runs as menu bar item with no dock icon
- [ ] Settings popover displays with all tabs
- [ ] Script text loads from file and displays in overlay
- [ ] Overlay appears as floating transparent panel
- [ ] Scroll speed adjustable from 0.2x to 5.0x
- [ ] Mirror mode flips text horizontally
- [ ] Keyboard shortcuts work globally
- [ ] Speech recognition transcribes in real-time (on-device or cloud)
- [ ] AI providers configurable with API key
- [ ] AI suggestions appear in overlay
- [ ] Accept/Dismiss controls work
- [ ] Settings persist between launches
- [ ] API keys stored securely in Keychain
- [ ] Liquid Glass UI styling applied
