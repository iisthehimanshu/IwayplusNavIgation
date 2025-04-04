// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GlobalAnnotationAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GlobalAnnotationAPIModelAdapter
    extends TypeAdapter<GlobalAnnotationAPIModel> {
  @override
  final int typeId = 21;

  @override
  GlobalAnnotationAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GlobalAnnotationAPIModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, GlobalAnnotationAPIModel obj) {
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
      other is GlobalAnnotationAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
