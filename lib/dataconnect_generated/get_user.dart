part of 'generated.dart';

class GetUserVariablesBuilder {
  String userId;

  final FirebaseDataConnect _dataConnect;
  GetUserVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<GetUserData> dataDeserializer = (dynamic json)  => GetUserData.fromJson(jsonDecode(json));
  Serializer<GetUserVariables> varsSerializer = (GetUserVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetUserData, GetUserVariables>> execute() {
    return ref().execute();
  }

  QueryRef<GetUserData, GetUserVariables> ref() {
    GetUserVariables vars= GetUserVariables(userId: userId,);
    return _dataConnect.query("GetUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetUserUser {
  final String userId;
  final String displayname;
  final String email;
  final Timestamp createdAt;
  final String type;
  final String avatarKey;
  final String? sessionToken;
  final Timestamp? sessionExpiry;
  GetUserUser.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']),
  displayname = nativeFromJson<String>(json['displayname']),
  email = nativeFromJson<String>(json['email']),
  createdAt = Timestamp.fromJson(json['createdAt']),
  type = nativeFromJson<String>(json['type']),
  avatarKey = nativeFromJson<String>(json['avatarKey']),
  sessionToken = json['sessionToken'] == null ? null : nativeFromJson<String>(json['sessionToken']),
  sessionExpiry = json['sessionExpiry'] == null ? null : Timestamp.fromJson(json['sessionExpiry']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserUser otherTyped = other as GetUserUser;
    return userId == otherTyped.userId && 
    displayname == otherTyped.displayname && 
    email == otherTyped.email && 
    createdAt == otherTyped.createdAt && 
    type == otherTyped.type && 
    avatarKey == otherTyped.avatarKey && 
    sessionToken == otherTyped.sessionToken && 
    sessionExpiry == otherTyped.sessionExpiry;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, displayname.hashCode, email.hashCode, createdAt.hashCode, type.hashCode, avatarKey.hashCode, sessionToken.hashCode, sessionExpiry.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['displayname'] = nativeToJson<String>(displayname);
    json['email'] = nativeToJson<String>(email);
    json['createdAt'] = createdAt.toJson();
    json['type'] = nativeToJson<String>(type);
    json['avatarKey'] = nativeToJson<String>(avatarKey);
    if (sessionToken != null) {
      json['sessionToken'] = nativeToJson<String?>(sessionToken);
    }
    if (sessionExpiry != null) {
      json['sessionExpiry'] = sessionExpiry!.toJson();
    }
    return json;
  }

  GetUserUser({
    required this.userId,
    required this.displayname,
    required this.email,
    required this.createdAt,
    required this.type,
    required this.avatarKey,
    this.sessionToken,
    this.sessionExpiry,
  });
}

@immutable
class GetUserData {
  final GetUserUser? user;
  GetUserData.fromJson(dynamic json):
  
  user = json['user'] == null ? null : GetUserUser.fromJson(json['user']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserData otherTyped = other as GetUserData;
    return user == otherTyped.user;
    
  }
  @override
  int get hashCode => user.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return json;
  }

  GetUserData({
    this.user,
  });
}

@immutable
class GetUserVariables {
  final String userId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetUserVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetUserVariables otherTyped = other as GetUserVariables;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  GetUserVariables({
    required this.userId,
  });
}

