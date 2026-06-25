class AppConstants {
  // Odoo
  static const String odooBaseUrl = 'https://dms.hdrelhaj.com';
  static const String odooDb = 'DeliveryDemo';

  // Traccar
  static const String traccarBaseUrl = 'https://dms.hdrelhaj.com';
  static const String traccarApiPath = '/api';
  static const String traccarOsmandPath = '/osmand';

  // Tracking intervals
  static const int trackingIntervalSeconds = 30;
  static const int idleIntervalSeconds = 120;

  // Storage keys
  static const String keySessionId = 'session_id';
  static const String keyUserId = 'user_id';
  static const String keyDriverId = 'driver_id';
  static const String keyDriverName = 'driver_name';
  static const String keyDeviceId = 'traccar_device_id';
  static const String keyTraccarAuth = 'traccar_basic_auth';
  static const String keyIsTracking = 'is_tracking';
}
