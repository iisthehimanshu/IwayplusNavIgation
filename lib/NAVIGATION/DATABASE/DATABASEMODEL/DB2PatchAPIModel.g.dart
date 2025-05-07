// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DB2PatchAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DB2PatchAPIModelAdapter extends TypeAdapter<DB2PatchAPIModel> {
  @override
  final int typeId = 60;

  @override
  DB2PatchAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DB2PatchAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DB2PatchAPIModel obj) {
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
      other is DB2PatchAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
