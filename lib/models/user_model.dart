class UserModel {
  String? uid;
  String? name;
  String? email;
  String? profilePicture;
  String? bio;
  String? contactInfo;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.profilePicture,
    this.bio,
    this.contactInfo,
  });

  // Convert a UserModel into a Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'bio': bio,
      'contactInfo': contactInfo,
    };
  }

  // Create a UserModel from a Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profilePicture: map['profilePicture'],
      bio: map['bio'],
      contactInfo: map['contactInfo'],
    );
  }
}
