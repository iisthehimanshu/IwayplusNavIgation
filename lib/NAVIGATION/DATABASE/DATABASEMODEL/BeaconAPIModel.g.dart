// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'BeaconAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BeaconAPIModelAdapter extends TypeAdapter<BeaconAPIModel> {
  @override
  final int typeId = 5;

  @override
  BeaconAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BeaconAPIModel(
      responseBody: (fields[0] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BeaconAPIModel obj) {
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
      other is BeaconAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
