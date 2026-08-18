import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dyslexia_helper.dart';
import 'main.dart'; // import speak and vocabularyData

// ================= OFFLINE ENCODING SCHEMES =================

// Compresses and encodes challenge settings to Base64 (fully offline)
String encodeChallenge(
    String language, int wordCount, int targetScore, List<String> words) {
  final Map<String, dynamic> data = {
    "l": language,
    "c": wordCount,
    "t": targetScore,
    "w": words,
    "i": "LBC-${Random().nextInt(9000) + 1000}" // unique challenge id
  };

  final String jsonStr = jsonEncode(data);
  final List<int> bytes = utf8.encode(jsonStr);
  return base64Url.encode(bytes);
}

// Decodes the challenge string
Map<String, dynamic>? decodeChallenge(String code) {
  try {
    final List<int> bytes = base64Url.decode(code.trim());
    final String jsonStr = utf8.decode(bytes);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  } catch (e) {
    return null;
  }
}

// Compresses completion result to verification string
String encodeCompletion(
    String challengeId, String studentName, int score, int total) {
  final Map<String, dynamic> data = {
    "i": challengeId,
    "s": studentName,
    "r": score,
    "m": total,
    "d": DateTime.now().toIso8601String().substring(0, 10),
    "v": "LB-VERIFIED"
  };

  final String jsonStr = jsonEncode(data);
  final List<int> bytes = utf8.encode(jsonStr);
  return base64Url.encode(bytes);
}

// Decodes completion details for the teacher
Map<String, dynamic>? decodeCompletion(String verificationCode) {
  try {
    final List<int> bytes = base64Url.decode(verificationCode.trim());
    final String jsonStr = utf8.decode(bytes);
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (data["v"] == "LB-VERIFIED") {
      return data;
    }
    return null;
  } catch (e) {
    return null;
  }
}

// ================= PRIMARY UI PORTAL =================

class SchoolChallengesScreen extends StatefulWidget {
  final String currentLanguage;
  const SchoolChallengesScreen({super.key, required this.currentLanguage});

  @override
  State<SchoolChallengesScreen> createState() => _SchoolChallengesScreenState();
}

class _SchoolChallengesScreenState extends State<SchoolChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF4F6FF),
      appBar: AppBar(
        title: const Text("School Homework Portal"),
        backgroundColor:
            isDark ? const Color(0xFF1E1E32) : const Color(0xFF4A5CF0),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          tabs: const [
            Tab(icon: Icon(Icons.school_rounded), text: "Student Portal"),
            Tab(
                icon: Icon(Icons.dashboard_customize_rounded),
                text: "Create Task"),
            Tab(icon: Icon(Icons.verified_user_rounded), text: "Verify Scores"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentPortal(isDark),
          _buildTeacherCreator(isDark),
          _buildTeacherVerifier(isDark),
        ],
      ),
    );
  }

  // ── Tab 1: Student Mode (Run Assignments) ──
  final TextEditingController _studentCodeController = TextEditingController();

  Widget _buildStudentPortal(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: isDark ? const Color(0xFF1E1E32) : Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment_ind_rounded,
                          color: Colors.teal, size: 24),
                      SizedBox(width: 10),
                      Text("Enter Homework Code",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Paste the challenge code provided by your teacher to unlock your custom vocabulary tasks. Work offline, and copy your completion receipt code to submit to your teacher.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _studentCodeController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  "Paste challenge code here (e.g. eyJsIjoiU3BhbmlzaCIsImMiOjV9...)",
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E32) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill_rounded),
            label: const Text("Unlock and Start Challenge"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              final challenge = decodeChallenge(_studentCodeController.text);
              if (challenge == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "❌ Invalid challenge code. Please verify and try again.")),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StudentChallengeRunner(challengeData: challenge),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Tab 2: Teacher Challenge Creator ──
  int _selectedWordCount = 5;
  int _selectedPassScore = 80;
  String _creatorLanguage = "Spanish";
  String _generatedCode = "";

  Widget _buildTeacherCreator(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Create Custom Task",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Language selector
          ListTile(
            title: const Text("Assignment Language"),
            trailing: DropdownButton<String>(
              value: _creatorLanguage,
              items: [
                "English",
                "French",
                "Spanish",
                "Hindi",
                "German",
                "Italian",
                "Portuguese",
                "Russian",
                "Korean",
                "Japanese",
                "Dutch",
                "Turkish",
                "Vietnamese",
                "Indonesian",
                "Chinese"
              ]
                  .map((lang) =>
                      DropdownMenuItem(value: lang, child: Text(lang)))
                  .toList(),
              onChanged: (v) => setState(() => _creatorLanguage = v!),
            ),
          ),
          // Word count slider
          ListTile(
            title: Text("Number of words: $_selectedWordCount"),
            subtitle: Slider(
              value: _selectedWordCount.toDouble(),
              min: 3,
              max: 15,
              divisions: 12,
              activeColor: Colors.teal,
              onChanged: (v) => setState(() => _selectedWordCount = v.round()),
            ),
          ),
          // Pass score slider
          ListTile(
            title: Text("Passing Target: $_selectedPassScore%"),
            subtitle: Slider(
              value: _selectedPassScore.toDouble(),
              min: 50,
              max: 100,
              divisions: 10,
              activeColor: Colors.teal,
              onChanged: (v) => setState(() => _selectedPassScore = v.round()),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.bolt_rounded),
            label: const Text("Compile Homework Code"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              if (vocabularyData.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Error: vocabulary list is empty.")),
                );
                return;
              }
              // Randomly pick unique words from main vocabulary dataset
              final rand = Random();
              final wordsList = List<Map<String, dynamic>>.from(vocabularyData)
                ..shuffle(rand);
              final List<String> chosenWords = wordsList
                  .take(_selectedWordCount)
                  .map((e) => e["word"].toString())
                  .toList();

              setState(() {
                _generatedCode = encodeChallenge(_creatorLanguage,
                    _selectedWordCount, _selectedPassScore, chosenWords);
              });
            },
          ),
          if (_generatedCode.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text("Shareable Challenge Code:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E32) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                _generatedCode,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Copy this code and write it on the blackboard, or distribute it to your students. They can load it completely offline.",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ]
        ],
      ),
    );
  }

  // ── Tab 3: Teacher Verification Console ──
  final TextEditingController _verifierController = TextEditingController();
  Map<String, dynamic>? _verifiedReceipt;

  Widget _buildTeacherVerifier(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Verify Student Completion Code",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _verifierController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Paste student completion code here...",
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E32) : Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.verified_rounded),
            label: const Text("Verify Offline Code"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              final receipt = decodeCompletion(_verifierController.text);
              setState(() {
                _verifiedReceipt = receipt;
              });
              if (receipt == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          "❌ Invalid completion code. Verification failed.")),
                );
              }
            },
          ),
          if (_verifiedReceipt != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                border: Border.all(color: Colors.teal, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text("VERIFIED OFFLINE RECEIPT",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.teal)),
                    ],
                  ),
                  const Divider(height: 20),
                  Text("Student Name: ${_verifiedReceipt!["s"]}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Challenge ID: ${_verifiedReceipt!["i"]}"),
                  const SizedBox(height: 6),
                  Text(
                      "Score: ${_verifiedReceipt!["r"]} / ${_verifiedReceipt!["m"]} correct answers"),
                  const SizedBox(height: 6),
                  Text("Completion Date: ${_verifiedReceipt!["d"]}"),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================= STUDENT CHALLENGE RUNNER GAME SCREEN =================

