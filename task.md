You are an expert Flutter developer and speech-therapy-informed UX designer.

Your task:  
Build a COMPLETE Flutter app for Android/iOS that helps a young child (3–6 years old) move from single words to simple sentences. The app is used ONLY by the child (no onboarding, no login, no settings, no consent screens). When the app opens, it goes straight into the main “games.”. The game is by default in landscape mode.

==================================================
HIGH-LEVEL REQUIREMENTS
==================================================

- Framework: Flutter (latest stable).
- Target: Android and iOS.
- Audience: 3–6 years old child with delayed speech who can already tap and play games on a phone.
- UX: Super simple, large touch targets, minimal reading required, bright but not overstimulating.
- No onboarding, no parental accounts, no analytics UI. App launch → Home screen with game modes.
- Focus: spoken language and sentence modeling using real-world photos (the parent will later replace placeholder images with photos from their home).

==================================================
MAIN MODES / SCREENS
==================================================

APP NAVIGATION:
- Use a simple Navigator structure (no complex routing, no auth).
- Root: HomeScreen with large buttons for each mode.
- Each mode is a full-screen page with a big back button to Home.
- No bottom nav needed.

ROUTES:
- `/` → HomeScreen
- `/action_phrases`
- `/objects`
- `/stories`
- `/story_player` (accepts a Story object)
- `/affirmations`
- `/verses`

SCREENS:

1) HomeScreen
    - Title at top: "Let’s Talk!"
    - Big primary button: "▶ Play All" (plays a short mixed session: a few action phrases, objects, one affirmation, one verse).
    - Large mode cards (grid or column):
        - "I want…"  → ActionPhrasesScreen
        - "Things at home" → ObjectsScreen
        - "Stories" → StoriesListScreen
        - "I am…" → AffirmationsScreen
        - "Bible verses" → VersesScreen

2) ActionPhrasesScreen ("I want…")
    - AppBar: title "I want…"
    - 2x3 grid of large tiles. Each tile:
        - Placeholder image (from assets) – parent will later replace with real photos.
        - Label and spoken sentence are the same.
    - Tapping a tile:
        - Tile briefly scales up / animates.
        - An overlay or large text shows the sentence for 1–2 seconds.
        - The app speaks the sentence via TTS.
    - Optional at bottom: round button "Say it again" to replay the last tapped phrase.

   Core phrases (hard-code them as initial content):
    - "I want to eat."
    - "I want to drink water."
    - "I want juice."
    - "I want to sleep."
    - "I want to play."
    - "I want to go outside."
    - "I want more."
    - "I am finished."
    - "Help me, please."
    - "Come here, please."
    - You can limit to 6–8 for the first grid and keep others as additional content.

3) ObjectsScreen ("Things at home")
    - AppBar: "Things at home"
    - At top: category chips (scrollable row), e.g.:
        - Toys, Food, Clothes, Bathroom
    - Below: grid of tiles for the current category. Each tile:
        - Placeholder image.
        - Short label: 2–4 words (e.g. "Big red ball").
    - On tap:
        - Speak a short description via TTS.
        - Show the text large on screen.

   Include some initial hard-coded objects like:

   Toys:
    - "Big red ball."
    - "Small blue car."
    - "Yellow teddy bear."
    - "Green dinosaur toy."

   Food:
    - "Yellow bananas."
    - "Red apple."
    - "Cold juice."
    - "Hot soup."

   Clothes:
    - "White shirt."
    - "Small black shoe."
    - "Blue jeans."
    - "Warm socks."

   For each object, allow an optional second line (e.g. "Throw the ball.", "I want to eat bananas."), and speak it right after the first if present.

4) StoriesListScreen
    - AppBar: "Stories"
    - Vertical list of big cards, each showing:
        - Story title.
        - Cover image.
    - On tap: navigate to StoryPlayerScreen with the chosen Story.

5) StoryPlayerScreen
    - Input: a Story object with multiple scenes.
    - Layout:
        - Top: story title.
        - Middle: scene image.
        - Bottom: current scene text (very short sentence).
        - Controls: "Back" (previous scene), "Play" (speak current sentence), "Next" (next scene).
    - After last scene, show a simple “Well done!” page with:
        - A very simple comprehension question.
        - 2–3 tappable images for answers.
        - On correct tap: happy animation + simple praise line spoken.

   Implement at least 2–3 micro-stories, e.g.:

   Story 1 – "The Red Ball"
   Scenes:
    - S1: "Ali has a red ball." (Line to practice: "Red ball.")
    - S2: "Ali throws the red ball." (Practice: "Throw the ball.")
    - S3: "The ball rolls under the chair." (Practice: "Where is the ball?")
    - S4: "Mama helps Ali get the ball." (Practice: "Help me, please.")
      End question example:
    - "Where is the ball?" → show options, correct one is under the chair.

   Story 2 – "Banana Snack"
   Scenes:
    - S1: "Sara is hungry." (Practice: "I am hungry.")
    - S2: "She sees yellow bananas." (Practice: "Yellow bananas.")
    - S3: "Sara says, 'I want to eat bananas.'" (Practice: "I want to eat.")
    - S4: "She eats the bananas. She is happy." (Practice: "I am happy.")

