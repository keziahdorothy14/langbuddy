import 'package:flutter/material.dart';
import 'dart:math';

// ================= HAND POSE REPRESENTATION =================

class FingerPose {
  final double
      fold; // 0.0 = fully extended (straight), 1.0 = fully folded (curled)
  final double angleOffset; // in radians, relative to base finger direction

  const FingerPose({required this.fold, this.angleOffset = 0.0});

  // Linear interpolation for smooth transitions
  static FingerPose lerp(FingerPose a, FingerPose b, double t) {
    return FingerPose(
      fold: a.fold + (b.fold - a.fold) * t,
      angleOffset: a.angleOffset + (b.angleOffset - a.angleOffset) * t,
    );
  }
}

class HandPose {
  final FingerPose thumb;
  final FingerPose index;
  final FingerPose middle;
  final FingerPose ring;
  final FingerPose pinky;
  final double wristRotation; // in radians

  const HandPose({
    required this.thumb,
    required this.index,
    required this.middle,
    required this.ring,
    required this.pinky,
    this.wristRotation = 0.0,
  });

  static HandPose lerp(HandPose a, HandPose b, double t) {
    return HandPose(
      thumb: FingerPose.lerp(a.thumb, b.thumb, t),
      index: FingerPose.lerp(a.index, b.index, t),
      middle: FingerPose.lerp(a.middle, b.middle, t),
      ring: FingerPose.lerp(a.ring, b.ring, t),
      pinky: FingerPose.lerp(a.pinky, b.pinky, t),
      wristRotation: a.wristRotation + (b.wristRotation - a.wristRotation) * t,
    );
  }
}

// ================= ASL FINGERSPELLING KEYFRAMES =================

const HandPose poseFist = HandPose(
  thumb: FingerPose(fold: 1.0, angleOffset: -0.2),
  index: FingerPose(fold: 1.0),
  middle: FingerPose(fold: 1.0),
  ring: FingerPose(fold: 1.0),
  pinky: FingerPose(fold: 1.0),
);

const HandPose poseOpen = HandPose(
  thumb: FingerPose(fold: 0.0, angleOffset: 0.3),
  index: FingerPose(fold: 0.0),
  middle: FingerPose(fold: 0.0),
  ring: FingerPose(fold: 0.0),
  pinky: FingerPose(fold: 0.0),
);

