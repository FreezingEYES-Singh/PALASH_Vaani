# Contributing to PALASH-Vaani (पलाश-वाणी)

Thank you for your interest in contributing to **PALASH-Vaani**, an AI-powered vernacular pedagogy and offline real-time translation tool designed for Jharkhand's mother tongue-based primary education (SIH PS 26042).

## Code of Conduct
We are committed to providing a welcoming, inclusive, and culturally respectful environment for all contributors, especially respecting tribal linguistic nuances and cultural heritage.

## Development Setup

1. **Prerequisites:**
   - Flutter SDK (3.24+ / 3.47+)
   - Dart SDK (3.5+)
   - Android Studio / VS Code with Flutter extension
   - JDK 17+

2. **Clone & Setup:**
   ```bash
   git clone https://github.com/divycoders/PALASH-Vaani.git
   cd PALASH-Vaani
   flutter pub get
   ```

3. **Running the App:**
   ```bash
   # Run in Chrome
   flutter run -d chrome

   # Run on connected Android tablet / emulator
   flutter run -d android
   ```

## Development Guidelines

1. **Zero Hallucination & Pedagogy Alignment:**
   - Curriculum phrases must map to verified JCERT / SCERT PALASH textbooks and NIPUN Bharat FLN learning outcomes.
   - Dual-script output (Ol Chiki script + Devanagari phonetic guide) must be maintained for Santhali.

2. **Edge Hardware Budget:**
   - Active RAM footprint must stay $\le 400\text{ MB}$ to guarantee stable execution on low-cost $2\text{ GB}$ RAM Android tablets (API 28+).
   - End-to-end voice latency budget must remain strictly $\le 3.0\text{ seconds}$.

3. **Code Quality & Testing:**
   Before submitting a Pull Request, ensure that all checks pass:
   ```bash
   flutter analyze
   flutter test
   ```

## Submitting Pull Requests
1. Create a feature branch: `git checkout -b feature/your-feature-name`.
2. Commit your changes with clear, semantic commit messages (e.g. `feat: ...`, `fix: ...`, `docs: ...`).
3. Push to your branch and open a Pull Request against `main`.
