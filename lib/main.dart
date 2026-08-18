import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';
import 'dart:async';
import 'package:confetti/confetti.dart'; // Add confetti animation

// Import New Inclusive Features
import 'dyslexia_helper.dart';
import 'sign_language.dart';
import 'survival_packs.dart';
import 'offline_tutor.dart';
import 'community_packs.dart';
import 'school_challenges.dart';

// ================= GAME PROGRESS STORAGE =================
Future<void> saveGameProgressWithLang(
    String gameName, String language, int level, int stars) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt("progress_${gameName}_${language}_level", level);
  // Only save stars if it's better than previous or not set
  final int existingStars =
      prefs.getInt("progress_${gameName}_${language}_stars_$level") ?? 0;
  if (stars > existingStars) {
    await prefs.setInt("progress_${gameName}_${language}_stars_$level", stars);
  }
}

Future<int> loadGameProgressWithLang(String gameName, String language) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt("progress_${gameName}_${language}_level") ?? 1;
}

Future<int> loadGameStarsForLevel(
    String gameName, String language, int level) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt("progress_${gameName}_${language}_stars_$level") ?? 0;
}

Future<int> loadGameTotalStars(String gameName, String language) async {
  final prefs = await SharedPreferences.getInstance();
  int total = 0;
  for (int i = 1; i <= 20; i++) {
    total += prefs.getInt("progress_${gameName}_${language}_stars_$i") ?? 0;
  }
  return total;
}

Future<void> saveGameProgress(String gameName, int level) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt("progress_$gameName", level);
}

Future<int> loadGameProgress(String gameName) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt("progress_$gameName") ?? 0;
}

Future<Map<String, int>> loadAllGameProgress(List<String> gameNames) async {
  final prefs = await SharedPreferences.getInstance();
  Map<String, int> progress = {};
  for (var game in gameNames) {
    progress[game] = prefs.getInt("progress_$game") ?? 0;
  }
  return progress;
}

const Map<String, String> ttsLanguages = {
  "English": "en-US",
  "French": "fr-FR",
  "Spanish": "es-ES",
  "Hindi": "hi-IN",
  "German": "de-DE",
  "Italian": "it-IT",
  "Portuguese": "pt-PT",
  "Russian": "ru-RU",
  "Chinese": "zh-CN",
  "Japanese": "ja-JP",
  "Korean": "ko-KR",

  // Others
  "Dutch": "nl-NL",
  "Turkish": "tr-TR",
  "Vietnamese": "vi-VN",
  "Indonesian": "id-ID",
};

Future<void> speak(String text, String language) async {
  final tts = FlutterTts();

  // Get the device-supported languages
  List<dynamic> availableLanguages = await tts.getLanguages;

  // Use the requested language code
  String langCode = ttsLanguages[language] ?? "en-US";

  // Fallback if not available
  if (!availableLanguages.contains(langCode)) {
    print("Language $language not supported. Falling back to English.");
    langCode = "en-US";
  }

  await tts.setLanguage(langCode);
  await tts.setSpeechRate(0.45);
  await tts.setPitch(1.0);

  await tts.speak(text);
}

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadVocabulary();
  await loadAccessibilitySettings(); // Load dyslexia & speech configurations offline
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const LangBuddyApp());
}

/* ================= APP ROOT ================= */

class LangBuddyApp extends StatelessWidget {
  const LangBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, // Listen to the themeNotifier
      builder: (context, currentMode, child) {
        return ValueListenableBuilder<AccessibilityConfig>(
          valueListenable: accessibilityNotifier,
          builder: (context, accessibility, child) {
            return MaterialApp(
              title: 'LangBuddy',
              debugShowCheckedModeBanner: false,
              theme: ThemeData.light(), // Light theme
              darkTheme: ThemeData.dark(), // Dark theme
              themeMode: currentMode, // Dynamically controlled
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final extraLetterSpacing = accessibility.useDyslexiaFont
                    ? 1.2 * accessibility.letterSpacingMultiplier
                    : 0.5 * (accessibility.letterSpacingMultiplier - 1.0);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler:
                        TextScaler.linear(accessibility.fontSizeMultiplier),
                  ),
                  child: DefaultTextStyle.merge(
                    // Apply accessibility settings to ordinary Text widgets
                    // throughout the app, not only to DyslexicText.
                    style: TextStyle(
                      letterSpacing: extraLetterSpacing,
                      fontFamily:
                          accessibility.useDyslexiaFont ? 'Courier' : null,
                      wordSpacing: accessibility.useDyslexiaFont ? 3.0 : null,
                      height: accessibility.useDyslexiaFont ? 1.45 : null,
                    ),
                    child: child!,
                  ),
                );
              },
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}

/* ================= DATA ================= */

List<Map<String, dynamic>> vocabularyData = [];

Future<void> loadVocabulary() async {
  final jsonString = await rootBundle.loadString('assets/data/vocabulary.json');
  final List<dynamic> jsonList = jsonDecode(jsonString);
  vocabularyData = jsonList.cast<Map<String, dynamic>>();
}

/* ================= HOME SCREEN ================= */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLanguage = "English";

  static const List<String> _languages = [
    "English",
    "French",
    "Spanish",
    "Hindi",
    "German",
    "Italian",
    "Japanese",
    "Chinese",
    "Russian",
    "Korean",
    "Dutch",
    "Turkish",
    "Vietnamese",
    "Indonesian",
  ];

