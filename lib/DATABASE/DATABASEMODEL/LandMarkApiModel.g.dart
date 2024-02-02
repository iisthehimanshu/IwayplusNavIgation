// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LandMarkApiModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LandMarkApiModelAdapter extends TypeAdapter<LandMarkApiModel> {
  @override
  final int typeId = 0;

  @override
  LandMarkApiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LandMarkApiModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LandMarkApiModel obj) {
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
      other is LandMarkApiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
