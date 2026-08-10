class AlbumModel {
  final String albumCode;
  final String clientName;
  final String event;
  final String coverImage;
  final List<AlbumDay> days;

  const AlbumModel({
    required this.albumCode,
    required this.clientName,
    required this.event,
    required this.coverImage,
    required this.days,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      albumCode: json["albumCode"] ?? "",
      clientName: json["clientName"] ?? "",
      event: json["event"] ?? "",
      coverImage: json["coverImage"] ?? "",
      days: (json["days"] as List? ?? [])
          .map((e) => AlbumDay.fromJson(e))
          .toList(),
    );
  }
}

class AlbumDay {
  final String name;
  final List<AlbumFolder> folders;

  const AlbumDay({
    required this.name,
    required this.folders,
  });

  factory AlbumDay.fromJson(Map<String, dynamic> json) {
    return AlbumDay(
      name: json["name"] ?? "",
      folders: (json["folders"] as List? ?? [])
          .map((e) => AlbumFolder.fromJson(e))
          .toList(),
    );
  }
}

class AlbumFolder {
  final String name;
  final int count;
  final List<String> photos;

  const AlbumFolder({
    required this.name,
    required this.count,
    required this.photos,
  });

  factory AlbumFolder.fromJson(Map<String, dynamic> json) {
    return AlbumFolder(
      name: json["name"] ?? "",
      count: json["count"] ?? 0,
      photos: List<String>.from(json["photos"] ?? []),
    );
  }
}
