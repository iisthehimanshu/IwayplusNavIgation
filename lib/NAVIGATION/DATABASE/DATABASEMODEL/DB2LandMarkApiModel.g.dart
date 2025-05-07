// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2LandMarkApiModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2LandMarkApiModelAdapter extends TypeAdapter<DB2LandMarkApiModel> {
  @override
  final int typeId = 62;

  @override
  DB2LandMarkApiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2LandMarkApiModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2LandMarkApiModel obj) {
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
      other is DB2LandMarkApiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
