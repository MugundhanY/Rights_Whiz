class UserDetailsModel {
  final String name;
  final String dob;
  final String language;
  final String avatar;
  final int score;
  final String tag;
  UserDetailsModel({required this.name, required this.dob, required this.language,required this.avatar, required this.score, required this.tag});

  Map<String, dynamic> getJson() => {
        'name': name,
        'dob': dob,
        'language': language,
        'avatar location': avatar,
        'Score': score,
        'tag': tag,
      };

  factory UserDetailsModel.getModelFromJson(Map<String, dynamic> json) {
    return UserDetailsModel(name: json["name"], dob: json["dob"], language: json["language"], avatar: json["avatar location"], score: json["Score"], tag: json["tag"]);
  }
}

class editUserDetailsModel {
  final String name;
  final String dob;
  final String language;
  final String avatar;
  editUserDetailsModel({required this.name, required this.dob, required this.language,required this.avatar});

  Map<String, dynamic> getJson() => {
    'name': name,
    'dob': dob,
    'language': language,
    'avatar location': avatar,
  };

  factory editUserDetailsModel.getModelFromJson(Map<String, dynamic> json) {
    return editUserDetailsModel(name: json["name"], dob: json["dob"], language: json["language"], avatar: json["avatar location"]);
  }
}



