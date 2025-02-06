import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function? onSettingsChanged;
  
  const SettingsScreen({
    super.key,
    this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  int _pomodoroLength = 25;
  int _restTime = 5;
  int _sessionsToGrow = 3;
  final List<String> _activityTags = [];
  String _newTag = '';
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final pomodoroLength = await _settingsService.getPomodoroLength();
    final restTime = await _settingsService.getRestTime();
    final sessionsToGrow = await _settingsService.getSessionsToGrow();
    final activityTags = await _settingsService.getActivityTags();
    
    setState(() {
      _pomodoroLength = pomodoroLength;
      _restTime = restTime;
      _sessionsToGrow = sessionsToGrow;
      _activityTags.clear();
      _activityTags.addAll(activityTags);
    });
  }

  Future<void> _savePomodoroLength(int length) async {
    await _settingsService.savePomodoroLength(length);
    widget.onSettingsChanged?.call();
  }

  Future<void> _saveRestTime(int time) async {
    await _settingsService.saveRestTime(time);
    widget.onSettingsChanged?.call();
  }

  Future<void> _saveSessionsToGrow(int sessions) async {
    await _settingsService.saveSessionsToGrow(sessions);
    widget.onSettingsChanged?.call();
  }

  Future<void> _saveActivityTags() async {
    await _settingsService.saveActivityTags(_activityTags);
    widget.onSettingsChanged?.call();
  }

  void _addTag() {
    if (_newTag.isNotEmpty && !_activityTags.contains(_newTag)) {
      setState(() {
        _activityTags.add(_newTag);
        _newTag = '';
        _tagController.clear();
      });
      _saveActivityTags();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _activityTags.remove(tag);
    });
    _saveActivityTags();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timer Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Timer Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pomodoro Length (minutes)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _pomodoroLength.toDouble(),
                      min: 1,
                      max: 60,
                      divisions: 59,
                      label: _pomodoroLength.toString(),
                      onChanged: (value) {
                        setState(() {
                          _pomodoroLength = value.round();
                        });
                      },
                      onChangeEnd: (value) {
                        _savePomodoroLength(value.round());
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Rest Time (minutes)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _restTime.toDouble(),
                      min: 1,
                      max: 15,
                      divisions: 14,
                      label: _restTime.toString(),
                      onChanged: (value) {
                        setState(() {
                          _restTime = value.round();
                        });
                      },
                      onChangeEnd: (value) {
                        _saveRestTime(value.round());
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sessions to Raise Chicken',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Slider(
                      value: _sessionsToGrow.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _sessionsToGrow.toString(),
                      onChanged: (value) {
                        setState(() {
                          _sessionsToGrow = value.round();
                        });
                      },
                      onChangeEnd: (value) {
                        _saveSessionsToGrow(value.round());
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Activity Tags',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Add new tag',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => _newTag = value,
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addTag,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _activityTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
