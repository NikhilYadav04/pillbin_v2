import 'dart:math';

class NotificationHelper {
  //* Titles
  static List<String> titlesExpiringSoon = [
    "⚠️ Medicine Expiry Alert!",
    "⏰ Your Medicine Is About to Expire!",
    "💊 Expiry Coming Up Soon!",
    "🚨 Medicine Nearing Expiry – Take Action!",
    "🕒 Check Before It’s Too Late!",
  ];

  static List<String> titlesExpired = [
    "💀 Medicine Expired!",
    "⚠️ Expired Medicine Alert!",
    "🚫 Time’s Up! Medicine Expired.",
    "⛔ Medicine Past Its Expiry Date!",
    "🩺 Expired Medicine Detected!",
  ];

  //* Base Descriptions (without name)
  static List<String> descExpiringSoon = [
    "is nearing its expiry date. Please review it and remove it from your inventory if it’s no longer safe to use.",
    "is close to expiring. Check your list and consider removing it soon to keep your inventory accurate and safe.",
    "is about to expire soon. Review your list to ensure everything stays up to date.",
  ];

  static List<String> descExpired = [
    "has expired. Please remove it immediately to keep your tracker clean and up to date.",
    "has crossed its expiry date. Discard it safely to maintain a reliable inventory.",
    "has expired. Please remove it from your inventory to keep it accurate and safe.",
  ];

  //* Get random expiring soon message
  static Map<String, String> getExpiringSoon(String medicineName) {
    final random = Random();
    int titleIndex = random.nextInt(titlesExpiringSoon.length);
    int descIndex = random.nextInt(descExpiringSoon.length);
    return {
      "title": titlesExpiringSoon[titleIndex],
      "desc": "$medicineName ${descExpiringSoon[descIndex]}",
    };
  }

  //* Get random expired message
  static Map<String, String> getExpired(String medicineName) {
    final random = Random();
    int titleIndex = random.nextInt(titlesExpired.length);
    int descIndex = random.nextInt(descExpired.length);
    return {
      "title": titlesExpired[titleIndex],
      "desc": "$medicineName ${descExpired[descIndex]}",
    };
  }
}
