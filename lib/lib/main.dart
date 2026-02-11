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
      debugShowCheckedModeBanner: false,
      title: 'RESIVO',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int streak = 0;
  int best = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      streak = p.getInt("streak") ?? 0;
      best = p.getInt("best") ?? 0;
    });
  }

  Future<void> complete() async {
    final p = await SharedPreferences.getInstance();
    streak++;
    if (streak > best) best = streak;
    await p.setInt("streak", streak);
    await p.setInt("best", best);
    setState(() {});
  }

  Future<void> reset() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    setState(() {
      streak = 0;
      best = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("RESIVO",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("There is only one day to start: Today.",
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 40),
              Text("Streak: $streak", style: const TextStyle(fontSize: 22)),
              Text("Best: $best", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: complete,
                child: const Text("Complete Today"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: reset,
                child: const Text("Reset"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
