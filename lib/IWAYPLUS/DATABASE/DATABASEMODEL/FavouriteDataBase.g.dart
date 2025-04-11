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
      favouriteDataBaseModel: fields[0] as FavouriteDataBaseModel,
    );
  }

  @override
  void write(BinaryWriter writer, FavouriteDataBaseModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.favouriteDataBaseModel);
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
