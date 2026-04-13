from translator import Translator


LANGUAGE_MAP = {
    "english": "word",
    "bagobo": "bagoboWord",
    "tagalog": "tagalog",
    "bisaya": "bisaya"
}


def main():
    translator = Translator("data.json")

    while True:
        print("\n=== Bagobo Tagabawa Translator ===")
        print("Languages: english, bagobo, tagalog, bisaya")
        print("Type 'exit' to quit")

        source = input("Source language: ").strip().lower()
        if source == "exit":
            break

        target = input("Target language: ").strip().lower()
        if target == "exit":
            break

        text = input("Enter word: ").strip()
        if text.lower() == "exit":
            break

        if source not in LANGUAGE_MAP or target not in LANGUAGE_MAP:
            print("Invalid language choice.")
            continue

        if source == target:
            print("Source and target languages must be different.")
            continue

        results = translator.translate(
            text,
            LANGUAGE_MAP[source],
            LANGUAGE_MAP[target]
        )

        if isinstance(results, dict) and "error" in results:
            print(results["error"])
            continue

        if not results:
            print("No translation found. Trying partial search...")
            # Try partial search
            search_results = translator.search_contains(
                text,
                LANGUAGE_MAP[source]
            )
            if search_results:
                print(f"\nFound {len(search_results)} partial matches:")
                for i, item in enumerate(search_results[:5], start=1):
                    print(f"\n{i}. English: {item.get('word', '')}")
                    print(f"   Bagobo: {item.get('bagoboWord', '')}")
                    print(f"   Tagalog: {item.get('tagalog', '')}")
                    print(f"   Bisaya: {item.get('bisaya', '')}")
            else:
                print("No matches found.")
            continue

        print(f"\nFound {len(results)} result(s):")
        for i, result in enumerate(results, start=1):
            print(f"\n{i}. {source.title()}: {result['source']}")
            print(f"   {target.title()}: {result['target']}")
            print(f"   English: {result['english']}")
            print(f"   Bagobo: {result['bagobo']}")
            print(f"   Tagalog: {result['tagalog']}")
            print(f"   Bisaya: {result['bisaya']}")
            print(f"   Part of Speech: {result['partOfSpeech']}")
            print(f"   Category: {result['category']}")
            if result['description']:
                print(f"   Description: {result['description']}")


if __name__ == "__main__":
    main()