6) AffirmationsScreen ("I am…")
    - AppBar: "I am…"
    - Show one big card at a time:
        - Large text (main affirmation).
        - Optional small explanatory line.
    - Controls:
        - Previous, Play (TTS), Next.
    - Example list:
        - "I am smart. I can learn."
        - "I am brave. I can try."
        - "I am kind. I share."
        - "I am loved. You love me."
        - "I can try again."

7) VersesScreen
    - AppBar: "Bible Verses"
    - Same layout style as AffirmationsScreen.
    - Each card:
        - Short verse.
        - Small reference.
        - One child-friendly explanation line.
    - Example list:
        - Verse: "God is love." (1 John 4:8) — Extra: "God loves you."
        - Verse: "Be kind to one another." — Extra: "We are kind."
        - Verse: "God is with me." — Extra: "I am not alone."
        - Verse: "Give thanks to the Lord." — Extra: "Thank you, God."
        - Verse: "Do not be afraid." — Extra: "God helps me."

8) Play-All Session (short mixed run)
    - Triggered from Home by "Play All" button.
    - Simple implementation:
        - Sequentially show a few random items from:
            - Action phrases
            - Objects
            - Affirmations
            - Verses
        - Child taps to progress.
    - This can just be a helper that picks content and uses existing UIs, or a separate lightweight SessionScreen.

==================================================
ARCHITECTURE & DATA MODELS
==================================================

Use clean, simple structure suitable for future extension, but not over-engineered.

SUGGESTED DATA MODELS (Dart classes):

1) Phrase
    - id
    - text (what to show & speak)
    - category (e.g. "action", "object", "affirmation", "verse")
    - imageAsset (String – local asset path)
    - extraText (optional – second line to speak)
    - maybe type enum to differentiate ActionPhrase / Object / Affirmation etc.

2) ObjectItem (if you want a separate type)
    - id
    - label (short description, "Big red ball.")
    - extraLine (optional, "Throw the ball.")
    - imageAsset
    - category (toys, food, clothes, etc.)

3) Story
    - id
    - title
    - coverImageAsset
    - List<StoryScene> scenes
    - Optional: finalQuestion text
    - Optional: answer options (for comprehension)

4) StoryScene
    - id
    - text (simple sentence)
    - practiceLine (short phrase to repeat; if null, use the same as text)
    - imageAsset

5) Verse
    - id
    - verseText (e.g. "God is love.")
    - reference (e.g. "1 John 4:8")
    - extraChildLine ("God loves you.")
    - imageAsset (optional, can reuse neutral ones)

Represent the initial content as in-code lists (constants or static providers) so that the app can run fully offline without needing any backend.

==================================================
AUDIO / TTS
==================================================

- Use a Flutter TTS plugin (for example, flutter_tts) to speak all phrases, descriptions, story sentences, affirmations, and verses.
- Provide a small wrapper service/class, e.g. `SpeechService`, to:
    - `speak(String text)`
    - optionally stop/cancel previous speech if needed.
- When the user taps a tile or presses "Play", call `SpeechService.speak(...)`.

==================================================
UI / UX GUIDELINES
==================================================

- Use Material 3 / modern Flutter design.
- Colors: soft, kid-friendly, but not too high-contrast or flashing.
- Buttons:
    - Very large tap areas.
    - Icons plus labels where possible.
- Text:
    - Large fonts (e.g. 24–32+ for main text).
    - Minimal sentences.
- Animations:
    - Tile tap → small scale up animation.
    - Simple fade/slide transitions between scenes/pages.

==================================================
STATE MANAGEMENT / ORGANIZATION
==================================================

- Keep it simple but clean:
    - You may use Provider, Riverpod, or simple ValueNotifiers; choose a widely used and stable solution.
- Organize into folders:
    - `lib/main.dart`
    - `lib/screens/` (home_screen.dart, action_phrases_screen.dart, objects_screen.dart, stories_list_screen.dart, story_player_screen.dart, affirmations_screen.dart, verses_screen.dart, session_screen.dart if needed)
    - `lib/models/` (phrase.dart, story.dart, story_scene.dart, verse.dart, etc.)
    - `lib/data/` (hard-coded lists of content, e.g. phrases_data.dart, stories_data.dart)
    - `lib/services/` (speech_service.dart)
    - `assets/images/...` (use placeholder images and wire up asset paths)
- Include an example `pubspec.yaml` snippet showing how assets and fonts are declared.

==================================================
DELIVERABLES
==================================================

Produce:

1) A full Flutter project structure (it can be presented as code snippets per file) including:
    - `main.dart` with `runApp`, `MaterialApp`, routes, and theme.
    - All screen widgets with layout as described.
    - Data model classes.
    - Hard-coded content lists.
    - Speech service implementation using TTS.
    - Example assets paths and `pubspec.yaml` asset configuration.

2) Code should be:
    - Readable and organized.
    - Using best practices for Flutter layout (e.g., avoiding deep nesting when possible, using reusable widgets for tiles/cards).
    - Ready for the parent to later replace image assets with real photos and adjust the hard-coded text lists.

3) Brief explanation/comments where necessary so that a developer can easily extend or customize:
    - How to add new phrases/objects.
    - How to add new stories.
    - How to update affirmations and verses.

Start by outlining the project file structure, then show each important Dart file in full.
