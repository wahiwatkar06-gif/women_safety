class JourneyData {
  String source;
  String destination;
  int durationMinutes;
  DateTime? startTime;
  DateTime? expectedArrival;
  bool isActive;
  bool isCompleted;
  bool isEscalated;
  int checkInAttempts;

  JourneyData({
    this.source = 'Campus Library, North Gate',
    this.destination = 'Greenwood Apartments, Block B',
    this.durationMinutes = 20,
    this.startTime,
    this.expectedArrival,
    this.isActive = false,
    this.isCompleted = false,
    this.isEscalated = false,
    this.checkInAttempts = 0,
  });

  String get formattedStartTime {
    if (startTime == null) return '--:--';
    final h = startTime!.hour;
    final m = startTime!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:$m $period';
  }

  String get formattedExpectedArrival {
    if (expectedArrival == null) return '--:--';
    final h = expectedArrival!.hour;
    final m = expectedArrival!.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:$m $period';
  }
}
