part of 'generated.dart';

class UpdateUserVariablesBuilder {
  String userId;
  Optional<String> _displayname = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _email = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _sessionToken = Optional.optional(nativeFromJson, nativeToJson);
  Optional<Timestamp> _sessionExpiry = Optional.optional((json) => json['sessionExpiry'] = Timestamp.fromJson(json['sessionExpiry']), defaultSerializer);

  final FirebaseDataConnect _dataConnect;  UpdateUserVariablesBuilder displayname(String? t) {
   _displayname.value = t;
   return this;
  }
  UpdateUserVariablesBuilder email(String? t) {
   _email.value = t;
   return this;
  }
  UpdateUserVariablesBuilder sessionToken(String? t) {
   _sessionToken.value = t;
   return this;
  }
  UpdateUserVariablesBuilder sessionExpiry(Timestamp? t) {
   _sessionExpiry.value = t;
   return this;
  }

  UpdateUserVariablesBuilder(this._dataConnect, {required  this.userId,});
  Deserializer<UpdateUserData> dataDeserializer = (dynamic json)  => UpdateUserData.fromJson(jsonDecode(json));
  Serializer<UpdateUserVariables> varsSerializer = (UpdateUserVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateUserData, UpdateUserVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateUserData, UpdateUserVariables> ref() {
    UpdateUserVariables vars= UpdateUserVariables(userId: userId,displayname: _displayname,email: _email,sessionToken: _sessionToken,sessionExpiry: _sessionExpiry,);
    return _dataConnect.mutation("UpdateUser", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateUserUserUpdate {
  final String userId;
  UpdateUserUserUpdate.fromJson(dynamic json):
  
  userId = nativeFromJson<String>(json['userId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserUserUpdate otherTyped = other as UpdateUserUserUpdate;
    return userId == otherTyped.userId;
    
  }
  @override
  int get hashCode => userId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    return json;
  }

  UpdateUserUserUpdate({
    required this.userId,
  });
}

@immutable
class UpdateUserData {
  final UpdateUserUserUpdate? user_update;
  UpdateUserData.fromJson(dynamic json):
  
  user_update = json['user_update'] == null ? null : UpdateUserUserUpdate.fromJson(json['user_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserData otherTyped = other as UpdateUserData;
    return user_update == otherTyped.user_update;
    
  }
  @override
  int get hashCode => user_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (user_update != null) {
      json['user_update'] = user_update!.toJson();
    }
    return json;
  }

  UpdateUserData({
    this.user_update,
  });
}

@immutable
class UpdateUserVariables {
  final String userId;
  late final Optional<String>displayname;
  late final Optional<String>email;
  late final Optional<String>sessionToken;
  late final Optional<Timestamp>sessionExpiry;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateUserVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']) {
  
  
  
    displayname = Optional.optional(nativeFromJson, nativeToJson);
    displayname.value = json['displayname'] == null ? null : nativeFromJson<String>(json['displayname']);
  
  
    email = Optional.optional(nativeFromJson, nativeToJson);
    email.value = json['email'] == null ? null : nativeFromJson<String>(json['email']);
  
  
    sessionToken = Optional.optional(nativeFromJson, nativeToJson);
    sessionToken.value = json['sessionToken'] == null ? null : nativeFromJson<String>(json['sessionToken']);
  
  
    sessionExpiry = Optional.optional((json) => json['sessionExpiry'] = Timestamp.fromJson(json['sessionExpiry']), defaultSerializer);
    sessionExpiry.value = json['sessionExpiry'] == null ? null : Timestamp.fromJson(json['sessionExpiry']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateUserVariables otherTyped = other as UpdateUserVariables;
    return userId == otherTyped.userId && 
    displayname == otherTyped.displayname && 
    email == otherTyped.email && 
    sessionToken == otherTyped.sessionToken && 
    sessionExpiry == otherTyped.sessionExpiry;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, displayname.hashCode, email.hashCode, sessionToken.hashCode, sessionExpiry.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    if(displayname.state == OptionalState.set) {
      json['displayname'] = displayname.toJson();
    }
    if(email.state == OptionalState.set) {
      json['email'] = email.toJson();
    }
    if(sessionToken.state == OptionalState.set) {
      json['sessionToken'] = sessionToken.toJson();
    }
    if(sessionExpiry.state == OptionalState.set) {
      json['sessionExpiry'] = sessionExpiry.toJson();
    }
    return json;
  }

  UpdateUserVariables({
    required this.userId,
    required this.displayname,
    required this.email,
    required this.sessionToken,
    required this.sessionExpiry,
  });
}

