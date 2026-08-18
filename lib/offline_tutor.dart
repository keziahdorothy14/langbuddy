import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dyslexia_helper.dart';
import 'main.dart'; // for vocabularyData and speak function

enum TutorState { greeting, vocabPractice, roleplay, grammarTip }

// Offline Multi-Language Dictionary & Phrase Mapping Engine
const Map<String, Map<String, String>> offlineDictionary = {
  "hello": {
    "English": "Hello",
    "French": "Bonjour",
    "Spanish": "Hola",
    "Hindi": "नमस्ते (Namaste)",
    "German": "Hallo",
    "Italian": "Ciao",
    "Chinese": "你好 (Nǐ hǎo)",
    "Japanese": "こんにちは (Konnichiwa)",
    "Korean": "안녕하세요 (Annyeonghaseyo)",
    "Russian": "Здравствуйте (Zdravstvuyte)",
    "Turkish": "Merhaba",
    "Vietnamese": "Xin chào",
    "Indonesian": "Halo",
    "Dutch": "Hallo"
  },
  "thank you": {
    "English": "Thank you",
    "French": "Merci",
    "Spanish": "Gracias",
    "Hindi": "धन्यवाद (Dhanyavaad)",
    "German": "Danke",
    "Italian": "Grazie",
    "Chinese": "谢谢 (Xièxiè)",
    "Japanese": "ありがとう (Arigatou)",
    "Korean": "감사합니다 (Gamsahamnida)",
    "Russian": "Спасибо (Spasibo)",
    "Turkish": "Teşekkür ederim",
    "Vietnamese": "Cảm ơn",
    "Indonesian": "Terima kasih",
    "Dutch": "Dank je"
  },
  "thanks": {
    "English": "Thanks",
    "French": "Merci",
    "Spanish": "Gracias",
    "Hindi": "धन्यवाद (Dhanyavaad)",
    "German": "Danke",
    "Italian": "Grazie",
    "Chinese": "谢谢 (Xièxiè)",
    "Japanese": "ありがとう (Arigatou)",
    "Korean": "고마워요 (Gomawoyo)",
    "Russian": "Спасибо (Spasibo)",
    "Turkish": "Teşekkürler",
    "Vietnamese": "Cảm ơn",
    "Indonesian": "Makasih",
    "Dutch": "Bedankt"
  },
  "goodbye": {
    "English": "Goodbye",
    "French": "Au revoir",
    "Spanish": "Adiós",
    "Hindi": "अलविदा (Alvida)",
    "German": "Auf Wiedersehen",
    "Italian": "Arrivederci",
    "Chinese": "再见 (Zàijiàn)",
    "Japanese": "さようなら (Sayounara)",
    "Korean": "안녕히 가세요 (Annyeonghi gaseyo)",
    "Russian": "До свидания (Do svidaniya)",
    "Turkish": "Hoşça kal",
    "Vietnamese": "Tạm biệt",
    "Indonesian": "Selamat tinggal",
    "Dutch": "Tot ziens"
  },
  "yes": {
    "English": "Yes",
    "French": "Oui",
    "Spanish": "Sí",
    "Hindi": "हाँ (Haan)",
    "German": "Ja",
    "Italian": "Sì",
    "Chinese": "是 (Shì)",
    "Japanese": "はい (Hai)",
    "Korean": "네 (Ne)",
    "Russian": "Да (Da)",
    "Turkish": "Evet",
    "Vietnamese": "Vâng",
    "Indonesian": "Ya",
    "Dutch": "Ja"
  },
  "no": {
    "English": "No",
    "French": "Non",
    "Spanish": "No",
    "Hindi": "नहीं (Nahin)",
    "German": "Nein",
    "Italian": "No",
    "Chinese": "不 (Bù)",
    "Japanese": "いいえ (Iie)",
    "Korean": "아니요 (Aniyo)",
    "Russian": "Нет (Net)",
    "Turkish": "Hayır",
    "Vietnamese": "Không",
    "Indonesian": "Tidak",
    "Dutch": "Nee"
  },
  "please": {
    "English": "Please",
    "French": "S'il vous plaît",
    "Spanish": "Por favor",
    "Hindi": "कृपया (Kripya)",
    "German": "Bitte",
    "Italian": "Per favore",
    "Chinese": "请 (Qǐng)",
    "Japanese": "お願いします (Onegaishimasu)",
    "Korean": "부탁합니다 (Butakhamnida)",
    "Russian": "Пожалуйста (Pozhaluysta)",
    "Turkish": "Lütfen",
    "Vietnamese": "Làm ơn",
    "Indonesian": "Tolong",
    "Dutch": "Alstublieft"
  },
  "water": {
    "English": "Water",
    "French": "Eau",
    "Spanish": "Agua",
    "Hindi": "पानी (Paani)",
    "German": "Wasser",
    "Italian": "Acqua",
    "Chinese": "水 (Shuǐ)",
    "Japanese": "水 (Mizu)",
    "Korean": "물 (Mul)",
    "Russian": "Вода (Voda)",
    "Turkish": "Su",
    "Vietnamese": "Nước",
    "Indonesian": "Air",
    "Dutch": "Water"
  },
  "food": {
    "English": "Food",
    "French": "Nourriture",
    "Spanish": "Comida",
    "Hindi": "खाना (Khana)",
    "German": "Essen",
    "Italian": "Cibo",
    "Chinese": "食物 (Shíwù)",
    "Japanese": "食べ物 (Tabemono)",
    "Korean": "음식 (Eumsik)",
    "Russian": "Еда (Yeda)",
    "Turkish": "Yemek",
    "Vietnamese": "Thức ăn",
    "Indonesian": "Makanan",
    "Dutch": "Voedsel"
  },
  "doctor": {
    "English": "Doctor",
    "French": "Médecin",
    "Spanish": "Médico",
    "Hindi": "डॉक्टर (Doctor)",
    "German": "Arzt",
    "Italian": "Dottore",
    "Chinese": "医生 (Yīshēng)",
    "Japanese": "医者 (Isha)",
    "Korean": "의사 (Uisa)",
    "Russian": "Врач (Vrach)",
    "Turkish": "Doktor",
    "Vietnamese": "Bác sĩ",
    "Indonesian": "Dokter",
    "Dutch": "Dokter"
  },
  "hospital": {
    "English": "Hospital",
    "French": "Hôpital",
    "Spanish": "Hospital",
    "Hindi": "अस्पताल (Aspataal)",
    "German": "Krankenhaus",
    "Italian": "Ospedale",
    "Chinese": "医院 (Yīyuàn)",
    "Japanese": "病院 (Byōin)",
    "Korean": "병원 (Byeongwon)",
    "Russian": "Больница (Bol'nitsa)",
    "Turkish": "Hastane",
    "Vietnamese": "Bệnh viện",
    "Indonesian": "Rumah sakit",
    "Dutch": "Ziekenhuis"
  },
  "where is": {
    "English": "Where is",
    "French": "Où est",
    "Spanish": "¿Dónde está",
    "Hindi": "कहां है (Kahan hai)",
    "German": "Wo ist",
    "Italian": "Dov'è",
    "Chinese": "在哪里 (Zài nǎlǐ)",
    "Japanese": "どこですか (Doko desu ka)",
    "Korean": "어디에 있나요 (Eodie innayo)",
    "Russian": "Где (Gde)",
    "Turkish": "Nerede",
    "Vietnamese": "Ở đâu",
    "Indonesian": "Di mana",
    "Dutch": "Waar is"
  },
  "how much": {
    "English": "How much",
    "French": "Combien",
    "Spanish": "¿Cuánto cuesta",
    "Hindi": "कितना है (Kitna hai)",
    "German": "Wie viel",
    "Italian": "Quanto costa",
    "Chinese": "多少钱 (Duōshǎo qián)",
    "Japanese": "いくらですか (Ikura desu ka)",
    "Korean": "얼마인가요 (Eolmaingayo)",
    "Russian": "Сколько стоит (Skol'ko stoit)",
    "Turkish": "Ne kadar",
    "Vietnamese": "Bao nhiêu",
    "Indonesian": "Berapa",
    "Dutch": "Hoeveel"
  },
  "help": {
    "English": "Help",
    "French": "Aide",
    "Spanish": "Ayuda",
    "Hindi": "मदद (Madad)",
    "German": "Hilfe",
    "Italian": "Aiuto",
    "Chinese": "帮助 (Bāngzhù)",
    "Japanese": "助けて (Tasukete)",
    "Korean": "도와주세요 (Dowajuseyo)",
    "Russian": "Помощь (Pomoshch')",
    "Turkish": "Yardım",
    "Vietnamese": "Giúp đỡ",
    "Indonesian": "Bantuan",
    "Dutch": "Hulp"
  },
};

