# Basic Usage

```dart
ExampleConnector.instance.CreateAdmin(createAdminVariables).execute();
ExampleConnector.instance.CreateUser(createUserVariables).execute();
ExampleConnector.instance.UpdateUser(updateUserVariables).execute();
ExampleConnector.instance.DeleteUser(deleteUserVariables).execute();
ExampleConnector.instance.CreatePlace(createPlaceVariables).execute();
ExampleConnector.instance.UpdatePlace(updatePlaceVariables).execute();
ExampleConnector.instance.DeletePlace(deletePlaceVariables).execute();
ExampleConnector.instance.CreateRoute(createRouteVariables).execute();
ExampleConnector.instance.UpdateUserAvatar(updateUserAvatarVariables).execute();
ExampleConnector.instance.ListUsers().execute();

```

## Optional Fields

Some operations may have optional fields. In these cases, the Flutter SDK exposes a builder method, and will have to be set separately.

Optional fields can be discovered based on classes that have `Optional` object types.

This is an example of a mutation with an optional field:

```dart
await ExampleConnector.instance.CreateRoute({ ... })
.description(...)
.execute();
```

Note: the above example is a mutation, but the same logic applies to query operations as well. Additionally, `createMovie` is an example, and may not be available to the user.

