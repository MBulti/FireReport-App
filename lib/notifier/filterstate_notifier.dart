// Provider für den FilterStatus
import 'package:firereport/models/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterStateNotifier extends StateNotifier<FilterStatus> {
  FilterStateNotifier() : super(FilterStatus.all) {
    _loadFilterState();
  }

  Future<void> _loadFilterState() async {
    final prefs = await SharedPreferences.getInstance();
    final filterIndex = prefs.getInt('filterStatus') ?? FilterStatus.all.index;
    state = FilterStatus.values[filterIndex];
  }

  void setFilter(FilterStatus status) async {
    state = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('filterStatus', status.index);
  }
}

final filterStatusProvider =
    StateNotifierProvider<FilterStateNotifier, FilterStatus>((ref) {
  return FilterStateNotifier();
});
