// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DataVersionLocalModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataVersionLocalModelAdapter extends TypeAdapter<DataVersionLocalModel> {
  @override
  final int typeId = 10;

  @override
  DataVersionLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataVersionLocalModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DataVersionLocalModel obj) {
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
      other is DataVersionLocalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