// Map A-Z letters to ASL hand poses
final Map<String, HandPose> aslPoses = {
  'A': const HandPose(
    thumb:
        FingerPose(fold: 0.0, angleOffset: -0.15), // thumb upright along side
    index: FingerPose(fold: 1.0),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'B': const HandPose(
    thumb: FingerPose(fold: 1.0, angleOffset: -0.3), // thumb crossed in front
    index: FingerPose(fold: 0.0),
    middle: FingerPose(fold: 0.0),
    ring: FingerPose(fold: 0.0),
    pinky: FingerPose(fold: 0.0),
  ),
  'C': const HandPose(
    thumb: FingerPose(fold: 0.5, angleOffset: 0.2),
    index: FingerPose(fold: 0.5, angleOffset: 0.1),
    middle: FingerPose(fold: 0.5, angleOffset: 0.1),
    ring: FingerPose(fold: 0.5, angleOffset: 0.1),
    pinky: FingerPose(fold: 0.5, angleOffset: 0.1),
  ),
  'D': const HandPose(
    thumb: FingerPose(fold: 0.7, angleOffset: -0.2),
    index: FingerPose(fold: 0.0), // index up
    middle: FingerPose(fold: 0.7),
    ring: FingerPose(fold: 0.7),
    pinky: FingerPose(fold: 0.7),
  ),
  'E': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.3),
    index: FingerPose(fold: 0.8),
    middle: FingerPose(fold: 0.8),
    ring: FingerPose(fold: 0.8),
    pinky: FingerPose(fold: 0.8),
  ),
  'F': const HandPose(
    thumb: FingerPose(fold: 0.7, angleOffset: -0.1), // thumb touches index
    index: FingerPose(fold: 0.7, angleOffset: 0.1),
    middle: FingerPose(fold: 0.0),
    ring: FingerPose(fold: 0.0),
    pinky: FingerPose(fold: 0.0),
  ),
  'G': const HandPose(
    thumb: FingerPose(fold: 0.0, angleOffset: -0.4), // pointing sideways
    index: FingerPose(fold: 0.0, angleOffset: -0.4),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
    wristRotation: -pi / 2, // Rotate sideways
  ),
  'H': const HandPose(
    thumb: FingerPose(fold: 0.9, angleOffset: -0.3),
    index: FingerPose(fold: 0.0, angleOffset: -0.4),
    middle: FingerPose(fold: 0.0, angleOffset: -0.4),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
    wristRotation: -pi / 2,
  ),
  'I': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 1.0),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 0.0), // pinky extended
  ),
  'J': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 1.0),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 0.0),
    wristRotation: 0.3, // slight twist
  ),
  'K': const HandPose(
    thumb: FingerPose(fold: 0.2, angleOffset: -0.1), // thumb up, touches middle
    index: FingerPose(fold: 0.0),
    middle: FingerPose(fold: 0.0, angleOffset: 0.15),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'L': const HandPose(
    thumb: FingerPose(fold: 0.0, angleOffset: 0.6), // thumb out wide
    index: FingerPose(fold: 0.0), // index up
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'M': const HandPose(
    thumb: FingerPose(fold: 0.9, angleOffset: -0.4), // tucked deep
    index: FingerPose(fold: 0.95),
    middle: FingerPose(fold: 0.95),
    ring: FingerPose(fold: 0.95),
    pinky: FingerPose(fold: 1.0),
  ),
  'N': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.3),
    index: FingerPose(fold: 0.95),
    middle: FingerPose(fold: 0.95),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'O': const HandPose(
    thumb: FingerPose(fold: 0.6, angleOffset: 0.25),
    index: FingerPose(fold: 0.6, angleOffset: 0.15),
    middle: FingerPose(fold: 0.6, angleOffset: 0.15),
    ring: FingerPose(fold: 0.6, angleOffset: 0.15),
    pinky: FingerPose(fold: 0.6, angleOffset: 0.15),
  ),
  'P': const HandPose(
    thumb: FingerPose(fold: 0.2, angleOffset: 0.1),
    index: FingerPose(fold: 0.0),
    middle: FingerPose(fold: 0.0, angleOffset: 0.2),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
    wristRotation: pi / 2, // Pointing down
  ),
  'Q': const HandPose(
    thumb: FingerPose(fold: 0.0, angleOffset: -0.4),
    index: FingerPose(fold: 0.0, angleOffset: -0.4),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
    wristRotation: pi / 2, // Pointing down
  ),
  'R': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 0.0, angleOffset: 0.05), // crossed
    middle: FingerPose(fold: 0.0, angleOffset: -0.05), // crossed
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'S': const HandPose(
    thumb: FingerPose(
        fold: 1.0, angleOffset: -0.3), // fist with thumb over fingers
    index: FingerPose(fold: 1.0),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'T': const HandPose(
    thumb: FingerPose(fold: 0.5, angleOffset: -0.1), // tucked under index
    index: FingerPose(fold: 0.85),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'U': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 0.0, angleOffset: 0.02), // closed tight
    middle: FingerPose(fold: 0.0, angleOffset: -0.02),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'V': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 0.0, angleOffset: -0.15), // V spread
    middle: FingerPose(fold: 0.0, angleOffset: 0.15),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'W': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 0.0, angleOffset: -0.2),
    middle: FingerPose(fold: 0.0, angleOffset: 0.0),
    ring: FingerPose(fold: 0.0, angleOffset: 0.2),
    pinky: FingerPose(fold: 1.0),
  ),
  'X': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 0.4, angleOffset: 0.1), // hooked index
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
  ),
  'Y': const HandPose(
    thumb: FingerPose(fold: 0.0, angleOffset: 0.7), // thumb wide
    index: FingerPose(fold: 1.0),
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 0.0, angleOffset: -0.3), // pinky wide
  ),
  'Z': const HandPose(
    thumb: FingerPose(fold: 0.8, angleOffset: -0.2),
    index: FingerPose(fold: 0.0), // index up, rest folded
    middle: FingerPose(fold: 1.0),
    ring: FingerPose(fold: 1.0),
    pinky: FingerPose(fold: 1.0),
    wristRotation: 0.2, // slight rotation for Z drawing style
  ),
};

HandPose getHandPoseForLetter(String char) {
  final upper = char.toUpperCase();
  return aslPoses[upper] ?? poseOpen;
}

// ================= DYNAMIC VECTOR HAND PAINTER =================

class HandSkeletonPainter extends CustomPainter {
  final HandPose pose;
  final Color color;

