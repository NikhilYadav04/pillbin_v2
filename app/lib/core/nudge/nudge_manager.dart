import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/core/nudge/nudge_model.dart';

class NudgeManager {
  static final NudgeManager _instance = NudgeManager._internal();
  factory NudgeManager() => _instance;
  NudgeManager._internal();

  static const _storage = FlutterSecureStorage();
  static const int maxNudgesPerSession = 3;

  // Persistent keys — these nudges are shown only once ever
  static const _keySeenLocations = 'NUDGE_SEEN_LOCATIONS';
  static const _keySeenBlogs = 'NUDGE_SEEN_BLOGS';
  static const _keySeenDonations = 'NUDGE_SEEN_DONATIONS';

  // In-memory session guard — reset every cold start
  bool _evaluated = false;

  /// Evaluates the current app state and returns up to [maxNudgesPerSession]
  /// nudges ordered by priority.
  ///
  /// [donations]        — raw request maps from DonationProvider.myRequests
  /// [expiringSoonCount] — count from MedicineProvider.expiringSoonMedicinesInventory
  Future<List<Nudge>> evaluate({
    required List<Map<String, dynamic>> donations,
    required int expiringSoonCount,
  }) async {
    if (_evaluated) return [];
    _evaluated = true;

    final nudges = <Nudge>[];
    final now = DateTime.now();

    // ── Priority 1: Donation approved ────────────────────────────────────────
    final approved =
        donations.where((d) => d['status'] == 'approved').toList();
    if (approved.isNotEmpty) {
      final name = _centerName(approved.first);
      nudges.add(Nudge(
        type: NudgeType.donationApproved,
        title: 'Donation Approved!',
        subtitle:
            'Your donation at $name has been approved. Call them to schedule a pickup.',
        icon: Icons.check_circle_outline,
        color: Colors.green,
        actionLabel: 'View Donations',
        route: '/my-donations-screen',
      ));
    }
    if (nudges.length >= maxNudgesPerSession) return nudges.take(3).toList();

    // ── Priority 2: Medicines expiring soon ───────────────────────────────────
    if (expiringSoonCount > 0) {
      nudges.add(Nudge(
        type: NudgeType.medicineExpiry,
        title: 'Medicines Expiring Soon',
        subtitle:
            '$expiringSoonCount medicine${expiringSoonCount > 1 ? 's are' : ' is'} expiring within 7 days. Consider donating them.',
        icon: Icons.medication_outlined,
        color: Colors.orange,
        actionLabel: 'View Inventory',
        route: '/inventory-screen',
      ));
    }
    if (nudges.length >= maxNudgesPerSession) return nudges.take(3).toList();

    // ── Priority 3: Donation pending for 2+ days ──────────────────────────────
    final longPending = donations.where((d) {
      if (d['status'] != 'pending') return false;
      final raw = d['createdAt'] as String?;
      if (raw == null) return false;
      try {
        return now.difference(DateTime.parse(raw)).inDays >= 2;
      } catch (_) {
        return false;
      }
    }).toList();
    if (longPending.isNotEmpty) {
      final days = now
          .difference(DateTime.parse(longPending.first['createdAt'] as String))
          .inDays;
      nudges.add(Nudge(
        type: NudgeType.donationPending,
        title: 'Donation Still Pending',
        subtitle:
            'Your request at ${_centerName(longPending.first)} has been pending for $days day${days > 1 ? 's' : ''}.',
        icon: Icons.hourglass_empty_outlined,
        color: Colors.orange,
        actionLabel: 'Check Status',
        route: '/my-donations-screen',
      ));
    }
    if (nudges.length >= maxNudgesPerSession) return nudges.take(3).toList();

    // ── Priority 4: Feature discovery — Locations (one-time) ─────────────────
    final seenLocations = await _storage.read(key: _keySeenLocations);
    if (seenLocations == null) {
      nudges.add(Nudge(
        type: NudgeType.featureLocations,
        title: 'Find Centers Near You',
        subtitle:
            'Discover nearby medical centers and safe medicine disposal points on the map.',
        icon: Icons.location_on_outlined,
        color: PillBinColors.primary,
        actionLabel: 'Explore',
        route: '/location-screen',
      ));
    }
    if (nudges.length >= maxNudgesPerSession) return nudges.take(3).toList();

    // ── Priority 5: Feature discovery — Blogs (one-time) ─────────────────────
    final seenBlogs = await _storage.read(key: _keySeenBlogs);
    if (seenBlogs == null) {
      nudges.add(Nudge(
        type: NudgeType.featureBlogs,
        title: 'Explore Health Tips',
        subtitle:
            'Read community blogs about safe medicine disposal and health awareness.',
        icon: Icons.dynamic_feed_outlined,
        color: const Color(0xFF2196F3),
        actionLabel: 'Read Blogs',
        route: '/all-blog-posts-screen',
      ));
    }
    if (nudges.length >= maxNudgesPerSession) return nudges.take(3).toList();

    // ── Priority 6: Feature discovery — Donate (one-time) ────────────────────
    final seenDonations = await _storage.read(key: _keySeenDonations);
    if (seenDonations == null && donations.isEmpty) {
      nudges.add(Nudge(
        type: NudgeType.featureDonations,
        title: 'Donate Unused Medicines',
        subtitle:
            'Have medicines you no longer need? Donate them to a nearby medical center.',
        icon: Icons.volunteer_activism_outlined,
        color: PillBinColors.primary,
        actionLabel: 'Learn More',
        route: '/my-donations-screen',
      ));
    }

    return nudges.take(maxNudgesPerSession).toList();
  }

  /// Persist that a one-time discovery nudge was seen so it never shows again.
  Future<void> markDiscoverySeen(NudgeType type) async {
    switch (type) {
      case NudgeType.featureLocations:
        await _storage.write(key: _keySeenLocations, value: 'true');
        break;
      case NudgeType.featureBlogs:
        await _storage.write(key: _keySeenBlogs, value: 'true');
        break;
      case NudgeType.featureDonations:
        await _storage.write(key: _keySeenDonations, value: 'true');
        break;
      default:
        break;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _centerName(Map<String, dynamic> donation) {
    final center = donation['medicalCenterId'];
    return center is Map
        ? (center['name'] as String? ?? 'Medical Center')
        : 'Medical Center';
  }
}
