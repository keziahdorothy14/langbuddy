#!/usr/bin/env python3
import re

# Read the file
with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find and remove the orphaned code block
# The orphaned code starts with "          return Column(" (10 spaces indent)
# and continues until "    Widget buildGameUI() {"

# Use regex to find and remove the orphaned section
pattern = r'(\n  \}\n\})(\s+)(          return Column\([\s\S]*?)(\n  Widget buildGameUI\(\) \{)'
replacement = r'\1\n\n  Widget buildGameUI() {'

new_content = re.sub(pattern, replacement, content)

# Write back
with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Fixed orphaned code")
