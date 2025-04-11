// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SignINAPIModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SignINAPIModelAdapter extends TypeAdapter<SignINAPIModel> {
  @override
  final int typeId = 7;

  @override
  SignINAPIModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SignINAPIModel(
      signInApiModel: fields[0] as SignInApiModel,
    );
  }

  @override
  void write(BinaryWriter writer, SignINAPIModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.signInApiModel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignINAPIModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
