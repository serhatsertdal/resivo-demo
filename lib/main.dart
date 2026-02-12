import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ResivoApp());
}

class ResivoApp extends StatelessWidget {
  const ResivoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resivo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int streak = 0;
  bool doneToday = false;

  static const _kStreak = 'streak';
  static const _kLastDoneDay = 'last_done_day'; // yyyy-mm-dd

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_kLastDoneDay);
    final s = prefs.getInt(_kStreak) ?? 0;

    setState(() {
      streak = s;
      doneToday = (last == _todayKey());
    });
  }

  Future<void> _completeToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final last = prefs.getString(_kLastDoneDay);

    int newStreak = prefs.getInt(_kStreak) ?? 0;

    // Basit streak mantığı:
    // Eğer bugün zaten tamamlandıysa değişme.
    if (last == today) return;

    // Eğer dün tamamlandıysa +1, değilse 1’e reset.
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    if (last == yKey) {
      newStreak += 1;
    } else {
      newStreak = 1;
    }

    await prefs.setInt(_kStreak, newStreak);
    await prefs.setString(_kLastDoneDay, today);

    setState(() {
      streak = newStreak;
      doneToday = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const motto = "Start with one day. Today.";

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                "RESIVO",
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 6,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    const Text(
                      motto,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Streak: $streak day(s)",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: doneToday ? null : _completeToday,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(doneToday ? "Completed Today ✅" : "I’m in. Today ✅"),
              ),
              const SizedBox(height: 14),
              Text(
                "Not depression-focused. For people who are tired of procrastinating and want to win.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              const Spacer(),
              Text(
                "Built with you. Resivo.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
