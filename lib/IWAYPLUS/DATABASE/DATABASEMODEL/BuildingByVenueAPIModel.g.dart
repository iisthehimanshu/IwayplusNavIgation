// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BuildingByVenueAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingByVenueAPIModelAdapter
    extends TypeAdapter<BuildingByVenueAPIModel> {
  @override
  final int typeId = 20;

  @override
  BuildingByVenueAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuildingByVenueAPIModel(
      responseBody: (fields[0] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BuildingByVenueAPIModel obj) {
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
      other is BuildingByVenueAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
