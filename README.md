# 🌍 LangBuddy

## Interactive Language Learning Helper Application

LangBuddy is a **Flutter-based language learning application** designed to make language learning simple, interactive, and accessible.

The application allows users to learn vocabulary, daily phrases, pronunciation, quizzes, and interactive games without requiring user registration or login.

> **Learn • Listen • Practice • Play • Improve**

---

# 📱 About LangBuddy

Learning a new language can be difficult when learners have to deal with complicated interfaces, account creation, internet dependency, and limited opportunities for practice.

**LangBuddy** provides a simple learning environment where users can open the application and immediately start learning.

The application combines:

- 📚 Vocabulary learning
- 💬 Daily phrases
- 🔊 Pronunciation practice
- 🔎 Text search
- 🎤 Voice search
- 🧠 Quizzes
- 🎮 Educational games
- 📊 Progress tracking
- 🌓 Light and dark themes
- 💾 Local/offline data storage

No account or authentication is required.

---

# ✨ Key Features

## 📚 1. Vocabulary Learning

Users can learn commonly used words with detailed information.

Each vocabulary item can contain:

- Native word
- Translation
- Pronunciation
- Audio pronunciation
- Example usage

### Example

```text
English: Apple
French: Pomme
Pronunciation: pohm

Users can listen to the pronunciation using Text-to-Speech.

💬 2. Daily Phrases

LangBuddy provides useful phrases for everyday communication.

Categories can include:

👋 Greetings
✈️ Travel
🚨 Emergency
🛍️ Shopping
🍽️ Food
🏠 Daily conversation
💼 Work
🤝 Social communication

Users can tap the audio button to hear the pronunciation.

🔊 3. Pronunciation Practice

The pronunciation module helps users become familiar with the correct pronunciation of words and phrases.

Users can:

Select a word or phrase.
View its pronunciation.
Listen to the pronunciation.
Repeat and practice.

The application uses Text-to-Speech (TTS) technology for audio playback.

🔎 4. Smart Search

LangBuddy provides a search system that allows users to find vocabulary quickly.

There are two search methods.

⌨️ Text Search

Users can type a word into the search bar.

Example:

Apple

The application can display:

Apple
Pomme
Pronunciation: pohm
🎤 Voice Search

Users can tap the microphone button and speak a word.

For example:

User: Apple

The application converts the speech into text and searches the vocabulary.

This feature uses Speech-to-Text technology.

🔊 5. Text-to-Speech

LangBuddy uses Text-to-Speech technology to help users listen to words and phrases.

Users can tap the 🔊 button to hear pronunciation.

This can help improve:

Listening
Pronunciation awareness
Word recognition
Speaking practice
🧠 6. Quiz Module

The quiz module allows users to test their language knowledge.

Quiz questions can include:

Multiple-choice questions
Translation questions
Vocabulary questions
Word identification
Language recognition

The application provides immediate feedback and calculates the score.

Example:

Question:


What is "Apple" in French?


A. Eau
B. Pomme
C. Merci
D. Bonjour

Correct answer:

Pomme
🎮 7. Games Module

LangBuddy includes five educational games designed to make language learning more engaging.

🔗 Game 1 — Match Word

Users match words with their correct translations.

Example:

Apple     → Pomme
Water     → Eau
Thank you → Merci

The game helps improve vocabulary recognition.

🧩 Game 2 — Word Guessing

Users are given a word, clue, or translation and must guess the correct answer.

Example:

French word:


"Bonjour"


What does it mean?


A. Goodbye
B. Hello
C. Thank you
D. Water
🔊 Game 3 — Audio Guess

The application plays the pronunciation of a word.

The user listens and selects the correct word.

Example:

🔊 Audio Playing...


A. Apple
B. Water
C. House
D. School

This game focuses on listening and word recognition.

✏️ Game 4 — Fill in the Blanks

Users complete a sentence or word by filling in the missing information.

Example:

Bonjour means ________.

Answer:

Hello

This game helps users understand vocabulary in context.

⏱️ Game 5 — Timed Quiz

Users answer questions within a fixed amount of time.

The game tests:

Knowledge
Memory
Speed
Vocabulary recognition

Example:

Time remaining: 10 seconds


What does "Merci" mean?


A. Hello
B. Goodbye
C. Thank you
D. Water
♾️ Unlimited Game Levels

LangBuddy is designed to support continuous learning through limitless levels.

Instead of restricting the user to a small fixed number of levels, the game system can continuously generate new challenges from the available vocabulary and learning content.

As users progress, challenges can become more difficult.

Example:

Level 1
   ↓
Level 2
   ↓
Level 3
   ↓
Level 4
   ↓
Level 5
   ↓
...
   ↓
Unlimited Levels

Possible difficulty progression:

Beginner
   ↓
Easy
   ↓
Intermediate
   ↓
Advanced
   ↓
Expert
🌐 Supported Languages

LangBuddy supports the following languages:

No.	Language
1	🇬🇧 English
2	🇫🇷 French
3	🇪🇸 Spanish
4	🇮🇳 Hindi
5	🇩🇪 German
6	🇮🇹 Italian
7	🇵🇹 Portuguese
8	🇷🇺 Russian
9	🇨🇳 Chinese
10	🇯🇵 Japanese
11	🇰🇷 Korean
12	🇳🇱 Dutch
13	🇹🇷 Turkish
14	🇻🇳 Vietnamese
15	🇮🇩 Indonesian

Users can select the language they want to learn from the application.

🌓 8. Light Mode & Dark Mode

LangBuddy provides both Light Mode and Dark Mode.

☀️ Light Mode

Designed for comfortable use in normal lighting conditions.

🌙 Dark Mode

Designed for comfortable viewing in low-light environments.

The selected theme can be applied throughout the application.

💾 9. Offline Progress Tracking

LangBuddy does not require users to create an account.

Learning information can be stored locally on the device using:

SharedPreferences

Possible locally stored information includes:

Quiz scores
Words learned
Game scores
Completed levels
Streak information
Learning statistics
Theme preference

This allows users to retain their learning progress without creating an account.

🔐 Privacy

LangBuddy follows a simple local-first approach.

The application does not require:

❌ Username
❌ Password
❌ Email registration
❌ User account
❌ Authentication

The application is designed to keep basic learning progress locally on the user's device.

🏠 Application Modules

The application consists of the following major modules:

                    ┌──────────────────┐
                    │    LangBuddy     │
                    │   Home Screen    │
                    └────────┬─────────┘
                             │
       ┌───────────┬─────────┼─────────┬───────────┐
       │           │         │         │           │
       ▼           ▼         ▼         ▼           ▼
 Vocabulary    Phrases   Search      Quiz        Games
       │           │         │         │           │
       │           │      ┌──┴──┐      │      ┌────┴────┐
       │           │      │     │      │      │         │
       │           │     Text  Voice   │    Game 1    Game 2
       │           │    Search Search  │    Game 3    Game 4
       │           │                    │    Game 5
       │           │                    │
       └───────────┴────────────────────┴──────────────┐
                                                       │
                                                       ▼
                                             ┌─────────────────┐
                                             │ Progress & Data │
                                             │ SharedPrefs     │
                                             └─────────────────┘
🏗️ Technology Stack
Technology	Purpose
Flutter	Cross-platform application development
Dart	Programming language
Material Design	User interface
Flutter TTS	Text-to-Speech
Speech to Text	Voice search
SharedPreferences	Local data storage
Android Studio	Android development
VS Code	Development environment
Git	Version control
GitHub	Source code hosting
🛠️ Requirements

Before running the project, install:

Required Software
Flutter SDK
Dart SDK
Android Studio or Visual Studio Code
Android SDK
Android Emulator or Android smartphone

Check whether Flutter is correctly installed:

flutter doctor
🚀 Getting Started
1. Clone the Repository
git clone https://github.com/YOUR_USERNAME/langbuddy.git

Replace:

YOUR_USERNAME

with your GitHub username.

2. Open the Project
cd langbuddy
3. Install Dependencies

Run:

flutter pub get
4. Check the Project

Run:

flutter doctor

Resolve any required Flutter or Android configuration issues.

5. Run LangBuddy
flutter run

You can run the application on:

Android Emulator
Android smartphone
iOS device
Web
Desktop platforms supported by Flutter
🧹 Troubleshooting

If the application shows a build error or behaves unexpectedly, run:

flutter clean

Then:

flutter pub get

Finally:

flutter run
🎤 Voice Search Permissions

Voice search requires microphone access.

For Android, the application may require:

<uses-permission android:name="android.permission.RECORD_AUDIO"/>

The required permission should be configured according to the version of the Speech-to-Text package being used.

📦 Build APK

To create a release APK:

flutter build apk --release

The APK is normally generated at:

build/app/outputs/flutter-apk/app-release.apk
📂 Project Structure

The basic Flutter project structure is:

langbuddy/
│
├── android/
│   └── Android-specific files
│
├── ios/
│   └── iOS-specific files
│
├── lib/
│   └── main.dart
│
├── test/
│   └── Application tests
│
├── .gitignore
├── README.md
├── pubspec.yaml
├── pubspec.lock
└── analysis_options.yaml
🔄 Application Flow

The general user flow is:

Open LangBuddy
      ↓
Select Language
      ↓
Home Screen
      ↓
 ┌────┼────┬────┬────┬────┐
 ↓    ↓    ↓    ↓    ↓
Words Phrases Search Quiz Games
 ↓    ↓    ↓    ↓    ↓
Learn Listen Search Test Play
      │
      ↓
  Track Progress
      │
      ↓
 Local Storage
🎯 Project Objectives

The main objectives of LangBuddy are:

Develop a simple language learning application.
Remove the need for authentication.
Support multiple languages.
Help users learn vocabulary.
Provide useful daily phrases.
Improve pronunciation awareness.
Provide Text-to-Speech functionality.
Provide voice-based vocabulary search.
Provide text-based vocabulary search.
Provide interactive quizzes.
Provide five educational games.
Support limitless game levels.
Store progress locally.
Provide light and dark themes.
Create an engaging and accessible learning environment.
🌟 Advantages

LangBuddy provides several advantages:

✅ No login required
✅ Simple interface
✅ Multiple language support
✅ Vocabulary learning
✅ Daily phrases
✅ Pronunciation support
✅ Text-to-Speech
✅ Voice search
✅ Text search
✅ Interactive quizzes
✅ Five educational games
✅ Unlimited learning levels
✅ Offline progress storage
✅ Light mode
✅ Dark mode
✅ Cross-platform Flutter development
👨‍🎓 Target Users

LangBuddy can be useful for:

Students
Beginners
Language enthusiasts
Travelers
Tourists
Children learning basic vocabulary
People preparing for travel
Users who want quick language practice
📊 Learning Approach

LangBuddy combines multiple learning methods:

             LANGUAGE LEARNING
                    │
       ┌────────────┼────────────┐
       │            │            │
       ▼            ▼            ▼
    Learning     Listening     Practice
       │            │            │
       ▼            ▼            ▼
 Vocabulary       TTS          Games
 Phrases          Audio        Quiz
       │                         │
       └────────────┬────────────┘
                    ▼
               Progress

This combination encourages users to learn, listen, practice, and test their knowledge.

🎮 Game-Based Learning

Games are included to make repeated practice more engaging.

The five games are:

1. Match Word
2. Word Guessing
3. Audio Guess
4. Fill in the Blanks
5. Timed Quiz

The game system is intended to provide continuous practice through dynamically generated challenges.

🧪 Testing

The application can be tested using the following test cases:

Module	Test Case	Expected Result
Language Selection	Select French	French learning content displayed
Vocabulary	Open vocabulary	Vocabulary list displayed
Vocabulary Audio	Tap speaker	Pronunciation played
Phrases	Open phrases	Daily phrases displayed
Search	Enter a word	Matching result displayed
Voice Search	Speak a word	Speech converted to search text
Quiz	Answer question	Score updated
Match Word	Match correct pair	Score increases
Word Guessing	Select correct answer	Correct answer shown
Audio Guess	Identify audio	Answer evaluated
Fill Blanks	Complete blank	Answer evaluated
Timed Quiz	Answer before timer ends	Score calculated
Theme	Switch theme	Interface changes
Progress	Complete quiz/game	Progress stored locally
🔮 Future Enhancements

Future versions of LangBuddy can include:

🤖 AI Conversation

AI-powered conversations allowing users to practice real-world communication.

🎤 Advanced Pronunciation Evaluation

Users could record their pronunciation and receive feedback based on similarity to the expected pronunciation.

🧠 Adaptive Learning

The difficulty of vocabulary and games could automatically change based on the user's performance.

🏆 Achievements

Introduce:

Badges
Rewards
Daily goals
XP
Leaderboards
🔁 Spaced Repetition

Frequently forgotten words could automatically appear more often.

🖼️ Image-Based Learning

Vocabulary could be associated with images.

Example:

🍎
Apple
Pomme
☁️ Cloud Synchronization

Future versions could optionally provide cloud backup and synchronization.

🌎 Additional Languages

More languages and regional variations could be added.

📜 License

This project is developed primarily for educational and academic purposes.

The project may be modified and extended according to the requirements of the developer or institution.

📚 References
Flutter

https://flutter.dev/

Flutter Documentation

https://docs.flutter.dev/

Dart

https://dart.dev/

Flutter TTS

https://pub.dev/packages/flutter_tts

Speech to Text

https://pub.dev/packages/speech_to_text

Shared Preferences

https://pub.dev/packages/shared_preferences

Material Design

https://m3.material.io/

💙 LangBuddy
Learn • Listen • Practice • Play • Improve

A simple language learning companion without the complexity of accounts.
