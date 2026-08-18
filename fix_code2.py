#!/usr/bin/env python3

# Read the file
with open('lib/main.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Find the line with the class closing "}" after all the Scaffold code
# and the line with "Widget buildGameUI() {"
start_remove = -1
end_remove = -1

for i, line in enumerate(lines):
    # Looking for the pattern where we have "}" followed by orphaned code
    if i > 0 and lines[i-1].strip() == '}' and line.strip().startswith('return Column('):
        start_remove = i - 1  # Start from the closing brace
    
    if 'Widget buildGameUI() {' in line and start_remove > -1:
        end_remove = i
        break

# If we found both markers, remove the orphaned code
if start_remove != -1 and end_remove != -1:
    # Keep lines before the orphaned block and from buildGameUI onwards
    new_lines = lines[:start_remove+1] + ['\n', '\n'] + lines[end_remove:]
    
    # Write back
    with open('lib/main.dart', 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
    
    print(f"Removed lines {start_remove+2} to {end_remove}: orphaned code block deleted")
else:
    print(f"Could not find the pattern. start_remove={start_remove}, end_remove={end_remove}")
