# வாணி சேது — VaaniSetu
## Tamil AI Assistant | Gemma 4 Good Hackathon 2026

> Bridging the digital divide for Tamil Nadu's 70 million Tamil speakers
> through offline-first, voice-first AI in their native language.

---

## 🏆 Hackathon Track
- **Primary**: Digital Equity & Inclusivity ($10,000)
- **Special Tech**: Ollama Prize ($10,000)
- **Main Track**: 3rd/4th Prize target ($10,000–$15,000)

---

## 🎯 The Problem
500+ million Tamil speakers worldwide. Zero major AI assistants that work natively in Tamil, offline, for low-literacy users. A farmer in Madurai can't access PM-KISAN. A grandmother in Thanjavur can't read her prescription. VaaniSetu fixes this.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| AI Model | Gemma 4 (4B) via Ollama |
| Backend | Python FastAPI |
| Mobile App | Flutter (Android) |
| Voice Input | speech_to_text (Tamil locale) |
| Voice Output | flutter_tts (Tamil TTS) |
| Vision | Gemma 4 multimodal (image analysis) |
| Offline | Ollama local inference |

---

## 📁 Project Structure

```
vaanisetu/
├── backend/
│   ├── main.py              ← FastAPI server + Gemma 4 integration
│   └── requirements.txt
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart        ← App entry + theme
│   │   ├── screens/
│   │   │   └── home_screen.dart   ← Main UI
│   │   ├── services/
│   │   │   ├── chat_service.dart  ← API calls
│   │   │   └── speech_service.dart ← STT + TTS
│   │   └── widgets/
│   │       ├── chat_bubble.dart
│   │       ├── topic_card.dart
│   │       └── mic_button.dart
│   └── pubspec.yaml
├── data/
│   └── tamil_kb/
│       └── schemes.yaml     ← Government schemes knowledge base
└── scripts/
    ├── setup.sh             ← One-time setup
    └── start.sh             ← Start all services
```

---

## 🚀 Quick Start (Mac M2)

### Step 1: Setup (one-time)
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Step 2: Start backend
```bash
# Terminal 1
ollama serve

# Terminal 2
cd backend
source venv/bin/activate
python main.py
```

### Step 3: Run Flutter
```bash
# Terminal 3
cd flutter_app
flutter run
```

### Test the API
```bash
# Health check
curl http://localhost:8000/health

# Test Tamil chat
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "PM கிசான் திட்டம் என்ன?"}'
```

---

## 📱 App Features

### ✅ Day 1-2 (DONE)
- [x] Project structure
- [x] FastAPI backend with Gemma 4
- [x] Tamil system prompt
- [x] Flutter app skeleton
- [x] Chat UI with Tamil fonts
- [x] Voice input (Tamil STT)
- [x] Voice output (Tamil TTS)
- [x] Topic quick-buttons
- [x] Camera/document scan endpoint

### 📋 Day 3-4
- [ ] Connect real Android device & test
- [ ] Tamil STT fine-tuning/testing
- [ ] Add conversation memory
- [ ] Test all 6 topic areas
- [ ] Fix UI bugs

### 📋 Day 5
- [ ] Unsloth fine-tuning on Tamil KB data
- [ ] Add more government scheme data
- [ ] Improve response quality

### 📋 Day 6
- [ ] Polish UI (animations, loading states)
- [ ] Add offline indicator
- [ ] Error handling

### 📋 Day 7
- [ ] Document scan flow complete
- [ ] End-to-end testing
- [ ] Performance optimization

### 📋 Day 8 (MOST IMPORTANT)
- [ ] Record demo video (3 min)
- [ ] Find real Tamil speaker for demo
- [ ] Tell the story: farmer/grandmother use case

### 📋 Day 9
- [ ] Kaggle writeup (1500 words)
- [ ] Push code to GitHub
- [ ] Deploy demo
- [ ] Submit!

---

## 🎬 Video Script (Day 8)

1. **[0:00-0:30]** Show problem: elderly Tamil woman can't use English apps
2. **[0:30-1:30]** Show VaaniSetu: speaks Tamil → gets Tamil answer (govt scheme)
3. **[1:30-2:00]** Demo: photograph a ration card → app reads it aloud
4. **[2:00-2:30]** Demo: ask health question in Tamil → spoken Tamil answer
5. **[2:30-3:00]** Impact slide: "70M Tamil speakers. Zero offline Tamil AI. Until now."

---

## 📊 Judging Criteria Alignment

| Criteria | Our Approach |
|----------|-------------|
| Impact & Vision (40pts) | Real problem, real Tamil Nadu context, film real user |
| Video Pitch (30pts) | Emotional story, grandmother/farmer demo |
| Technical Depth (30pts) | Gemma 4 multimodal + voice + offline via Ollama |

---

## 🌟 Why This Wins

1. **Real, local problem** — Tamil digital exclusion is documented
2. **Unique angle** — No other team will build specifically for Tamil
3. **Three Gemma 4 features** — LLM + Vision + multilingual
4. **Eligible for 3 prizes** — Digital Equity + Ollama + Main Track
5. **Emotional story** — Easy to make judges feel the impact
