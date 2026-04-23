// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'today_page.dart';
import 'history_page.dart';
import 'welcome_view.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? onDarkModeChanged;
  final bool initialDarkMode;

  const HomeScreen({
    super.key,
    this.onDarkModeChanged,
    this.initialDarkMode = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  late bool _isDarkMode;

  static const List<Widget> _pages = <Widget>[TodayPage(), HistoryPage()];

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi logout
  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeView()),
      );
    }
  }

  // Fungsi toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      if (widget.onDarkModeChanged != null) {
        widget.onDarkModeChanged!(_isDarkMode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna dari theme saat ini
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? Colors.grey[850] : Colors.grey[100];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Logo Pays
            Image.asset(
              "assets/img/icon_logo_tr.png",
              height: 65,
              width: 65,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
          ],
        ),
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          // Tombol Dark Mode
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: textColor,
            ),
            onPressed: _toggleDarkMode,
            tooltip: _isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          // Tombol Logout
          IconButton(
            icon: Icon(Icons.logout, color: textColor),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Hari Ini'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: bgColor,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: textColor.withOpacity(0.6),
      ),
    );
  }
}
