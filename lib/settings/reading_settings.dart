import 'package:shared_preferences/shared_preferences.dart';

const checkInChoices = [5, 10, 15, 20, 30, 45, 60];
const answerChoices = [1, 2, 3, 5];

const _checkInKey = 'readingCheckInMinutes';
const _answerKey = 'readingAnswerMinutes';

class ReadingSettings {
  const ReadingSettings({this.checkInMinutes = 15, this.answerMinutes = 2});

  final int checkInMinutes;
  final int answerMinutes;

  ReadingSettings copyWith({int? checkInMinutes, int? answerMinutes}) =>
      ReadingSettings(
        checkInMinutes: checkInMinutes ?? this.checkInMinutes,
        answerMinutes: answerMinutes ?? this.answerMinutes,
      );
}

String minutesLabel(int minutes) {
  if (minutes == 60) return '1 hour';
  return minutes == 1 ? '1 minute' : '$minutes minutes';
}

Future<ReadingSettings> loadReadingSettings() async {
  final prefs = SharedPreferencesAsync();
  final checkIn = await prefs.getInt(_checkInKey);
  final answer = await prefs.getInt(_answerKey);
  return ReadingSettings(
    checkInMinutes: checkInChoices.contains(checkIn) ? checkIn! : 15,
    answerMinutes: answerChoices.contains(answer) ? answer! : 2,
  );
}

Future<void> saveReadingSettings(ReadingSettings s) async {
  final prefs = SharedPreferencesAsync();
  await prefs.setInt(_checkInKey, s.checkInMinutes);
  await prefs.setInt(_answerKey, s.answerMinutes);
}