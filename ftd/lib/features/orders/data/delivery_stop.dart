import 'package:equatable/equatable.dart';

class DeliveryStop extends Equatable {
  final int id;
  final int sequence;
  final String partnerName;
  final double? lat;
  final double? lng;
  final String status;
  final DateTime? eta;
  final DateTime? actualArrival;
  final String? notes;
  final int photoCount;

  const DeliveryStop({
    required this.id,
    required this.sequence,
    required this.partnerName,
    this.lat,
    this.lng,
    required this.status,
    this.eta,
    this.actualArrival,
    this.notes,
    required this.photoCount,
  });

  factory DeliveryStop.fromOdoo(Map<String, dynamic> json) {
    return DeliveryStop(
      id: json['id'] as int,
      sequence: json['sequence'] as int? ?? 0,
      partnerName: _str(json['partner_id']),
      lat: _float(json['partner_lat']),
      lng: _float(json['partner_lng']),
      status: json['status'] as String? ?? 'pending',
      eta: _dateTime(json['eta']),
      actualArrival: _dateTime(json['actual_arrival']),
      notes: _text(json['notes']),
      photoCount: json['photo_count'] as int? ?? 0,
    );
  }

  static String _str(dynamic val) {
    if (val is List && val.length >= 2) return val[1].toString();
    if (val is String) return val;
    return '';
  }

  static double? _float(dynamic val) {
    if (val == null || val == false) return null;
    if (val is double) return val == 0.0 ? null : val;
    if (val is int) return val == 0 ? null : val.toDouble();
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

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'arrived':
        return 'Arrived';
      case 'done':
        return 'Done';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  // Next action the driver can take — matches Odoo method names on delivery.stop
  String? get nextAction {
    switch (status) {
      case 'pending':
        return 'action_arrived';
      case 'arrived':
        return 'action_done';
      default:
        return null;
    }
  }

  String? get nextStatus {
    switch (status) {
      case 'pending':
        return 'arrived';
      case 'arrived':
        return 'done';
      default:
        return null;
    }
  }

  String? get nextStatusLabel {
    switch (status) {
      case 'pending':
        return 'Mark Arrived';
      case 'arrived':
        return 'Mark Done';
      default:
        return null;
    }
  }

  bool get isActive => status == 'pending' || status == 'arrived';

  bool get hasCoordinates => lat != null && lng != null;

  DeliveryStop copyWith({String? status, DateTime? actualArrival}) {
    return DeliveryStop(
      id: id,
      sequence: sequence,
      partnerName: partnerName,
      lat: lat,
      lng: lng,
      status: status ?? this.status,
      eta: eta,
      actualArrival: actualArrival ?? this.actualArrival,
      notes: notes,
      photoCount: photoCount,
    );
  }

  @override
  List<Object?> get props => [id, sequence, partnerName, status, eta];
}
