import 'package:firereport/models/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RequestDetailNotifier extends ChangeNotifier {
  final Ref ref;
  RequestType requestType = RequestType.operationalUniform;

  int quantity = 0;
  int size = 54;

  RequestDetailNotifier(this.ref);

  void setRequestType(RequestType type) {
    requestType = type;
    notifyListeners();
  }

  void setQuantity(int quantity) {
    if (quantity >= 0) {
      this.quantity = quantity;
      notifyListeners();
    }
  }
}

final requestDetailProvider =
    ChangeNotifierProvider.autoDispose((ref) => RequestDetailNotifier(ref));
