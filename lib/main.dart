import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'firebase_options.dart';
import 'package:confetti/confetti.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoApp',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// splash_screen.dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  final int backgroundLeaves = 20;
  final int foregroundLeaves = 15;
  final Random random = Random();
  final List<_Leaf> backLayer = [];
  final List<_Leaf> frontLayer = [];

  // Sparkles
  final int sparklesCount = 25;
  final List<_Sparkle> sparkles = [];

  //Emoji sequence
  final List<String> _emojis = ["🌍", "🌳", "💧", "🍃"];
  int _currentEmojiIndex = 0;

  @override
  void initState() {
    super.initState();

    // Background leaves
    for (int i = 0; i < backgroundLeaves; i++) {
      backLayer.add(_Leaf(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 15 + 8,
        speed: random.nextDouble() * 1 + 0.3,
        rotation: random.nextDouble() * pi * 2,
        rotationSpeed: random.nextDouble() * 0.02,
        color: Colors.green.shade200.withOpacity(0.5),
      ));
    }

    // Foreground leaves
    for (int i = 0; i < foregroundLeaves; i++) {
      frontLayer.add(_Leaf(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 25 + 15,
        speed: random.nextDouble() * 2 + 1.2,
        rotation: random.nextDouble() * pi * 2,
        rotationSpeed: random.nextDouble() * 0.05,
        color: Colors.green.shade400.withOpacity(0.9),
      ));
    }

    // Sparkles around circle
    for (int i = 0; i < sparklesCount; i++) {
      sparkles.add(_Sparkle(
        angle: random.nextDouble() * 2 * pi,
        distance: 120 + random.nextDouble() * 30, // distance from circle
        size: random.nextDouble() * 5 + 2,
        opacity: random.nextDouble(),
      ));
    }

    // Logo grow animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // Text fade-in animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _textController.forward();
    });

    // Navigate to AuthPage after 8 seconds
    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthPage()),
      );
    });

    // Animate leaves
    _animateLeaves(backLayer);
    _animateLeaves(frontLayer);

    // Animate sparkles
    Timer.periodic(const Duration(milliseconds: 150), (timer) {
      setState(() {
        for (var s in sparkles) {
          s.opacity += (random.nextDouble() - 0.5) * 0.3;
          if (s.opacity < 0) s.opacity = 0;
          if (s.opacity > 1) s.opacity = 1;
        }
      });
    });

    // Change emoji every 3s
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentEmojiIndex = (_currentEmojiIndex + 1) % _emojis.length;
      });
    });
  }

  void _animateLeaves(List<_Leaf> layer) {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var leaf in layer) {
          leaf.y += leaf.speed / 100;
          leaf.rotation += leaf.rotationSpeed;
          if (leaf.y > 1.2) {
            leaf.y = -0.2;
            leaf.x = random.nextDouble();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenCenter = MediaQuery.of(context).size.center(Offset.zero);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Background layer leaves
          ...backLayer.map((leaf) {
            return Positioned(
              left: MediaQuery.of(context).size.width * leaf.x,
              top: MediaQuery.of(context).size.height * leaf.y,
              child: Transform.rotate(
                angle: leaf.rotation,
                child: Icon(Icons.eco, size: leaf.size, color: leaf.color),
              ),
            );
          }).toList(),

          // Foreground layer leaves
          ...frontLayer.map((leaf) {
            return Positioned(
              left: MediaQuery.of(context).size.width * leaf.x,
              top: MediaQuery.of(context).size.height * leaf.y,
              child: Transform.rotate(
                angle: leaf.rotation,
                child: Icon(Icons.eco, size: leaf.size, color: leaf.color),
              ),
            );
          }).toList(),
// Sparkles around circle
          ...sparkles.map((s) {
            final offset = Offset(
              screenCenter.dx + cos(s.angle) * s.distance,
              screenCenter.dy + sin(s.angle) * s.distance,
            );
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: Opacity(
                opacity: s.opacity,
                child: Container(
                  width: s.size,
                  height: s.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    //  Magical eco sparkles (greens)
                    gradient: RadialGradient(
                      colors: [
                        Colors.greenAccent.withOpacity(0.9),
                        Colors.lightGreen.withOpacity(0.7),
                        Colors.tealAccent.withOpacity(0.5),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // circle logo with emojisis
          Center(
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _logoController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50.withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 50,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _emojis[_currentEmojiIndex],
                    key: ValueKey<int>(_currentEmojiIndex),
                    style: const TextStyle(fontSize: 100),
                  ),
                ),
              ),
            ),
          ),

          // App name
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textController,
              child: const Text(
                "EcoApp",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tagline
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _textController,
              child: const Text(
                "Grow Green, Live Clean",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Leaf class
class _Leaf {
  double x, y, size, speed, rotation, rotationSpeed;
  Color color;

  _Leaf({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });
}

//  Sparkle class
class _Sparkle {
  double angle, distance, size, opacity;

  _Sparkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.opacity,
  });
}

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  String selectedRole = 'Student';
  String? selectedSchool;
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _classCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

//Pre-filled Punjab school list
  final List<String> schools = [
    "Government Senior Secondary School, Ludhiana",
    "DAV College, Jalandhar",
    "Punjab University, Chandigarh",
    "Khalsa College, Amritsar",
    "Guru Nanak Dev University, Amritsar"
  ];

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isLogin) {
        // Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        // Signup
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );

        final uid = cred.user!.uid;
        final userData = {
          'uid': uid,
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'role': selectedRole,
          'school': selectedSchool,
          'address': _addressCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (selectedRole == 'Student') {
          userData['class'] = _classCtrl.text.trim();
          await FirebaseFirestore.instance
              .collection('students')
              .doc(uid)
              .set(userData);
        } else if (selectedRole == 'Teacher') {
          await FirebaseFirestore.instance
              .collection('teachers')
              .doc(uid)
              .set(userData);
        } else if (selectedRole == 'Admin') {
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(uid)
              .set(userData);
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isLogin
                ? 'Login successful!'
                : 'Account created successfully!')),
      );

      final role = selectedRole;
      Widget nextPage;
      if (role == "Student") {
        nextPage = StudentHomePage(role: role, name: _nameCtrl.text);
      } else if (role == "Teacher") {
        nextPage = TeacherHomePage(role: role, name: _nameCtrl.text);
      } else {
        nextPage = AdminHomePage(role: role, name: _nameCtrl.text);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextPage),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget roleSelector() {
    final roles = ['Student', 'Teacher', 'Admin'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: roles.map((r) {
        final active = selectedRole == r;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text(r),
            selected: active,
            onSelected: (_) => setState(() => selectedRole = r),
            selectedColor: Colors.green.shade200,
            backgroundColor: Colors.grey.shade200,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = selectedRole == 'Student';
    final isTeacher = selectedRole == 'Teacher';
    return Scaffold(
      appBar: AppBar(
        title: Text('EcoApp'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Toggle login/signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(() => isLogin = true),
                    child: Text('Login',
                        style: TextStyle(
                            color: isLogin ? Colors.green.shade800 : null)),
                  ),
                  Text('|'),
                  TextButton(
                    onPressed: () => setState(() => isLogin = false),
                    child: Text('Signup',
                        style: TextStyle(
                            color: !isLogin ? Colors.green.shade800 : null)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Role selector
                        Text('I am a',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        roleSelector(),
                        SizedBox(height: 16),

                        // Name (only for signup)
                        if (!isLogin)
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: InputDecoration(labelText: 'Full name'),
                            validator: (v) => (v == null || v.trim().length < 2)
                                ? 'Enter your name'
                                : null,
                          ),

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Enter email';
                            if (!v.contains('@')) return 'Enter valid email';
                            return null;
                          },
                        ),

                        // Password
                        TextFormField(
                          controller: _passCtrl,
                          decoration: InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (v) {
                            if (isLogin && (v == null || v.trim().isEmpty))
                              return 'Enter password';
                            if (!isLogin && (v == null || v.trim().length < 6))
                              return 'Min 6 chars';
                            return null;
                          },
                        ),

                        //Dropdown for school (shown for Student + Teacher)
                        if (!isLogin && (isStudent || isTeacher))
                          DropdownButtonFormField<String>(
                            decoration:
                                InputDecoration(labelText: "Select School"),
                            value: selectedSchool,
                            items: schools.map((school) {
                              return DropdownMenuItem(
                                value: school,
                                child: Text(school),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedSchool = val;
                              });
                            },
                            validator: (v) {
                              if (!isLogin && (v == null || v.isEmpty)) {
                                return 'Please select your school';
                              }
                              return null;
                            },
                          ),

                        //  Address
                        if (!isLogin)
                          TextFormField(
                            controller: _addressCtrl,
                            decoration: InputDecoration(labelText: 'Address'),
                            validator: (v) {
                              if (!isLogin && (v == null || v.trim().isEmpty))
                                return 'Enter your address';
                              return null;
                            },
                          ),

                        // Class (only when Student & signup)
                        if (!isLogin && isStudent)
                          TextFormField(
                            controller: _classCtrl,
                            decoration:
                                InputDecoration(labelText: 'Class / Grade'),
                          ),

                        SizedBox(height: 18),

                        ElevatedButton.icon(
                          icon: Icon(isLogin ? Icons.login : Icons.person_add),
                          label: Text(isLogin ? 'Login' : 'Create account'),
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size.fromHeight(48)),
                          onPressed: submit,
                        ),

                        SizedBox(height: 10),

                        // Secondary actions
                        if (isLogin)
                          TextButton(
                            onPressed: () {
                              setState(() => isLogin = false);
                            },
                            child: Text('Don\'t have account? Sign up'),
                          )
                        else
                          TextButton(
                            onPressed: () {
                              setState(() => isLogin = true);
                            },
                            child: Text('Already have account? Login'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Text(
                'By continuing you agree to share basic profile info for EcoApp demo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- STUDENT HOME ----------------
// ---------------- STUDENT HOME ----------------
class StudentHomePage extends StatefulWidget {
  final String name;
  final String role;

  const StudentHomePage({super.key, required this.name, required this.role});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int _currentIndex = 0;
  // ✅ HIGHLIGHTED: studentScore added
  int studentScore = 0; // starts from 0, updated dynamically

  // ✅ HIGHLIGHTED: function to update score
  void addPoints(int earnedPoints) {
    setState(() {
      studentScore += earnedPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      MainPage(key: ValueKey("MainPage")),
      LessonsPage(key: ValueKey("LessonsPage")),
      LearningResourcesPage(key: ValueKey("LearningResourcesPage")),
      FeedPage(key: ValueKey("FeedPage"), taskTitle: "defaultTask"),
      TasksPage(key: ValueKey("TasksPage")),
      LeaderboardPage(key: ValueKey("LeaderboardPage")),
      ProfilePage(
        key: const ValueKey("ProfilePage"),
        name: widget.name,
        role: widget.role,
      ),
    ];

    // Safety check
    Widget bodyPage = (_currentIndex >= 0 && _currentIndex < _pages.length)
        ? _pages[_currentIndex]
        : _pages[0];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500), // fade speed
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: bodyPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "Lessons"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "LearningResourcesPage"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Feed"),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline), label: "Tasks"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: "Leaderboard"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          //BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Creation"),
        ],
      ),
    );
  }
}
// -------- MAIN TAB (HOME) --------

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  final List<String> quotes = const [
    "🌱 Small actions today make a greener tomorrow.",
    "💧 Every drop counts, save water!",
    "🌳 Plant a tree, grow a future.",
    "♻️ Recycle today for a better tomorrow."
  ];

  @override
  Widget build(BuildContext context) {
    final dailyQuote = quotes[0]; // can randomize later
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SortingGamePage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 1.0, end: 1.3),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                onEnd: () async {
                  await Future.delayed(const Duration(milliseconds: 200));
                  if (context.mounted) {
                    (context as Element).markNeedsBuild();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade700,
                        Colors.lightGreen.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.recycling,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Motivational Quote
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                dailyQuote,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          // Spin the Wheel
          Card(
            child: ListTile(
              leading: const Icon(Icons.casino, color: Colors.purple),
              title: const Text("Spin the Wheel 🎡"),
              subtitle: const Text("Win points, badges, and surprises!"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SpinWheelPage()),
                );
              },
            ),
          ),
          // Water Saver Challenge
          Card(
            child: ListTile(
              leading: const Icon(Icons.water_drop, color: Colors.blueAccent),
              title: const Text("💧 Water Saver Challenge"),
              subtitle: const Text("Tap water droplets to save them!"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WaterSaverChallengePage(),
                  ),
                );
              },
            ),
          ),

          // Upcoming Events
          Card(
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.green),
              title: const Text('Upcoming Events'),
              subtitle: const Text('Register for local eco events'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UpcomingEventsPage()),
              ),
            ),
          ),
        ],
      ),

      // Floating Calendar Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventCalendarPage()),
          );
        },
        backgroundColor: Colors.green.shade600,
        tooltip: "Event Calendar",
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_today, size: 28, color: Colors.white),
            SizedBox(height: 2),
            Text(
              "Calendar",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class WaterSaverChallengePage extends StatefulWidget {
  const WaterSaverChallengePage({super.key});

  @override
  State<WaterSaverChallengePage> createState() =>
      _WaterSaverChallengePageState();
}

class _WaterSaverChallengePageState extends State<WaterSaverChallengePage>
    with TickerProviderStateMixin {
  final Random random = Random();
  final int maxDroplets = 5;
  final List<double> positionsX = [];
  final List<double> positionsY = [];
  final List<bool> showSplash = [];
  int score = 0;
  int timeLeft = 30;
  bool gameOver = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < maxDroplets; i++) {
      positionsX.add(random.nextDouble());
      positionsY.add(random.nextDouble() * 0.5);
      showSplash.add(false);
    }

    // Droplet movement
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!gameOver) {
        setState(() {
          for (int i = 0; i < maxDroplets; i++) {
            positionsY[i] += 0.015 + score * 0.001; // speed increases
            if (positionsY[i] > 1.0) {
              positionsY[i] = 0;
              positionsX[i] = random.nextDouble();
            }
          }
        });
      }
    });

    // Countdown timer
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        setState(() {
          gameOver = true;
        });
        t.cancel();
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void saveDroplet(int index) {
    setState(() {
      score += 1;
      showSplash[index] = true;

      // Hide splash after 300ms
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          showSplash[index] = false;
        });
      });

      positionsY[index] = 0;
      positionsX[index] = random.nextDouble();
    });
  }

  double getWaterLevelFraction() {
    // Max water level corresponds to score 30
    return min(score / 30.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final waterHeight = MediaQuery.of(context).size.height * 0.25;

    return Scaffold(
      body: Stack(
        children: [
          // Keep the original gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlueAccent, Colors.greenAccent],
              ),
            ),
          ),

          // Transparent tub with rising water
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Tub border (transparent)
                Container(
                  width: 100,
                  height: waterHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70, width: 3),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                  ),
                ),
                // Water fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 100,
                  height: waterHeight * getWaterLevelFraction(),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // "Water Saved" label floating inside tub
                Positioned(
                  top: 8,
                  child: Text(
                    "💧 Water Saved",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black45)
                        ]),
                  ),
                ),
              ],
            ),
          ),

          // Droplets
          for (int i = 0; i < maxDroplets; i++)
            Positioned(
              top: positionsY[i] * MediaQuery.of(context).size.height,
              left: positionsX[i] * MediaQuery.of(context).size.width * 0.9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () => saveDroplet(i),
                    child: AnimatedScale(
                      scale: showSplash[i] ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.water_drop,
                          color: Colors.blueAccent, size: 40),
                    ),
                  ),
                  if (showSplash[i])
                    AnimatedOpacity(
                      opacity: showSplash[i] ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(Icons.bubble_chart,
                          color: Colors.lightBlueAccent, size: 30),
                    ),
                ],
              ),
            ),

          // Score and Timer
          Positioned(
            top: 40,
            left: 16,
            child: Text(
              "Score: $score",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: Text(
              "Time: $timeLeft s",
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),

          // Game Over Overlay
          if (gameOver)
            Center(
              child: Container(
                color: Colors.white70,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "🏆 Game Over!",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Your Score: $score",
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const WaterSaverChallengePage()));
                        },
                        child: const Text("Play Again"))
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// -------- LESSONS TAB --------
class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> quotes = [
    "🌱 Small actions today make a greener tomorrow.",
    "💧 Every drop counts, save water!",
    "🌳 Plant a tree, grow a future.",
    "♻️ Recycle today for a better tomorrow."
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Run 3 bounces on page load
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        _controller.forward(from: 0.0).then((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _controller.forward(from: 0.0);
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dailyQuote = quotes[0]; // can randomize later
    final String currentUserId = "YOUR_LOGGED_IN_USER_ID"; // set dynamically
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lessons",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Motivational quote card
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                dailyQuote,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          // ⭐ NEW: CHATBOT BUTTON
          // ⭐ CHATBOT BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Card(
              color: Colors.blue.shade100,
              child: ListTile(
                leading: const Icon(Icons.chat, color: Colors.blueAccent),
                title: const Text("Eco Chatbot 🤖"),
                subtitle: const Text("Ask your eco-questions!"),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                onTap: () async {
                  const chatGPTUrl =
                      'https://chat.openai.com/'; // 👈 or Gemini link
                  final uri = Uri.parse(chatGPTUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $chatGPTUrl';
                  }
                },
              ),
            ),
          ),

          // 🔥 QUIZ SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Quizzes 🎯",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // DYNAMIC QUIZZES FROM FIRESTORE
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('quizzes')
                      .orderBy('createdAt', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No quizzes yet");
                    }

                    final quizzes = snapshot.data!.docs;
                    return Column(
                      children: quizzes.map((doc) {
                        final quiz = doc.data()! as Map<String, dynamic>;
                        // <-- REPLACE OLD CARD WITH THIS NEW CARD
                        return Card(
                          color: Colors.green.shade100,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading:
                                const Icon(Icons.quiz, color: Colors.green),
                            title: Text(quiz['title'] ?? 'Untitled Quiz'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ➤ Challenge Friend Icon
                                IconButton(
                                  icon: const Icon(Icons.emoji_events,
                                      color: Colors.orange),
                                  tooltip: "Challenge a Friend",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChallengeFriendScreen(
                                          taskTitle:
                                              quiz['title'] ?? "Untitled Quiz",
                                          currentUserId: currentUserId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Colors.black54),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DynamicQuizPage(
                                    quizId: doc.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          // LESSONS SECTION
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lessons')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No lessons yet"));
                }

                final lessons = snapshot.data!.docs;
                return ListView(
                  shrinkWrap:
                      true, // ✅ let it size itself inside parent ListView
                  physics: const NeverScrollableScrollPhysics(),
                  children: lessons.map((doc) {
                    final lesson = doc.data()! as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.book, color: Colors.green),
                      title: Text(lesson["title"] ?? "Untitled"),
                      onTap: () {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (context) => LessonDetailPage(
                              lessonTitle: lesson["title"] ?? "Untitled",
                              lessonContent: lesson["content"] ?? "",
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatGPTPage extends StatefulWidget {
  const ChatGPTPage({super.key});

  @override
  State<ChatGPTPage> createState() => _ChatGPTPageState();
}

class _ChatGPTPageState extends State<ChatGPTPage> {
  late final WebViewController _controller;
  bool _isLoading = true; // ✅ For showing loader

  @override
  void initState() {
    super.initState();

    // ✅ 1. Set up WebView platform implementation
    if (WebViewPlatform.instance == null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        WebViewPlatform.instance = AndroidWebViewPlatform();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        WebViewPlatform.instance = WebKitWebViewPlatform();
      }
    }

    // ✅ 2. Create controller and load ChatGPT
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://chat.openai.com/?model=gpt-4o'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eco Chatbot 🤖'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          // ✅ WebView content
          WebViewWidget(controller: _controller),

          // ✅ Loading spinner overlay
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}

class LessonDetailPage extends StatelessWidget {
  final String lessonTitle;
  final String lessonContent;

  const LessonDetailPage({
    super.key,
    required this.lessonTitle,
    required this.lessonContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lessonTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(lessonContent),
      ),
    );
  }
}

// ---------------- DYNAMIC QUIZ PAGE ----------------
class DynamicQuizPage extends StatefulWidget {
  final String? challengeId;
  final bool isChallenger;
  final String? quizId; // Firestore document ID
  final Map<String, dynamic>? quizData;

  const DynamicQuizPage({
    super.key,
    this.quizId,
    this.quizData,
    this.challengeId,
    this.isChallenger = true,
  });

  @override
  State<DynamicQuizPage> createState() => _DynamicQuizPageState();
}

class _DynamicQuizPageState extends State<DynamicQuizPage> {
  List<Map<String, dynamic>> quizzes = [];
  int currentIndex = 0;
  int score = 0;
  bool answered = false;
  int? selectedOption;
  late ConfettiController _confetti;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    fetchQuiz();
  }

  Future<void> fetchQuiz() async {
    if (widget.quizData != null) {
      final List<Map<String, dynamic>> questions =
          List<Map<String, dynamic>>.from(widget.quizData!["questions"]);
      setState(() {
        quizzes = questions;
        loading = false;
      });
    } else if (widget.quizId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (doc.exists) {
        final List<Map<String, dynamic>> questions =
            List<Map<String, dynamic>>.from(doc.data()!["questions"]);
        setState(() {
          quizzes = questions;
          loading = false;
        });
      } else {
        setState(() => loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Quiz not found!")));
      }
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Quiz not found!")));
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void checkAnswer(int index) {
    if (answered) return;

    setState(() {
      answered = true;
      selectedOption = index;

      if (index == quizzes[currentIndex]["answer"]) {
        score++;
        _confetti.play();
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), nextQuestion);
  }

  void nextQuestion() {
    if (currentIndex < quizzes.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedOption = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("🎉 Quiz Finished!"),
          content: Text(
              "You scored $score / ${quizzes.length}\n\n${score == quizzes.length ? "🌟 Perfect!" : "Keep learning 🌱"}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final quiz = quizzes[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz 🌱"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / quizzes.length,
                color: Colors.green,
                backgroundColor: Colors.green.shade100,
                minHeight: 10,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  quiz["question"] as String,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: (quiz["options"] as List).length,
                  itemBuilder: (context, index) {
                    final option = (quiz["options"] as List)[index];
                    final correct = quiz["answer"] == index;

                    Color cardColor = Colors.white;
                    if (answered) {
                      if (index == selectedOption) {
                        cardColor = correct ? Colors.green : Colors.red;
                      } else if (correct) {
                        cardColor = Colors.green.shade200;
                      }
                    }

                    return GestureDetector(
                      onTap: () => checkAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            )
                          ],
                        ),
                        child: Text(
                          option.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: -pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LearningResourcesPage extends StatefulWidget {
  const LearningResourcesPage({super.key});

  @override
  State<LearningResourcesPage> createState() => _LearningResourcesPageState();
}

class _LearningResourcesPageState extends State<LearningResourcesPage> {
  final TextEditingController searchController = TextEditingController();
  final String apiKey =
      "5a8dff013ab14cf89bb5b2feb763baa3"; // Replace with your NewsAPI key

  Future<List<Map<String, String>>> fetchPunjabNews() async {
    final url = Uri.parse(
        "https://newsapi.org/v2/everything?q=Punjab+environment&language=en&pageSize=10&sortBy=publishedAt&apiKey=$apiKey");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List articles = data['articles'] ?? [];

      return articles.map<Map<String, String>>((article) {
        final Map<String, dynamic> art = article as Map<String, dynamic>;
        return {
          "title": art['title']?.toString() ?? "No title",
          "content": art['description']?.toString() ?? "No description",
          "url": art['url']?.toString() ?? "",
        };
      }).toList();
    } else {
      throw Exception("Failed to fetch news: ${response.statusCode}");
    }
  }

  // Launch YouTube search in default browser
  void _launchYouTubeSearch(String query) async {
    final url = "https://www.youtube.com/results?search_query=$query";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not launch YouTube")),
      );
    }
  }

  // ---------- Fetch Air Quality (WAQI) ----------
  Future<Map<String, dynamic>> fetchAirQuality(String city) async {
    const String token =
        "a29afe2ce02c2255bbc8c2f0901800d45d9d0b7e"; // your WAQI token
    final url = Uri.parse("https://api.waqi.info/feed/$city/?token=$token");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData["status"] == "ok" && jsonData.containsKey("data")) {
        return jsonData["data"];
      } else {
        throw Exception("Invalid response: ${jsonData["status"]}");
      }
    } else {
      throw Exception(
          "Failed to load air quality data: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Punjab Environment News"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ---------- Search YouTube Bar ----------
          Card(
            color: Colors.orange.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    "Search Environmental Videos",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: "Enter topic...",
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          final query = searchController.text.trim();
                          if (query.isNotEmpty) {
                            _launchYouTubeSearch(query);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---------- Dynamic News Cards ----------
          FutureBuilder<List<Map<String, String>>>(
            future: fetchPunjabNews(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error loading news: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("No news found"));
              }

              final newsCards = snapshot.data!;
              return Column(
                children: newsCards.map((card) {
                  return GestureDetector(
                    onTap: () async {
                      final url = card['url']!;
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.lightBlueAccent,
                            Colors.greenAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card['title']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card['content']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}

// -------- FEED TAB WITH REACTIONS --------
class FeedPage extends StatefulWidget {
  final String taskTitle;
  const FeedPage({super.key, required this.taskTitle});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  Future<void> _openPostDialog() async {
    final _titleCtrl = TextEditingController();
    final _descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Create Post"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_titleCtrl.text.isNotEmpty && _descCtrl.text.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance.collection('posts').add({
                    "user": user?.email ?? "Anonymous",
                    "text": "${_titleCtrl.text}: ${_descCtrl.text}",
                    "likes": 0,
                    "comments": 0,
                    "reactions": {"🌱": 0, "💧": 0, "♻️": 0, "❤️": 0},
                    "createdAt": FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(ctx);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Feed"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _openPostDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts yet"));
          }
          final posts = snapshot.data!.docs;
          return ListView(
            children: [
              // Eco Student of the Week at top
              Card(
                margin: const EdgeInsets.all(12),
                color: Colors.yellow.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ListTile(
                  leading:
                      Icon(Icons.emoji_events, color: Colors.orange, size: 32),
                  title: Text(
                    "Eco Student of the Week",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("⭐ Rishitha for planting 5 trees!"),
                ),
              ),
              // Posts
              ...posts.map((doc) {
                final post = doc.data() as Map<String, dynamic>;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User + post
                        ListTile(
                          title: Text(post["user"] ?? ""),
                          subtitle: Text(post["text"] ?? ""),
                        ),
                        const SizedBox(height: 4),

                        // Reactions Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: (post["reactions"] as Map<String, dynamic>)
                              .keys
                              .map(
                            (emoji) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(doc.id)
                                        .update({
                                      "reactions.$emoji":
                                          FieldValue.increment(1),
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(emoji,
                                          style: const TextStyle(fontSize: 18)),
                                      const SizedBox(width: 4),
                                      Text("${(post["reactions"][emoji])}"),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                        const Divider(),

                        // Likes & Comments
                        Row(
                          children: [
                            const Icon(Icons.thumb_up,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Text("${post["likes"] ?? 0}"),
                            const SizedBox(width: 16),
                            const Icon(Icons.comment,
                                color: Colors.blue, size: 18),
                            const SizedBox(width: 4),
                            Text("${post["comments"] ?? 0}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
// -------- TASKS TAB WITH STREAK BADGE AND FIRESTORE --------

class TasksPage extends StatefulWidget {
  final String? taskFilter;
  const TasksPage({super.key, this.taskFilter});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> tasks = [];
  int streakDays = 5;
  int totalPoints = 0;
  DateTime? lastCompletion;

  String userId = '';
  Set<String> feedTasks = {}; // still loaded but not used

  // badge tracking
  List<String> unlockedBadges = [];

  // NEW: confetti
  late ConfettiController _confettiController;
  String _newlyUnlockedBadge = '';

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadUserAndScore();
    _loadTasks();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

// ⭐ NEW: load tasks from 'newtasks' collection (teacher-added)
  Future<void> _loadTasks() async {
    final taskDocs = await _firestore.collection('newtasks').get();
    setState(() {
      tasks = taskDocs.docs.map((doc) {
        return {
          "title": doc.id,
          "points": doc.data()['points'] ?? 10,
          "completed": false, // student-specific completion
        };
      }).toList();
    });
  }

  Future<void> _loadUserAndScore() async {
    final user = _auth.currentUser;
    if (user != null) {
      userId = user.uid;

      // Load score
      final doc = await _firestore.collection('score').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          totalPoints = data['points'] ?? 0;
          // load badges if exist
          unlockedBadges = List<String>.from(data['badges'] ?? []);
        });
      } else {
        await _firestore
            .collection('score')
            .doc(userId)
            .set({'points': 0, 'badges': []});
        setState(() {
          totalPoints = 0;
          unlockedBadges = [];
        });
      }

      // Load streak
      final streakDoc = await _firestore
          .collection('score')
          .doc(userId)
          .collection('streak')
          .doc('current')
          .get();
      if (streakDoc.exists && streakDoc.data() != null) {
        final streakData = streakDoc.data()!;
        setState(() {
          streakDays = streakData['streakDays'] ?? streakDays;
          if (streakData['lastCompletion'] != null) {
            lastCompletion =
                (streakData['lastCompletion'] as Timestamp).toDate();
          }
        });
      } else {
        await _firestore
            .collection('score')
            .doc(userId)
            .collection('streak')
            .doc('current')
            .set({'streakDays': streakDays, 'lastCompletion': null});
      }

      // Load completed tasks
      final taskDocs = await _firestore
          .collection('score')
          .doc(userId)
          .collection('tasks')
          .get();
      if (taskDocs.docs.isNotEmpty) {
        setState(() {
          for (var taskDoc in taskDocs.docs) {
            final index = tasks.indexWhere((t) => t["title"] == taskDoc.id);
            if (index != -1) {
              tasks[index]["completed"] = taskDoc.data()['completed'] ?? false;
            }
          }
        });
      }

      // Listen to feed tasks in real-time (optional)
      _firestore
          .collection('feed')
          .doc(userId)
          .collection('tasks')
          .snapshots()
          .listen((snapshot) {
        final newFeedTasks =
            snapshot.docs.map((e) => e.data()['task'] as String).toSet();
        setState(() {
          feedTasks = newFeedTasks;
        });

        // Auto mark tasks completed if feed posted
        for (var i = 0; i < tasks.length; i++) {
          if (!tasks[i]["completed"] &&
              feedTasks.any(
                  (t) => t.toLowerCase() == tasks[i]["title"].toLowerCase())) {
            _handleTaskAuto(i); // mark completed automatically
          }
        }
      });
    }
  }

  Future<void> _handleTaskAuto(int taskIndex) async {
    Map<String, dynamic> task = tasks[taskIndex];

    final taskDoc = await _firestore
        .collection('score')
        .doc(userId)
        .collection('tasks')
        .doc(task["title"])
        .get();

    final today = DateTime.now();
    if (taskDoc.exists) {
      final completedOn = taskDoc.data()?['completedOn'] as Timestamp?;
      if (completedOn != null &&
          DateTime(completedOn.toDate().year, completedOn.toDate().month,
                  completedOn.toDate().day) ==
              DateTime(today.year, today.month, today.day)) {
        return; // Already completed today
      }
    }

    // Mark task completed
    tasks[taskIndex]["completed"] = true;
    totalPoints += task["points"] as int;

    double progress = tasks.isEmpty
        ? 0
        : tasks.where((t) => t["completed"]).length / tasks.length;
    int percentage = (progress * 100).toInt();

    // Handle streak
    int updatedStreak = streakDays;
    if (lastCompletion != null) {
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final lastDate = DateTime(
          lastCompletion!.year, lastCompletion!.month, lastCompletion!.day);

      if (lastDate == yesterday) {
        updatedStreak += 1;
      } else if (lastDate != today) {
        updatedStreak = 1;
      }
    } else {
      updatedStreak = 1;
    }
    lastCompletion = today;
    setState(() {
      streakDays = updatedStreak;
    });

    // NEW: badge unlock logic with confetti
    List<String> newlyUnlocked = [];

    int completedTasksCount = tasks.where((t) => t["completed"]).length;

    // Badge thresholds
    Map<int, String> badgeMap = {
      1: "Starter",
      3: "Eco Hero",
      6: "Green Warrior",
      9: "Planet Protector",
      12: "Eco Champion",
      15: "Ultimate Green Star"
    };

    badgeMap.forEach((taskCount, badgeName) {
      if (completedTasksCount >= taskCount &&
          !unlockedBadges.contains(badgeName)) {
        unlockedBadges.add(badgeName);
        newlyUnlocked.add(badgeName);
      }
    });
    // Trigger confetti + dialog for each new badge
    for (var badge in newlyUnlocked) {
      _newlyUnlockedBadge = badge;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _confettiController.play();

        // Badge unlock messages
        String dialogContent = '';
        String buttonText = '';

        if (badge == 'Starter') {
          dialogContent =
              "Fantastic! You’ve earned the 'Starter' badge. You’ve taken your first step towards making a positive impact on the environment. Keep it up!";
          buttonText = "Keep Going!";
        } else if (badge == 'Eco Hero') {
          dialogContent =
              "Amazing! You’ve unlocked the 'Eco Hero' badge. Your dedication to eco-friendly actions is inspiring. Continue making a difference!";
          buttonText = "Go Green Hero!";
        } else if (badge == 'Green Warrior') {
          dialogContent =
              "6 tasks completed! Outstanding! Your dedication earns the ‘Green Warrior’ badge!";
          buttonText = "Keep it Up!";
        } else if (badge == 'Planet Protector') {
          dialogContent =
              "Incredible! ‘Planet Protector’ unlocked. Keep protecting our Earth!";
          buttonText = "Go Green!";
        } else if (badge == 'Eco Champion') {
          dialogContent =
              "12 tasks done! The environment thanks you. Eco Champion unlocked!";
          buttonText = "Champion!";
        } else if (badge == 'Ultimate Green Star') {
          dialogContent = "15 tasks completed! You’re an Ultimate Green Star!";
          buttonText = "Legendary!";
        } else {
          dialogContent = "You unlocked the badge: $_newlyUnlockedBadge";
          buttonText = "Awesome!";
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("🎉 Congratulations!"),
            content: Text(dialogContent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _confettiController.stop();
                },
                child: Text(buttonText),
              ),
            ],
          ),
        );
      });
    }
    // Save task
    await _firestore
        .collection('score')
        .doc(userId)
        .collection('tasks')
        .doc(task["title"])
        .set({'completed': true, 'completedOn': today});

    // Save points & percentage
    await _firestore.collection('score').doc(userId).set({
      'points': totalPoints,
      'percentage': percentage,
      'badges': unlockedBadges,
    });

    // Save streak
    await _firestore
        .collection('score')
        .doc(userId)
        .collection('streak')
        .doc('current')
        .set({'streakDays': updatedStreak, 'lastCompletion': lastCompletion});
  }

  int get completedPoints => tasks
      .where((t) => t["completed"])
      .fold(0, (sum, t) => sum + t["points"] as int);

  @override
  Widget build(BuildContext context) {
    double progress = tasks.isEmpty
        ? 0
        : tasks.where((t) => t["completed"]).length / tasks.length;
    // ===== tasks remaining message =====
    List<int> badgeThresholds = [1, 3, 6, 9, 12, 15];
    int completedTasksCount = tasks.where((t) => t["completed"]).length;
    int? nextBadgeCount = badgeThresholds.firstWhere(
        (t) => t > completedTasksCount,
        orElse: () => 0); // 0 means no more badges
    String nextBadgeMessage = '';
    if (nextBadgeCount > 0) {
      int tasksLeft = nextBadgeCount - completedTasksCount;
      nextBadgeMessage =
          "Only $tasksLeft task(s) left to unlock your next badge!";
    } else {
      nextBadgeMessage = "🎉 You’ve unlocked all badges! Amazing!";
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Tasks"),
        backgroundColor: Colors.green,
        actions: [
          // 🔔 Notifications icon with red dot
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('notifications')
                .where('receiverId', isEqualTo: userId)
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              int unreadCount = 0;
              if (snapshot.hasData) {
                unreadCount = snapshot.data!.docs.length;
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      // Navigate to NotificationsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NotificationsPage(currentUserId: userId),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Stack(
        // NEW: Wrap with Stack for confetti overlay
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streak badge at top
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.orange.shade100,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.local_fire_department,
                        color: Colors.red, size: 32),
                    title: Text(
                      "🔥 $streakDays-day streak!",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Keep completing your eco tasks!"),
                  ),
                ),
                // badge display
                if (unlockedBadges.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.green.shade100,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.emoji_events,
                          color: Colors.green, size: 32),
                      title: const Text(
                        "Unlocked Badges",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(unlockedBadges.join(", ")),
                    ),
                  ),
                // Progress bar
                const Text(
                  "Task Progress",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  color: Colors.green,
                  backgroundColor: Colors.green.shade100,
                  minHeight: 12,
                ),
                const SizedBox(height: 8),
                Text(
                  "${(progress * 100).toInt()}% completed | Points: $totalPoints",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                // ===== NEW: display tasks remaining message =====
                const SizedBox(height: 8),
                Text(
                  nextBadgeMessage,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Today's Tasks",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(task["title"]),
                          trailing: task["completed"]
                              ? const Text(
                                  "Completed",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Checkbox(
                                  value: task["completed"],
                                  onChanged: (_) => _handleTaskAuto(index),
                                  activeColor: Colors.green,
                                ),
                          subtitle: Text("Points: ${task["points"]}"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // NEW: Confetti overlay

          Align(
            alignment: Alignment.center, // center for full impact
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true, // ✅ loop continuously until stopped manually
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.purple,
                Colors.yellow,
                Colors.pink
              ], // more vibrant and encouraging
              numberOfParticles: 50, // more particles for excitement
              gravity: 0.3,
              emissionFrequency: 0.05, // rapid emission for effect
              maxBlastForce: 50,
              minBlastForce: 20,
              blastDirection: -3.14 / 2, // upward
              particleDrag: 0.05, // natural falling
            ),
          ),
        ],
      ),
    );
  }
}

// -------- PROFILE TAB --------
class ProfilePage extends StatelessWidget {
  final String name;
  final String role;

  const ProfilePage({super.key, required this.name, required this.role});

  Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // ✅ Use role to decide which collection to look in
      final doc = await FirebaseFirestore.instance
          .collection(
              role.toLowerCase() + "s") // "students", "teachers", "admins"
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Profile fetch error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getScoreData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection('score')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
    } catch (e) {
      debugPrint("Score fetch error: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _getTasks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final taskDocs = await FirebaseFirestore.instance
          .collection('score')
          .doc(user.uid)
          .collection('tasks')
          .get();

      return taskDocs.docs
          .map((e) =>
              {"title": e.id, "completed": e.data()['completed'] ?? false})
          .toList();
    } catch (e) {
      debugPrint("Tasks fetch error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data ?? {};

        return FutureBuilder<Map<String, dynamic>?>(
          future: _getScoreData(),
          builder: (context, scoreSnapshot) {
            final scoreData = scoreSnapshot.data ?? {};
            final streakDays = scoreData['streakDays'] ?? 0;
            final unlockedBadges = List<String>.from(scoreData['badges'] ?? []);

            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _getTasks(),
              builder: (context, tasksSnapshot) {
                final tasks = tasksSnapshot.data ?? [];
                final completedTasks =
                    tasks.where((t) => t['completed']).length;

                return Scaffold(
                  appBar: AppBar(title: const Text("Profile")),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Profile",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        // Name
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.green),
                            const SizedBox(width: 10),
                            Text("Name: ${profile["name"] ?? name}"),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Role
                        Row(
                          children: [
                            const Icon(Icons.badge, color: Colors.blue),
                            const SizedBox(width: 10),
                            Text("Role: ${profile["role"] ?? role}"),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Email
                        Row(
                          children: [
                            const Icon(Icons.email, color: Colors.red),
                            const SizedBox(width: 10),
                            Text("Email: ${profile["email"] ?? ""}"),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Class
                        Row(
                          children: [
                            const Icon(Icons.class_, color: Colors.orange),
                            const SizedBox(width: 10),
                            Text("Class: ${profile["class"] ?? ""}"),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // School
                        Row(
                          children: [
                            const Icon(Icons.school, color: Colors.purple),
                            const SizedBox(width: 10),
                            Text("School: ${profile["school"] ?? ""}"),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Address
                        Row(
                          children: [
                            const Icon(Icons.home, color: Colors.brown),
                            const SizedBox(width: 10),
                            Text("Address: ${profile["address"] ?? ""}"),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ★ Impressive Achievements Card for Judges ★
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          color: Colors.green.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "🌟 Achievements",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text("Name: ${profile['name'] ?? name}"),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.local_fire_department,
                                        color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text("Streak: $streakDays days"),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                        "Tasks Completed: $completedTasks / ${tasks.length}"),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (unlockedBadges.isNotEmpty)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.emoji_events,
                                          color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              "Badges: ${unlockedBadges.join(', ')}")),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Logout button
                        Center(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Logout"),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ---------------- ADMIN HOME ----------------
class AdminHomePage extends StatelessWidget {
  final String name;
  final String role;

  const AdminHomePage({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              "Welcome $name!\nRole: $role\n⚙️ Manage app & users here.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),

          // --- Admin: Add Event ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.add, color: Colors.blue),
              title: const Text('Add Event (Admin)'),
              subtitle: const Text('Create a new event'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const AdminAddEventPage()), // ✅ NAVIGATION
                );
              },
            ),
          ),

          // --- Admin: Manage Events ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.orange),
              title: const Text('Manage Events (Admin)'),
              subtitle: const Text('View & mark attendance'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminEventsPage()), // ✅ NAVIGATION
                );
              },
            ),
          ),

          // --- Admin: Upcoming Events ---
          Card(
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.green),
              title: const Text('Upcoming Events'),
              subtitle: const Text('View all upcoming events'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const UpcomingEventsPage()), // ✅ NAVIGATION
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: const Text("Event Calendar"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const EventCalendarPage()), // ✅ Navigation
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Leaderboard Page (reads score/{uid} docs, ordered by points desc)

class LeaderboardPage extends StatefulWidget {
  // 🔥 NEW (changed only this line, rest untouched)
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState(); // 🔥 NEW
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // 🔥 NEW
  String selectedSchool = "All Schools"; // 🔥 NEW

  Future<Map<String, dynamic>> _getStudentFullData(String studentId) async {
    // 🔥 NEW (moved inside state class)
    final firestore = FirebaseFirestore.instance;

    final studentDoc =
        await firestore.collection('students').doc(studentId).get();
    final studentData = studentDoc.data() ?? {};

    final scoreDoc = await firestore.collection('score').doc(studentId).get();
    final scoreData = scoreDoc.data() ?? {};
    final ecoPoints = scoreData['points'] ?? 0;

    final streakDoc = await firestore
        .collection('score')
        .doc(studentId)
        .collection('streak')
        .doc('current')
        .get();
    final streakDays =
        streakDoc.exists ? (streakDoc.data()?['streakDays'] ?? 0) : 0;

    final tasksSnap = await firestore
        .collection('score')
        .doc(studentId)
        .collection('tasks')
        .get();
    final tasksCompleted =
        tasksSnap.docs.where((doc) => doc.data()['completed'] == true).length;

    final badgesUnlocked = (scoreData['badges'] as List?)?.length ?? 0;

    return {
      "id": studentId,
      "name": studentData['name'] ?? "Unnamed",
      "ecoPoints": ecoPoints,
      "streak": streakDays,
      "tasksCompleted": tasksCompleted,
      "badgesUnlocked": badgesUnlocked,
      "school": studentData['school'] ?? "Unknown", // 🔥 NEW
    };
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // 🔥 NEW: Dropdown to select school
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('students').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final allSchools = snapshot.data!.docs
                  .map((doc) => doc['school']?.toString() ?? "Unknown")
                  .toSet()
                  .toList();
              allSchools.sort();

              final dropdownItems = ["All Schools", ...allSchools];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: selectedSchool,
                  items: dropdownItems.map((school) {
                    return DropdownMenuItem(
                      value: school,
                      child: Text(school),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => selectedSchool = val);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Show school wise",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('students').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final studentDocs = snapshot.data!.docs;

                if (studentDocs.isEmpty) {
                  return const Center(child: Text("No students yet!"));
                }

                // 🔥 NEW: Apply school filter
                final filteredDocs = selectedSchool == "All Schools"
                    ? studentDocs
                    : studentDocs
                        .where((doc) => (doc['school'] ?? "") == selectedSchool)
                        .toList();

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(
                      filteredDocs.map((doc) => _getStudentFullData(doc.id))),
                  builder: (context, futureSnapshot) {
                    if (!futureSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final studentsData = futureSnapshot.data!;
                    studentsData.sort((a, b) => (b['ecoPoints'] as int)
                        .compareTo(a['ecoPoints'] as int));

                    return ListView.builder(
                      itemCount: studentsData.length,
                      itemBuilder: (context, index) {
                        final data = studentsData[index];
                        final isCurrentUser = data['id'] == currentUser?.uid;

                        Widget rankIcon;
                        if (index == 0) {
                          rankIcon = const Icon(Icons.emoji_events,
                              color: Colors.amber, size: 30);
                        } else if (index == 1) {
                          rankIcon = const Icon(Icons.emoji_events,
                              color: Colors.grey, size: 30);
                        } else if (index == 2) {
                          rankIcon = const Icon(Icons.emoji_events,
                              color: Colors.brown, size: 30);
                        } else {
                          rankIcon = CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: Text(
                              "${index + 1}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }

                        return Card(
                          color: isCurrentUser
                              ? Colors.green.shade50
                              : Colors.white,
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: rankIcon,
                            title: Text(
                              isCurrentUser
                                  ? "${data['name']} (YOU)"
                                  : data['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCurrentUser
                                    ? Colors.green
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              "🏫 School: ${data['school']}\n"
                              "🌱 Points: ${data['ecoPoints']}   🔥 Streak: ${data['streak']}\n"
                              "✅ Tasks: ${data['tasksCompleted']}     🎖️ Badges: ${data['badgesUnlocked']}",
                            ),
                            trailing: Icon(
                              isCurrentUser
                                  ? Icons.star
                                  : Icons.arrow_forward_ios,
                              color: isCurrentUser ? Colors.green : Colors.grey,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChallengeFriendScreen extends StatelessWidget {
  final String taskTitle;
  final String currentUserId;

  const ChallengeFriendScreen({
    super.key,
    required this.taskTitle,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Challenge a Friend"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .where('uid', isNotEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No other students found."));
          }

          final students = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade200,
                      child: Text(
                        student['name'][0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      student['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text("Ready to challenge for: $taskTitle"),
                    trailing: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('challenges')
                          .where('challengerId', isEqualTo: currentUserId)
                          .where('challengedId', isEqualTo: student['uid'])
                          .where('taskTitle', isEqualTo: taskTitle)
                          .snapshots(),
                      builder: (context, challengeSnapshot) {
                        if (!challengeSnapshot.hasData ||
                            challengeSnapshot.data!.docs.isEmpty) {
                          // No challenge sent yet
                          return ElevatedButton(
                            onPressed: () async {
                              final firestore = FirebaseFirestore.instance;

                              // 1. Add challenge
                              await firestore.collection('challenges').add({
                                'challengerId': currentUserId,
                                'challengedId': student['uid'],
                                'taskTitle': taskTitle,
                                'status': 'pending',
                                'quizId': 'quiz001',
                                'winnerId': null,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              // 2. Add notification (fixed timestamp)
                              await firestore.collection('notifications').add({
                                'senderId': currentUserId,
                                'receiverId': student['uid'],
                                'taskTitle': taskTitle,
                                'status': 'pending',
                                'timestamp': DateTime.now(), // ✅ fix
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Challenge sent successfully!"),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Challenge"),
                          );
                        } else {
                          // Challenge exists, check status
                          final challengeDoc =
                              challengeSnapshot.data!.docs.first;
                          final status = challengeDoc['status'];

                          return ElevatedButton(
                            onPressed: null, // disable button
                            style: ElevatedButton.styleFrom(
                              backgroundColor: status == 'accepted'
                                  ? Colors.green
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              status == 'accepted' ? "Accepted" : "✓",
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  final String currentUserId;
  const NotificationsPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('notifications')
            .where('receiverId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final notif = docs[index];
              final senderId = notif['senderId'];
              final taskTitle = notif['taskTitle'];
              final status = notif['status'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  title: Text("$senderId sent you a challenge!"),
                  subtitle: Text("Task: $taskTitle"),
                  trailing: status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                // 1. Update notification status
                                await _firestore
                                    .collection('notifications')
                                    .doc(notif.id)
                                    .update({'status': 'accepted'});

                                // 2. Update challenge status
                                final challengeQuery = await _firestore
                                    .collection('challenges')
                                    .where('challengerId', isEqualTo: senderId)
                                    .where('challengedId',
                                        isEqualTo: currentUserId)
                                    .where('taskTitle', isEqualTo: taskTitle)
                                    .limit(1)
                                    .get();

                                if (challengeQuery.docs.isNotEmpty) {
                                  await _firestore
                                      .collection('challenges')
                                      .doc(challengeQuery.docs.first.id)
                                      .update({'status': 'accepted'});
                                }

                                // ✅ 3. Navigate to MyChallengesPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyChallengesPage(
                                        currentUserId: currentUserId),
                                  ),
                                );
                              },
                              child: const Text("Accept"),
                            ),
                            TextButton(
                              onPressed: () async {
                                // 1. Update notification status
                                await _firestore
                                    .collection('notifications')
                                    .doc(notif.id)
                                    .update({'status': 'rejected'});

                                // 2. Update matching challenge status
                                final challengeQuery = await _firestore
                                    .collection('challenges')
                                    .where('challengerId', isEqualTo: senderId)
                                    .where('challengedId',
                                        isEqualTo: currentUserId)
                                    .where('taskTitle', isEqualTo: taskTitle)
                                    .limit(1)
                                    .get();

                                if (challengeQuery.docs.isNotEmpty) {
                                  await _firestore
                                      .collection('challenges')
                                      .doc(challengeQuery.docs.first.id)
                                      .update({'status': 'rejected'});
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Challenge Rejected!"),
                                  ),
                                );
                              },
                              child: const Text("Reject"),
                            ),
                          ],
                        )
                      : Text(status.toString().toUpperCase()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------- MY CHALLENGES PAGE ----------------

// ---------------- MY CHALLENGES PAGE ----------------
class MyChallengesPage extends StatelessWidget {
  final String currentUserId;

  const MyChallengesPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Challenges"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('challenges')
            .where('challengedId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No challenges yet."));
          }

          final challenges = snapshot.data!.docs;

          return ListView.builder(
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              final status = challenge['status'] ?? 'pending';
              final taskTitle = challenge['taskTitle'] ?? 'Untitled Quiz';
              final challengerId = challenge['challengerId'] ?? 'Unknown';
              final quizId = challenge['quizId'];

              // DEBUG LOG
              print("Challenge loaded: $challenge");

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        status == 'accepted' ? Colors.green : Colors.orange,
                    child: Text(
                      taskTitle.isNotEmpty ? taskTitle[0] : "?",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(taskTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Challenged by: $challengerId"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (status == 'accepted')
                        IconButton(
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.green),
                          tooltip: "Start Quiz",
                          onPressed: () async {
                            if (quizId == null || quizId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Quiz ID missing!")),
                              );
                              return;
                            }

                            final quizDoc = await FirebaseFirestore.instance
                                .collection('quizzes')
                                .doc(quizId)
                                .get();

                            if (!quizDoc.exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Quiz not found!")),
                              );
                              return;
                            }

                            final quizData = quizDoc.data()!;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DynamicQuizPage(
                                  quizId: quizId,
                                  quizData: quizData,
                                ),
                              ),
                            );
                          },
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'accepted'
                              ? Colors.green.shade100
                              : (status == 'pending'
                                  ? Colors.orange.shade100
                                  : Colors.red.shade100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: status == 'accepted'
                                ? Colors.green.shade800
                                : (status == 'pending'
                                    ? Colors.orange.shade800
                                    : Colors.red.shade800),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class IncomingChallengeListener extends StatelessWidget {
  final String currentUserId;
  const IncomingChallengeListener({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('challenges')
          .where('challengedId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        final challenges = snapshot.data!.docs;
        if (challenges.isNotEmpty) {
          final challenge = challenges.first;
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("Challenge Received!"),
                content: Text(
                    "Student ${challenge['challengerId']} challenged you!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('challenges')
                          .doc(challenge.id)
                          .update({'status': 'accepted'});
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DynamicQuizPage(
                            challengeId: challenge.id,
                            isChallenger: false,
                          ),
                        ),
                      );
                    },
                    child: Text("Accept"),
                  ),
                ],
              ),
            );
          });
        }
        return Container();
      },
    );
  }
}

// ---------------- TEACHER HOME ----------------
class TeacherHomePage extends StatefulWidget {
  final String name;
  final String role;

  const TeacherHomePage({super.key, required this.name, required this.role});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      TeacherLessonsPage(), // lessons tab for teachers
      FeedPage(
          taskTitle: "defaultTask"), // feed tab, no add button in feed page
      const TeacherTasksPage(), // tasks tab for teachers
      const LeaderboardPage(), // leaderboard
      TeacherProfilePage(name: widget.name, role: widget.role), // profile
    ];

    Widget bodyPage = (_currentIndex >= 0 && _currentIndex < _pages.length)
        ? _pages[_currentIndex]
        : _pages[0];

    return Scaffold(
      body: bodyPage,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "Lessons"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: "Leaderboard"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// -------- TEACHER LESSONS PAGE --------
class TeacherLessonsPage extends StatelessWidget {
  final List<String> quotes = [
    "🌱 Small actions today make a greener tomorrow.",
    "💧 Every drop counts, save water!",
    "🌳 Plant a tree, grow a future.",
    "♻️ Recycle today for a better tomorrow."
  ];

  @override
  Widget build(BuildContext context) {
    final dailyQuote = quotes[0]; // can randomize later

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lessons"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Add New Lesson",
            onPressed: () => _openAddLessonDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.quiz),
            tooltip: "Add New Quiz",
            onPressed: () => _openAddQuizDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Motivational quote card
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                dailyQuote,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.green),
              title: const Text('Upcoming Events'),
              subtitle: const Text('See all upcoming events and register'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const UpcomingEventsPage()), // ✅ NAVIGATION
                );
              },
            ),
          ),
          // 🔥 SUBMITTED QUIZZES SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Submitted Quizzes 🎯",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('quizzes')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No quizzes yet");
                    }

                    final quizzes = snapshot.data!.docs;
                    return Column(
                      children: quizzes.map((doc) {
                        final quiz = doc.data()! as Map<String, dynamic>;
                        return Card(
                          color: Colors.green.shade100,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading:
                                const Icon(Icons.quiz, color: Colors.green),
                            title: Text(quiz['title'] ?? 'Untitled Quiz'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // ✅ Delete confirmation
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Delete Quiz"),
                                    content: const Text(
                                        "Are you sure you want to delete this quiz?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('quizzes')
                                      .doc(doc.id)
                                      .delete();
                                }
                              },
                            ),
                            onTap: () {
                              // Optional: open DynamicQuizPage for preview
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DynamicQuizPage(
                                    quizId: doc.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lessons')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No lessons yet"));
                }
                final lessons = snapshot.data!.docs;
                return ListView(
                  children: lessons.map((doc) {
                    final lesson = doc.data()! as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.book, color: Colors.green),
                      title: Text(lesson["title"] ?? "Untitled"),
                      onTap: () {
                        Navigator.push(
                          ctx,
                          MaterialPageRoute(
                            builder: (context) => LessonDetailPage(
                              lessonTitle: lesson["title"] ?? "Untitled",
                              lessonContent: lesson["content"] ?? "",
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Add new lesson (existing)
  void _openAddLessonDialog(BuildContext context) {
    final _titleCtrl = TextEditingController();
    final _contentCtrl = TextEditingController();
    final _imageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Lesson"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: _contentCtrl,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 3,
              ),
              TextField(
                controller: _imageCtrl,
                decoration:
                    const InputDecoration(labelText: "Image URL (optional)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_titleCtrl.text.trim().isNotEmpty &&
                  _contentCtrl.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance.collection('lessons').add({
                  "title": _titleCtrl.text.trim(),
                  "content": _contentCtrl.text.trim(),
                  "image": _imageCtrl.text.trim(),
                  "createdAt": FieldValue.serverTimestamp(),
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  // ---- NEW: Add New Quiz ----
  void _openAddQuizDialog(BuildContext context) {
    final _titleCtrl = TextEditingController();
    final List<Map<String, dynamic>> _questions = [];

    final _questionCtrl = TextEditingController();
    final List<TextEditingController> _optionCtrls =
        List.generate(4, (_) => TextEditingController());
    int _answerIndex = 0;

    void _addQuestion() {
      if (_questionCtrl.text.trim().isNotEmpty &&
          _optionCtrls.every((c) => c.text.trim().isNotEmpty)) {
        _questions.add({
          "question": _questionCtrl.text.trim(),
          "options": _optionCtrls.map((c) => c.text.trim()).toList(),
          "answer": _answerIndex,
        });
        _questionCtrl.clear();
        for (var c in _optionCtrls) c.clear();
        _answerIndex = 0;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Text(
                  "Add New Quiz",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleCtrl,
                          decoration: InputDecoration(
                            labelText: "Quiz Title",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.green.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _questionCtrl,
                          decoration: InputDecoration(
                            labelText: "Question",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.green.shade50,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: List.generate(4, (i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: i,
                                    groupValue: _answerIndex,
                                    activeColor: Colors.green,
                                    onChanged: (val) {
                                      setState(() {
                                        _answerIndex = val!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: _optionCtrls[i],
                                      decoration: InputDecoration(
                                        labelText: "Option ${i + 1}",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        filled: true,
                                        fillColor: Colors.green.shade50,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _addQuestion();
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Question"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${_questions.length} question(s) added",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel")),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        _addQuestion();
                        if (_titleCtrl.text.trim().isNotEmpty &&
                            _questions.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('quizzes')
                              .add({
                            "title": _titleCtrl.text.trim(),
                            "questions": _questions,
                            "createdAt": FieldValue.serverTimestamp(),
                          });
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text("Submit Quiz"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------- TEACHER FEED PAGE --------
class TeacherFeedPage extends StatelessWidget {
  const TeacherFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Feed"),
        actions: const [], // ✅ ensures no buttons/icons appear
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No posts yet"));
          }
          final posts = snapshot.data!.docs;
          return ListView(
            children: [
              // Eco Student of the Week at top
              Card(
                margin: const EdgeInsets.all(12),
                color: Colors.yellow.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const ListTile(
                  leading:
                      Icon(Icons.emoji_events, color: Colors.orange, size: 32),
                  title: Text(
                    "Eco Student of the Week",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("⭐ Rishitha for planting 5 trees!"),
                ),
              ),
              // Posts
              ...posts.map((doc) {
                final post = doc.data() as Map<String, dynamic>;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(post["user"] ?? ""),
                          subtitle: Text(post["text"] ?? ""),
                        ),
                        const SizedBox(height: 4),
                        // Reactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: (post["reactions"] as Map<String, dynamic>)
                              .keys
                              .map(
                            (emoji) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Row(
                                  children: [
                                    Text(emoji,
                                        style: const TextStyle(fontSize: 18)),
                                    const SizedBox(width: 4),
                                    Text("${(post["reactions"][emoji])}"),
                                  ],
                                ),
                              );
                            },
                          ).toList(),
                        ),
                        const Divider(),
                        // Likes & Comments
                        Row(
                          children: [
                            const Icon(Icons.thumb_up,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Text("${post["likes"] ?? 0}"),
                            const SizedBox(width: 16),
                            const Icon(Icons.comment,
                                color: Colors.blue, size: 18),
                            const SizedBox(width: 4),
                            Text("${post["comments"] ?? 0}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class TeacherPollCard extends StatefulWidget {
  const TeacherPollCard({super.key});

  @override
  State<TeacherPollCard> createState() => _TeacherPollCardState();
}

//poll page//
class _TeacherPollCardState extends State<TeacherPollCard> {
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> choiceControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addChoiceField() {
    setState(() {
      choiceControllers.add(TextEditingController());
    });
  }

  void _submitPoll() async {
    final question = questionController.text.trim();
    final choices = choiceControllers
        .map((c) => c.text.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    if (question.isEmpty || choices.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add a question and at least 2 choices")),
      );
      return;
    }

    final teacherId = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('polls').add({
      "question": question,
      "choices": choices,
      "teacherId": teacherId,
      "createdAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Poll created successfully!")),
    );

    questionController.clear();
    for (var c in choiceControllers) c.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create a Poll",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: "Poll Question"),
            ),
            const SizedBox(height: 8),
            ...choiceControllers.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextField(
                      controller: c,
                      decoration: const InputDecoration(labelText: "Choice")),
                )),
            TextButton.icon(
              onPressed: _addChoiceField,
              icon: const Icon(Icons.add),
              label: const Text("Add Choice"),
            ),
            ElevatedButton(
              onPressed: _submitPoll,
              child: const Text("Post Poll"),
            ),
          ],
        ),
      ),
    );
  }
}

// -------- TEACHER PROFILE PAGE --------
class TeacherProfilePage extends StatelessWidget {
  final String name;
  final String role;

  const TeacherProfilePage({super.key, required this.name, required this.role});

  Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final doc = await FirebaseFirestore.instance
          .collection(role.toLowerCase() + "s") // "teachers"
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Profile fetch error: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snapshot.data ?? {};

        return Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Profile",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Name
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.green),
                    const SizedBox(width: 10),
                    Text("Name: ${profile["name"] ?? name}"),
                  ],
                ),
                const SizedBox(height: 12),

                // Role
                Row(
                  children: [
                    const Icon(Icons.badge, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text("Role: ${profile["role"] ?? role}"),
                  ],
                ),
                const SizedBox(height: 12),

                // Email
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.red),
                    const SizedBox(width: 10),
                    Text("Email: ${profile["email"] ?? ""}"),
                  ],
                ),
                const SizedBox(height: 12),

                // Class
                Row(
                  children: [
                    const Icon(Icons.class_, color: Colors.orange),
                    const SizedBox(width: 10),
                    Text("Class: ${profile["class"] ?? ""}"),
                  ],
                ),
                const SizedBox(height: 12),

                // School
                Row(
                  children: [
                    const Icon(Icons.school, color: Colors.purple),
                    const SizedBox(width: 10),
                    Text("School: ${profile["school"] ?? ""}"),
                  ],
                ),
                const SizedBox(height: 12),

                // Address
                Row(
                  children: [
                    const Icon(Icons.home, color: Colors.brown),
                    const SizedBox(width: 10),
                    Text("Address: ${profile["address"] ?? ""}"),
                  ],
                ),

                const SizedBox(height: 40),

                // Logout button
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------- TEACHER TASKS PAGE --------
class TeacherTasksPage extends StatefulWidget {
  const TeacherTasksPage({super.key});

  @override
  State<TeacherTasksPage> createState() => _TeacherTasksPageState();
}

class _TeacherTasksPageState extends State<TeacherTasksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final taskDocs = await _firestore.collection('newtasks').get();
    setState(() {
      tasks = taskDocs.docs
          .map((doc) => {
                "title": doc.id,
                "points": doc.data()['points'] ?? 10,
              })
          .toList();
    });
  }

  Future<void> _addNewTask() async {
    final _titleCtrl = TextEditingController();
    final _pointsCtrl = TextEditingController(text: "10");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add New Task"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Task Title"),
              ),
              TextField(
                controller: _pointsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Points"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleCtrl.text.trim();
              final points = int.tryParse(_pointsCtrl.text) ?? 10;
              if (title.isNotEmpty) {
                // Save task to Firestore
                await _firestore
                    .collection('newtasks')
                    .doc(title)
                    .set({'points': points});
                // Update local list
                setState(() {
                  tasks.add({"title": title, "points": points});
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add Task"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addNewTask,
            tooltip: "Add New Task",
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks found"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(task["title"]),
                    subtitle: Text("Points: ${task["points"]}"),
                    trailing: const Icon(
                      Icons.lock_outline, // indicate teacher cannot complete
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

int globalEcoPoints = 0;

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key});

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _SpinWheelPageState extends State<SpinWheelPage>
    with TickerProviderStateMixin {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  int _score = 0;
  late AnimationController _pageAnimationController;
  late Animation<Offset> _pageOffsetAnimation;

  final List<String> rewards = [
    "Match the Pair 🎯",
    "Riddle 🧩",
    "Word Scramble 🔤",
    "Try Again 🔄",
    "Learn from Chatbot 🤖",
  ];

  final List<Color> segmentColors = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.cyanAccent,
  ];

  @override
  void initState() {
    super.initState();

    _pageAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _pageOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _pageAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start page animation
    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _controller.close();
    _confettiController.dispose();
    _pageAnimationController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    final randomIndex = Random().nextInt(rewards.length);
    _controller.add(randomIndex);

    Future.delayed(const Duration(seconds: 4), () {
      final reward = rewards[randomIndex];
      if (!mounted) return;

      // Play confetti for fun rewards
      if (reward.contains("Riddle") ||
          reward.contains("Word Scramble") ||
          reward.contains("Match the Pair") ||
          reward.contains("Learn from Chatbot")) _confettiController.play();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "🎉 You Won! 🎉",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reward,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (reward.contains("Match the Pair"))
                const Text(
                  "🧩 Get ready to match the pairs! Click Accept to start.",
                  textAlign: TextAlign.center,
                ),
              if (reward.contains("Learn from Chatbot"))
                const Text(
                  "🤖 Ask the chatbot an eco-question! Click Accept to start.",
                  textAlign: TextAlign.center,
                ),
              if (reward.contains("Riddle"))
                const Text("🧩 Unlock a riddle challenge!"),
              if (reward.contains("Match the Pair"))
                const Text("Match the right Pairs!"),
              if (reward.contains("Word Scramble"))
                const Text("🔤 Try a word scramble!"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate only after accepting
                if (reward.contains("Riddle")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RiddlePage()),
                  );
                } else if (reward.contains("Word Scramble")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WordScramblePage()),
                  );
                } else if (reward.contains("Match the Pair")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MatchPairPage()),
                  );
                } else if (reward.contains("Learn from Chatbot")) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                }
              },
              child: const Text("Accept ✅"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Eco Spin Game 🌱🎡"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SlideTransition(
        position: _pageOffsetAnimation,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.pink
                ],
                numberOfParticles: 50,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Score Card
                  Card(
                    margin: const EdgeInsets.all(12),
                    color: Colors.yellow.shade100,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        "Eco Points: $_score",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Spin Wheel
                  SizedBox(
                    height: size.width * 0.3,
                    width: size.width * 0.3,
                    child: FortuneWheel(
                      animateFirst: false,
                      selected: _controller.stream,
                      indicators: const [
                        FortuneIndicator(
                          alignment: Alignment.topCenter,
                          child: TriangleIndicator(color: Colors.red),
                        ),
                      ],
                      items: [
                        for (var reward in rewards)
                          FortuneItem(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    segmentColors[rewards.indexOf(reward) %
                                        segmentColors.length],
                                    Colors.white.withOpacity(0.3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  reward,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Spin Button
                  GestureDetector(
                    onTap: _spinWheel,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 1, end: 1.05),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOut,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.green,
                              Colors.lightGreen,
                              Colors.yellow
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            )
                          ],
                        ),
                        child: const Text(
                          "SPIN NOW 🎡",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Try your luck and learn eco-tips! 🌱",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchPairPage extends StatefulWidget {
  const MatchPairPage({super.key});

  @override
  State<MatchPairPage> createState() => _MatchPairPageState();
}

class _MatchPairPageState extends State<MatchPairPage>
    with TickerProviderStateMixin {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  final Map<String, String> pairs = {
    "Tree": "🌳",
    "Sun": "☀️",
    "Rain": "🌧️",
    "Recycle": "♻️",
  };

  late List<String> keys;
  late List<String> values;
  Map<String, bool> matched = {};

  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    keys = pairs.keys.toList()..shuffle();
    values = pairs.values.toList()..shuffle();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..forward();
  }

  void _checkCompletion() {
    if (matched.length == pairs.length) {
      _confettiController.play();
      globalEcoPoints += 10;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.purple.shade50,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "🎉 All Pairs Matched! 🎉",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "You've earned +10 Eco Points! 🌱",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  keys.shuffle();
                  values.shuffle();
                  matched.clear();
                });
              },
              child: const Text("Play Again 🔄"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("Match the Pair 🌱"),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.pink,
                Colors.orange
              ],
              numberOfParticles: 50,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "Eco Points: $globalEcoPoints",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Draggable Keys with Bounce Animation
                      Column(
                        children: keys.map((key) {
                          return ScaleTransition(
                            scale: Tween<double>(begin: 0, end: 1).animate(
                                CurvedAnimation(
                                    parent: _bounceController,
                                    curve: Curves.elasticOut)),
                            child: Draggable<String>(
                              data: key,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          Colors.purpleAccent,
                                          Colors.orangeAccent
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(2, 2))
                                    ],
                                  ),
                                  child: Text(
                                    key,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  key,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black26),
                                ),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: matched[key] == true
                                      ? LinearGradient(colors: [
                                          Colors.greenAccent,
                                          Colors.green
                                        ])
                                      : LinearGradient(colors: [
                                          Colors.pinkAccent,
                                          Colors.orangeAccent
                                        ]),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2))
                                  ],
                                ),
                                child: Text(
                                  key,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      // Drag Targets with Pulse Animation
                      Column(
                        children: values.map((val) {
                          return DragTarget<String>(
                            onWillAccept: (_) => true,
                            onAccept: (receivedKey) {
                              if (pairs[receivedKey] == val) {
                                setState(() {
                                  matched[receivedKey] = true;
                                });
                                _confettiController.play();
                                _checkCompletion();
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(16),
                                width: size.width * 0.3,
                                decoration: BoxDecoration(
                                  gradient: candidateData.isNotEmpty
                                      ? LinearGradient(
                                          colors: [
                                            Colors.yellow,
                                            Colors.orangeAccent
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Colors.lightBlueAccent,
                                            Colors.blueAccent
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2))
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  val,
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiddlePage extends StatefulWidget {
  const RiddlePage({super.key});

  @override
  State<RiddlePage> createState() => _RiddlePageState();
}

class _RiddlePageState extends State<RiddlePage> {
  final List<Map<String, String>> riddles = [
    {
      "question": "I am green and help you breathe, what am I?",
      "answer": "Tree"
    },
    {
      "question": "I can be recycled again and again, what am I?",
      "answer": "Paper"
    },
    {
      "question": "I shine during the day and give light, what am I?",
      "answer": "Sun"
    },
    {
      "question": "I fall from the sky and water plants, what am I?",
      "answer": "Rain"
    },
  ];

  late Map<String, String> currentRiddle;
  final TextEditingController _controller = TextEditingController();
  String _message = "";
  late ConfettiController _confettiController;

  int _currentIndex = 0; // Track current riddle

  @override
  void initState() {
    super.initState();
    currentRiddle = riddles[_currentIndex]; // Start with first riddle
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    if (_controller.text.trim().toLowerCase() ==
        currentRiddle["answer"]!.toLowerCase()) {
      setState(() {
        _message = "🎉 Correct! 🌱";
      });
      _confettiController.play(); // Play confetti for correct answer
    } else {
      setState(() {
        _message = "❌ Wrong! Try Again.";
      });
    }
  }

  void _pickNextRiddle() {
    _currentIndex = (_currentIndex + 1) % riddles.length; // Next riddle
    setState(() {
      currentRiddle = riddles[_currentIndex];
      _controller.clear();
      _message = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text("Eco Riddle Challenge 🧩"),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.pink,
                Colors.orange
              ],
              numberOfParticles: 50,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Riddle card
                Card(
                  margin: const EdgeInsets.all(12),
                  color: Colors.yellow.shade100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Text(
                      currentRiddle["question"]!,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Answer input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter your answer here...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Check answer button
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Check Answer ✅",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _message,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _message.contains("Correct")
                          ? Colors.green
                          : Colors.red),
                ),
                const SizedBox(height: 30),
                // Next riddle button
                ElevatedButton(
                  onPressed: _pickNextRiddle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Next Riddle 🔄",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WordScramblePage extends StatefulWidget {
  const WordScramblePage({super.key});

  @override
  State<WordScramblePage> createState() => _WordScramblePageState();
}

class _WordScramblePageState extends State<WordScramblePage> {
  final List<Map<String, String>> words = [
    {"word": "Tree", "hint": "I am green and help you breathe 🌳"},
    {"word": "Paper", "hint": "You can recycle me again and again 📄"},
    {"word": "Sun", "hint": "I shine bright during the day ☀️"},
    {"word": "Rain", "hint": "I fall from the sky and water plants 🌧️"},
  ];

  late Map<String, String> currentWord;
  String scrambled = "";
  final TextEditingController _controller = TextEditingController();
  String _message = "";
  late ConfettiController _confettiController;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    currentWord = words[_currentIndex];
    scrambled = _scrambleWord(currentWord["word"]!);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _scrambleWord(String word) {
    List<String> chars = word.split('');
    chars.shuffle();
    return chars.join();
  }

  void _checkAnswer() {
    if (_controller.text.trim().toLowerCase() ==
        currentWord["word"]!.toLowerCase()) {
      setState(() {
        _message = "🎉 Correct! 🌟";
      });
      _confettiController.play();
    } else {
      setState(() {
        _message = "❌ Wrong! Try Again.";
      });
    }
  }

  void _nextWord() {
    _currentIndex = (_currentIndex + 1) % words.length;
    setState(() {
      currentWord = words[_currentIndex];
      scrambled = _scrambleWord(currentWord["word"]!);
      _controller.clear();
      _message = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: const Text("Word Scramble Challenge 🔤"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.pink,
                Colors.orange
              ],
              numberOfParticles: 50,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Scrambled word card
                Card(
                  margin: const EdgeInsets.all(12),
                  color: Colors.yellow.shade100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      children: [
                        Text(
                          "Unscramble this word:",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          scrambled,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentWord["hint"]!,
                          style: const TextStyle(
                              fontSize: 16, fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Answer input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Enter your answer here...",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Check answer button
                ElevatedButton(
                  onPressed: _checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Check Answer ✅",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _message,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _message.contains("Correct")
                          ? Colors.green
                          : Colors.red),
                ),
                const SizedBox(height: 30),
                // Next word button
                ElevatedButton(
                  onPressed: _nextWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Next Word 🔄",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------
// ChatPage using Wit.ai
// ---------------------
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  String _reply = "";

  // ⚡ PUT YOUR WIT.AI SERVER ACCESS TOKEN HERE
  final String witToken = "N2XXQQBQLSLN2L4PDZN64V2XHIGV4VMA";

  // Simple intent-based preset replies
  final Map<String, String> intentResponses = {
    "save_water": "💧 Save water by turning off taps when not in use!",
    "plant_tree": "🌳 Plant trees to make your environment greener!",
    "recycle": "♻️ Recycle waste to reduce pollution.",
    "greet": "Hello! I'm your EcoBot 🤖🌱 How can I help?",
    "default": "I am not sure about that. Can you ask something else?"
  };

  Future<void> _sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _reply = "Typing...");

    final url = Uri.parse(
        "https://api.wit.ai/message?v=20250924&q=${Uri.encodeQueryComponent(query)}");

    try {
      final response =
          await http.get(url, headers: {"Authorization": "Bearer $witToken"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Get the first intent detected
        String detectedIntent = "";
        if (data['intents'] != null && data['intents'].isNotEmpty) {
          detectedIntent = data['intents'][0]['name'];
        }

        setState(() => _reply =
            intentResponses[detectedIntent] ?? intentResponses["default"]!);
      } else {
        setState(() => _reply = "Error: ${response.body}");
      }
    } catch (e) {
      setState(() => _reply = "Error: $e");
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Eco Chatbot 🤖")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _reply,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask me anything...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SortingGamePage extends StatefulWidget {
  const SortingGamePage({super.key});

  @override
  State<SortingGamePage> createState() => _SortingGamePageState();
}

class _SortingGamePageState extends State<SortingGamePage>
    with TickerProviderStateMixin {
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  final Map<String, String> items = {
    "Plastic Bottle": "Recyclable",
    "Apple Core": "Compost",
    "Candy Wrapper": "Trash",
    "Newspaper": "Recyclable",
    "Banana Peel": "Compost",
    "Chip Bag": "Trash"
  };

  late List<String> keys;
  Map<String, bool> sorted = {};
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    keys = items.keys.toList()..shuffle();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.8,
      upperBound: 1.1,
    )..repeat(reverse: true);
  }

  void _checkCompletion() {
    if (sorted.length == items.length) {
      _confettiController.play();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("🎉 All Items Sorted!"),
          content: Text("Your total Eco Points: $globalEcoPoints"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  keys.shuffle();
                  sorted.clear();
                });
              },
              child: const Text("Play Again 🔄"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("Sorting Game ♻️"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.pink,
                Colors.orange
              ],
              numberOfParticles: 50,
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
              Text(
                "Eco Points: $globalEcoPoints",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Draggable Items
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: keys.map((item) {
                        bool isSorted = sorted[item] ?? false;
                        return ScaleTransition(
                          scale: _bounceController,
                          child: Draggable<String>(
                            data: item,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isSorted
                                        ? [Colors.green, Colors.lightGreen]
                                        : [Colors.blue, Colors.lightBlueAccent],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(2, 2))
                                  ],
                                ),
                                child: Text(item,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            childWhenDragging: Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(item),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSorted
                                      ? [Colors.greenAccent, Colors.green]
                                      : [
                                          Colors.yellowAccent,
                                          Colors.orangeAccent
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2))
                                ],
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Drag Target Bins
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ["Recyclable", "Compost", "Trash"].map((bin) {
                        return DragTarget<String>(
                          onWillAccept: (_) => true,
                          onAccept: (item) {
                            if (items[item] == bin) {
                              setState(() {
                                sorted[item] = true;
                                globalEcoPoints += 10;
                              });
                              _confettiController.play();
                            }
                            _checkCompletion();
                          },
                          builder: (context, candidateData, rejectedData) {
                            bool hovering = candidateData.isNotEmpty;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(16),
                              width: size.width * 0.3,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: hovering
                                      ? [Colors.greenAccent, Colors.lightGreen]
                                      : [
                                          Colors.orangeAccent,
                                          Colors.deepOrangeAccent
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2))
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  bin,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminAddEventPage extends StatefulWidget {
  const AdminAddEventPage({Key? key}) : super(key: key);

  @override
  State<AdminAddEventPage> createState() => _AdminAddEventPageState();
}

class _AdminAddEventPageState extends State<AdminAddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  DateTime? _date;
  bool _saving = false;

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null) return;
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay(hour: 10, minute: 0));
    setState(() {
      _date = DateTime(d.year, d.month, d.day, t?.hour ?? 10, t?.minute ?? 0);
    });
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate() || _date == null) {
      if (_date == null)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pick event date/time')));
      return;
    }
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final docRef = FirebaseFirestore.instance.collection('events').doc();
      await docRef.set({
        'title': _title.text.trim(),
        'description': _desc.text.trim(),
        'location': _location.text.trim(),
        'date': Timestamp.fromDate(_date!),
        'contactEmail': FirebaseAuth.instance.currentUser?.email ?? '',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _saving = false;
        _title.clear();
        _desc.clear();
        _location.clear();
        _date = null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Event created')));
      // ✅ NAVIGATION: Go to AdminEventsPage after creating event
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminEventsPage()),
      );
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date == null
        ? 'Pick date & time'
        : DateFormat('dd MMM yyyy, hh:mm a').format(_date!);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event (Admin)')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3),
                const SizedBox(height: 8),
                TextFormField(
                    controller: _location,
                    decoration: const InputDecoration(labelText: 'Location')),
                const SizedBox(height: 8),
                ListTile(
                  title: Text('Event Date'),
                  subtitle: Text(dateText),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _saveEvent,
                  icon: const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Create Event'),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class UpcomingEventsPage extends StatefulWidget {
  const UpcomingEventsPage({Key? key}) : super(key: key);
  @override
  State<UpcomingEventsPage> createState() => _UpcomingEventsPageState();
}

class _UpcomingEventsPageState extends State<UpcomingEventsPage> {
  final eventsRef =
      FirebaseFirestore.instance.collection('events').orderBy('date');

  // ✅ New function: show confirmation dialog & extra details
  Future<void> _showRegistrationDialog(
      String eventId, Map<String, dynamic> eventData) async {
    final _phoneController = TextEditingController();
    final _notesController = TextEditingController();
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Register for ${eventData['title']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Do you want to register for this event?'),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Any Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              confirmed = true;
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed) {
      await _register(eventId, eventData, extraData: {
        'phone': _phoneController.text.trim(),
        'notes': _notesController.text.trim(),
      });
    }
  }

  // Updated register function to accept extraData
  Future<void> _register(String eventId, Map<String, dynamic> eventData,
      {Map<String, dynamic>? extraData}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please login')));
      return;
    }
    final uid = user.uid;

    final regRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(uid);
    final studentRef =
        FirebaseFirestore.instance.collection('students').doc(uid);

    final already = await regRef.get();
    if (already.exists) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Already registered')));
      return;
    }

    // Get student name/email
    final studentSnap = await studentRef.get();
    String name = user.displayName ?? '';
    String email = user.email ?? '';
    if (studentSnap.exists) {
      final d = studentSnap.data()!;
      name = d['name'] ?? name;
      email = d['email'] ?? email;
    }

    // Save registration
    final regData = {
      'userId': uid,
      'name': name,
      'email': email,
      'registeredAt': FieldValue.serverTimestamp(),
      'status': 'registered',
      'certificateIssued': false,
      ...?extraData,
    };
    await regRef.set(regData);

    // Mirror in student doc
    await studentRef.set({
      'registeredEvents': {
        eventId: {
          'title': eventData['title'] ?? '',
          'date': eventData['date'] ?? null,
          'status': 'registered',
          'certificateNote': '',
          ...?extraData,
        }
      }
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Registered successfully')));
  }

  // ---------------- NEW: Share Function ----------------
  void _shareEvent(Map<String, dynamic> data) {
    final title = data['title'] ?? '';
    final desc = data['description'] ?? '';
    final dateTs = data['date'] as Timestamp?;
    final dateText = dateTs != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(dateTs.toDate())
        : '';
    final location = data['location'] ?? '';
    final msg = '🌱 Upcoming Eco Event: $title\n'
        'When: $dateText\n'
        'Where: $location\n'
        'Details: $desc\n\n'
        'Join & earn EcoPoints and Certificate!';
    Share.share(msg); // ✅ Share via WhatsApp, Gmail, Messenger, etc.
  }

// ---------------- WhatsApp Share ----------------
  void _shareViaWhatsApp(Map<String, dynamic> data) async {
    final title = data['title'] ?? '';
    final desc = data['description'] ?? '';
    final dateTs = data['date'] as Timestamp?;
    final dateText = dateTs != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(dateTs.toDate())
        : '';
    final location = data['location'] ?? '';
    final msg =
        '🌱 Upcoming Eco Event: $title\nWhen: $dateText\nWhere: $location\nDetails: $desc\n\nJoin & earn EcoPoints and Certificate!';
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(msg)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('WhatsApp not installed or cannot launch')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsRef.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text('No upcoming events'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data()! as Map<String, dynamic>;
              final dateTs = data['date'] as Timestamp?;
              final dateText = dateTs != null
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(dateTs.toDate())
                  : '—';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(data['title'] ?? ''),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateText),
                        if (data['location'] != null) Text(data['location']),
                      ]),
                  // ✅ Updated button to show dialog
                  trailing: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Important, otherwise Row takes full width
                    children: [
                      ElevatedButton(
                        child: const Text('Register'),
                        onPressed: () => _showRegistrationDialog(doc.id, data),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.green),
                        onPressed: () => _shareEvent(data),
                        tooltip: 'Share via all apps',
                      ),
                    ],
                  ),

                  onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: Text(data['title'] ?? ''),
                            content: SingleChildScrollView(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('When: $dateText'),
                                const SizedBox(height: 8),
                                Text(data['description'] ?? ''),
                                const SizedBox(height: 8),
                                Text('Contact: ${data['contactEmail'] ?? '—'}'),
                              ],
                            )),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'))
                            ],
                          )),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _shareEvent(Map<String, dynamic> data) {
  final title = data['title'] ?? '';
  final desc = data['description'] ?? '';
  final dateTs = data['date'] as Timestamp?;
  final dateText = dateTs != null
      ? DateFormat('dd MMM yyyy, hh:mm a').format(dateTs.toDate())
      : '';
  final location = data['location'] ?? '';
  final msg = '🌱 Upcoming Eco Event: $title\n'
      'When: $dateText\n'
      'Where: $location\n'
      'Details: $desc\n\n'
      'Join & earn EcoPoints and Certificate!';

  Share.share(msg); // Opens native share sheet
}

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({Key? key}) : super(key: key);

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  final eventsRef =
      FirebaseFirestore.instance.collection('events').orderBy('date');

  Future<void> _markComplete(
      {required String eventId,
      required String userId,
      required String userName}) async {
    final regRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .collection('registrations')
        .doc(userId);
    final studentRef =
        FirebaseFirestore.instance.collection('students').doc(userId);
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'admin';

    await regRef.update({
      'status': 'completed',
      'certificateIssued': true,
      'certificateNote': 'Issued offline by organizer',
      'attendanceMarkedBy': adminUid,
      'attendedAt': FieldValue.serverTimestamp(),
    });

    // Mirror in student's doc
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();
    final title = eventDoc['title'] ?? '';

    await studentRef.set({
      'registeredEvents': {
        eventId: {
          'title': title,
          'date': eventDoc['date'],
          'status': 'completed',
          'certificateNote': 'Issued offline by organizer'
        }
      }
    }, SetOptions(merge: true));

    // award coins
    await _awardEcoCoins(userId, 50);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Marked $userName as attended & issued offline certificate')));
  }

  Future<void> _awardEcoCoins(String userId, int coins) async {
    final userRef =
        FirebaseFirestore.instance.collection('students').doc(userId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final current = (snap.exists && snap.data()!.containsKey('ecoCoins'))
          ? (snap.data()!['ecoCoins'] as int)
          : 0;
      tx.set(userRef, {'ecoCoins': current + coins}, SetOptions(merge: true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events (Admin)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsRef.snapshots(),
        builder: (c, s) {
          if (!s.hasData)
            return const Center(child: CircularProgressIndicator());
          final events = s.data!.docs;
          if (events.isEmpty)
            return const Center(child: Text('No events created yet'));
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, i) {
              final edoc = events[i];
              final e = edoc.data()! as Map<String, dynamic>;
              final date =
                  e['date'] != null ? (e['date'] as Timestamp).toDate() : null;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ExpansionTile(
                  title: Text(e['title'] ?? ''),
                  subtitle: date != null
                      ? Text(DateFormat('dd MMM yyyy, hh:mm a').format(date))
                      : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('events')
                            .doc(edoc.id)
                            .collection('registrations')
                            .snapshots(),
                        builder: (ctx, regsSnap) {
                          if (!regsSnap.hasData)
                            return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Loading registrants...'));
                          final regs = regsSnap.data!.docs;
                          if (regs.isEmpty)
                            return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('No registrants yet'));
                          return Column(
                            children: regs.map((r) {
                              final d = r.data()! as Map<String, dynamic>;
                              final status = d['status'] ?? 'registered';
                              return ListTile(
                                title: Text(d['name'] ?? d['userId']),
                                subtitle: Text('Status: $status'),
                                trailing: status == 'completed'
                                    ? const Text('Certificate issued',
                                        style: TextStyle(color: Colors.green))
                                    : ElevatedButton(
                                        child: const Text('Mark attended'),
                                        onPressed: () => _markComplete(
                                            eventId: edoc.id,
                                            userId: r.id,
                                            userName: d['name'] ?? r.id),
                                      ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// inside ProfilePage build method (where you show profile info) add this widget
Widget studentEventsSection() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const SizedBox();

  final studentRef = FirebaseFirestore.instance.collection('students').doc(uid);
  return StreamBuilder<DocumentSnapshot>(
    stream: studentRef.snapshots(),
    builder: (context, snap) {
      if (!snap.hasData) return const SizedBox();
      final data = snap.data!.data() as Map<String, dynamic>? ?? {};
      final regEvents = data['registeredEvents'] as Map<String, dynamic>? ?? {};
      if (regEvents.isEmpty)
        return const Padding(
          padding: EdgeInsets.all(12),
          child: Text('No registered events yet'),
        );
      final entries = regEvents.entries.toList();
      entries.sort((a, b) {
        final ad = a.value['date'] as Timestamp?;
        final bd = b.value['date'] as Timestamp?;
        if (ad == null || bd == null) return 0;
        return (ad as Timestamp).compareTo(bd as Timestamp);
      });

      return Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('My Events',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...entries.map((e) {
              final ed = e.value as Map<String, dynamic>;
              final dateTs = ed['date'] as Timestamp?;
              final dateText = dateTs != null
                  ? DateFormat('dd MMM yyyy').format(dateTs.toDate())
                  : '';
              final status = ed['status'] ?? 'registered';
              final cert = ed['certificateNote'] ?? '';
              return ListTile(
                title: Text(ed['title'] ?? ''),
                subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dateText.isNotEmpty) Text(dateText),
                      Text('Status: $status'),
                      if (cert.isNotEmpty)
                        Text('Certificate: $cert',
                            style: const TextStyle(fontSize: 12)),
                    ]),
              );
            }).toList(),
          ]),
        ),
      );
    },
  );
}

class EventCalendarPage extends StatefulWidget {
  const EventCalendarPage({Key? key}) : super(key: key);

  @override
  State<EventCalendarPage> createState() => _EventCalendarPageState();
}

class _EventCalendarPageState extends State<EventCalendarPage> {
  final eventsRef =
      FirebaseFirestore.instance.collection('events').orderBy('date');
  Map<DateTime, List<Map<String, dynamic>>> eventsMap = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() async {
    final snapshot = await eventsRef.get();
    Map<DateTime, List<Map<String, dynamic>>> tempMap = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final dateTs = data['date'] as Timestamp?;
      if (dateTs != null) {
        final date = DateTime(
            dateTs.toDate().year, dateTs.toDate().month, dateTs.toDate().day);
        if (tempMap[date] == null) tempMap[date] = [];
        tempMap[date]!.add(data);
      }
    }

    setState(() {
      eventsMap = tempMap;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return eventsMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Calendar'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.greenAccent.shade400,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ],
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4)
                ],
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle(color: Colors.red),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedDay == null
                ? const Center(
                    child: Text('Select a day to see events',
                        style: TextStyle(fontSize: 16)))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: _getEventsForDay(_selectedDay!).map((event) {
                      final dateText = event['date'] != null
                          ? DateFormat('hh:mm a')
                              .format((event['date'] as Timestamp).toDate())
                          : '';
                      return Card(
                        elevation: 3,
                        shadowColor: Colors.green.shade100,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.greenAccent,
                            child: Text(
                              DateFormat('dd').format(
                                  (event['date'] as Timestamp).toDate()),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(event['title'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time: $dateText'),
                              if (event['location'] != null)
                                Text('Location: ${event['location']}'),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(event['title'] ?? ''),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(event['description'] ?? ''),
                                      const SizedBox(height: 8),
                                      if (event['contactEmail'] != null)
                                        Text(
                                            'Contact: ${event['contactEmail']}'),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
