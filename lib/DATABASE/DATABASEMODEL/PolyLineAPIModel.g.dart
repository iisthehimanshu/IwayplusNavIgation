// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PolyLineAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PolyLineAPIModelAdapter extends TypeAdapter<PolyLineAPIModel> {
  @override
  final int typeId = 2;

  @override
  PolyLineAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PolyLineAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PolyLineAPIModel obj) {
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
      other is PolyLineAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
