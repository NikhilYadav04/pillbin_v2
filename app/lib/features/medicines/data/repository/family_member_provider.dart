import 'package:flutter/material.dart';
import 'package:pillbin/features/medicines/data/service/family_member_services.dart';
import 'package:pillbin/network/models/family_member_model.dart';

class FamilyMemberProvider extends ChangeNotifier {
  final FamilyMemberServices _services = FamilyMemberServices();

  String? _lastError;
  String? get lastError => _lastError;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<FamilyMember> _members = [];
  List<FamilyMember> get members => _members;

  //* null = the account owner ("Self"); otherwise a FamilyMember id
  String? _selectedId;
  String? get selectedId => _selectedId;

  void selectProfile(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  FamilyMember? get selectedMember {
    if (_selectedId == null) return null;
    for (final member in _members) {
      if (member.id == _selectedId) return member;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final response = await _services.list();

    if (response.statusCode == 200) {
      final list = response.data!["familyMembers"] as List;
      _members = list
          .map((m) => FamilyMember.fromJson(m as Map<String, dynamic>))
          .toList();

      //* the selected profile may have just been deleted elsewhere
      if (_selectedId != null &&
          !_members.any((m) => m.id == _selectedId)) {
        _selectedId = null;
      }
    } else {
      _lastError = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> add({required String name, String? relation}) async {
    _lastError = null;
    final response = await _services.add(name: name, relation: relation);

    if (response.statusCode == 201) {
      final data = response.data!["familyMember"] as Map<String, dynamic>;
      _members = [..._members, FamilyMember.fromJson(data)];
      notifyListeners();
      return true;
    }

    _lastError = response.message;
    notifyListeners();
    return false;
  }

  Future<bool> remove(String memberId) async {
    _lastError = null;
    final response = await _services.remove(memberId);

    if (response.statusCode == 200) {
      _members = _members.where((m) => m.id != memberId).toList();
      if (_selectedId == memberId) _selectedId = null;
      notifyListeners();
      return true;
    }

    _lastError = response.message;
    notifyListeners();
    return false;
  }

  void reset() {
    _members = [];
    _selectedId = null;
    _lastError = null;
    notifyListeners();
  }
}
