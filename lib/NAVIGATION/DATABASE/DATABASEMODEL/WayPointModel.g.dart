// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WayPointModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WayPointModelAdapter extends TypeAdapter<WayPointModel> {
  @override
  final int typeId = 9;

  @override
  WayPointModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WayPointModel(
      responseBody: (fields[0] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WayPointModel obj) {
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
      other is WayPointModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
