# violette_api_client.api.DatesDeSpectacleApi

## Load the API package
```dart
import 'package:violette_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiShowDatesCompanyCompanyIdGet**](DatesDeSpectacleApi.md#apishowdatescompanycompanyidget) | **GET** /api/show-dates/company/{companyId} | Lister les dates d&#39;une compagnie
[**apiShowDatesGet**](DatesDeSpectacleApi.md#apishowdatesget) | **GET** /api/show-dates | Lister toutes les dates de spectacle
[**apiShowDatesIdGet**](DatesDeSpectacleApi.md#apishowdatesidget) | **GET** /api/show-dates/{id} | Récupérer une date par id
[**apiShowDatesIdSkillRequirementsGet**](DatesDeSpectacleApi.md#apishowdatesidskillrequirementsget) | **GET** /api/show-dates/{id}/skill-requirements | Lister les besoins artistiques d&#39;une date
[**apiShowDatesIdSkillRequirementsPost**](DatesDeSpectacleApi.md#apishowdatesidskillrequirementspost) | **POST** /api/show-dates/{id}/skill-requirements | Ajouter un besoin artistique
[**apiShowDatesPost**](DatesDeSpectacleApi.md#apishowdatespost) | **POST** /api/show-dates | Créer une date de spectacle


# **apiShowDatesCompanyCompanyIdGet**
> ShowDateDto apiShowDatesCompanyCompanyIdGet(companyId)

Lister les dates d'une compagnie

Retourne toutes les dates de spectacle d'une compagnie. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getDatesDeSpectacleApi();
final int companyId = 789; // int | 

try {
    final response = api.apiShowDatesCompanyCompanyIdGet(companyId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DatesDeSpectacleApi->apiShowDatesCompanyCompanyIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **companyId** | **int**|  | 

### Return type

[**ShowDateDto**](ShowDateDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiShowDatesGet**
> ShowDateDto apiShowDatesGet()

Lister toutes les dates de spectacle

Retourne toutes les dates de spectacle, triées par date croissante. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getDatesDeSpectacleApi();

try {
    final response = api.apiShowDatesGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DatesDeSpectacleApi->apiShowDatesGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ShowDateDto**](ShowDateDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiShowDatesIdGet**
> ShowDateDto apiShowDatesIdGet(id)

Récupérer une date par id

Retourne le détail d'une date de spectacle. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getDatesDeSpectacleApi();
final int id = 789; // int | 

try {
    final response = api.apiShowDatesIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DatesDeSpectacleApi->apiShowDatesIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ShowDateDto**](ShowDateDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiShowDatesIdSkillRequirementsGet**
> ShowDateSkillRequirementDto apiShowDatesIdSkillRequirementsGet(id)

Lister les besoins artistiques d'une date

Retourne les besoins artistiques par compétence pour une date de spectacle. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getDatesDeSpectacleApi();
final int id = 789; // int | 

try {
    final response = api.apiShowDatesIdSkillRequirementsGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DatesDeSpectacleApi->apiShowDatesIdSkillRequirementsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**ShowDateSkillRequirementDto**](ShowDateSkillRequirementDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiShowDatesIdSkillRequirementsPost**
> ShowDateSkillRequirementDto apiShowDatesIdSkillRequirementsPost(id, createSkillRequirementRequestDto)

Ajouter un besoin artistique

Ajoute un besoin artistique par compétence à une date de spectacle. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getDatesDeSpectacleApi();
final int id = 789; // int | 
final CreateSkillRequirementRequestDto createSkillRequirementRequestDto = ; // CreateSkillRequirementRequestDto | 

try {
    final response = api.apiShowDatesIdSkillRequirementsPost(id, createSkillRequirementRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DatesDeSpectacleApi->apiShowDatesIdSkillRequirementsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **createSkillRequirementRequestDto** | [**CreateSkillRequirementRequestDto**](CreateSkillRequirementRequestDto.md)|  | 

### Return type

[**ShowDateSkillRequirementDto**](ShowDateSkillRequirementDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiShowDatesPost**
> ShowDateDto apiShowDatesPost(createShowDateRequestDto)

Créer une date de spectacle

Crée une nouvelle date de spectacle pour une compagnie. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getDatesDeSpectacleApi();
final CreateShowDateRequestDto createShowDateRequestDto = ; // CreateShowDateRequestDto | 

try {
    final response = api.apiShowDatesPost(createShowDateRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling DatesDeSpectacleApi->apiShowDatesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createShowDateRequestDto** | [**CreateShowDateRequestDto**](CreateShowDateRequestDto.md)|  | 

### Return type

[**ShowDateDto**](ShowDateDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

