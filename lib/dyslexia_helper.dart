import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ================= ACCESSIBILITY STATE =================

class AccessibilityConfig {
  final bool useDyslexiaFont;
  final double fontSizeMultiplier;
  final double letterSpacingMultiplier;
  final double wordSpacingMultiplier;
  final bool highContrast;
  final bool slowSpeech;
  final bool showPhonetics;

  const AccessibilityConfig({
    this.useDyslexiaFont = false,
    this.fontSizeMultiplier = 1.0,
    this.letterSpacingMultiplier = 1.0,
    this.wordSpacingMultiplier = 1.0,
    this.highContrast = false,
    this.slowSpeech = false,
    this.showPhonetics = false,
  });

  AccessibilityConfig copyWith({
    bool? useDyslexiaFont,
    double? fontSizeMultiplier,
    double? letterSpacingMultiplier,
    double? wordSpacingMultiplier,
    bool? highContrast,
    bool? slowSpeech,
    bool? showPhonetics,
  }) {
    return AccessibilityConfig(
      useDyslexiaFont: useDyslexiaFont ?? this.useDyslexiaFont,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      letterSpacingMultiplier:
          letterSpacingMultiplier ?? this.letterSpacingMultiplier,
      wordSpacingMultiplier:
          wordSpacingMultiplier ?? this.wordSpacingMultiplier,
      highContrast: highContrast ?? this.highContrast,
      slowSpeech: slowSpeech ?? this.slowSpeech,
      showPhonetics: showPhonetics ?? this.showPhonetics,
    );
  }
}

// Global Notifier for Accessibility Settings
final ValueNotifier<AccessibilityConfig> accessibilityNotifier =
    ValueNotifier(const AccessibilityConfig());

// Load accessibility settings from local storage (Offline design)
Future<void> loadAccessibilitySettings() async {
  final prefs = await SharedPreferences.getInstance();
  accessibilityNotifier.value = AccessibilityConfig(
    useDyslexiaFont: prefs.getBool('access_useDyslexiaFont') ?? false,
    fontSizeMultiplier: prefs.getDouble('access_fontSizeMultiplier') ?? 1.0,
    letterSpacingMultiplier:
        prefs.getDouble('access_letterSpacingMultiplier') ?? 1.0,
    wordSpacingMultiplier:
        prefs.getDouble('access_wordSpacingMultiplier') ?? 1.0,
    highContrast: prefs.getBool('access_highContrast') ?? false,
    slowSpeech: prefs.getBool('access_slowSpeech') ?? false,
    showPhonetics: prefs.getBool('access_showPhonetics') ?? false,
  );
}

// Save settings offline
Future<void> saveAccessibilitySetting(String key, dynamic value) async {
  final prefs = await SharedPreferences.getInstance();
  if (value is bool) {
    await prefs.setBool('access_$key', value);
  } else if (value is double) {
    await prefs.setDouble('access_$key', value);
  }
}

// ================= DYSLEXIA ALGORITHMS =================

// Syllable breaking algorithm for English & other words
String splitSyllables(String word) {
  if (word.length <= 3) return word;

  final vowels = RegExp(r'[aeiouyAEIOUY]');
  List<String> syllables = [];
  String current = "";

  for (int i = 0; i < word.length; i++) {
    String char = word[i];
    current += char;

    if (vowels.hasMatch(char)) {
      if (i + 2 < word.length) {
        String next1 = word[i + 1];
        String next2 = word[i + 2];

        // V-C-C-V: Split between the consonants (e.g. ap-ple, doc-tor)
        if (!vowels.hasMatch(next1) && !vowels.hasMatch(next2)) {
          current += next1;
          syllables.add(current);
          current = "";
          i++; // skip next1
        }
        // V-C-V: Split before the consonant (e.g. wa-ter, ho-tel)
        else if (!vowels.hasMatch(next1) && vowels.hasMatch(next2)) {
          syllables.add(current);
          current = "";
        }
      }
    }
  }

  if (current.isNotEmpty) {
    if (syllables.isNotEmpty && current.length <= 1) {
      syllables[syllables.length - 1] += current;
    } else {
      syllables.add(current);
    }
  }

  // Merge final silent e
  if (syllables.length > 1 &&
      (syllables.last.toLowerCase() == 'e' ||
          syllables.last.toLowerCase() == 'es') &&
      !vowels.hasMatch(syllables[syllables.length - 2].characters.last)) {
    String last = syllables.removeLast();
    syllables[syllables.length - 1] += last;
  }

  return syllables.join("·");
}

