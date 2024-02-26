// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BuildingAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingAPIModelAdapter extends TypeAdapter<BuildingAPIModel> {
  @override
  final int typeId = 6;

  @override
  BuildingAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BuildingAPIModel obj) {
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
      other is BuildingAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
