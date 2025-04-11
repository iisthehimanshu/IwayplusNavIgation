// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OutDoorModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OutDoorModelAdapter extends TypeAdapter<OutDoorModel> {
  @override
  final int typeId = 8;

  @override
  OutDoorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OutDoorModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, OutDoorModel obj) {
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
      other is OutDoorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