  HandSkeletonPainter({required this.pose, this.color = Colors.teal});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2 + 10);

    canvas.save();
    // Apply wrist rotation
    canvas.translate(center.dx, center.dy);
    canvas.rotate(pose.wristRotation);
    canvas.translate(-center.dx, -center.dy);

    // ── Define Base Landmarks ──
    final wrist = Offset(size.width / 2, size.height * 0.85);
    final palmCenter = Offset(size.width / 2, size.height * 0.6);

    // Finger base attachments
    final basePinky = Offset(size.width / 2 - 45, size.height * 0.52);
    final baseRing = Offset(size.width / 2 - 18, size.height * 0.48);
    final baseMiddle = Offset(size.width / 2 + 10, size.height * 0.48);
    final baseIndex = Offset(size.width / 2 + 38, size.height * 0.52);
    final baseThumb = Offset(size.width / 2 + 45, size.height * 0.7);

    // ── Draw Palm Backing ──
    final palmPath = Path()
      ..moveTo(wrist.dx - 20, wrist.dy)
      ..lineTo(basePinky.dx - 5, basePinky.dy)
      ..quadraticBezierTo(
          baseRing.dx, baseRing.dy - 5, baseMiddle.dx, baseMiddle.dy - 5)
      ..lineTo(baseIndex.dx + 5, baseIndex.dy)
      ..lineTo(baseThumb.dx + 8, baseThumb.dy)
      ..lineTo(wrist.dx + 20, wrist.dy)
      ..close();
    canvas.drawPath(palmPath, fillPaint);

    // ── Helper to draw a parametric finger ──
    void drawFinger(
        Offset base, double angleRad, double length, FingerPose fingerPose,
        {bool isThumb = false}) {
      // 3 segments per finger
      final segLength = length / 3.0;
      Offset prevJoint = base;
      double currentAngle = angleRad + fingerPose.angleOffset;

      // Draw the finger segments
      for (int i = 0; i < 3; i++) {
        // Bend curl calculations
        // When fold is 1.0 (folded), finger segments curl inwards (by adding pi/2.5 per joint)
        double bendMultiplier = isThumb ? 0.95 : 1.25;
        double curl = fingerPose.fold * (pi / 2.2) * bendMultiplier;
        currentAngle += (i > 0) ? curl : (curl * 0.4);

        final nextJoint = Offset(
          prevJoint.dx + segLength * cos(currentAngle),
          prevJoint.dy + segLength * sin(currentAngle),
        );

        canvas.drawLine(prevJoint, nextJoint, paint);
        prevJoint = nextJoint;
      }
    }

    // ── Draw Fingers ──
    // Pinky (Angles point upwards, e.g., around -pi/2 which is -90 deg)
    drawFinger(basePinky, -pi * 0.62, 55.0, pose.pinky);

    // Ring
    drawFinger(baseRing, -pi * 0.56, 70.0, pose.ring);

    // Middle
    drawFinger(baseMiddle, -pi * 0.50, 75.0, pose.middle);

    // Index
    drawFinger(baseIndex, -pi * 0.44, 70.0, pose.index);

    // Thumb (Points more rightwards/sideways)
    drawFinger(baseThumb, -pi * 0.12, 48.0, pose.thumb, isThumb: true);

    // ── Draw Wrist Base Joint Line ──
    canvas.drawLine(Offset(wrist.dx - 22, wrist.dy),
        Offset(wrist.dx + 22, wrist.dy), paint);
    canvas.drawLine(
        palmCenter,
        wrist,
        Paint()
          ..color = color.withOpacity(0.2)
          ..strokeWidth = 6);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HandSkeletonPainter oldDelegate) {
    return oldDelegate.pose != pose || oldDelegate.color != color;
  }
}

// ================= INTERACTIVE FINGERSPELLING SCREEN =================

class SignLanguageScreen extends StatefulWidget {
  final String? initialWord;
  const SignLanguageScreen({super.key, this.initialWord});

  @override
  State<SignLanguageScreen> createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;

  String currentWord = "BUDDY";
  int currentLetterIndex = 0;

