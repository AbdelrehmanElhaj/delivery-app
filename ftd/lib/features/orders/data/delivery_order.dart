import 'package:equatable/equatable.dart';

class DeliveryOrder extends Equatable {
  final int id;
  final String name;
  final String customerName;
  final String state;
  final String mode;
  final DateTime? scheduledDate;
  final String? notes;
  final int? tripId;
  final String? tripName;

  const DeliveryOrder({
    required this.id,
    required this.name,
    required this.customerName,
    required this.state,
    required this.mode,
    this.scheduledDate,
    this.notes,
    this.tripId,
    this.tripName,
  });

  factory DeliveryOrder.fromOdoo(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as int,
      name: json['name'] as String,
      customerName: _str(json['partner_id']),
      state: json['state'] as String? ?? 'draft',
      mode: json['mode'] as String? ?? 'delivery',
      scheduledDate: _dateTime(json['scheduled_date']),
      notes: _text(json['notes']),
      tripId: _id(json['trip_id']),
      tripName: _str(json['trip_id']),
    );
  }

  static String _str(dynamic val) {
    if (val is List && val.length >= 2) return val[1].toString();
    if (val is String) return val;
    return '';
  }

  static int? _id(dynamic val) {
    if (val is List && val.isNotEmpty) return val[0] as int?;
    if (val is int) return val;
    return null;
  }

  static String? _text(dynamic val) {
    if (val == null || val == false) return null;
    return val as String;
  }

  static DateTime? _dateTime(dynamic val) {
    if (val == null || val == false) return null;
    return DateTime.tryParse(val as String);
  }

  DeliveryOrder copyWith({String? state}) {
    return DeliveryOrder(
      id: id,
      name: name,
      customerName: customerName,
      state: state ?? this.state,
      mode: mode,
      scheduledDate: scheduledDate,
      notes: notes,
      tripId: tripId,
      tripName: tripName,
    );
  }

  // State transitions — maps Odoo action methods
  String? get nextAction {
    switch (state) {
      case 'confirmed':
        return 'action_in_progress';
      case 'in_progress':
        return 'action_done';
      default:
        return null;
    }
  }

  String? get nextState {
    switch (state) {
      case 'confirmed':
        return 'in_progress';
      case 'in_progress':
        return 'done';
      default:
        return null;
    }
  }

  String? get nextStateLabel {
    switch (state) {
      case 'confirmed':
        return 'Start Delivery';
      case 'in_progress':
        return 'Mark Done';
      default:
        return null;
    }
  }

  bool get isActive => state == 'confirmed' || state == 'in_progress';

  @override
  List<Object?> get props =>
      [id, name, customerName, state, mode, scheduledDate, tripId];
}