const List<String> supportedLanguages = [
  "English",
  "French",
  "Spanish",
  "Hindi",
  "German",
  "Italian",
  "Portuguese",
  "Russian",
  "Chinese",
  "Japanese",
  "Korean",
  "Dutch",
  "Turkish",
  "Vietnamese",
  "Indonesian",
];

const Map<String, String> languageAliases = {
  'english': 'English',
  'french': 'French',
  'spanish': 'Spanish',
  'hindi': 'Hindi',
  'german': 'German',
  'italian': 'Italian',
  'portuguese': 'Portuguese',
  'russian': 'Russian',
  'chinese': 'Chinese',
  'japanese': 'Japanese',
  'korean': 'Korean',
  'dutch': 'Dutch',
  'turkish': 'Turkish',
  'vietnamese': 'Vietnamese',
  'indonesian': 'Indonesian',
};

const Map<String, Map<String, String>> exampleSentenceLibrary = {
  "hotel": {
    "Spanish": "Tengo una reserva en el hotel.",
    "German": "Ich habe eine Reservierung im Hotel.",
    "French": "J'ai une réservation à l'hôtel.",
    "Japanese": "ホテルに予約があります。",
  },
  "school": {
    "Spanish": "Voy a la escuela.",
    "German": "Ich gehe zur Schule.",
    "French": "Je vais à l'école.",
    "Japanese": "私は学校に行きます。",
  },
  "apple": {
    "Spanish": "Como una manzana.",
    "German": "Ich esse einen Apfel.",
    "French": "Je mange une pomme.",
    "Japanese": "私はリンゴを食べます。",
  },
  "love": {
    "Spanish": "El amor hace la vida más bella.",
    "German": "Liebe macht das Leben schöner.",
    "French": "L'amour rend la vie plus belle.",
    "Japanese": "愛は人生をより美しくします。",
  },
  "queso": {
    "Spanish": "El queso sabe delicioso.",
  },
};

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({required this.text, required this.isUser, required this.time});
}

