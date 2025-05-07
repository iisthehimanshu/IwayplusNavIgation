// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2PolyLineAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2PolyLineAPIModelAdapter extends TypeAdapter<DB2PolyLineAPIModel> {
  @override
  final int typeId = 61;

  @override
  DB2PolyLineAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2PolyLineAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2PolyLineAPIModel obj) {
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
      other is DB2PolyLineAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
