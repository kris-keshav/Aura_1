class AuraUser {
  AuraUser({
    required this.about,
    required this.email,
    required this.id,
    required this.image,
    required this.name,
  });
  late String about;
  late String email;
  late String id;
  late String image;
  late String name;

  AuraUser.fromJson(Map<String, dynamic> json){
    about = json['about'] ?? '';
    email = json['email'] ?? '';
    id = json['id'] ?? '';
    image = json['image'] ?? '';
    name = json['name'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['about'] = about;
    data['email'] = email;
    data['id'] = id;
    data['image'] = image;
    data['name'] = name;
    return data;
  }
}