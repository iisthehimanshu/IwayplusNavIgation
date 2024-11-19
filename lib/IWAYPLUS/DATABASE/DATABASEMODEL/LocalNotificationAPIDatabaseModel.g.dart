// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'LocalNotificationAPIDatabaseModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalNotificationAPIDatabaseModelAdapter
    extends TypeAdapter<LocalNotificationAPIDatabaseModel> {
  @override
  final int typeId = 25;

  @override
  LocalNotificationAPIDatabaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalNotificationAPIDatabaseModel(
      responseBody: (fields[0] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LocalNotificationAPIDatabaseModel obj) {
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
      other is LocalNotificationAPIDatabaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
