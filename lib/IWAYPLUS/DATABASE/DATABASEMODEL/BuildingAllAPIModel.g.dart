// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BuildingAllAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingAllAPIModelAdapter extends TypeAdapter<BuildingAllAPIModel> {
  @override
  final int typeId = 3;

  @override
  BuildingAllAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingAllAPIModel(
      responseBody: (fields[0] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BuildingAllAPIModel obj) {
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
      other is BuildingAllAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
