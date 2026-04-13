import json
import re

with open(r"C:\capstone dictionary\speech_to_text\lib\data\dictionary_data.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Find the dictionaryWords list
start = content.index("const List<DictionaryWord> dictionaryWords = [")
# Find the matching closing bracket
bracket_count = 0
end = start
for i, ch in enumerate(content[start:]):
    if ch == "[":
        bracket_count += 1
    elif ch == "]":
        bracket_count -= 1
        if bracket_count == 0:
            end = start + i + 1
            break

words_section = content[start:end]
print(f"Words section length: {len(words_section)} chars")

# Parse each DictionaryWord entry
words = []
# Match each DictionaryWord block
entry_pattern = re.compile(
    r"DictionaryWord\(\s*"
    r"id:\s*'([^']*)',\s*"
    r"word:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"bagoboWord:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"tagalog:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"bisaya:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"partOfSpeech:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"description:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"synonyms:\s*\[(.*?)\],\s*"
    r"exampleSentence:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"category:\s*'((?:[^'\\]|\\.)*)',\s*"
    r"pronunciation:\s*'((?:[^'\\]|\\.)*)',\s*\)",
    re.DOTALL
)

matches = entry_pattern.findall(words_section)
print(f"Found {len(matches)} words via regex")

# If regex didn't work well, try line-by-line parsing
if len(matches) < 10:
    print("Trying line-by-line parsing...")
    # Split by DictionaryWord(
    entries = words_section.split("DictionaryWord(")
    print(f"Found {len(entries)-1} entries via split")

    for entry in entries[1:]:
        try:
            # Extract fields using simpler regex
            id_match = re.search(r"id:\s*'([^']*)'", entry)
            word_match = re.search(r"word:\s*'((?:[^'\\]|\\.)*)'", entry)
            bagobo_match = re.search(r"bagoboWord:\s*'((?:[^'\\]|\\.)*)'", entry)
            tagalog_match = re.search(r"tagalog:\s*'((?:[^'\\]|\\.)*)'", entry)
            bisaya_match = re.search(r"bisaya:\s*'((?:[^'\\]|\\.)*)'", entry)
            pos_match = re.search(r"partOfSpeech:\s*'((?:[^'\\]|\\.)*)'", entry)
            desc_match = re.search(r"description:\s*'((?:[^'\\]|\\.)*)'", entry)
            cat_match = re.search(r"category:\s*'((?:[^'\\]|\\.)*)'", entry)
            pron_match = re.search(r"pronunciation:\s*'((?:[^'\\]|\\.)*)'", entry)

            if id_match and word_match:
                word_obj = {
                    "id": id_match.group(1),
                    "word": word_match.group(1),
                    "bagoboWord": bagobo_match.group(1) if bagobo_match else "",
                    "tagalog": tagalog_match.group(1) if tagalog_match else "",
                    "bisaya": bisaya_match.group(1) if bisaya_match else "",
                    "partOfSpeech": pos_match.group(1) if pos_match else "",
                    "description": desc_match.group(1) if desc_match else "",
                    "category": cat_match.group(1) if cat_match else "",
                    "pronunciation": pron_match.group(1) if pron_match else ""
                }
                words.append(word_obj)
        except Exception as e:
            print(f"Error parsing entry: {e}")
            continue
else:
    for m in matches:
        word_obj = {
            "id": m[0],
            "word": m[1],
            "bagoboWord": m[2],
            "tagalog": m[3],
            "bisaya": m[4],
            "partOfSpeech": m[5],
            "description": m[6],
            "category": m[9],
            "pronunciation": m[10]
        }
        words.append(word_obj)

print(f"Total words extracted: {len(words)}")

# Write to data.json
with open(r"C:\capstone dictionary\speech_to_text\bagobo_translator\data.json", "w", encoding="utf-8") as f:
    json.dump(words, f, ensure_ascii=False, indent=2)

print("data.json created successfully!")
print(f"First word: {words[0]}")
print(f"Last word: {words[-1]}")
