// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DataVersionMultipleLocalModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataVersionMultipleLocalModelAdapter
    extends TypeAdapter<DataVersionMultipleLocalModel> {
  @override
  final int typeId = 40;

  @override
  DataVersionMultipleLocalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataVersionMultipleLocalModel(
      responseBody: fields[0] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, DataVersionMultipleLocalModel obj) {
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
      other is DataVersionMultipleLocalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
