# violette_api_client.api.UtilisateursApi

## Load the API package
```dart
import 'package:violette_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiUsersByFirebaseFirebaseUidGet**](UtilisateursApi.md#apiusersbyfirebasefirebaseuidget) | **GET** /api/users/by-firebase/{firebaseUid} | Récupérer un utilisateur par Firebase UID
[**apiUsersGet**](UtilisateursApi.md#apiusersget) | **GET** /api/users | Lister les utilisateurs (pagination)
[**apiUsersIdGet**](UtilisateursApi.md#apiusersidget) | **GET** /api/users/{id} | Récupérer un utilisateur par identifiant
[**apiUsersMeGet**](UtilisateursApi.md#apiusersmeget) | **GET** /api/users/me | Contexte de l&#39;utilisateur courant
[**apiUsersMeProfileGet**](UtilisateursApi.md#apiusersmeprofileget) | **GET** /api/users/me/profile | Profil complet de l&#39;utilisateur courant
[**apiUsersPost**](UtilisateursApi.md#apiuserspost) | **POST** /api/users | Créer un profil utilisateur


# **apiUsersByFirebaseFirebaseUidGet**
> VioletteUserDto apiUsersByFirebaseFirebaseUidGet(firebaseUid)

Récupérer un utilisateur par Firebase UID

Retourne le profil utilisateur par Firebase UID. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getUtilisateursApi();
final String firebaseUid = firebaseUid_example; // String | 

try {
    final response = api.apiUsersByFirebaseFirebaseUidGet(firebaseUid);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UtilisateursApi->apiUsersByFirebaseFirebaseUidGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **firebaseUid** | **String**|  | 

### Return type

[**VioletteUserDto**](VioletteUserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUsersGet**
> VioletteUserDto apiUsersGet(page, size)

Lister les utilisateurs (pagination)

Retourne la liste paginée des utilisateurs, triée par createdAt DESC. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getUtilisateursApi();
final int page = 56; // int | 
final int size = 56; // int | 

try {
    final response = api.apiUsersGet(page, size);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UtilisateursApi->apiUsersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **page** | **int**|  | [optional] [default to 0]
 **size** | **int**|  | [optional] [default to 20]

### Return type

[**VioletteUserDto**](VioletteUserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUsersIdGet**
> VioletteUserDto apiUsersIdGet(id)

Récupérer un utilisateur par identifiant

Retourne le profil utilisateur par identifiant. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getUtilisateursApi();
final int id = 789; // int | 

try {
    final response = api.apiUsersIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UtilisateursApi->apiUsersIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**VioletteUserDto**](VioletteUserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUsersMeGet**
> AuthenticatedUserDto apiUsersMeGet()

Contexte de l'utilisateur courant

Retourne les informations de l'utilisateur authentifié depuis le JWT (firebaseUid, email, nom).

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getUtilisateursApi();

try {
    final response = api.apiUsersMeGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UtilisateursApi->apiUsersMeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**AuthenticatedUserDto**](AuthenticatedUserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUsersMeProfileGet**
> VioletteUserDto apiUsersMeProfileGet()

Profil complet de l'utilisateur courant

Retourne le profil backend complet (firstName, lastName, rôles, compétences) de l'utilisateur authentifié. Accessible à tout utilisateur ayant un profil backend créé.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getUtilisateursApi();

try {
    final response = api.apiUsersMeProfileGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling UtilisateursApi->apiUsersMeProfileGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**VioletteUserDto**](VioletteUserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiUsersPost**
> VioletteUserDto apiUsersPost(createUserRequestDto)

Créer un profil utilisateur

Crée un profil utilisateur backend à partir du JWT (firebaseUid, email) et du corps de requête (firstName, lastName, roles).

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getUtilisateursApi();
final CreateUserRequestDto createUserRequestDto = ; // CreateUserRequestDto | 

try {
    final response = api.apiUsersPost(createUserRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling UtilisateursApi->apiUsersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createUserRequestDto** | [**CreateUserRequestDto**](CreateUserRequestDto.md)|  | 

### Return type

[**VioletteUserDto**](VioletteUserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

