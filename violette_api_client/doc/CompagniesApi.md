# violette_api_client.api.CompagniesApi

## Load the API package
```dart
import 'package:violette_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiCompaniesIdGet**](CompagniesApi.md#apicompaniesidget) | **GET** /api/companies/{id} | Récupérer une compagnie par id
[**apiCompaniesIdMembersGet**](CompagniesApi.md#apicompaniesidmembersget) | **GET** /api/companies/{id}/members | Lister les membres d&#39;une compagnie
[**apiCompaniesIdShowsGet**](CompagniesApi.md#apicompaniesidshowsget) | **GET** /api/companies/{id}/shows | Lister les revues d&#39;une compagnie


# **apiCompaniesIdGet**
> CabaretCompanyDto apiCompaniesIdGet(id)

Récupérer une compagnie par id

Retourne le détail d'une compagnie. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getCompagniesApi();
final int id = 789; // int | 

try {
    final response = api.apiCompaniesIdGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompagniesApi->apiCompaniesIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**CabaretCompanyDto**](CabaretCompanyDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiCompaniesIdMembersGet**
> CompanyMemberDto apiCompaniesIdMembersGet(id)

Lister les membres d'une compagnie

Retourne les artistes membres d'une compagnie. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getCompagniesApi();
final int id = 789; // int | 

try {
    final response = api.apiCompaniesIdMembersGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompagniesApi->apiCompaniesIdMembersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**CompanyMemberDto**](CompanyMemberDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiCompaniesIdShowsGet**
> CabaretShowDto apiCompaniesIdShowsGet(id)

Lister les revues d'une compagnie

Retourne les revues d'une compagnie. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getCompagniesApi();
final int id = 789; // int | 

try {
    final response = api.apiCompaniesIdShowsGet(id);
    print(response);
} on DioException catch (e) {
    print('Exception when calling CompagniesApi->apiCompaniesIdShowsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**CabaretShowDto**](CabaretShowDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

