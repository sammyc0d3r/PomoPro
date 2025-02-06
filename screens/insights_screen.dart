import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class InsightsScreen extends StatefulWidget {
  final Function(bool shouldRefresh)? onScreenVisible;

  const InsightsScreen({
    super.key,
    this.onScreenVisible,
  });

  @override
  State<InsightsScreen> createState() => InsightsScreenState();
}

class InsightsScreenState extends State<InsightsScreen>
    with AutomaticKeepAliveClientMixin {
  final _settingsService = SettingsService();
  Map<String, int> _activityTime = {};
  int _totalMinutes = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    loadActivityData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onScreenVisible?.call(true);
  }

  @override
  void dispose() {
    widget.onScreenVisible?.call(false);
    super.dispose();
  }

  // Made public for external refresh
  Future<void> loadActivityData() async {
    final activityTime = await _settingsService.getActivityTime();
    final totalMinutes = activityTime.values.fold(0, (sum, time) => sum + time);

    if (mounted) {
      setState(() {
        _activityTime = activityTime;
        _totalMinutes = totalMinutes;
      });
    }
  }

  Widget _buildTotalTimeCard() {
    final hours = _totalMinutes ~/ 60;
    final minutes = _totalMinutes % 60;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, size: 24),
                SizedBox(width: 8),
                Text(
                  'Total Focus Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${hours}h ${minutes}m',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBreakdownCard() {
    if (_activityTime.isEmpty) {
      return Card(
        elevation: 2,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No activity data yet.\nComplete some Pomodoro sessions to see insights!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.pie_chart_outline, size: 24),
                SizedBox(width: 8),
                Text(
                  'Activity Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._activityTime.entries.map((entry) {
              final percentage = (_totalMinutes > 0)
                  ? (entry.value / _totalMinutes * 100).toStringAsFixed(1)
                  : '0';
              final hours = entry.value ~/ 60;
              final minutes = entry.value % 60;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '${hours}h ${minutes}m',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '$percentage%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _totalMinutes > 0 ? entry.value / _totalMinutes : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amber.withOpacity(0.8),
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMostProductiveCard() {
    if (_activityTime.isEmpty) {
      return const SizedBox.shrink();
    }

    final mostProductiveActivity =
        _activityTime.entries.reduce((a, b) => a.value > b.value ? a : b);
    final hours = mostProductiveActivity.value ~/ 60;
    final minutes = mostProductiveActivity.value % 60;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stars_outlined, size: 24),
                SizedBox(width: 8),
                Text(
                  'Most Productive Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              mostProductiveActivity.key,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${hours}h ${minutes}m',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: loadActivityData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Insights',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTotalTimeCard(),
              const SizedBox(height: 16),
              _buildMostProductiveCard(),
              const SizedBox(height: 16),
              _buildActivityBreakdownCard(),
            ],
          ),
        ),
      ),
    );
  }
}
