// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FavouriteDataBase.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavouriteDataBaseModelAdapter
    extends TypeAdapter<FavouriteDataBaseModel> {
  @override
  final int typeId = 4;

  @override
  FavouriteDataBaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavouriteDataBaseModel(
      venueBuildingName: fields[0] as String,
      venueBuildingLocation: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavouriteDataBaseModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.venueBuildingName)
      ..writeByte(1)
      ..write(obj.venueBuildingLocation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavouriteDataBaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
