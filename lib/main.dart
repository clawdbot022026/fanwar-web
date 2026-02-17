import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

void main() {
  runApp(const FanWarApp());
}

class FanWarApp extends StatelessWidget {
  const FanWarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FanWar: The Ultimate Clash',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
      ),
      home: const WarPage(),
    );
  }
}

class WarPage extends StatefulWidget {
  const WarPage({super.key});

  @override
  State<WarPage> createState() => _WarPageState();
}

class _WarPageState extends State<WarPage> with SingleTickerProviderStateMixin {
  // Mock Data (In real app, fetch from backend)
  String side1Name = "Messi";
  String side2Name = "Ronaldo";
  // Using placeholder images
  String side1Image = "https://upload.wikimedia.org/wikipedia/commons/b/b4/Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg";
  String side2Image = "https://upload.wikimedia.org/wikipedia/commons/8/8c/Cristiano_Ronaldo_2018.jpg";

  int votes1 = 12503;
  int votes2 = 11982;
  bool hasVoted = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _vote(int side) {
    if (hasVoted) return;

    setState(() {
      if (side == 1) votes1++;
      else votes2++;
      hasVoted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You voted for ${side == 1 ? side1Name : side2Name}! 🔥"),
        backgroundColor: side == 1 ? Colors.blueAccent : Colors.redAccent,
      ),
    );
  }

  void _shareWar() {
    // In a real app, generate a dynamic image card here.
    // For MVP, we share the text/link.
    Share.share(
      "🔥 WAR: $side1Name vs $side2Name! \n\n"
      "Current Stats:\n"
      "$side1Name: ${(votes1 / (votes1 + votes2) * 100).toStringAsFixed(1)}%\n"
      "$side2Name: ${(votes2 / (votes1 + votes2) * 100).toStringAsFixed(1)}%\n\n"
      "Vote now! 👇\n"
      "https://fanwar-web.vercel.app/war/messi-vs-ronaldo",
      subject: "FanWar: Pick your side!",
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = votes1 + votes2;
    double percent1 = totalVotes == 0 ? 0.5 : votes1 / totalVotes;

    return Scaffold(
      appBar: AppBar(
        title: Text("FanWar 🔥", style: GoogleFonts.bangers(fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareWar,
          )
        ],
      ),
      body: Column(
        children: [
          // VS Section
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Row(
                  children: [
                    // Side 1 (Blue)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _vote(1),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(side1Image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4), 
                                BlendMode.darken
                              ),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(side1Name, style: GoogleFonts.bangers(fontSize: 40, color: Colors.blueAccent)),
                                if (hasVoted)
                                  Text("$votes1 Votes", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Side 2 (Red)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _vote(2),
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(side2Image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4), 
                                BlendMode.darken
                              ),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(side2Name, style: GoogleFonts.bangers(fontSize: 40, color: Colors.redAccent)),
                                if (hasVoted)
                                  Text("$votes2 Votes", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // VS Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.orangeAccent)],
                    ),
                    child: Text("VS", style: GoogleFonts.blackOpsOne(color: Colors.black, fontSize: 30)),
                  ),
                ),
              ],
            ),
          ),

          // Stats Bar
          if (hasVoted)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text("Live Results", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  LinearPercentIndicator(
                    animation: true,
                    lineHeight: 30.0,
                    animationDuration: 1000,
                    percent: percent1,
                    center: Text("${(percent1 * 100).toStringAsFixed(1)}% vs ${(100 - percent1 * 100).toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                    barRadius: const Radius.circular(10),
                    progressColor: Colors.blueAccent,
                    backgroundColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _shareWar,
                    icon: const Icon(Icons.share),
                    label: const Text("Share on Instagram Story"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  )
                ],
              ),
            ),
            
          // Comments Section Mockup
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black54,
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  Text("Comments (12k)", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.grey),
                  _buildComment("Arun", "Messi is the GOAT 🐐 no debate!", Colors.blueAccent),
                  _buildComment("Priya", "CR7 forever! SIUUUU! 🔥", Colors.redAccent),
                  _buildComment("Karthik", "Both are legends respect 🙏", Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(String user, String text, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color, child: Text(user[0])),
      title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(text, style: const TextStyle(color: Colors.white70)),
      trailing: const Icon(Icons.favorite_border, size: 16),
    );
  }
}
