import 'dart:async';

class UserConnectionManager {
  static final Map<String, Timer> cityTimers = {};
  static final Set<String> activeUsers = {};

  static void stopUpdates(String userId) {
    print("UserConnectionManager: Stopping updates for user $userId");
    cityTimers[userId]?.cancel();
    cityTimers.remove(userId);
    activeUsers.remove(userId);
  }

  static bool isUserActive(String userId) {
    return activeUsers.contains(userId);
  }
}