class OfflineTutorScreen extends StatefulWidget {
  final String targetLanguage;
  const OfflineTutorScreen({super.key, required this.targetLanguage});

  @override
  State<OfflineTutorScreen> createState() => _OfflineTutorScreenState();
}

class _OfflineTutorScreenState extends State<OfflineTutorScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;

  bool _isListening = false;
  bool _isTutorTyping = false;
  bool _voiceResponseEnabled = true;

  TutorState _tutorState = TutorState.greeting;
  int _roleplayStep = 0;
  String _activeScenario = "";
  final Map<String, dynamic> _currentVocabTarget = {};

  String _difficultyLevel = 'normal';
  int _sessionCorrect = 0;
  int _sessionIncorrect = 0;
  final List<Map<String, dynamic>> _sessionHistory = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initTutorGreeting();
  }

  void _initTutorGreeting() {
    setState(() {
      _isTutorTyping = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(Message(
          text:
              "Hello! 👋 I am Buddy, your Offline AI Tutor. I can help you practice ${widget.targetLanguage} without any internet connection!\n\nWhat would you like to do?",
          isUser: false,
          time: DateTime.now(),
        ));
        _isTutorTyping = false;
      });
      _speakTutorResponse(_messages.last.text);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Speak out tutor responses (offline speech synthesis)
  Future<void> _speakTutorResponse(String text) async {
    if (!_voiceResponseEnabled) return;

    // Clean up emojis and markdown formatting before speaking
    String cleanText = text.replaceAll(RegExp(r'[^\w\s\.,!\?]'), '');

    final config = accessibilityNotifier.value;
    double speechRate = config.slowSpeech ? 0.35 : 0.45;

    await _flutterTts.stop();
    await _flutterTts.setLanguage("en-US"); // Explanations are in English
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.speak(cleanText);
  }

  String _startVocabPractice() {
    if (vocabularyData.isNotEmpty) {
      final randomItem =
          vocabularyData[Random().nextInt(vocabularyData.length)];
      _currentVocabTarget.clear();
      _currentVocabTarget.addAll(randomItem);
      String word = randomItem['word'] ?? '';
      return "📝 Vocabulary Quiz!\n\nHow do you translate the word '$word' into ${widget.targetLanguage}?";
    }
    return "📝 Vocabulary Practice:\n\nTry translating common everyday words like 'Hello', 'Thank you', or 'Water' into ${widget.targetLanguage}!";
  }

  String _getGrammarTip() {
    final tips = [
      "💡 Grammar Tip for ${widget.targetLanguage}:\n\nPay attention to word order! In many languages (like German or Japanese), verbs or key modifiers move to the end of subordinate clauses.",
      "💡 Grammar Tip for ${widget.targetLanguage}:\n\nNouns often have grammatical genders or specific articles. Always learn new nouns along with their primary article!",
      "💡 Grammar Tip for ${widget.targetLanguage}:\n\nRegular verbs follow predictable conjugation rules based on subject pronouns (I, You, We, They). Master key helper verbs first!",
    ];
    return tips[Random().nextInt(tips.length)];
  }

  String _evaluateVocabPractice(String userText) {
    String word = _currentVocabTarget['word'] ?? '';
    String target =
        (_currentVocabTarget['translations']?[widget.targetLanguage] ?? '')
            .toString()
            .toLowerCase();
    if (target.isNotEmpty && userText.toLowerCase().contains(target)) {
      return "🎉 Excellent! That's correct!\n\n'$word' in ${widget.targetLanguage} is indeed '$target'.\n\nType '1' or 'vocab' for another word, or ask me anything else!";
    }
    return "Good try! The standard ${widget.targetLanguage} translation for '$word' is: '$target'.\n\nKeep practicing! Type '1' for another quiz.";
  }

  String _evaluateRoleplay(String input) {
    _roleplayStep++;
    if (_roleplayStep == 1) {
      _activeScenario = input;
      return "🎭 Roleplay Started [ Scenario: $input ]\n\nTutor: \"Hello! Welcome. How can I assist you today?\"\n\n(Reply in ${widget.targetLanguage} or English to continue the conversation!)";
    } else if (_roleplayStep == 2) {
      return "🎭 Tutor: \"Great! Let me write that down for you. Is there anything else you need assistance with?\"\n\n(Reply to continue or type 'menu' to exit roleplay)";
    } else {
      _tutorState = TutorState.greeting;
      _activeScenario = "";
      return "👏 Roleplay completed! Great practice session.\n\nType 'menu' to return to the main options or ask any question!";
    }
  }

  void _submitMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _processUserMessage(text);
  }

  void _startSpeechListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
      });
    }
  }

  void _stopSpeechListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Offline AI Response Engine (Natural Language Processor + Heuristics)
  void _processUserMessage(String userText) {
    if (userText.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages
          .add(Message(text: userText, isUser: true, time: DateTime.now()));
      _isTutorTyping = true;
    });
    _scrollToBottom();

    final input = userText.toLowerCase().trim();

    // Small delay to simulate AI thinking
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      String reply = "";

      // 1. Menu Reset Commands
      if (input == "menu" ||
          input.contains("start over") ||
          input.contains("reset")) {
        _tutorState = TutorState.greeting;
        _roleplayStep = 0;
        _activeScenario = "";
        reply =
            "Let's start over! What would you like to ask or practice today?\n\n"
            "• Ask me to translate any sentence or word\n"
            "• Ask for situational helper (airport, hotel, restaurant, clinic, etc.)\n"
            "• Ask any grammar question\n"
            "• Or type 1 (Vocab Practice), 2 (Roleplay), 3 (Grammar Tips)";
      }
      // 2. Explicit Menu Option Selections
      else if (input == "1" ||
          (input.contains("vocab") && input.contains("practice"))) {
        _tutorState = TutorState.vocabPractice;
        reply = _startVocabPractice();
      } else if (input == "2" ||
          (input.contains("roleplay") && _activeScenario.isEmpty)) {
        _tutorState = TutorState.roleplay;
        _roleplayStep = 0;
        reply =
            "Let's simulate a real-world scenario. Choose a conversation pack:\n\n"
            "• Option A: [ At the Clinic ]\n"
            "• Option B: [ At the Bus Station ]\n"
            "• Option C: [ At the Retail Market ]";
      } else if (input == "3" ||
          (input.contains("grammar") && input.contains("tip"))) {
        _tutorState = TutorState.grammarTip;
        reply = _getGrammarTip();
      }
      // 3. Active Quiz / Roleplay State handlers
      else if (_tutorState == TutorState.vocabPractice &&
          (input.length <= 15 &&
              !input.contains("translate") &&
              !input.contains("how"))) {
        reply = _evaluateVocabPractice(userText);
      } else if (_tutorState == TutorState.roleplay &&
          _activeScenario.isNotEmpty) {
        reply = _evaluateRoleplay(input);
      }
      // 4. Accessibility / Display Adjustments
      else if (_isAccessibilityQuery(input)) {
        reply = _handleAccessibilityRequest();
      }
      // 5. Progress check
      else if (_isProgressQuery(input)) {
        reply = _handleProgressQuery();
      }
      // 6. Difficulty settings
      else if (_isDifficultyQuery(input)) {
        reply = _handleDifficultyRequest();
      }
      // 7. Sentence example requests
      else if (_isSentenceExampleQuery(input)) {
        reply = _handleSentenceExampleQuery(userText);
      }
      // 8. Pronunciation help
      else if (_isPronunciationQuery(input)) {
        reply = _handlePronunciationQuery(userText);
      }
      // 9. Freeform Translation Request Engine
      else if (_isTranslationQuery(input)) {
        reply = _handleTranslationQuery(userText);
      }
      // 10. Situational / Travel Helper Engine
      else if (_isSituationalQuery(input)) {
        reply = _handleSituationalQuery(userText);
      }
      // 11. Word Definition / Meaning Lookup Engine
      else if (_isMeaningQuery(input)) {
        reply = _handleMeaningQuery(userText);
      }
      // 12. Grammar Explanation Query Engine
      else if (_isGrammarQuery(input)) {
        reply = _handleGrammarQuery(userText);
      }
      // 13. Freeform Conversational Q&A
      else {
        reply = _handleConversationalQuery(userText);
      }

      setState(() {
        _messages
            .add(Message(text: reply, isUser: false, time: DateTime.now()));
        _isTutorTyping = false;
      });
      _scrollToBottom();
      _speakTutorResponse(reply);
    });
  }

  // --- NLP Intent Recognition Helpers ---

  bool _isTranslationQuery(String input) {
    return input.contains("translate") ||
        input.contains("how to say") ||
        input.contains("how do you say") ||
        input.contains("what is the word for") ||
        input.contains("in spanish") ||
        input.contains("in french") ||
        input.contains("in german") ||
        input.contains("in hindi") ||
        input.contains("in italian") ||
        input.contains("in japanese") ||
        input.contains("in chinese") ||
        input.contains("in russian") ||
        input.contains("in korean") ||
        input.contains("in dutch") ||
        input.contains("in turkish") ||
        input.contains("in vietnamese") ||
        input.contains("in indonesian");
  }

  bool _isSituationalQuery(String input) {
    return input.contains("lost") ||
        input.contains("airport") ||
        input.contains("hotel") ||
        input.contains("restaurant") ||
        input.contains("clinic") ||
        input.contains("hospital") ||
        input.contains("station") ||
        input.contains("ticket") ||
        input.contains("police") ||
        input.contains("embassy") ||
        input.contains("market") ||
        input.contains("taxi") ||
        input.contains("emergency") ||
        input.contains("sick") ||
        input.contains("fever") ||
        input.contains("order coffee") ||
        input.contains("directions");
  }

  bool _isMeaningQuery(String input) {
    return input.contains("what does") ||
        input.contains("meaning of") ||
        input.contains("define") ||
        input.contains("definition");
  }

  bool _isGrammarQuery(String input) {
    return input.contains("grammar") ||
        input.contains("verb") ||
        input.contains("tense") ||
        input.contains("conjugat") ||
        input.contains("gender") ||
        input.contains("plural") ||
        input.contains("pronoun") ||
        input.contains("adjective");
  }

  bool _isAccessibilityQuery(String input) {
    return input.contains("bigger text") ||
        input.contains("dyslexia") ||
        input.contains("pastel") ||
        input.contains("accessibility") ||
        input.contains("larger font");
  }

  bool _isProgressQuery(String input) {
    return input.contains("what did i learn") ||
        input.contains("what did i learn today") ||
        input.contains("progress") ||
        input.contains("learned today") ||
        input.contains("today i learned");
  }

  bool _isDifficultyQuery(String input) {
    return input.contains("make it harder") ||
        input.contains("harder") ||
        input.contains("make it easier") ||
        input.contains("easier") ||
        input.contains("difficulty");
  }

  bool _isSentenceExampleQuery(String input) {
    return input.contains("sentence") && input.contains("with") ||
        input.contains("example sentence") ||
        input.contains("give me a sentence");
  }

  bool _isPronunciationQuery(String input) {
    return input.contains("pronounce") ||
        input.contains("pronunciation") ||
        input.contains("how do i pronounce") ||
        input.contains("say it slowly") ||
        input.contains("slow replay");
  }

  bool _isFreeTranslationQuery(String input) {
    return input.contains("all 15 languages") ||
        input.contains("all languages") ||
        input.contains("every language");
  }

  // --- NLP Offline Handlers ---

  String _detectTargetLanguage(String text, String fallback) {
    final lower = text.toLowerCase();
    for (var alias in languageAliases.keys) {
      if (lower.contains(alias)) return languageAliases[alias]!;
    }
    return fallback;
  }

  List<String> _parseRequestedLanguages(String text) {
    final lower = text.toLowerCase();
    final requested = <String>{};
    for (var alias in languageAliases.keys) {
      if (lower.contains(alias)) {
        requested.add(languageAliases[alias]!);
      }
    }
    if (requested.isEmpty) {
      return [widget.targetLanguage];
    }
    return requested.toList();
  }

  String _extractPrimaryTerm(String text) {
    final quoteMatch = RegExp(r'''('([^']+)'|"([^"]+)")''').firstMatch(text);
    if (quoteMatch != null) {
      return (quoteMatch.group(1) ?? quoteMatch.group(2) ?? '').trim();
    }

    String cleaned = text.toLowerCase();
    cleaned = cleaned.replaceAll(
      RegExp(
          r'how to say|how do you say|how do i say|translate|translate to|what does|meaning of|define|definition|mean|the word|say|pronounce|pronunciation|sentence with|give me a sentence with|example sentence with|in english|in spanish|in german|in japanese|in french|in chinese|in russian|in korean|in dutch|in turkish|in vietnamese|in indonesian|all 15 languages|all languages|every language|please|can you|could you|i want|i need|into|to|for',
          caseSensitive: false),
      '',
    );
    for (var alias in languageAliases.keys) {
      cleaned = cleaned.replaceAll(alias, '');
    }
    cleaned = cleaned.replaceAll(RegExp(r'[^a-zA-ZÀ-ÿ0-9\s]'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  Map<String, String> _lookupTranslations(String term) {
    final normalized = term.toLowerCase();
    if (normalized.isEmpty) return {};

    for (var entry in vocabularyData) {
      final String word = (entry['word'] ?? '').toString();
      if (word.toLowerCase() == normalized) {
        return Map<String, String>.from(entry['translations'] ?? {});
      }
      final translations =
          Map<String, String>.from(entry['translations'] ?? {});
      for (var value in translations.values) {
        if (value.toLowerCase() == normalized) {
          return translations;
        }
      }
    }

    for (var key in offlineDictionary.keys) {
      if (key.toLowerCase() == normalized) {
        final map = <String, String>{};
        for (var lang in supportedLanguages) {
          map[lang] = offlineDictionary[key]?[lang] ?? key;
        }
        return map;
      }
      final translations = offlineDictionary[key]!;
      for (var value in translations.values) {
        if (value.toLowerCase() == normalized) {
          final map = <String, String>{};
          for (var lang in supportedLanguages) {
            map[lang] = translations[lang] ?? key;
          }
          return map;
        }
      }
      if (key.toLowerCase().contains(normalized) ||
          translations.values
              .any((v) => v.toLowerCase().contains(normalized))) {
        final map = <String, String>{};
        for (var lang in supportedLanguages) {
          map[lang] = translations[lang] ?? key;
        }
        return map;
      }
    }

    return {};
  }

  String _handleTranslationQuery(String userText) {
    final requestedLanguages = _parseRequestedLanguages(userText);
    final term = _extractPrimaryTerm(userText);
    final translations = _lookupTranslations(term);

    if (translations.isEmpty) {
      return "I don't have an exact offline match for '$term' right now, but I can still help with something related or give you a useful phrase. Try another common word like 'hotel', 'water', or 'help'.";
    }

    if (_isFreeTranslationQuery(userText)) {
      final output = StringBuffer(
          "🌎 Free Translation across ${supportedLanguages.length} languages for '$term':\n\n");
      for (var lang in supportedLanguages) {
        output.writeln("$lang: ${translations[lang] ?? term}");
      }
      return output.toString();
    }

    if (requestedLanguages.length > 1) {
      final output =
          StringBuffer("🌍 Multi-language translation for '$term':\n\n");
      for (var lang in requestedLanguages) {
        output.writeln("$lang: ${translations[lang] ?? term}");
      }
      output.writeln("\n📌 Pronunciation: [ ${getPhoneticHint(term)} ]");
      return output.toString();
    }

    final targetLang = requestedLanguages.first;
    final translation = translations[targetLang] ?? term;
    final phonetic = getPhoneticHint(term);
    _sessionHistory.add({
      'word': term,
      'language': targetLang,
      'type': 'translate',
      'time': DateTime.now().toIso8601String(),
    });
    return "🤖 Translation to $targetLang:\n\n✨ $translation\n\n📌 Pronunciation: [ $phonetic ]\n\nWould you like audio or a related example sentence?";
  }

  String _handlePronunciationQuery(String userText) {
    final term = _extractPrimaryTerm(userText);
    final phonetic = getPhoneticHint(term.isEmpty ? userText : term);
    return "🔊 Pronunciation Help:\n\n• Word: ${term.isEmpty ? userText : term}\n• Pronounced as: $phonetic\n\nType 'slow replay' to hear it slowly.";
  }

  String _handleSentenceExampleQuery(String userText) {
    final language = _detectTargetLanguage(userText, widget.targetLanguage);
    final term = _extractPrimaryTerm(userText).toLowerCase();
    final sentence = exampleSentenceLibrary[term]?[language];

    if (sentence != null && sentence.isNotEmpty) {
      return "📝 Example Sentence in $language:\n\n$sentence\n\nWould you like audio narration for this sentence?";
    }

    return "📝 I found the word '$term', but not a ready-made example sentence for $language offline yet. Ask me another word or try a common item like 'hotel' or 'school'.";
  }

  String _handleProgressQuery() {
    final totalSessions = _sessionHistory.length;
    final todaysWords =
        _sessionHistory.map((item) => item['word'] as String).toSet().length;
    return "📊 Today's Progress:\n\n• Words practiced: $todaysWords\n• Total actions: $totalSessions\n• Correct answers: $_sessionCorrect\n• Mistakes corrected: $_sessionIncorrect\n\nKeep going—ask for another quiz or practice session!";
  }

  String _handleDifficultyRequest() {
    if (_difficultyLevel == 'normal') {
      _difficultyLevel = 'hard';
      return "⚡ Let's make it harder. Let's try intermediate words like 'biblioteca' (library).\n\nType '1' for a harder vocabulary quiz.";
    }
    if (_difficultyLevel == 'hard') {
      _difficultyLevel = 'easy';
      return "🌱 Switching to easier words so you can build confidence. We'll keep sentences short and clear.\n\nType '1' for an easier practice round.";
    }
    return "🎯 Difficulty mode is set to $_difficultyLevel. Type '1' for a new vocabulary quiz.";
  }

  String _handleAccessibilityRequest() {
    final current = accessibilityNotifier.value;
    final updated = current.copyWith(
      useDyslexiaFont: true,
      fontSizeMultiplier: 1.35,
      letterSpacingMultiplier: 1.5,
      wordSpacingMultiplier: 1.4,
      highContrast: false,
    );
    accessibilityNotifier.value = updated;
    saveAccessibilitySetting('useDyslexiaFont', true);
    saveAccessibilitySetting('fontSizeMultiplier', 1.35);
    saveAccessibilitySetting('letterSpacingMultiplier', 1.5);
    saveAccessibilitySetting('wordSpacingMultiplier', 1.4);
    return "♿ Dyslexia-friendly mode is on. Text is larger with soft pastel styling, and audio narration is still available. Ask me to continue with flashcards or pronunciation.";
  }

  Map<String, dynamic>? _lookupVocabularyEntry(String term) {
    final normalized = term.toLowerCase();
    if (normalized.isEmpty) return null;
    for (var entry in vocabularyData) {
      final word = (entry['word'] ?? '').toString();
      if (word.toLowerCase() == normalized) return entry;
      final translations =
          Map<String, String>.from(entry['translations'] ?? {});
      for (var value in translations.values) {
        if (value.toLowerCase() == normalized) return entry;
      }
    }
    return null;
  }

  String _getExampleSentenceText(String key, String language) {
    return exampleSentenceLibrary[key.toLowerCase()]?[language] ?? '';
  }

  String _handleMeaningQuery(String userText) {
    final term = _extractPrimaryTerm(userText);
    final targetLang = _detectTargetLanguage(userText, 'English');
    final entry = _lookupVocabularyEntry(term);

    if (entry != null) {
      final translations =
          Map<String, String>.from(entry['translations'] ?? {});
      final englishWord = (entry['word'] ?? '').toString();
      final responseWord = translations[targetLang] ?? englishWord;
      final exampleSentence = _getExampleSentenceText(englishWord, targetLang);
      final exampleSuffix =
          exampleSentence.isNotEmpty ? "\n\nExample: $exampleSentence" : '';
      return "📖 $englishWord means '$responseWord' in $targetLang.$exampleSuffix\n\nPronunciation: [ ${getPhoneticHint(englishWord)} ]";
    }

    return "📖 I couldn't find an offline meaning for '$term' yet. Try asking about a common word like 'apple', 'hotel', or 'school'.";
  }

  Map<String, dynamic> _selectPracticeWord() {
    final candidates = vocabularyData.where((entry) {
      final word = (entry['word'] ?? '').toString();
      if (_difficultyLevel == 'hard') {
        return word.length > 6;
      } else if (_difficultyLevel == 'easy') {
        return word.length <= 6;
      }
      return true;
    }).toList();
    if (candidates.isEmpty) {
      return vocabularyData[Random().nextInt(vocabularyData.length)];
    }
    return candidates[Random().nextInt(candidates.length)];
  }

  void _recordPracticeResult(String word, bool correct) {
    if (correct) {
      _sessionCorrect += 1;
    } else {
      _sessionIncorrect += 1;
    }
    _sessionHistory.add({
      'word': word,
      'language': widget.targetLanguage,
      'correct': correct,
      'time': DateTime.now().toIso8601String(),
    });
  }

  String _handleSituationalQuery(String userText) {
    final targetLang = _detectTargetLanguage(userText, widget.targetLanguage);
    final lower = userText.toLowerCase();

    if (lower.contains("airport") ||
        lower.contains("ticket") ||
        lower.contains("flight")) {
      return "✈️ [Situational Helper: At the Airport]\n\nHere are essential phrases in $targetLang:\n\n"
          "1. \"Where is gate 5?\" -> [ $targetLang Translation: Where is the gate ]\n"
          "2. \"I lost my passport.\" -> [ Need help finding passport ]\n"
          "3. \"Where can I buy a ticket?\" -> [ Ticket assistance ]\n\n"
          "💡 Tip: Show your ticket on your screen if you need quick direction from airport staff!";
    } else if (lower.contains("hotel") || lower.contains("room")) {
      return "🏨 [Situational Helper: At the Hotel]\n\nKey $targetLang phrases for check-in:\n\n"
          "1. \"I have a reservation.\" -> [ Hotel reservation ]\n"
          "2. \"What time is check-out?\" -> [ Check out timing ]\n"
          "3. \"Is Wi-Fi included?\" -> [ Wi-Fi query ]\n\n"
          "Would you like me to translate any of these into $targetLang?";
    } else if (lower.contains("lost") || lower.contains("direction")) {
      return "🗺️ [Situational Helper: Directions & Lost]\n\nUseful $targetLang expressions when lost:\n\n"
          "1. \"I am lost, can you help me?\"\n"
          "2. \"Where is the nearest subway station?\"\n"
          "3. \"Please show me on the map.\"\n\n"
          "💡 Tip: Keep emergency embassy contacts saved offline!";
    }

    return "💡 [Situational Helper for ${widget.targetLanguage}]\n\n"
        "Here are key emergency & travel phrases in ${widget.targetLanguage}:\n\n"
        "• \"I need help.\" -> (Emergency assistance)\n"
        "• \"Where is the hospital?\" -> (Healthcare request)\n"
        "• \"Please write it down.\" -> (Communication helper)\n\n"
        "Ask me to translate any specific sentence you need!";
  }

  String _handleGrammarQuery(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains("verb") || lower.contains("conjugat")) {
      return "💡 Offline Grammar Helper: Verbs in ${widget.targetLanguage}\n\n"
          "Verb endings change depending on the subject (I, You, He/She, We, They).\n"
          "E.g., In Spanish & French, present tense verbs add regular suffixes (-o, -as, -a vs -e, -es, -e).\n\n"
          "Would you like another grammar rule or quiz?";
    }

    return _getGrammarTip();
  }

  String _handleConversationalQuery(String userText) {
    final lower = userText.toLowerCase();

    if (lower.contains("hello") ||
        lower.contains("hi") ||
        lower.contains("hey")) {
      return "Hey! I'm Buddy, your offline language buddy. 😊 I can help you with translations, grammar, travel phrases, or just chat in ${widget.targetLanguage}. What would you like to do today?";
    } else if (lower.contains("who are you") ||
        lower.contains("what can you do")) {
      return "I’m Buddy, your friendly offline tutor and conversation partner. I can help you:\n"
          "• translate words and sentences\n"
          "• explain grammar in a simple way\n"
          "• give quick travel phrases for airport, hotel, restaurant and clinic situations\n"
          "• practice conversation, quizzes and pronunciation\n\n"
          "Just ask me anything, and I’ll keep it casual and helpful.";
    } else if (lower.contains("thank")) {
      return "You’re welcome! 😊 I’m happy to help anytime. Want to try another word or phrase?";
    }

    return "I’m here to chat and help with ${widget.targetLanguage}. Ask me to translate a word, give you a travel sentence, or explain a grammar point. I’ve got you!";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilityConfig>(
      valueListenable: accessibilityNotifier,
      builder: (context, accessConfig, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: getDyslexiaBackgroundColor(context),
          appBar: AppBar(
            title: const Text("Offline AI Voice Tutor"),
            backgroundColor:
                isDark ? const Color(0xFF1E1E32) : const Color(0xFF4A5CF0),
            actions: [
              IconButton(
                icon: Icon(
                    _voiceResponseEnabled ? Icons.volume_up : Icons.volume_off),
                onPressed: () {
                  setState(() {
                    _voiceResponseEnabled = !_voiceResponseEnabled;
                  });
                  if (!_voiceResponseEnabled) _flutterTts.stop();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // ── Chat Messages ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.82),
                        decoration: getDyslexiaCardDecoration(
                          context,
                          defaultColor: msg.isUser
                              ? (isDark ? Colors.teal : const Color(0xFF4A5CF0))
                              : (isDark
                                  ? const Color(0xFF1E1E32)
                                  : Colors.white),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User message is straight text, tutor message is dyslexia styled
                            msg.isUser
                                ? Text(
                                    msg.text,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                  )
                                : DyslexicText(
                                    msg.text,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              "${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: 10,
                                color:
                                    msg.isUser ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Tutor Typing Indicator ──
              if (_isTutorTyping)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.teal),
                        ),
                        SizedBox(width: 10),
                        Text("Buddy is thinking...",
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

              // ── Quick Suggestions Bar ──
              if (_messages.isNotEmpty && !_isTutorTyping)
                _buildQuickSuggestionsBar(),

              // ── Input & Voice Bar ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                color: isDark ? const Color(0xFF16162A) : Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: "Ask anything, translate, or speak...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF0F0F1E)
                              : const Color(0xFFF0F2FF),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (v) => _submitMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Voice Dictation Microphone Button (Offline STT)
                    GestureDetector(
                      onLongPressStart: (_) => _startSpeechListening(),
                      onLongPressEnd: (_) => _stopSpeechListening(),
                      child: FloatingActionButton(
                        heroTag: "mic_btn",
                        mini: true,
                        backgroundColor:
                            _isListening ? Colors.red : Colors.teal,
                        onPressed: () {
                          if (_isListening) {
                            _stopSpeechListening();
                          } else {
                            _startSpeechListening();
                          }
                        },
                        child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Send Button
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.teal),
                      onPressed: _submitMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickSuggestionsBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    List<String> suggestions = [
      "How do you say 'school' in Spanish, German, and Japanese?",
      "How do I pronounce 'queso'?",
      "Give me a sentence with 'hotel' in Spanish.",
      "Can you show me words with bigger text?",
      "What did I learn today?",
      "Translate 'love' into all 15 languages.",
      "1. Vocab Practice",
      "2. Chat Roleplay",
      "3. Grammar Tips"
    ];

    return Container(
      height: 46,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              backgroundColor:
                  isDark ? const Color(0xFF1E1E32) : Colors.teal.shade50,
              label: Text(
                suggestions[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.tealAccent : Colors.teal.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                _textController.text = suggestions[index];
                _submitMessage();
              },
            ),
          );
        },
      ),
    );
  }
}