  // Speed multiplier
  double speed = 1.0;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialWord != null && widget.initialWord!.isNotEmpty) {
      currentWord = widget.initialWord!
          .replaceAll(RegExp(r'[^a-zA-Z]'), '')
          .toUpperCase();
    }
    _textController.text = currentWord;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (isPlaying) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && isPlaying) {
              setState(() {
                if (currentLetterIndex < currentWord.length - 1) {
                  currentLetterIndex++;
                  _animationController.forward(from: 0.0);
                } else {
                  // Loop to start
                  currentLetterIndex = 0;
                  _animationController.forward(from: 0.0);
                }
              });
            }
          });
        }
      }
    });

    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _updateWord(String val) {
    String cleanVal = val.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    if (cleanVal.isEmpty) return;
    setState(() {
      currentWord = cleanVal;
      currentLetterIndex = 0;
      isPlaying = false;
    });
    _animationController.forward(from: 0.0);
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });
    if (isPlaying) {
      _animationController.duration =
          Duration(milliseconds: (900 / speed).round());
      _animationController.forward(from: 0.0);
    }
  }

  void _nextLetter() {
    setState(() {
      isPlaying = false;
      if (currentLetterIndex < currentWord.length - 1) {
        currentLetterIndex++;
      } else {
        currentLetterIndex = 0;
      }
    });
    _animationController.forward(from: 0.0);
  }

  void _prevLetter() {
    setState(() {
      isPlaying = false;
      if (currentLetterIndex > 0) {
        currentLetterIndex--;
      } else {
        currentLetterIndex = currentWord.length - 1;
      }
    });
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate current and target poses for smooth interpolations
    String currentLetter =
        currentWord.isNotEmpty ? currentWord[currentLetterIndex] : "A";
    String prevLetter = currentLetter;
    if (_animationController.value < 1.0) {
      if (currentLetterIndex > 0) {
        prevLetter = currentWord[currentLetterIndex - 1];
      } else if (currentWord.isNotEmpty) {
        prevLetter = currentWord.characters.last;
      }
    }

    HandPose poseFrom = getHandPoseForLetter(prevLetter);
    HandPose poseTo = getHandPoseForLetter(currentLetter);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF4F6FF),
      appBar: AppBar(
        title: const Text("ASL Sign Language Translator"),
        backgroundColor:
            isDark ? const Color(0xFF1E1E32) : const Color(0xFF4A5CF0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Explanation ──
              Card(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.accessibility_new,
                              color: Colors.teal, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "Fingerspelling AI Animator",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This tool dynamically generates American Sign Language (ASL) fingerspelling gestures. Useful for deaf or hard-of-hearing learners to spell words.",
                        style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Input field ──
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: "Enter Word to Spell",
                  labelStyle: TextStyle(
                      color: isDark ? Colors.tealAccent : Colors.teal.shade700),
                  hintText: "Type any word...",
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E32) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.spellcheck),
                ),
                onChanged: _updateWord,
              ),
              const SizedBox(height: 24),

              // ── Dynamic Canvas Rendering ──
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16162A) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    // Smoothly interpolate between hand poses
                    final interpolatedPose = HandPose.lerp(
                      poseFrom,
                      poseTo,
                      Curves.easeInOut.transform(_animationController.value),
                    );
                    return Stack(
                      children: [
                        // The skeletal hand representation
                        Center(
                          child: CustomPaint(
                            size: const Size(200, 200),
                            painter: HandSkeletonPainter(
                              pose: interpolatedPose,
                              color: isDark
                                  ? Colors.tealAccent
                                  : Colors.teal.shade600,
                            ),
                          ),
                        ),
                        // Character Overlay Display
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              currentLetter,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.tealAccent
                                    : Colors.teal.shade800,
                              ),
                            ),
                          ),
                        ),
                        // Visual Word Spellout Progress Indicator
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Wrap(
                              spacing: 6,
                              children:
                                  List.generate(currentWord.length, (idx) {
                                final active = idx == currentLetterIndex;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? (isDark
                                            ? Colors.tealAccent
                                            : Colors.teal)
                                        : Colors.grey.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    currentWord[idx],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: active
                                          ? (isDark
                                              ? Colors.black87
                                              : Colors.white)
                                          : (isDark
                                              ? Colors.white60
                                              : Colors.black54),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Animator Controls ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_previous_rounded),
                    color: isDark ? Colors.white70 : Colors.black87,
                    onPressed: _prevLetter,
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton(
                    onPressed: _togglePlay,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      backgroundColor: isDark ? Colors.tealAccent : Colors.teal,
                      foregroundColor: isDark ? Colors.black87 : Colors.white,
                    ),
                    child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36),
                  ),
                  const SizedBox(width: 14),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_next_rounded),
                    color: isDark ? Colors.white70 : Colors.black87,
                    onPressed: _nextLetter,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Speed Control Slider ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.speed, size: 20, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      "Speed: ${speed.toStringAsFixed(1)}x",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Expanded(
                      child: Slider(
                        value: speed,
                        min: 0.5,
                        max: 2.0,
                        divisions: 6,
                        activeColor: Colors.teal,
                        inactiveColor: Colors.teal.withOpacity(0.2),
                        onChanged: (v) {
                          setState(() {
                            speed = v;
                            if (isPlaying) {
                              _animationController.duration =
                                  Duration(milliseconds: (900 / speed).round());
                            }
                          });
                        },
                      ),
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
