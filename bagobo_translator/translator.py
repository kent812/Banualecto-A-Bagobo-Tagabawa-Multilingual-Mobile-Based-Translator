import json


class Translator:
    def __init__(self, json_file="data.json"):
        with open(json_file, "r", encoding="utf-8") as f:
            self.words = json.load(f)

        self.valid_fields = ["word", "bagoboWord", "tagalog", "bisaya"]

    def normalize(self, text):
        return text.strip().lower()

    def translate(self, query, source_lang, target_lang):
        query = self.normalize(query)

        if source_lang not in self.valid_fields:
            return {"error": f"Invalid source language: {source_lang}"}

        if target_lang not in self.valid_fields:
            return {"error": f"Invalid target language: {target_lang}"}

        matches = []

        for item in self.words:
            source_value = item.get(source_lang, "")
            if not source_value:
                continue

            parts = [p.strip().lower() for p in source_value.split(",")]

            if query == source_value.strip().lower() or query in parts:
                matches.append({
                    "id": item.get("id", ""),
                    "source": item.get(source_lang, ""),
                    "target": item.get(target_lang, ""),
                    "english": item.get("word", ""),
                    "bagobo": item.get("bagoboWord", ""),
                    "tagalog": item.get("tagalog", ""),
                    "bisaya": item.get("bisaya", ""),
                    "partOfSpeech": item.get("partOfSpeech", ""),
                    "description": item.get("description", ""),
                    "category": item.get("category", "")
                })

        return matches

    def search_contains(self, query, source_lang):
        query = self.normalize(query)

        if source_lang not in self.valid_fields:
            return {"error": f"Invalid language field: {source_lang}"}

        matches = []

        for item in self.words:
            source_value = item.get(source_lang, "")
            if source_value and query in source_value.lower():
                matches.append(item)

        return matches