  static const Map<String, String> _languageEmojis = {
    "English": "🇬🇧",
    "French": "🇫🇷",
    "Spanish": "🇪🇸",
    "Hindi": "🇮🇳",
    "German": "🇩🇪",
    "Italian": "🇮🇹",
    "Japanese": "🇯🇵",
    "Chinese": "🇨🇳",
    "Russian": "🇷🇺",
    "Korean": "🇰🇷",
    "Dutch": "🇳🇱",
    "Turkish": "🇹🇷",
    "Vietnamese": "🇻🇳",
    "Indonesian": "🇮🇩",
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF0F2FF),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor:
                isDark ? const Color(0xFF1A1A2E) : const Color(0xFF4A5CF0),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF4A5CF0), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: Image.asset(
                                    'assets/logo/langbuddy_logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Lang",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Buddy",
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined,
                                  color: Colors.white),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SettingsScreen()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Hello, Learner! 👋",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "What would you like\nto learn today?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language Selector
                  _buildSectionTitle("🌍  Select Language", isDark),
                  const SizedBox(height: 12),
                  _buildLanguageSelector(isDark),
                  const SizedBox(height: 28),

                  // Feature Cards
                  _buildSectionTitle("📚  Explore Features", isDark),
                  const SizedBox(height: 12),
                  _buildFeatureCards(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : const Color(0xFF2D3748),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E32) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.indigo.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A5CF0), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.language, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Learning language",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isDense: true,
                    isExpanded: true,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2D3748),
                    ),
                    dropdownColor:
                        isDark ? const Color(0xFF1E1E32) : Colors.white,
                    items: _languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang,
                        child: Text(
                          "${_languageEmojis[lang] ?? '🌐'}  $lang",
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : const Color(0xFF2D3748),
                            fontSize: 15,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => selectedLanguage = v!),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context, bool isDark) {
    final cards = [
      _CardData(
        icon: Icons.search_rounded,
        title: "Search",
        subtitle: "Look up any word instantly",
        gradient: const [Color(0xFF4A5CF0), Color(0xFF7C76F0)],
        onTap: () => open(context, const SearchScreen()),
      ),
      _CardData(
        icon: Icons.menu_book_rounded,
        title: "Vocabulary",
        subtitle: "Browse word collections",
        gradient: const [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
        onTap: () =>
            open(context, VocabularyScreen(language: selectedLanguage)),
      ),
      _CardData(
        icon: Icons.quiz_rounded,
        title: "Quiz",
        subtitle: "Test your knowledge",
        gradient: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
        onTap: () => open(context, QuizScreen(language: selectedLanguage)),
      ),
      _CardData(
        icon: Icons.bar_chart_rounded,
        title: "Progress",
        subtitle: "Track your achievements",
        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
        onTap: () => open(context, ProgressScreen(language: selectedLanguage)),
      ),
      _CardData(
        icon: Icons.videogame_asset_rounded,
        title: "Games",
        subtitle: "Learn while having fun",
        gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
        onTap: () => open(context, GamesScreen(language: selectedLanguage)),
      ),
      // ── Inclusive AI voice tutor ──
      _CardData(
        icon: Icons.forum_rounded,
        title: "AI Voice Tutor",
        subtitle: "Chat with Offline AI Tutor",
        gradient: const [Color(0xFFEC4899), Color(0xFFF43F5E)],
        onTap: () =>
            open(context, OfflineTutorScreen(targetLanguage: selectedLanguage)),
      ),
      // ── Sign Language fingerspelling ──
      _CardData(
        icon: Icons.accessibility_new_rounded,
        title: "Sign Language",
        subtitle: "ASL Fingerspelling Animator",
        gradient: const [Color(0xFF14B8A6), Color(0xFF0D9488)],
        onTap: () => open(context, const SignLanguageScreen()),
      ),
      // ── Multilingual survival packs ──
      _CardData(
        icon: Icons.health_and_safety_rounded,
        title: "Survival Packs",
        subtitle: "Healthcare, Transport, Legal, etc.",
        gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
        onTap: () => open(
            context, SurvivalPacksScreen(currentLanguage: selectedLanguage)),
      ),
      // ── Community-tailored packs ──
      _CardData(
        icon: Icons.agriculture_rounded,
        title: "Community Packs",
        subtitle: "Farming, local trade words, etc.",
        gradient: const [Color(0xFFFF9800), Color(0xFFE65100)],
        onTap: () => open(
            context, CommunityPacksScreen(targetLanguage: selectedLanguage)),
      ),
      // ── School Portal offline homework sync ──
      _CardData(
        icon: Icons.school_rounded,
        title: "School Portal",
        subtitle: "Offline Homework & Dashboard",
        gradient: const [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        onTap: () => open(
            context, SchoolChallengesScreen(currentLanguage: selectedLanguage)),
      ),
      _CardData(
        icon: Icons.info_outline_rounded,
        title: "About",
        subtitle: "App info & credits",
        gradient: const [Color(0xFF6B7280), Color(0xFF4B5563)],
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AboutSheet(),
        ),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _buildFeatureCard(cards[index], isDark),
    );
  }

  Widget _buildFeatureCard(_CardData data, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: data.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: data.gradient.first.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative circle
              Positioned(
                right: -15,
                top: -15,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: -20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(data.icon, color: Colors.white, size: 24),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          data.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _CardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}

// Dummy open function to navigate (replace with your actual navigation)
void open(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

/* ================= UI HELPERS ================= */

Widget card(IconData icon, String title, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.indigo),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

/* ================= SEARCH SCREEN ================= */
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  late stt.SpeechToText speech;
  bool isListening = false;
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
    searchResults = vocabularyData; // show all words initially
  }

  void search(String query) {
    setState(() {
      searchResults = vocabularyData.where((wordData) {
        final word = wordData['word'].toString().toLowerCase();
        final translations = (wordData['translations'] as Map<String, dynamic>)
            .values
            .map((e) => e.toString().toLowerCase());
        return word.contains(query.toLowerCase()) ||
            translations.any((t) => t.contains(query.toLowerCase()));
      }).toList();
    });
  }

  Future<void> startListening() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (result) {
          controller.text = result.recognizedWords;
          search(result.recognizedWords);
        },
      );
    }
  }

  void stopListening() {
    speech.stop();
    setState(() => isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Words")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search bar + voice button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Search word...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => search(value),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none),
                  onPressed: () {
                    if (isListening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Search results
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final wordData = searchResults[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wordData['word'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          ...wordData['translations']
                              .entries
                              .map<Widget>((entry) {
                            final language = entry.key;
                            final translation = entry.value;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$language: $translation'),
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () async {
                                    await speak(translation, language);
                                  },
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= VOCABULARY SCREEN ================= */

class VocabularyScreen extends StatelessWidget {
  final String language;
  const VocabularyScreen({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vocabulary Collection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.accessibility_new_rounded),
            tooltip: "ASL Translator",
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SignLanguageScreen())),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: vocabularyData.length,
        itemBuilder: (context, index) {
          final w = vocabularyData[index];
          final wordText = w['word'];
          final transText = w['translations'][language] ?? "";

          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: isDark ? const Color(0xFF1E1E32) : Colors.white,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Row(
                children: [
                  Expanded(
                    child: DyslexicText(
                      wordText,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.indigo),
                    onPressed: () => speak(wordText, "English"),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        transText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.tealAccent : Colors.teal.shade800,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.teal),
                          onPressed: () => speak(transText, language),
                        ),
                        IconButton(
                          icon: const Icon(Icons.accessibility_new,
                              color: Colors.teal),
                          tooltip: "Fingerspell this",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SignLanguageScreen(initialWord: transText),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ================= QUIZ SCREEN ================= */

class QuizScreen extends StatefulWidget {
  final String language;
  const QuizScreen({super.key, required this.language});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> questions = [];
  int index = 0;
  int score = 0;
  late ConfettiController _confettiController;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    questions = generateQuizQuestions(vocabularyData, 15, widget.language);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Function to generate quiz questions dynamically
  List<Map<String, dynamic>> generateQuizQuestions(
      List<Map<String, dynamic>> vocab, int totalQuestions, String language) {
    final random = Random();
    List<Map<String, dynamic>> quizQuestions = [];

    // Flatten vocab translations for wrong options
    List<String> allOptions =
        List<String>.from(vocab.map((e) => e["translations"][language]!));

    while (quizQuestions.length < totalQuestions) {
      var wordEntry = vocab[random.nextInt(vocab.length)];
      String questionWord = wordEntry["word"];
      String correct = wordEntry["translations"][language]!;

      // Generate 2 wrong options
      List<String> wrongOptions = [];
      while (wrongOptions.length < 2) {
        String option = allOptions[random.nextInt(allOptions.length)];
        if (option != correct && !wrongOptions.contains(option)) {
          wrongOptions.add(option);
        }
      }

      // Shuffle options
      List<String> options = [correct, ...wrongOptions]..shuffle();

      quizQuestions.add({
        "q": "What is '$questionWord' in $language?",
        "options": options,
        "answer": correct
      });
    }

    return quizQuestions;
  }

  void answer(String selected) async {
    if (selected == questions[index]["answer"]) {
      score++;
    }
    if (index < questions.length - 1) {
      setState(() => index++);
    } else {
      // Save score to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("quiz_score_${widget.language}", score);
      int best = prefs.getInt("quiz_best_${widget.language}") ?? 0;
      if (score > best) {
        await prefs.setInt("quiz_best_${widget.language}", score);
      }

      setState(() {
        quizCompleted = true;
      });
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quizCompleted) {
      double percent = score / questions.length;
      int stars = 0;
      String feedback = "Keep Practicing!";
      String medalEmoji = "🥉";
      if (percent >= 0.85) {
        stars = 3;
        feedback = "Outstanding! Perfect Score!";
        medalEmoji = "🏆";
      } else if (percent >= 0.6) {
        stars = 2;
        feedback = "Great Job! Almost Perfect!";
        medalEmoji = "🥇";
      } else if (percent >= 0.35) {
        stars = 1;
        feedback = "Good Effort! Keep going!";
        medalEmoji = "🥈";
      }

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFFAE8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        medalEmoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Quiz Completed!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feedback,
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stars Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (starIndex) {
                          bool filled = starIndex < stars;
                          return Icon(
                            filled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: filled
                                ? Colors.amber
                                : (isDark ? Colors.white30 : Colors.black12),
                            size: 48,
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  "Score",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDark ? Colors.white60 : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$score / ${questions.length}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.purpleAccent
                                        : const Color(0xFF8B5CF6),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: 40,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey.shade300),
                            Column(
                              children: [
                                Text(
                                  "Percent",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDark ? Colors.white60 : Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${(percent * 100).toInt()}%",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.tealAccent
                                        : const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Back to Home",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    double progressPercent = index / questions.length;
    List<Color> buttonColors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E1E38)]
                : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: isDark ? Colors.white70 : Colors.black87),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Exit Quiz?"),
                            content: const Text(
                                "Your current progress will be lost."),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Exit")),
                            ],
                          ),
                        );
                      },
                    ),
                    Text(
                      "Quiz — ${widget.language}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "Score: $score",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.tealAccent
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 8,
                      width: (MediaQuery.of(context).size.width - 40) *
                          progressPercent,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Question ${index + 1} of ${questions.length}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.indigo.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        questions[index]["q"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ...List.generate(questions[index]["options"].length,
                    (optIndex) {
                  String option = questions[index]["options"][optIndex];
                  Color color = buttonColors[optIndex % buttonColors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.85)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => answer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ================= PROGRESS SCREEN ================= */

class ProgressScreen extends StatefulWidget {
  final String language;
  const ProgressScreen({super.key, required this.language});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int quizLastScore = 0;
  int quizBestScore = 0;

  Map<String, int> gameLevels = {};
  Map<String, int> gameStars = {};

  final List<String> games = [
    "Word Match",
    "Fill in the Blank",
    "Audio Guess",
    "Timed Quiz",
  ];

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Quiz Progress
    quizLastScore = prefs.getInt("quiz_score_${widget.language}") ?? 0;
    quizBestScore = prefs.getInt("quiz_best_${widget.language}") ?? 0;

    // Games Progress
    Map<String, int> levels = {};
    Map<String, int> stars = {};
    for (var g in games) {
      levels[g] = prefs.getInt("progress_${g}_${widget.language}_level") ?? 1;
      stars[g] = await loadGameTotalStars(g, widget.language);
    }

    setState(() {
      gameLevels = levels;
      gameStars = stars;
    });
  }

  Future<void> resetProgress() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Progress?"),
        content: Text(
            "This will permanently clear your progress for ${widget.language}."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Reset"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("quiz_score_${widget.language}");
      await prefs.remove("quiz_best_${widget.language}");

      for (var g in games) {
        await prefs.remove("progress_${g}_${widget.language}_level");
        for (int i = 1; i <= 20; i++) {
          await prefs.remove("progress_${g}_${widget.language}_stars_$i");
        }
      }

      loadProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Progress for ${widget.language} has been reset.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate total progress
    int totalLevels = 0;
    int totalStars = 0;
    for (var g in games) {
      totalLevels += (gameLevels[g] ?? 1) - 1; // Completed levels
      totalStars += gameStars[g] ?? 0;
    }

    // Determine Language Title Badge
    String rankTitle = "Novice Explorer";
    String rankEmoji = "🌱";
    if (totalLevels >= 15 || totalStars >= 40) {
      rankTitle = "Fluent Grandmaster";
      rankEmoji = "👑";
    } else if (totalLevels >= 8 || totalStars >= 20) {
      rankTitle = "Advanced Speaker";
      rankEmoji = "🏆";
    } else if (totalLevels >= 3 || totalStars >= 8) {
      rankTitle = "Active Learner";
      rankEmoji = "⭐";
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Progress — ${widget.language}"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            tooltip: "Reset Progress",
            onPressed: resetProgress,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Overall Rank Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                      : [const Color(0xFF6366F1), const Color(0xFFD946EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.purple.shade900 : Colors.indigo)
                        .withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    rankEmoji,
                    style: const TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rankTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Overall stats for ${widget.language}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                          "Levels Clear", "$totalLevels", Colors.amberAccent),
                      Container(width: 1, height: 32, color: Colors.white30),
                      _buildStatItem(
                          "Stars Earned", "$totalStars ⭐", Colors.yellowAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Quiz Card ──
            Text(
              "📝  Quiz Performance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.assignment_turned_in,
                        color: Color(0xFFF43F5E), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Quiz Best Score",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          "Last score: $quizLastScore / 15",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "$quizBestScore / 15",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.pinkAccent : const Color(0xFFF43F5E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Games Card List ──
            Text(
              "🎮  Game Accomplishments",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 12),
            ...games.map((g) {
              int level = gameLevels[g] ?? 1;
              int stars = gameStars[g] ?? 0;

              IconData gameIcon = Icons.sports_esports;
              Color gameColor = Colors.blue;
              if (g == "Word Match") {
                gameIcon = Icons.link;
                gameColor = Colors.indigo;
              } else if (g == "Guess the Word") {
                gameIcon = Icons.psychology;
                gameColor = Colors.orange;
              } else if (g == "Fill in the Blank") {
                gameIcon = Icons.edit;
                gameColor = Colors.teal;
              } else if (g == "Audio Guess") {
                gameIcon = Icons.volume_up;
                gameColor = Colors.cyan;
              } else if (g == "Timed Quiz") {
                gameIcon = Icons.timer;
                gameColor = Colors.pink;
              }

              // Progress value from 0.0 to 1.0 (Level 10 max visual progress)
              double prog = (level - 1) / 10.0;
              if (prog > 1.0) prog = 1.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: gameColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(gameIcon, color: gameColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  "Stars: $stars ⭐",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.amberAccent
                                        : Colors.amber.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Level $level",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                level > 1 ? "Active" : "Locked/Not Started",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: level > 1 ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Level Progress Bar
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: prog,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: gameColor,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

/* ================= SETTINGS SCREEN ================= */

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  double ttsSpeed = 0.5;
  double ttsPitch = 1.0;

  // Dyslexia & accessibility settings
  bool useDyslexiaFont = false;
  double fontSizeMultiplier = 1.0;
  double letterSpacingMultiplier = 1.0;
  bool highContrast = false;
  bool slowSpeech = false;
  bool showPhonetics = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      ttsSpeed = prefs.getDouble('ttsSpeed') ?? 0.5;
      ttsPitch = prefs.getDouble('ttsPitch') ?? 1.0;

      final access = accessibilityNotifier.value;
      useDyslexiaFont = access.useDyslexiaFont;
      fontSizeMultiplier = access.fontSizeMultiplier;
      letterSpacingMultiplier = access.letterSpacingMultiplier;
      highContrast = access.highContrast;
      slowSpeech = access.slowSpeech;
      showPhonetics = access.showPhonetics;
    });
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setDouble('ttsSpeed', ttsSpeed);
    await prefs.setDouble('ttsPitch', ttsPitch);
  }

  void _updateAccessibility() {
    final newConfig = AccessibilityConfig(
      useDyslexiaFont: useDyslexiaFont,
      fontSizeMultiplier: fontSizeMultiplier,
      letterSpacingMultiplier: letterSpacingMultiplier,
      highContrast: highContrast,
      slowSpeech: slowSpeech,
      showPhonetics: showPhonetics,
    );
    accessibilityNotifier.value = newConfig;

    // Save each to local store
    saveAccessibilitySetting('useDyslexiaFont', useDyslexiaFont);
    saveAccessibilitySetting('fontSizeMultiplier', fontSizeMultiplier);
    saveAccessibilitySetting(
        'letterSpacingMultiplier', letterSpacingMultiplier);
    saveAccessibilitySetting('highContrast', highContrast);
    saveAccessibilitySetting('slowSpeech', slowSpeech);
    saveAccessibilitySetting('showPhonetics', showPhonetics);
  }

  Future<void> resetProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // reset accessibility locally
    accessibilityNotifier.value = const AccessibilityConfig();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('All progress and settings have been reset!')),
    );
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilityConfig>(
      valueListenable: accessibilityNotifier,
      builder: (context, accessConfig, child) {
        return Scaffold(
          backgroundColor: getDyslexiaBackgroundColor(context),
          appBar: AppBar(
            title: const Text('Settings & Accessibility'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (accessConfig.useDyslexiaFont)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.amber.shade700, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.accessibility_new_rounded,
                          color: Colors.amber.shade900),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "✨ Dyslexia-Friendly Layout Active: Syllable coloring, high-legibility spacing & glare reduction enabled across all screens.",
                          style: TextStyle(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Text("Visual Theme",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() => isDarkMode = value);
                    themeNotifier.value =
                        isDarkMode ? ThemeMode.dark : ThemeMode.light;
                    saveSettings();
                  },
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text("Dyslexia & Accessibility Support",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Dyslexia Friendly Layout'),
                subtitle: const Text(
                    'Uses high-legibility layout and colors alternate syllables.'),
                value: useDyslexiaFont,
                activeThumbColor: Colors.teal,
                onChanged: (value) {
                  setState(() => useDyslexiaFont = value);
                  _updateAccessibility();
                },
              ),
              SwitchListTile(
                title: const Text('High Contrast Colors'),
                subtitle: const Text(
                    'Force high-contrast text overlay for better visibility.'),
                value: highContrast,
                activeThumbColor: Colors.teal,
                onChanged: (value) {
                  setState(() => highContrast = value);
                  _updateAccessibility();
                },
              ),
              SwitchListTile(
                title: const Text('Show Phonetic Guides'),
                subtitle: const Text(
                    'Displays speech breakdown and spelling hints under words.'),
                value: showPhonetics,
                activeThumbColor: Colors.teal,
                onChanged: (value) {
                  setState(() => showPhonetics = value);
                  _updateAccessibility();
                },
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                    "Font Size: ${fontSizeMultiplier.toStringAsFixed(1)}x",
                    style: const TextStyle(fontSize: 14)),
              ),
              Slider(
                value: fontSizeMultiplier,
                min: 0.8,
                max: 1.6,
                divisions: 10,
                activeColor: Colors.teal,
                label: "${fontSizeMultiplier.toStringAsFixed(1)}x",
                onChanged: (value) {
                  setState(() => fontSizeMultiplier = value);
                  _updateAccessibility();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                    "Letter Spacing: ${letterSpacingMultiplier.toStringAsFixed(1)}x",
                    style: const TextStyle(fontSize: 14)),
              ),
              Slider(
                value: letterSpacingMultiplier,
                min: 1.0,
                max: 2.0,
                divisions: 10,
                activeColor: Colors.teal,
                label: "${letterSpacingMultiplier.toStringAsFixed(1)}x",
                onChanged: (value) {
                  setState(() => letterSpacingMultiplier = value);
                  _updateAccessibility();
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Preview: Wider letter spacing makes each word easier to read.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 8),
              const Text("Speech Settings",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal)),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Slow Speech Synthesizer'),
                subtitle: const Text(
                    'Speaks words slower for pronunciation learning.'),
                value: slowSpeech,
                activeThumbColor: Colors.teal,
                onChanged: (value) {
                  setState(() => slowSpeech = value);
                  _updateAccessibility();
                },
              ),
              ListTile(
                title: const Text('Speech Pitch'),
                subtitle: Slider(
                  value: ttsPitch,
                  min: 0.5,
                  max: 1.5,
                  divisions: 10,
                  activeColor: Colors.teal,
                  label: ttsPitch.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => ttsPitch = value);
                    saveSettings();
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: resetProgress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Reset App Settings & Progress',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

const Map<String, String> _emojiClues = {
  "apple": "🍎",
  "banana": "🍌",
  "orange": "🍊",
  "bread": "🍞",
  "milk": "🥛",
  "water": "💧",
  "food": "🍔",
  "egg": "🥚",
  "meat": "🥩",
  "fish": "🐟",
  "fruit": "🍓",
  "vegetable": "🥕",
  "dog": "🐶",
  "cat": "🐱",
  "bird": "🐦",
  "horse": "🐴",
  "cow": "🐮",
  "pig": "🐷",
  "sheep": "🐑",
  "lion": "🦁",
  "tiger": "🐯",
  "bear": "🐻",
  "elephant": "🐘",
  "monkey": "🐒",
  "book": "📖",
  "pen": "🖊️",
  "pencil": "✏️",
  "paper": "📄",
  "key": "🔑",
  "door": "🚪",
  "window": "🪟",
  "table": "🪵",
  "chair": "🪑",
  "bed": "🛏️",
  "clock": "⏰",
  "watch": "⌚",
  "phone": "📱",
  "computer": "💻",
  "bag": "🎒",
  "car": "🚗",
  "bicycle": "🚲",
  "train": "🚆",
  "plane": "✈️",
  "bus": "🚌",
  "boat": "⛵",
  "ship": "🚢",
  "sun": "☀️",
  "moon": "🌙",
  "star": "⭐",
  "sky": "☁️",
  "tree": "🌳",
  "flower": "🌸",
  "grass": "🌿",
  "river": "🏞️",
  "mountain": "🏔️",
  "sea": "🌊",
  "wind": "💨",
  "fire": "🔥",
  "house": "🏠",
  "school": "🏫",
  "hospital": "🏥",
  "shop": "🏪",
  "market": "🛒",
  "office": "🏢",
  "city": "🏙️",
  "village": "🏡",
  "street": "🛣️",
  "hand": "✋",
  "foot": "🦶",
  "eye": "👁️",
  "ear": "👂",
  "nose": "👃",
  "mouth": "👄",
  "head": "👤",
  "heart": "❤️",
  "red": "🔴",
  "blue": "🔵",
  "green": "🟢",
  "yellow": "🟡",
  "black": "⚫",
  "white": "⚪",
  "friend": "🤝",
  "family": "👨‍👩‍👧‍👦",
  "mother": "👩",
  "father": "👨",
  "brother": "👦",
  "sister": "👧",
  "child": "👶",
  "teacher": "👩‍🏫",
  "doctor": "👨‍⚕️",
  "run": "🏃",
  "walk": "🚶",
  "sleep": "😴",
  "write": "✍️",
  "read": "📖",
  "speak": "🗣️",
  "eat": "🍽️",
  "drink": "🥤"
};

String getWordClueOrEmoji(String word) {
  final cleanWord = word.trim().toLowerCase();
  final emoji = _emojiClues[cleanWord];
  if (emoji != null) {
    return "$emoji $word";
  }
  return word;
}

class GameEngine {
  static final _random = Random();

  static List<Map<String, dynamic>> getRandomWords(int count) {
    final shuffled = List<Map<String, dynamic>>.from(vocabularyData)
      ..shuffle(_random);
    return shuffled.take(count).toList();
  }

  static Map<String, String> generateWordMatch(String language) {
    final words = getRandomWords(4);
    final Map<String, String> pairs = {};
    for (var w in words) {
      pairs[w['word']] = w['translations'][language] ?? w['word'];
    }
    return pairs;
  }

  static Map<String, dynamic> generateGuessWord(String language) {
    final words = getRandomWords(4);
    final answer = words[0]['translations'][language] ?? words[0]['word'];
    final options =
        words.map((w) => w['translations'][language] ?? w['word']).toList();
    options.shuffle(_random);
    return {"english": words[0]['word'], "answer": answer, "options": options};
  }

  static Map<String, dynamic> generateAudioGuess(String language) {
    final words = getRandomWords(4);
    final answer = words[0]['translations'][language] ?? words[0]['word'];
    final options =
        words.map((w) => w['translations'][language] ?? w['word']).toList();
    options.shuffle(_random);
    return {
      "answer": answer,
      "options": options,
      "sound": "🔊 ${answer.isNotEmpty ? answer[0] : ''}..."
    };
  }

  static Map<String, dynamic> generateTimedQuiz(String language) {
    final words = getRandomWords(4);
    final answer = words[0]['translations']["English"] ?? words[0]['word'];
    final options =
        words.map((w) => w['translations']["English"] ?? w['word']).toList();
    options.shuffle(_random);
    return {
      "question":
          "Select the correct English translation for '${words[0]['translations'][language]}' ($language):",
      "answer": answer,
      "options": options
    };
  }
}

/* ================= GAMES SCREEN ================= */
class GamesScreen extends StatefulWidget {
  final String language;
  const GamesScreen({super.key, required this.language});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  Map<String, int> levels = {};
  Map<String, int> stars = {};

  final List<String> gameNames = [
    "Word Match",
    "Fill in the Blank",
    "Audio Guess",
    "Timed Quiz",
  ];

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, int> loadedLevels = {};
    Map<String, int> loadedStars = {};
    for (var g in gameNames) {
      loadedLevels[g] =
          prefs.getInt("progress_${g}_${widget.language}_level") ?? 1;
      loadedStars[g] = await loadGameTotalStars(g, widget.language);
    }
    setState(() {
      levels = loadedLevels;
      stars = loadedStars;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gameConfigs = [
      {
        "title": "Word Match",
        "desc": "Connect matching word pairs",
        "icon": Icons.link,
        "gradient": const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        "widget":
            LevelGameWidget(gameType: "Word Match", language: widget.language),
      },
      {
        "title": "Fill in the Blank",
        "desc": "Spell the missing letters",
        "icon": Icons.edit,
        "gradient": const [Color(0xFF10B981), Color(0xFF059669)],
        "widget": LevelGameWidget(
            gameType: "Fill in the Blank", language: widget.language),
      },
      {
        "title": "Audio Guess",
        "desc": "Listen and identify words",
        "icon": Icons.volume_up,
        "gradient": const [Color(0xFF06B6D4), Color(0xFF0891B2)],
        "widget":
            LevelGameWidget(gameType: "Audio Guess", language: widget.language),
      },
      {
        "title": "Timed Quiz",
        "desc": "Translate before time runs out",
        "icon": Icons.timer,
        "gradient": const [Color(0xFFF43F5E), Color(0xFFE11D48)],
        "widget":
            LevelGameWidget(gameType: "Timed Quiz", language: widget.language),
      },
    ];

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text("Games — ${widget.language}"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemCount: gameConfigs.length,
        itemBuilder: (context, index) {
          final conf = gameConfigs[index];
          final title = conf["title"] as String;
          final level = levels[title] ?? 1;
          final totalStars = stars[title] ?? 0;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: conf["gradient"] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      (conf["gradient"] as List<Color>).first.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => conf["widget"] as Widget),
                  ).then((_) => loadProgress());
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              conf["icon"] as IconData,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          if (totalStars > 0)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.yellow, size: 16),
                                const SizedBox(width: 2),
                                Text(
                                  "$totalStars",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conf["desc"] as String,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Level $level",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ================= LEVEL GAME WIDGET ================= */
class LevelGameWidget extends StatefulWidget {
  final String gameType;
  final String language;

  const LevelGameWidget(
      {super.key, required this.gameType, required this.language});
  @override
  State<LevelGameWidget> createState() => _LevelGameWidgetState();
}

class _LevelGameWidgetState extends State<LevelGameWidget> {
  late FlutterTts flutterTts;
  bool isSpeaking = false;
  int level = 1;
  int questionIndex = 0;
  int score = 0;
  int earnedStars = 0;
  late List<Map<String, dynamic>> questions;
  bool levelCompleted = false;

  // Correct answer feedback
  bool showCorrectAnswer = false;
  String correctAnswer = "";

  // Timer for timed quiz
  int timeLeft = 15;
  Timer? timer;

  late ConfettiController _confettiController;

  String languageCode() {
    switch (widget.language) {
      case "English":
        return "en-US";
      case "French":
        return "fr-FR";
      case "German":
        return "de-DE";
      case "Spanish":
        return "es-ES";
      case "Hindi":
        return "hi-IN";
      case "Italian":
        return "it-IT";
      case "Portuguese":
        return "pt-PT";
      case "Russian":
        return "ru-RU";
      case "Chinese":
        return "zh-CN";
      case "Japanese":
        return "ja-JP";
      case "Korean":
        return "ko-KR";
      case "Dutch":
        return "nl-NL";
      case "Turkish":
        return "tr-TR";
      case "Vietnamese":
        return "vi-VN";
      case "Indonesian":
        return "id-ID";
      default:
        return "en-US";
    }
  }

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setSpeechRate(0.4);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    generateLevelQuestions();
  }

  Future<void> speakOnce(String word) async {
    if (isSpeaking) return;

    isSpeaking = true;
    await flutterTts.stop();
    await flutterTts.speak(word);
    await flutterTts.setSpeechRate(0.4);

    flutterTts.setCompletionHandler(() {
      isSpeaking = false;
    });
  }

  void generateLevelQuestions() {
    questions = List.generate(10, (_) {
      switch (widget.gameType) {
        case "Word Match":
          return {"pairs": GameEngine.generateWordMatch(widget.language)};
        case "Guess the Word":
          return GameEngine.generateGuessWord(widget.language);
        case "Audio Guess":
          final q = GameEngine.generateAudioGuess(widget.language);
          // Play the word automatically
          flutterTts.setLanguage(languageCode()); // see helper below
          flutterTts.speak(q['answer']); // speak the correct word
          return q;
        case "Timed Quiz":
          return GameEngine.generateTimedQuiz(widget.language);
        case "Fill in the Blank":
          final word = GameEngine.getRandomWords(1)[0];
          return {
            "sentence":
                'Translate "${word['translations'][widget.language]}" (${widget.language}) to English:',
            "answer": word['translations']["English"]
          };
        default:
          return {};
      }
    });

    questionIndex = 0;
    score = 0;
    levelCompleted = false;
    showCorrectAnswer = false;
    if (widget.gameType == "Timed Quiz") startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timeLeft = 15;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          t.cancel();
          showCorrectAnswer = true;
          correctAnswer = getCorrectAnswerForCurrentQuestion();
        }
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }

  String getCorrectAnswerForCurrentQuestion() {
    final q = questions[questionIndex];
    switch (widget.gameType) {
      case "Word Match":
        return q['pairs'].values.first;
      case "Fill in the Blank":
      case "Guess the Word":
      case "Audio Guess":
      case "Timed Quiz":
        return q['answer'];
      default:
        return "";
    }
  }

  void nextQuestion(bool correct) {
    if (correct) score++;
    if (!correct) {
      setState(() {
        showCorrectAnswer = true;
        correctAnswer = getCorrectAnswerForCurrentQuestion();
      });
      return;
    }

    if (questionIndex + 1 >= questions.length) {
      // Calculate stars: 3 for 100%, 2 for ≥70%, 1 for ≥40%, 0 otherwise
      int stars = 0;
      double pct = score / questions.length;
      if (pct >= 1.0) {
        stars = 3;
      } else if (pct >= 0.7)
        stars = 2;
      else if (pct >= 0.4) stars = 1;

      // Level completed — save with language-specific key
      setState(() {
        levelCompleted = true;
        earnedStars = stars;
        _confettiController.play();
      });
      saveGameProgressWithLang(
          widget.gameType, widget.language, level + 1, stars);
      stopTimer();
    } else {
      setState(() {
        questionIndex++;
        showCorrectAnswer = false;
        if (widget.gameType == "Timed Quiz") startTimer();
      });
    }
  }

  void goToNextLevel() {
    setState(() {
      level++;
      earnedStars = 0;
      generateLevelQuestions();
    });
    if (widget.gameType == "Timed Quiz") startTimer();
  }

  Widget buildProgressBar(bool isDark) {
    double progress = (questionIndex + 1) / questions.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${questionIndex + 1} / ${questions.length}   •   ✅ $score",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 8,
              width: (MediaQuery.of(context).size.width - 32) * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gameType == "Timed Quiz"
                      ? [Colors.orange, Colors.red]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _confettiController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── LEVEL COMPLETE SCREEN ──
    if (levelCompleted) {
      String rewardEmoji = ["🥉", "🥈", "🥇", "🏆"][earnedStars.clamp(0, 3)];
      List<String> rewardMessages = [
        "Keep practicing! 💪",
        "Good effort! 👍",
        "Great job! 🎉",
        "Perfect! Outstanding! 🌟"
      ];
      String msg = rewardMessages[earnedStars.clamp(0, 3)];

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFFAE8FF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(rewardEmoji, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 12),
                      Text(
                        "Level $level Complete!",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        msg,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            3,
                            (i) => Icon(
                                  i < earnedStars
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: i < earnedStars
                                      ? Colors.amber
                                      : (isDark
                                          ? Colors.white24
                                          : Colors.black12),
                                  size: 52,
                                )),
                      ),
                      const SizedBox(height: 24),
                      // Score card
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.07)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text("Score",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey)),
                                const SizedBox(height: 4),
                                Text("$score / ${questions.length}",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.purpleAccent
                                          : const Color(0xFF8B5CF6),
                                    )),
                              ],
                            ),
                            Container(
                                width: 1,
                                height: 36,
                                color: isDark
                                    ? Colors.white12
                                    : Colors.grey.shade200),
                            Column(
                              children: [
                                Text("Stars",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey)),
                                const SizedBox(height: 4),
                                Text("$earnedStars ⭐",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.amberAccent
                                          : Colors.amber.shade700,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              side: BorderSide(
                                  color: isDark
                                      ? Colors.white30
                                      : Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text("Exit",
                                style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey[700])),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: goToNextLevel,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 14),
                              backgroundColor: const Color(0xFF8B5CF6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 4,
                            ),
                            child: const Text(
                              "Next Level →",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.amber,
                    Colors.pink,
                    Colors.blue,
                    Colors.green,
                    Colors.orange
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── GAME QUESTION UI ──
    final currentQuestion = questions[questionIndex];

    // Game-type color theme
    List<Color> gameGradient;
    switch (widget.gameType) {
      case "Word Match":
        gameGradient = [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
        break;
      case "Guess the Word":
        gameGradient = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        break;
      case "Fill in the Blank":
        gameGradient = [const Color(0xFF10B981), const Color(0xFF059669)];
        break;
      case "Audio Guess":
        gameGradient = [const Color(0xFF06B6D4), const Color(0xFF0891B2)];
        break;
      case "Timed Quiz":
        gameGradient = [const Color(0xFFF43F5E), const Color(0xFFE11D48)];
        break;
      default:
        gameGradient = [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
    }

    // Option button colors
    const optionColors = [
      Color(0xFF6366F1),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFF43F5E),
    ];

    Widget gameUI;

    switch (widget.gameType) {
      case "Word Match":
        Map<String, String> pairs =
            Map<String, String>.from(currentQuestion["pairs"]);
        List<String> leftWords = pairs.keys.toList();
        List<String> rightWords = pairs.values.toList()..shuffle();
        String selectedWord = "";
        String message = "";

        gameUI = StatefulBuilder(builder: (context, setLocalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Tap a word on the left, then match it on the right",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: leftWords.map((word) {
                        bool isSelected = selectedWord == word;
                        return GestureDetector(
                          onTap: () => setLocalState(() {
                            selectedWord = word;
                            message = "";
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? gameGradient[0]
                                  : (isDark
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.indigo.shade50),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? gameGradient[0]
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              word,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: rightWords.map((meaning) {
                        return GestureDetector(
                          onTap: () {
                            if (selectedWord.isEmpty) return;
                            setLocalState(() {
                              if (pairs[selectedWord] == meaning) {
                                message = "✅ Correct!";
                                leftWords.remove(selectedWord);
                                rightWords.remove(meaning);
                                pairs.remove(selectedWord);
                                selectedWord = "";
                                if (pairs.isEmpty) nextQuestion(true);
                              } else {
                                message = "❌ Wrong! Try again";
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.transparent, width: 2),
                            ),
                            child: Text(
                              meaning,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: message.contains("✅") ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          );
        });
        break;

      case "Fill in the Blank":
        TextEditingController controller = TextEditingController();
        String answer = currentQuestion["answer"];
        gameUI = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                        color: Colors.teal.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                currentQuestion["sentence"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87, fontSize: 18),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                hintText: "Type the English word here",
                hintStyle:
                    TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade50,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gameGradient),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton(
                onPressed: () => nextQuestion(
                    controller.text.trim().toLowerCase() ==
                        answer.toLowerCase()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text("Submit",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            if (showCorrectAnswer) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text("Correct Answer: $correctAnswer",
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        if (questionIndex + 1 < questions.length) {
                          questionIndex++;
                        }
                        showCorrectAnswer = false;
                      }),
                      child: const Text("Next Question →"),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
        break;

      case "Audio Guess":
        List<String> options = List<String>.from(currentQuestion["options"]);
        String answer = currentQuestion["answer"];
        gameUI = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  await flutterTts.stop();
                  flutterTts.setLanguage(languageCode());
                  flutterTts.speak(answer);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gameGradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: gameGradient[0].withOpacity(0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Icon(Icons.volume_up_rounded,
                      color: Colors.white, size: 56),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text("Tap to hear the word",
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            const SizedBox(height: 24),
            ...List.generate(options.length, (i) {
              Color c = optionColors[i % optionColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c, c.withOpacity(0.85)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: c.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => nextQuestion(options[i] == answer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(options[i],
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }),
            if (showCorrectAnswer) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text("Correct: $correctAnswer",
                        style: const TextStyle(
                            fontSize: 17,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        if (questionIndex + 1 < questions.length) {
                          questionIndex++;
                        }
                        showCorrectAnswer = false;
                      }),
                      child: const Text("Next Question →"),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
        break;

      case "Guess the Word":
        List<String> options = List<String>.from(currentQuestion["options"]);
        String answer = currentQuestion["answer"];
        gameUI = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                        color: Colors.amber.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  Text("How do you say this in ${widget.language}?",
                      style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey[600])),
                  const SizedBox(height: 12),
                  Text(
                    getWordClueOrEmoji(currentQuestion["english"] ?? ""),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? Colors.amberAccent : const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(options.length, (i) {
              Color c = optionColors[i % optionColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c, c.withOpacity(0.85)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: c.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => nextQuestion(options[i] == answer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(options[i],
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }),
            if (showCorrectAnswer) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text("Correct: $correctAnswer",
                        style: const TextStyle(
                            fontSize: 17,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        if (questionIndex + 1 < questions.length) {
                          questionIndex++;
                        }
                        showCorrectAnswer = false;
                      }),
                      child: const Text("Next Question →"),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
        break;

      case "Timed Quiz":
        List<String> options = List<String>.from(currentQuestion["options"]);
        String answer = currentQuestion["answer"];
        String questionText = currentQuestion["question"] ?? "";
        double timerPct = timeLeft / 15.0;
        Color timerColor = timeLeft > 8
            ? Colors.green
            : (timeLeft > 4 ? Colors.orange : Colors.red);

        gameUI = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: timerPct,
                      backgroundColor:
                          isDark ? Colors.white12 : Colors.grey.shade200,
                      color: timerColor,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: timerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "⏱ ${timeLeft}s",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: timerColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                        color: Colors.red.withOpacity(0.07),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                ],
              ),
              child: Text(
                questionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(options.length, (i) {
              Color c = optionColors[i % optionColors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c, c.withOpacity(0.85)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: c.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      stopTimer();
                      nextQuestion(options[i] == answer);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(options[i],
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }),
            if (showCorrectAnswer) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text("Time's up! Correct: $correctAnswer",
                        style: const TextStyle(
                            fontSize: 17,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        if (questionIndex + 1 < questions.length) {
                          questionIndex++;
                          showCorrectAnswer = false;
                          startTimer();
                        }
                      }),
                      child: const Text("Next Question →"),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
        break;

      default:
        gameUI = const Center(child: Text("Unknown game type"));
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gameGradient),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.gameType,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Level $level · ${widget.language}",
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.grey)),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildProgressBar(isDark),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: gameUI)),
          ],
        ),
      ),
    );
  }

  Widget buildGameUI() {
    Map<String, dynamic> currentQuestion = questions[questionIndex];

    switch (widget.gameType) {
      case "Timed Quiz":
      case "Fill in the Blank":
        List<String> options =
            List<String>.from(currentQuestion["options"] ?? []);
        String answer = currentQuestion["answer"] ?? "";
        String questionText = currentQuestion["question"] ?? "";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  questionText,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (widget.gameType == "Timed Quiz")
                  Text(
                    "⏱ $timeLeft s",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...options.map(
              (option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade100,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => nextQuestion(option == answer),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            if (showCorrectAnswer)
              Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Correct Answer: $correctAnswer",
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        questionIndex++;
                        showCorrectAnswer = false;
                        if (widget.gameType == "Timed Quiz") {
                          startTimer();
                        }
                      });
                    },
                    child: const Text("Next Question →"),
                  ),
                ],
              ),
          ],
        );

      default:
        return const Center(child: Text("Game type not supported."));
    }
  }
}

/* ================= ABOUT SCREEN ================= */

class AboutSheet extends StatelessWidget {
  const AboutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "LangBuddy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.tealAccent : Colors.teal.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Learn languages through play — for everyone, everywhere",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              _sectionLabel("⚡  Core Features", isDark),
              _aboutTile(
                icon: Icons.extension,
                title: "Auto-Generated Games",
                desc:
                    "Word Match, Fill in the Blank & Timed Quiz — all adapting to your vocabulary.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.public,
                title: "Multi-Language Support",
                desc:
                    "Practice with French, German, Spanish, Hindi, Japanese, Arabic & 10+ more languages.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.emoji_events,
                title: "Levels & Rewards",
                desc:
                    "Endless difficulty levels with confetti celebrations, progress tracking & scores.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.search,
                title: "Smart Vocabulary Search",
                desc:
                    "Instantly search words and phrases across all supported languages.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.bar_chart,
                title: "Progress Tracking",
                desc:
                    "Visual progress bars and game history saved locally per language.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.volume_up,
                title: "Text-to-Speech Pronunciation",
                desc:
                    "Native pronunciation for every word with adjustable speed and pitch.",
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _sectionLabel("♿  Inclusive & Accessibility", isDark),
              _aboutTile(
                icon: Icons.font_download,
                title: "Dyslexia Support",
                desc:
                    "OpenDyslexic font mode, high-contrast colours & extra letter spacing for easier reading.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.sign_language,
                title: "Sign Language Companion",
                desc:
                    "Animated ISL/ASL signs for vocabulary words — learn language visually without sound.",
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _sectionLabel("🌍  Survival & Offline", isDark),
              _aboutTile(
                icon: Icons.local_hospital,
                title: "Survival Vocabulary Packs",
                desc:
                    "Emergency phrases, travel essentials, medical terms & disaster vocab — fully offline.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.psychology,
                title: "Offline AI Tutor",
                desc:
                    "A conversational AI tutor that works entirely offline — practise anytime, anywhere.",
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _sectionLabel("🏫  Community & School", isDark),
              _aboutTile(
                icon: Icons.people,
                title: "Community Vocabulary Packs",
                desc:
                    "Browse and play packs created by the LangBuddy community across topics & cultures.",
                isDark: isDark,
              ),
              _aboutTile(
                icon: Icons.school,
                title: "School Challenges",
                desc:
                    "Curriculum-aligned challenges and classroom competitions for students of all ages.",
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              const AppCredits(),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isDark ? Colors.tealAccent.shade100 : Colors.teal.shade700,
        ),
      ),
    );
  }

  Widget _aboutTile({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          desc,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }
}

class AppCredits extends StatefulWidget {
  const AppCredits({super.key});

  @override
  State<AppCredits> createState() => _AppCreditsState();
}

class _AppCreditsState extends State<AppCredits> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const version = "1.0.0";
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Version $version",
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Made with ❤️ for language learners by KEZIAH DOROTHY A G",
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
