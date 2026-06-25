// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PendingPingsTable extends PendingPings
    with TableInfo<$PendingPingsTable, PendingPing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingPingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lonMeta = const VerificationMeta('lon');
  @override
  late final GeneratedColumn<double> lon = GeneratedColumn<double>(
      'lon', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _bearingMeta =
      const VerificationMeta('bearing');
  @override
  late final GeneratedColumn<double> bearing = GeneratedColumn<double>(
      'bearing', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _altitudeMeta =
      const VerificationMeta('altitude');
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
      'altitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deviceId, lat, lon, timestamp, speed, bearing, altitude, accuracy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_pings';
  @override
  VerificationContext validateIntegrity(Insertable<PendingPing> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lon')) {
      context.handle(
          _lonMeta, lon.isAcceptableOrUnknown(data['lon']!, _lonMeta));
    } else if (isInserting) {
      context.missing(_lonMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('bearing')) {
      context.handle(_bearingMeta,
          bearing.isAcceptableOrUnknown(data['bearing']!, _bearingMeta));
    } else if (isInserting) {
      context.missing(_bearingMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(_altitudeMeta,
          altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta));
    } else if (isInserting) {
      context.missing(_altitudeMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingPing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingPing(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lon: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lon'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed'])!,
      bearing: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bearing'])!,
      altitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude'])!,
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
    );
  }

  @override
  $PendingPingsTable createAlias(String alias) {
    return $PendingPingsTable(attachedDatabase, alias);
  }
}

class PendingPing extends DataClass implements Insertable<PendingPing> {
  final int id;
  final String deviceId;
  final double lat;
  final double lon;
  final int timestamp;
  final double speed;
  final double bearing;
  final double altitude;
  final double accuracy;
  const PendingPing(
      {required this.id,
      required this.deviceId,
      required this.lat,
      required this.lon,
      required this.timestamp,
      required this.speed,
      required this.bearing,
      required this.altitude,
      required this.accuracy});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['lat'] = Variable<double>(lat);
    map['lon'] = Variable<double>(lon);
    map['timestamp'] = Variable<int>(timestamp);
    map['speed'] = Variable<double>(speed);
    map['bearing'] = Variable<double>(bearing);
    map['altitude'] = Variable<double>(altitude);
    map['accuracy'] = Variable<double>(accuracy);
    return map;
  }

  PendingPingsCompanion toCompanion(bool nullToAbsent) {
    return PendingPingsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      lat: Value(lat),
      lon: Value(lon),
      timestamp: Value(timestamp),
      speed: Value(speed),
      bearing: Value(bearing),
      altitude: Value(altitude),
      accuracy: Value(accuracy),
    );
  }

  factory PendingPing.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingPing(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lat: serializer.fromJson<double>(json['lat']),
      lon: serializer.fromJson<double>(json['lon']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      speed: serializer.fromJson<double>(json['speed']),
      bearing: serializer.fromJson<double>(json['bearing']),
      altitude: serializer.fromJson<double>(json['altitude']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'lat': serializer.toJson<double>(lat),
      'lon': serializer.toJson<double>(lon),
      'timestamp': serializer.toJson<int>(timestamp),
      'speed': serializer.toJson<double>(speed),
      'bearing': serializer.toJson<double>(bearing),
      'altitude': serializer.toJson<double>(altitude),
      'accuracy': serializer.toJson<double>(accuracy),
    };
  }

  PendingPing copyWith(
          {int? id,
          String? deviceId,
          double? lat,
          double? lon,
          int? timestamp,
          double? speed,
          double? bearing,
          double? altitude,
          double? accuracy}) =>
      PendingPing(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        timestamp: timestamp ?? this.timestamp,
        speed: speed ?? this.speed,
        bearing: bearing ?? this.bearing,
        altitude: altitude ?? this.altitude,
        accuracy: accuracy ?? this.accuracy,
      );
  PendingPing copyWithCompanion(PendingPingsCompanion data) {
    return PendingPing(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lon: data.lon.present ? data.lon.value : this.lon,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      speed: data.speed.present ? data.speed.value : this.speed,
      bearing: data.bearing.present ? data.bearing.value : this.bearing,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingPing(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('timestamp: $timestamp, ')
          ..write('speed: $speed, ')
          ..write('bearing: $bearing, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, deviceId, lat, lon, timestamp, speed, bearing, altitude, accuracy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingPing &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.lat == this.lat &&
          other.lon == this.lon &&
          other.timestamp == this.timestamp &&
          other.speed == this.speed &&
          other.bearing == this.bearing &&
          other.altitude == this.altitude &&
          other.accuracy == this.accuracy);
}

class PendingPingsCompanion extends UpdateCompanion<PendingPing> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<double> lat;
  final Value<double> lon;
  final Value<int> timestamp;
  final Value<double> speed;
  final Value<double> bearing;
  final Value<double> altitude;
  final Value<double> accuracy;
  const PendingPingsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lon = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.speed = const Value.absent(),
    this.bearing = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
  });
  PendingPingsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required double lat,
    required double lon,
    required int timestamp,
    required double speed,
    required double bearing,
    required double altitude,
    required double accuracy,
  })  : deviceId = Value(deviceId),
        lat = Value(lat),
        lon = Value(lon),
        timestamp = Value(timestamp),
        speed = Value(speed),
        bearing = Value(bearing),
        altitude = Value(altitude),
        accuracy = Value(accuracy);
  static Insertable<PendingPing> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<double>? lat,
    Expression<double>? lon,
    Expression<int>? timestamp,
    Expression<double>? speed,
    Expression<double>? bearing,
    Expression<double>? altitude,
    Expression<double>? accuracy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      if (timestamp != null) 'timestamp': timestamp,
      if (speed != null) 'speed': speed,
      if (bearing != null) 'bearing': bearing,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
    });
  }

  PendingPingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? deviceId,
      Value<double>? lat,
      Value<double>? lon,
      Value<int>? timestamp,
      Value<double>? speed,
      Value<double>? bearing,
      Value<double>? altitude,
      Value<double>? accuracy}) {
    return PendingPingsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      timestamp: timestamp ?? this.timestamp,
      speed: speed ?? this.speed,
      bearing: bearing ?? this.bearing,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lon.present) {
      map['lon'] = Variable<double>(lon.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (bearing.present) {
      map['bearing'] = Variable<double>(bearing.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingPingsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('lat: $lat, ')
          ..write('lon: $lon, ')
          ..write('timestamp: $timestamp, ')
          ..write('speed: $speed, ')
          ..write('bearing: $bearing, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PendingPingsTable pendingPings = $PendingPingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [pendingPings];
}

typedef $$PendingPingsTableCreateCompanionBuilder = PendingPingsCompanion
    Function({
  Value<int> id,
  required String deviceId,
  required double lat,
  required double lon,
  required int timestamp,
  required double speed,
  required double bearing,
  required double altitude,
  required double accuracy,
});
typedef $$PendingPingsTableUpdateCompanionBuilder = PendingPingsCompanion
    Function({
  Value<int> id,
  Value<String> deviceId,
  Value<double> lat,
  Value<double> lon,
  Value<int> timestamp,
  Value<double> speed,
  Value<double> bearing,
  Value<double> altitude,
  Value<double> accuracy,
});

class $$PendingPingsTableFilterComposer
    extends Composer<_$AppDatabase, $PendingPingsTable> {
  $$PendingPingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bearing => $composableBuilder(
      column: $table.bearing, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));
}

class $$PendingPingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingPingsTable> {
  $$PendingPingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lon => $composableBuilder(
      column: $table.lon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bearing => $composableBuilder(
      column: $table.bearing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));
}

class $$PendingPingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingPingsTable> {
  $$PendingPingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lon =>
      $composableBuilder(column: $table.lon, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get bearing =>
      $composableBuilder(column: $table.bearing, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);
}

class $$PendingPingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PendingPingsTable,
    PendingPing,
    $$PendingPingsTableFilterComposer,
    $$PendingPingsTableOrderingComposer,
    $$PendingPingsTableAnnotationComposer,
    $$PendingPingsTableCreateCompanionBuilder,
    $$PendingPingsTableUpdateCompanionBuilder,
    (
      PendingPing,
      BaseReferences<_$AppDatabase, $PendingPingsTable, PendingPing>
    ),
    PendingPing,
    PrefetchHooks Function()> {
  $$PendingPingsTableTableManager(_$AppDatabase db, $PendingPingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingPingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingPingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingPingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lon = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<double> speed = const Value.absent(),
            Value<double> bearing = const Value.absent(),
            Value<double> altitude = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
          }) =>
              PendingPingsCompanion(
            id: id,
            deviceId: deviceId,
            lat: lat,
            lon: lon,
            timestamp: timestamp,
            speed: speed,
            bearing: bearing,
            altitude: altitude,
            accuracy: accuracy,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String deviceId,
            required double lat,
            required double lon,
            required int timestamp,
            required double speed,
            required double bearing,
            required double altitude,
            required double accuracy,
          }) =>
              PendingPingsCompanion.insert(
            id: id,
            deviceId: deviceId,
            lat: lat,
            lon: lon,
            timestamp: timestamp,
            speed: speed,
            bearing: bearing,
            altitude: altitude,
            accuracy: accuracy,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingPingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PendingPingsTable,
    PendingPing,
    $$PendingPingsTableFilterComposer,
    $$PendingPingsTableOrderingComposer,
    $$PendingPingsTableAnnotationComposer,
    $$PendingPingsTableCreateCompanionBuilder,
    $$PendingPingsTableUpdateCompanionBuilder,
    (
      PendingPing,
      BaseReferences<_$AppDatabase, $PendingPingsTable, PendingPing>
    ),
    PendingPing,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PendingPingsTableTableManager get pendingPings =>
      $$PendingPingsTableTableManager(_db, _db.pendingPings);
}
