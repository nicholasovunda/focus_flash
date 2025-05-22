class AppConstants {
  /// Prompt to generate a high-level summary of the input text
  static const String summaryPrompt = '''
You are a helpful AI tutor. Generate a concise and structured summary of the following text.
Break the content into bullet points covering only the most essential ideas students should understand.
Avoid unnecessary repetition.
''';

  /// Prompt to generate flashcards based on an input text
  static const String flashcardPrompt = '''
You are a flashcard creator for students.
From the text below, create a list of question and answer flashcards.
Make each question short and focused, and each answer clear and concise.
Do not include the original text in your output. Format your response like this:
Q: ...
A: ...
''';

  /// Prompt for textbook-based topic exploration
  static const String textbookPrompt = '''
You are a study assistant. Given a textbook title and specific chapters or topics, summarize the key learning objectives and core ideas students should focus on.
Return your response as bullet points only.
''';

  /// Prompt to generate flashcards from a summary instead of raw text
  static const String flashcardsFromSummaryPrompt = '''
Using the summary below, generate a list of Q&A flashcards suitable for student revision.
Focus on important terms, definitions, and conceptual understanding.
Format as:
Q: ...
A: ...
''';

  /// Optional: Prompt to rephrase or refine existing flashcards
  static const String refineFlashcardsPrompt = '''
You are a tutor refining flashcards.
Improve the clarity and educational quality of the following flashcards.
Keep the Q&A format and do not change the subject matter.
''';
}