// Curated lookup database of Phonetic guides for English words
const Map<String, String> phoneticGuides = {
  "Apple": "AH-puhl",
  "Book": "buuk",
  "Water": "WAH-ter",
  "House": "hows",
  "Food": "food",
  "Doctor": "DOK-ter",
  "Hospital": "HOS-pi-tuhl",
  "School": "skool",
  "Teacher": "TEE-cher",
  "Student": "STOO-duhnt",
  "Family": "FAM-uh-lee",
  "Friend": "frend",
  "Love": "luhv",
  "Time": "tym",
  "Day": "day",
  "Night": "nyt",
  "Sun": "suhn",
  "Moon": "moon",
  "Star": "stahr",
  "Rain": "rayn",
  "Money": "MUHN-ee",
  "Market": "MAHR-kit",
  "Train": "trayn",
  "Bus": "buhs",
  "Ticket": "TIK-it",
  "Emergency": "i-MUR-juhn-see",
  "Police": "puh-LEES",
  "Lawyer": "LOY-er",
  "Medicine": "MED-uh-sin",
  "Pain": "payn",
  "Fever": "FEE-vur",
  "Seed": "seed",
  "Harvest": "HAHR-vist",
  "Soil": "soyl",
  "Price": "prys",
  "Shop": "shop",
  "Customer": "KUHS-tuh-mur",
  "Allergy": "AL-er-jee",
  "Ambulance": "AM-byoo-luhns",
  "Dizzy": "DIZ-ee",
  "Embassy": "EM-buh-see",
  "Passport": "PAS-pawrt",
  "Station": "STAY-shuhn",
  "Translate": "TRANZ-layt",
  "Language": "LANG-gwij",
  "Restaurant": "RES-tuh-rahnt",
  "Hotel": "hoh-TEL",
};

// Returns phonetic guide if exists, otherwise a syllable-spaced string
String getPhoneticHint(String word) {
  if (phoneticGuides.containsKey(word)) {
    return phoneticGuides[word]!;
  }
  return splitSyllables(word);
}

// ================= DYSLEXIA LAYOUT HELPER STYLES =================

Color getDyslexiaBackgroundColor(BuildContext context) {
  final config = accessibilityNotifier.value;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (config.useDyslexiaFont) {
    return isDark ? const Color(0xFF12121E) : const Color(0xFFFFFDF2);
  }
  return isDark ? const Color(0xFF0F0F1E) : const Color(0xFFF4F6FF);
}

BoxDecoration getDyslexiaCardDecoration(BuildContext context, {Color? defaultColor}) {
  final config = accessibilityNotifier.value;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  if (config.useDyslexiaFont) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1C1C2E) : const Color(0xFFFFFFF8),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: config.highContrast
            ? (isDark ? Colors.yellow : Colors.black)
            : (isDark ? Colors.tealAccent.withOpacity(0.7) : Colors.teal.shade400),
        width: 2.0,
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.tealAccent : Colors.teal).withOpacity(0.12),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )
      ],
    );
  }

  return BoxDecoration(
    color: defaultColor ?? (isDark ? const Color(0xFF1E1E32) : Colors.white),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      )
    ],
  );
}

// ================= DYSLEXIC READABILITY TEXT WIDGET =================

class DyslexicText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool animateSyllables;

  const DyslexicText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.animateSyllables = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AccessibilityConfig>(
      valueListenable: accessibilityNotifier,
      builder: (context, config, child) {
        // High Contrast override colors
        Color? textColor = style?.color;
        if (config.highContrast) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          textColor =
              isDark ? const Color(0xFFFFEB3B) : const Color(0xFF000000);
        }

        final baseStyle = (style ?? const TextStyle()).copyWith(
          fontSize: style?.fontSize ?? 16.0,
          height: config.useDyslexiaFont ? 1.65 : style?.height,
          fontWeight:
              config.useDyslexiaFont ? FontWeight.w600 : style?.fontWeight,
          fontFamily: config.useDyslexiaFont ? 'Courier' : style?.fontFamily,
          color: textColor,
        );
        final TextStyle finalStyle = config.useDyslexiaFont
            ? baseStyle.copyWith(
                letterSpacing: 2.2 * config.letterSpacingMultiplier,
                wordSpacing: 4.5 * config.wordSpacingMultiplier,
              )
            : baseStyle;

        // If dyslexia mode is active, format text with syllable highlights even for full sentences
        if (config.useDyslexiaFont && text.trim().isNotEmpty) {
          final words = text.split(' ');
          List<InlineSpan> spans = [];

          for (int w = 0; w < words.length; w++) {
            final word = words[w];
            if (word.length > 3 && RegExp(r'[a-zA-Z]').hasMatch(word)) {
              final parts = splitSyllables(word).split('·');
              for (int index = 0; index < parts.length; index++) {
                final isEven = index % 2 == 0;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final syllableColor = isEven
                    ? (textColor ?? (isDark ? Colors.white : Colors.black87))
                    : (isDark ? Colors.cyanAccent : Colors.teal.shade700);
                spans.add(TextSpan(
                  text: parts[index],
                  style: finalStyle.copyWith(
                    color: syllableColor,
                    fontWeight: FontWeight.bold,
                  ),
                ));
              }
            } else {
              spans.add(TextSpan(
                text: word,
                style: finalStyle,
              ));
            }

            if (w < words.length - 1) {
              spans.add(TextSpan(
                text: ' ',
                style: finalStyle,
              ));
            }
          }

          return RichText(
            textAlign: textAlign ?? TextAlign.start,
            textScaler: MediaQuery.textScalerOf(context),
            text: TextSpan(children: spans),
          );
        }

        return Text(
          text,
          style: finalStyle,
          textAlign: textAlign,
        );
      },
    );
  }
}

