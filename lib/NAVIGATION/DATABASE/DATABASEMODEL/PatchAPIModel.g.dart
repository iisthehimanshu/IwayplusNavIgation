// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PatchAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatchAPIModelAdapter extends TypeAdapter<PatchAPIModel> {
  @override
  final int typeId = 1;

  @override
  PatchAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatchAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PatchAPIModel obj) {
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
      other is PatchAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
