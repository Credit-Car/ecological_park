// library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_admin.dart';

part 'create_user.dart';

part 'update_user.dart';

part 'delete_user.dart';

part 'create_place.dart';

part 'update_place.dart';

part 'delete_place.dart';

part 'create_route.dart';

part 'update_user_avatar.dart';

part 'list_users.dart';

part 'get_user.dart';

part 'is_admin.dart';

part 'get_user_by_email.dart';

part 'get_user_by_displayname.dart';

part 'list_places.dart';

part 'get_place.dart';

part 'list_routes.dart';

part 'get_route.dart';

part 'get_user_avatar_key.dart';







class ExampleConnector {
  
  
  CreateAdminVariablesBuilder createAdmin ({required String uid, required String displayname, required String email, }) {
    return CreateAdminVariablesBuilder(dataConnect, uid: uid,displayname: displayname,email: email,);
  }
  
  
  CreateUserVariablesBuilder createUser ({required String uid, required String displayname, required String email, }) {
    return CreateUserVariablesBuilder(dataConnect, uid: uid,displayname: displayname,email: email,);
  }
  
  
  UpdateUserVariablesBuilder updateUser ({required String userId, }) {
    return UpdateUserVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  DeleteUserVariablesBuilder deleteUser ({required String userId, }) {
    return DeleteUserVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  CreatePlaceVariablesBuilder createPlace ({required String name, required String coordinates, }) {
    return CreatePlaceVariablesBuilder(dataConnect, name: name,coordinates: coordinates,);
  }
  
  
  UpdatePlaceVariablesBuilder updatePlace ({required String placeId, }) {
    return UpdatePlaceVariablesBuilder(dataConnect, placeId: placeId,);
  }
  
  
  DeletePlaceVariablesBuilder deletePlace ({required String placeId, }) {
    return DeletePlaceVariablesBuilder(dataConnect, placeId: placeId,);
  }
  
  
  CreateRouteVariablesBuilder createRoute ({required String userId, required String name, }) {
    return CreateRouteVariablesBuilder(dataConnect, userId: userId,name: name,);
  }
  
  
  UpdateUserAvatarVariablesBuilder updateUserAvatar ({required String userId, required String avatarKey, }) {
    return UpdateUserAvatarVariablesBuilder(dataConnect, userId: userId,avatarKey: avatarKey,);
  }
  
  
  ListUsersVariablesBuilder listUsers () {
    return ListUsersVariablesBuilder(dataConnect, );
  }
  
  
  GetUserVariablesBuilder getUser ({required String userId, }) {
    return GetUserVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  IsAdminVariablesBuilder isAdmin ({required String userId, }) {
    return IsAdminVariablesBuilder(dataConnect, userId: userId,);
  }
  
  
  GetUserByEmailVariablesBuilder getUserByEmail ({required String email, }) {
    return GetUserByEmailVariablesBuilder(dataConnect, email: email,);
  }
  
  
  GetUserByDisplaynameVariablesBuilder getUserByDisplayname ({required String displayname, }) {
    return GetUserByDisplaynameVariablesBuilder(dataConnect, displayname: displayname,);
  }
  
  
  ListPlacesVariablesBuilder listPlaces () {
    return ListPlacesVariablesBuilder(dataConnect, );
  }
  
  
  GetPlaceVariablesBuilder getPlace ({required String placeId, }) {
    return GetPlaceVariablesBuilder(dataConnect, placeId: placeId,);
  }
  
  
  ListRoutesVariablesBuilder listRoutes () {
    return ListRoutesVariablesBuilder(dataConnect, );
  }
  
  
  GetRouteVariablesBuilder getRoute ({required String routeId, }) {
    return GetRouteVariablesBuilder(dataConnect, routeId: routeId,);
  }
  
  
  GetUserAvatarKeyVariablesBuilder getUserAvatarKey ({required String userId, }) {
    return GetUserAvatarKeyVariablesBuilder(dataConnect, userId: userId,);
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'asia-east1',
    'example',
    'travelassistant',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