class StudentChallengeRunner extends StatefulWidget {
  final Map<String, dynamic> challengeData;
  const StudentChallengeRunner({super.key, required this.challengeData});

  @override
  State<StudentChallengeRunner> createState() => _StudentChallengeRunnerState();
}

class _StudentChallengeRunnerState extends State<StudentChallengeRunner> {
  final TextEditingController _nameController = TextEditingController();
  bool _nameEntered = false;

  int _currentIndex = 0;
  int _score = 0;
  List<String> _words = [];
  String _language = "";
  int _passTarget = 80;
  String _challengeId = "";

  List<String> _options = [];
  String _correctAnswer = "";
  bool _quizFinished = false;
  String _completionReceiptCode = "";

  @override
  void initState() {
    super.initState();
    _language = widget.challengeData["l"] ?? "Spanish";
    _passTarget = widget.challengeData["t"] ?? 80;
    _challengeId = widget.challengeData["i"] ?? "";
    _words = List<String>.from(widget.challengeData["w"] ?? []);
  }

  void _setupQuestion() {
    final currentWordText = _words[_currentIndex];

    // Find item details from global vocabulary database
    final wordEntry = vocabularyData.firstWhere(
      (e) =>
          e["word"].toString().toLowerCase() == currentWordText.toLowerCase(),
      orElse: () => {
        "word": currentWordText,
        "translations": {_language: currentWordText}
      },
    );

    _correctAnswer = wordEntry["translations"][_language] ?? currentWordText;

    // Generate wrong options
    List<String> wrong = [];
    final rand = Random();
    final List<Map<String, dynamic>> choices = List.from(vocabularyData)
      ..shuffle(rand);
    for (var c in choices) {
      String trans = c["translations"][_language] ?? "";
      if (trans.isNotEmpty &&
          trans != _correctAnswer &&
          !wrong.contains(trans)) {
        wrong.add(trans);
      }
      if (wrong.length >= 2) break;
    }

    while (wrong.length < 2) {
      wrong.add("Option-${rand.nextInt(100)}");
    }

    _options = [_correctAnswer, ...wrong]..shuffle();
  }

  void _answerQuestion(String choice) {
    if (choice == _correctAnswer) {
      _score++;
    }

    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _setupQuestion();
      });
    } else {
      // Completed, generate completion signature
      final code = encodeCompletion(
          _challengeId, _nameController.text.trim(), _score, _words.length);
      setState(() {
        _quizFinished = true;
        _completionReceiptCode = code;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_nameEntered) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF4F6FF),
        appBar: AppBar(title: const Text("Enter Name to Start")),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Please enter your full name before beginning:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Your Name...",
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E32) : Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) return;
                  setState(() {
                    _nameEntered = true;
                    _setupQuestion();
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Start Assignment",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              )
            ],
          ),
        ),
      );
    }

    if (_quizFinished) {
      final success = ((_score / _words.length) * 100) >= _passTarget;
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF4F6FF),
        appBar: AppBar(title: const Text("Challenge Finished")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  success ? "🎉 Challenge Passed!" : "⚠️ Challenge Completed",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: success ? Colors.green : Colors.orange),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Score: $_score / ${_words.length} correct answers\nTarget pass score was $_passTarget%",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              const Text("Completion Code Receipt (Submit to teacher):",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E32) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  _completionReceiptCode,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Copy this entire code and show it to your teacher. Your teacher will paste it on their device to verify your score offline.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          ),
        ),
      );
    }

    final currentWordText = _words[_currentIndex];
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF4F6FF),
      appBar: AppBar(
          title: Text("Challenge task ${_currentIndex + 1}/${_words.length}")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Translate the English word to $_language:",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: DyslexicText(
                currentWordText,
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 50),
            ..._options.map((opt) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal.shade50,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _answerQuestion(opt),
                  child: Text(opt, style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
