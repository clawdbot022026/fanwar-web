import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const FanWarApp());
}

class FanWarApp extends StatelessWidget {
  const FanWarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FanWar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Simple navigation state for MVP
  bool isCreating = false;

  // Current War Data (Default)
  String side1Name = "Messi";
  String side2Name = "Ronaldo";
  String side1Image = "https://upload.wikimedia.org/wikipedia/commons/b/b4/Lionel-Messi-Argentina-2022-FIFA-World-Cup_%28cropped%29.jpg";
  String side2Image = "https://upload.wikimedia.org/wikipedia/commons/8/8c/Cristiano_Ronaldo_2018.jpg";

  void _startWar(String s1, String s2, String img1, String img2) {
    setState(() {
      side1Name = s1;
      side2Name = s2;
      side1Image = img1;
      side2Image = img2;
      isCreating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isCreating
        ? CreateWarPage(onWarCreated: _startWar, onCancel: () => setState(() => isCreating = false))
        : WarPage(
            side1Name: side1Name,
            side2Name: side2Name,
            side1Image: side1Image,
            side2Image: side2Image,
            onCreateNew: () => setState(() => isCreating = true),
          );
  }
}

class WarPage extends StatefulWidget {
  final String side1Name;
  final String side2Name;
  final String side1Image;
  final String side2Image;
  final VoidCallback onCreateNew;

  const WarPage({
    super.key,
    required this.side1Name,
    required this.side2Name,
    required this.side1Image,
    required this.side2Image,
    required this.onCreateNew,
  });

  @override
  State<WarPage> createState() => _WarPageState();
}

class _WarPageState extends State<WarPage> with SingleTickerProviderStateMixin {
  int votes1 = 12503;
  int votes2 = 11982;
  bool hasVoted = false;
  
  // Comment Data
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [
    {"user": "Arun", "text": "Messi is the GOAT 🐐 no debate!", "color": Colors.blueAccent, "likes": 45, "isLiked": false},
    {"user": "Priya", "text": "CR7 forever! SIUUUU! 🔥", "color": Colors.redAccent, "likes": 128, "isLiked": true},
    {"user": "Karthik", "text": "Both are legends respect 🙏", "color": Colors.grey, "likes": 12, "isLiked": false},
  ];

  void _vote(int side) {
    if (hasVoted) return;
    setState(() {
      if (side == 1) votes1++;
      else votes2++;
      hasVoted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You voted for ${side == 1 ? widget.side1Name : widget.side2Name}! 🔥"),
        backgroundColor: side == 1 ? Colors.blueAccent : Colors.redAccent,
      ),
    );
  }

  void _shareWar() {
    int total = votes1 + votes2;
    // Updated Link to GitHub Pages
    String link = "https://clawdbot022026.github.io/fanwar-web/";
    
    Share.share(
      "🔥 WAR: ${widget.side1Name} vs ${widget.side2Name}! \n\n"
      "Current Stats:\n"
      "${widget.side1Name}: ${(votes1 / total * 100).toStringAsFixed(1)}%\n"
      "${widget.side2Name}: ${(votes2 / total * 100).toStringAsFixed(1)}%\n\n"
      "Vote now! 👇\n$link",
      subject: "FanWar: Pick your side!",
    );
  }

  void _addComment() {
    if (_commentController.text.isEmpty) return;
    setState(() {
      comments.insert(0, {
        "user": "You",
        "text": _commentController.text,
        "color": Colors.purpleAccent,
        "likes": 0,
        "isLiked": false
      });
      _commentController.clear();
    });
  }

  void _likeComment(int index) {
    setState(() {
      if (comments[index]['isLiked']) {
        comments[index]['likes']--;
        comments[index]['isLiked'] = false;
      } else {
        comments[index]['likes']++;
        comments[index]['isLiked'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = votes1 + votes2;
    double percent1 = totalVotes == 0 ? 0.5 : votes1 / totalVotes;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onCreateNew,
        icon: const Icon(Icons.add),
        label: const Text("Create War"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Column(
        children: [
          // VS Section
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Row(
                  children: [
                    // Side 1
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _vote(1),
                        child: _buildSide(widget.side1Name, widget.side1Image, votes1, Colors.blueAccent, hasVoted),
                      ),
                    ),
                    // Side 2
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _vote(2),
                        child: _buildSide(widget.side2Name, widget.side2Image, votes2, Colors.redAccent, hasVoted),
                      ),
                    ),
                  ],
                ),
                // VS Badge & Header
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text("FanWar 🔥", 
                      style: GoogleFonts.bangers(fontSize: 32, color: Colors.white, shadows: [const Shadow(blurRadius: 10, color: Colors.black)])
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(blurRadius: 15, color: Colors.orangeAccent.withOpacity(0.6))],
                    ),
                    child: Text("VS", style: GoogleFonts.blackOpsOne(color: Colors.black, fontSize: 24)),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: _shareWar,
                  ),
                ),
              ],
            ),
          ),

