import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:life_points/storage.dart';

// Event callback type for point updates
typedef PointsUpdatedCallback = void Function(int newPoints);

class OverdueService {
  Timer? _timer;
  // Check frequently so we don't miss any overdue tasks
  static const Duration _checkInterval = Duration(minutes: 1);
  static DateTime? _lastDeductionTime; // Track when we last deducted points

  // List of callbacks to notify when points are changed
  final List<PointsUpdatedCallback> _pointsUpdateListeners = [];

  // Add a listener for point updates
  void addPointsUpdateListener(PointsUpdatedCallback callback) {
    _pointsUpdateListeners.add(callback);
    debugPrint(
      'Added points update listener, total listeners: ${_pointsUpdateListeners.length}',
    );
  }

  // Remove a listener
  void removePointsUpdateListener(PointsUpdatedCallback callback) {
    _pointsUpdateListeners.remove(callback);
    debugPrint(
      'Removed points update listener, total listeners: ${_pointsUpdateListeners.length}',
    );
  }

  // Notify all listeners about a points update
  void _notifyPointsUpdated(int newPoints) {
    debugPrint(
      'Notifying ${_pointsUpdateListeners.length} listeners about points update',
    );
    for (var listener in _pointsUpdateListeners) {
      listener(newPoints);
    }
  }

  void startService() {
    try {
      debugPrint('Starting overdue service - will check every minute');
      _timer?.cancel();
      _timer = Timer.periodic(_checkInterval, (_) {
        _checkOverdueTasks().catchError((error) {
          debugPrint('Error checking overdue tasks: $error');
        });
      });
    } catch (e) {
      debugPrint('Error starting overdue service: $e');
    }
  }

  void stopService() {
    try {
      _timer?.cancel();
      _timer = null;
      debugPrint('Stopped overdue service');
    } catch (e) {
      debugPrint('Error stopping overdue service: $e');
    }
  }

  Future<void> _checkOverdueTasks() async {
    try {
      final now = DateTime.now();
      debugPrint('Checking for overdue tasks at: ${now.toString()}');

      final tasks = await Storage.getTasks();
      final settings = await Storage.getOverdueSettings();
      final frequency = settings['frequency'];
      final pointsToDeduct = settings['points'] as int;

      debugPrint('Settings: Frequency: $frequency, Points: $pointsToDeduct');

      // Skip if points to deduct is 0 or negative, or if frequency is set to Never
      if (pointsToDeduct <= 0 || frequency == 'Never') {
        debugPrint(
          'Points deduction disabled: ${frequency == 'Never' ? 'Frequency set to Never' : 'Points to deduct is 0 or negative'}',
        );
        return;
      }

      // Determine if enough time has passed since last deduction
      bool shouldDeductNow = false;
      if (_lastDeductionTime == null) {
        // First time checking
        shouldDeductNow = true;
        debugPrint('First time checking, will deduct if overdue tasks exist');
      } else {
        Duration timeSinceLastDeduction = now.difference(_lastDeductionTime!);
        debugPrint(
          'Time since last deduction: ${timeSinceLastDeduction.inMinutes} minutes',
        );

        switch (frequency) {
          case 'Never':
            shouldDeductNow = false; // Never deduct points
            break;
          case 'Every Minute':
            shouldDeductNow = timeSinceLastDeduction.inMinutes >= 1;
            break;
          case 'Every Hour':
            shouldDeductNow = timeSinceLastDeduction.inHours >= 1;
            break;
          case 'Every Day':
            shouldDeductNow = timeSinceLastDeduction.inDays >= 1;
            break;
          case 'Every Week':
            shouldDeductNow = timeSinceLastDeduction.inDays >= 7;
            break;
          default:
            shouldDeductNow = false; // Default to never for safety
            debugPrint(
              'Unknown frequency: $frequency, defaulting to never deduct',
            );
        }
      }

      if (!shouldDeductNow) {
        debugPrint(
          'Not time to deduct points yet based on frequency: $frequency',
        );
        return;
      }

      // Find overdue tasks
      final incompleteTasks =
          tasks
              .where(
                (task) =>
                    task['completed'] != true && task['isUntimed'] != true,
              )
              .toList();

      if (incompleteTasks.isEmpty) {
        debugPrint('No incomplete timed tasks found');
        return;
      }

      bool hasOverdueTasks = false;
      for (var task in incompleteTasks) {
        try {
          final taskDate = DateTime.parse(task['date']);
          final timeParts = (task['time'] as String).split(':');
          final taskDateTime = DateTime(
            taskDate.year,
            taskDate.month,
            taskDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          if (taskDateTime.isBefore(now)) {
            debugPrint('Found overdue task: ${task['name']}');
            hasOverdueTasks = true;
            break;
          }
        } catch (e) {
          debugPrint('Error processing task date/time: $e');
          continue;
        }
      }

      if (hasOverdueTasks) {
        final currentPoints = await Storage.getPoints();
        final newPoints = currentPoints - pointsToDeduct;
        final finalPoints = newPoints < 0 ? 0 : newPoints;

        await Storage.savePoints(finalPoints);
        _lastDeductionTime = now; // Update last deduction time

        debugPrint('POINTS DEDUCTED: -$pointsToDeduct due to overdue tasks');
        debugPrint('Previous points: $currentPoints, New points: $finalPoints');

        // Notify listeners about the points update
        _notifyPointsUpdated(finalPoints);
      } else {
        debugPrint('No overdue tasks found');
      }
    } catch (e) {
      debugPrint('Error in _checkOverdueTasks: $e');
    }
  }
}
