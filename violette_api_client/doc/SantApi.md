# violette_api_client.api.SantApi

## Load the API package
```dart
import 'package:violette_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiPingGet**](SantApi.md#apipingget) | **GET** /api/ping | Vérifie que l&#39;application est démarrée


# **apiPingGet**
> JsonObject apiPingGet()

Vérifie que l'application est démarrée

Retourne le statut et la version du backend Violette.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getSantApi();

try {
    final response = api.apiPingGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling SantApi->apiPingGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

