// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2DataVersionLocalModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2DataVersionLocalModelAdapter
    extends TypeAdapter<DB2DataVersionLocalModel> {
  @override
  final int typeId = 63;

  @override
  DB2DataVersionLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2DataVersionLocalModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2DataVersionLocalModel obj) {
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
      other is DB2DataVersionLocalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
