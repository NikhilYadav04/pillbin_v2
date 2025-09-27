class Dateformatter {
  static String customDateDifference(DateTime start, DateTime end) {
    //* Make sure start <= end
    if (end.isBefore(start)) {
      final temp = start;
      start = end;
      end = temp;
    }

    //* Total days difference
    final totalDays = end.difference(start).inDays;

    //* Calculate years, months, days precisely
    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (days < 0) {
      final prevMonth =
          DateTime(end.year, end.month, 0); // last day of previous month
      days += prevMonth.day;
      months--;
    }

    if (months < 0) {
      months += 12;
      years--;
    }

    //* Total months difference (ignoring years)
    int totalMonths = (end.year - start.year) * 12 + (end.month - start.month);
    int mDays = end.day - start.day;
    if (mDays < 0) {
      final prevMonth = DateTime(end.year, end.month, 0);
      mDays += prevMonth.day;
      totalMonths--;
    }

    //* ✅ Return based on your conditions
    if (totalMonths < 1) {
      return "${totalDays+1} days";
    } else if (years < 1) {
      return "$totalMonths months $mDays days";
    } else {
      return "$years years $months months $days days";
    }
  }
}
