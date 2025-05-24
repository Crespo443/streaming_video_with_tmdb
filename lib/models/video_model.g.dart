// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoModelAdapter extends TypeAdapter<VideoModel> {
  @override
  final int typeId = 0;

  @override
  VideoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      thumbnailUrl: fields[3] as String,
      backdrop_path: fields[4] as String,
      videoUrl: fields[5] as String,
      categories: (fields[6] as List).cast<String>(),
      type: fields[7] as String,
      rating: fields[8] as double,
      tags: (fields[9] as List).cast<String>(),
      releaseDate: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VideoModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.backdrop_path)
      ..writeByte(5)
      ..write(obj.videoUrl)
      ..writeByte(6)
      ..write(obj.categories)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.releaseDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
