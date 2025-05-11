// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2BeaconAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2BeaconAPIModelAdapter extends TypeAdapter<DB2BeaconAPIModel> {
  @override
  final int typeId = 64;

  @override
  DB2BeaconAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2BeaconAPIModel(
      responseBody: (fields[0] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2BeaconAPIModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.responseBody);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DB2BeaconAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
