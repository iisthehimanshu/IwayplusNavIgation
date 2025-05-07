// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'VenueBeaconAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VenueBeaconAPIModelAdapter extends TypeAdapter<VenueBeaconAPIModel> {
  @override
  final int typeId = 55;

  @override
  VenueBeaconAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VenueBeaconAPIModel(
      responseBody: (fields[0] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, VenueBeaconAPIModel obj) {
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
      other is VenueBeaconAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
