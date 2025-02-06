import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import 'dart:async';
import 'settings_screen.dart';
import 'insights_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _settingsService = SettingsService();
  String? _userEmail;
  int _pomodoroMinutes = 25;
  int _restMinutes = 5;
  int _timeLeftInSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  bool _isRestMode = false;
  int _completedSessions = 0;
  int _sessionsToGrow = 3;
  int _selectedIndex = 0;
  List<String> _activityTags = [];
  String? _selectedTag;
  Timer? _settingsRefreshTimer;
  final _insightsKey = GlobalKey<InsightsScreenState>();
  bool _shouldRefreshInsights = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
    // Set up periodic settings refresh
    _settingsRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshSettings(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _settingsRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshSettings() async {
    if (!_isRunning) {
      // Only refresh when timer is not running
      final activityTags = await _settingsService.getActivityTags();
      final pomodoroLength = await _settingsService.getPomodoroLength();
      final restTime = await _settingsService.getRestTime();
      final sessionsToGrow = await _settingsService.getSessionsToGrow();

      setState(() {
        _activityTags = activityTags;
        if (!_isRunning) {
          _pomodoroMinutes = pomodoroLength;
          _restMinutes = restTime;
          _sessionsToGrow = sessionsToGrow;
          _timeLeftInSeconds =
              _isRestMode ? restTime * 60 : pomodoroLength * 60;
        }
      });
    }
  }

  Future<void> _loadSettings() async {
    final pomodoroLength = await _settingsService.getPomodoroLength();
    final restTime = await _settingsService.getRestTime();
    final activityTags = await _settingsService.getActivityTags();
    final lastSelectedTag = await _settingsService.getLastSelectedTag();
    final completedSessions = await _settingsService.getCompletedSessions();
    final sessionsToGrow = await _settingsService.getSessionsToGrow();

    setState(() {
      _pomodoroMinutes = pomodoroLength;
      _restMinutes = restTime;
      _timeLeftInSeconds = pomodoroLength * 60;
      _activityTags = activityTags;
      _selectedTag = lastSelectedTag ??
          (_activityTags.isNotEmpty ? _activityTags.first : null);
      _completedSessions = completedSessions;
      _sessionsToGrow = sessionsToGrow;
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail');
    });
  }

  void _startTimer() {
    if (_timer != null || (!_isRestMode && _selectedTag == null)) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeftInSeconds > 0) {
          _timeLeftInSeconds--;
        } else {
          _timer?.cancel();
          _timer = null;
          _isRunning = false;
          if (_isRestMode) {
            // Rest period completed, increment session and reset to work mode
            _incrementProgress();
            // Add completed time to activity statistics
            if (_selectedTag != null) {
              _settingsService.addTimeToActivity(
                  _selectedTag!, _pomodoroMinutes);
              _shouldRefreshInsights = true;
            }
            _isRestMode = false;
            _timeLeftInSeconds = _pomodoroMinutes * 60;
            _showCompletionDialog();
            // Switch to insights tab
            setState(() {
              _selectedIndex = 1; // Switch to insights tab
            });
          } else {
            // Work period completed, start rest period
            _isRestMode = true;
            _timeLeftInSeconds = _restMinutes * 60;
            _showRestDialog();
          }
        }
      });
    });
  }

  Future<void> _incrementProgress() async {
    setState(() {
      _completedSessions++;
    });
    await _settingsService.saveCompletedSessions(_completedSessions);
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      // Keep the current mode (work/rest) and only reset the time
      _timeLeftInSeconds =
          _isRestMode ? _restMinutes * 60 : _pomodoroMinutes * 60;
      _isRunning = false;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  String _formatTime() {
    int minutes = _timeLeftInSeconds ~/ 60;
    int seconds = _timeLeftInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getMotivationalMessage() {
    final totalMinutes = _completedSessions * _pomodoroMinutes;
    if (_completedSessions >= _sessionsToGrow) {
      return 'Amazing! You\'ve focused for $totalMinutes minutes\nand raised a Super Chicken! 🐔✨';
    } else {
      final sessionsLeft = _sessionsToGrow - _completedSessions;
      return 'Keep going! $sessionsLeft more sessions\nto raise your Super Chicken! 🥚';
    }
  }

  Widget _buildProgressTracker() {
    final isGrown = _completedSessions >= _sessionsToGrow;
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.withOpacity(0.2),
          ),
          child: Image.asset(
            isGrown
                ? 'assets/images/bigchicken.PNG'
                : 'assets/images/small_chicken.PNG',
            width: 120,
            height: 120,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _getMotivationalMessage(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: _completedSessions / _sessionsToGrow,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _completedSessions >= _sessionsToGrow ? Colors.green : Colors.amber,
          ),
          minHeight: 10,
        ),
        const SizedBox(height: 5),
        Text(
          'Sessions completed: $_completedSessions/$_sessionsToGrow',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Great Job! 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Wow—You completed another focus session!'),
              const SizedBox(height: 10),
              Text(
                _getMotivationalMessage(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Start Another'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetTimer();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Time for a Break! 🌟'),
          content:
              const Text('Great work! Take a moment to rest and recharge.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Start Rest Timer'),
              onPressed: () {
                Navigator.of(context).pop();
                _startTimer(); // Automatically start the rest timer
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveLastSelectedTag(String? tag) async {
    if (tag != null) {
      await _settingsService.saveLastSelectedTag(tag);
    }
  }

  Widget _buildTagSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activityTags.map((tag) {
                final isSelected = tag == _selectedTag;
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (bool selected) async {
                    setState(() {
                      _selectedTag = selected ? tag : null;
                    });
                    await _saveLastSelectedTag(_selectedTag);
                  },
                  selectedColor: Colors.amber.shade200,
                  checkmarkColor: Colors.black87,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _onInsightsVisibilityChanged(bool isVisible) {
    if (isVisible && _shouldRefreshInsights) {
      _insightsKey.currentState?.loadActivityData();
      _shouldRefreshInsights = false;
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _selectedIndex == 0
              ? (_isRestMode ? 'Rest Time' : 'Pomodoro Timer')
              : _selectedIndex == 1
                  ? 'Insights'
                  : 'Settings',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Pomodoro Timer Tab
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTagSelector(),
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProgressTracker(),
                        const SizedBox(height: 30),
                        Text(
                          _isRestMode ? 'Rest Time' : 'Focus Time',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _formatTime(),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _selectedTag == null
                                  ? null
                                  : _isRunning
                                      ? _pauseTimer
                                      : _startTimer,
                              icon: Icon(
                                  _isRunning ? Icons.pause : Icons.play_arrow),
                              label: Text(_isRunning ? 'Pause' : 'Start'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton.icon(
                              onPressed: _resetTimer,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Insights Tab
          InsightsScreen(
            key: _insightsKey,
            onScreenVisible: _onInsightsVisibilityChanged,
          ),
          // Settings Tab
          SettingsScreen(
            onSettingsChanged: _loadSettings,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