          // Stats Bar
          if (hasVoted)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                children: [
                  LinearPercentIndicator(
                    animation: true,
                    lineHeight: 24.0,
                    animationDuration: 1000,
                    percent: percent1,
                    center: Text(
                      "${(percent1 * 100).toStringAsFixed(1)}% vs ${(100 - percent1 * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    barRadius: const Radius.circular(12),
                    progressColor: Colors.blueAccent,
                    backgroundColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
            
          // Comments Section
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Trash Talk (${comments.length})", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Icon(Icons.comment, color: Colors.grey),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: comments.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final c = comments[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: c['color'], 
                                    radius: 12,
                                    child: Text(c['user'][0], style: const TextStyle(fontSize: 12, color: Colors.white)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(c['user'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => _likeComment(index),
                                    child: Row(
                                      children: [
                                        Icon(
                                          c['isLiked'] ? Icons.favorite : Icons.favorite_border,
                                          size: 16,
                                          color: c['isLiked'] ? Colors.pink : Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text("${c['likes']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(c['text'], style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // Input Field
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              filled: true,
                              fillColor: Colors.black,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.deepOrangeAccent),
                          onPressed: _addComment,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSide(String name, String image, int votes, Color color, bool showVotes) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: GoogleFonts.bangers(fontSize: 32, color: color)),
            if (showVotes)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("$votes", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}

class CreateWarPage extends StatefulWidget {
  final Function(String, String, String, String) onWarCreated;
  final VoidCallback onCancel;

  const CreateWarPage({super.key, required this.onWarCreated, required this.onCancel});

  @override
  State<CreateWarPage> createState() => _CreateWarPageState();
}

class _CreateWarPageState extends State<CreateWarPage> {
  final _side1Controller = TextEditingController();
  final _side2Controller = TextEditingController();
  final _img1Controller = TextEditingController();
  final _img2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New War 🔥"),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Who is fighting?", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildInput("Side 1 Name (e.g. Batman)", _side1Controller, Icons.person),
              const SizedBox(height: 10),
              _buildInput("Side 1 Image URL", _img1Controller, Icons.image),
              const SizedBox(height: 30),
              _buildInput("Side 2 Name (e.g. Superman)", _side2Controller, Icons.person_outline),
              const SizedBox(height: 10),
              _buildInput("Side 2 Image URL", _img2Controller, Icons.image),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_side1Controller.text.isNotEmpty && _side2Controller.text.isNotEmpty) {
                    widget.onWarCreated(
                      _side1Controller.text,
                      _side2Controller.text,
                      _img1Controller.text.isNotEmpty ? _img1Controller.text : "https://via.placeholder.com/300",
                      _img2Controller.text.isNotEmpty ? _img2Controller.text : "https://via.placeholder.com/300",
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("START WAR ⚔️", style: GoogleFonts.bangers(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
