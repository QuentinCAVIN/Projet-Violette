# violette_api_client.api.RservationsArtistesApi

## Load the API package
```dart
import 'package:violette_api_client/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**apiArtistBookingsIdDelete**](RservationsArtistesApi.md#apiartistbookingsiddelete) | **DELETE** /api/artist-bookings/{id} | Désélectionner un artiste
[**apiArtistBookingsIdRespondPatch**](RservationsArtistesApi.md#apiartistbookingsidrespondpatch) | **PATCH** /api/artist-bookings/{id}/respond | Répondre à une demande de confirmation
[**apiArtistBookingsMePendingGet**](RservationsArtistesApi.md#apiartistbookingsmependingget) | **GET** /api/artist-bookings/me/pending | Mes demandes de confirmation en attente
[**apiArtistBookingsPost**](RservationsArtistesApi.md#apiartistbookingspost) | **POST** /api/artist-bookings | Sélectionner un artiste pour une date
[**apiArtistBookingsShowDatesShowDateIdGet**](RservationsArtistesApi.md#apiartistbookingsshowdatesshowdateidget) | **GET** /api/artist-bookings/show-dates/{showDateId} | Lister les réservations d&#39;une date
[**apiArtistBookingsShowDatesShowDateIdSendConfirmationsPost**](RservationsArtistesApi.md#apiartistbookingsshowdatesshowdateidsendconfirmationspost) | **POST** /api/artist-bookings/show-dates/{showDateId}/send-confirmations | Envoyer les demandes de confirmation


# **apiArtistBookingsIdDelete**
> apiArtistBookingsIdDelete(id)

Désélectionner un artiste

Supprime une réservation en statut SELECTED. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getRservationsArtistesApi();
final int id = 789; // int | 

try {
    api.apiArtistBookingsIdDelete(id);
} on DioException catch (e) {
    print('Exception when calling RservationsArtistesApi->apiArtistBookingsIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiArtistBookingsIdRespondPatch**
> ArtistBookingDto apiArtistBookingsIdRespondPatch(id, respondToBookingRequestDto)

Répondre à une demande de confirmation

L'artiste accepte (CONFIRMED) ou refuse (REFUSED) une demande. Requiert le rôle ARTIST.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getRservationsArtistesApi();
final int id = 789; // int | 
final RespondToBookingRequestDto respondToBookingRequestDto = ; // RespondToBookingRequestDto | 

try {
    final response = api.apiArtistBookingsIdRespondPatch(id, respondToBookingRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RservationsArtistesApi->apiArtistBookingsIdRespondPatch: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **respondToBookingRequestDto** | [**RespondToBookingRequestDto**](RespondToBookingRequestDto.md)|  | 

### Return type

[**ArtistBookingDto**](ArtistBookingDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiArtistBookingsMePendingGet**
> ArtistBookingDto apiArtistBookingsMePendingGet()

Mes demandes de confirmation en attente

Retourne les réservations PENDING_CONFIRMATION de l'artiste authentifié. Requiert le rôle ARTIST.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getRservationsArtistesApi();

try {
    final response = api.apiArtistBookingsMePendingGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling RservationsArtistesApi->apiArtistBookingsMePendingGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ArtistBookingDto**](ArtistBookingDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiArtistBookingsPost**
> ArtistBookingDto apiArtistBookingsPost(createBookingRequestDto)

Sélectionner un artiste pour une date

Crée une réservation en statut SELECTED pour un artiste sur une date. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getRservationsArtistesApi();
final CreateBookingRequestDto createBookingRequestDto = ; // CreateBookingRequestDto | 

try {
    final response = api.apiArtistBookingsPost(createBookingRequestDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RservationsArtistesApi->apiArtistBookingsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createBookingRequestDto** | [**CreateBookingRequestDto**](CreateBookingRequestDto.md)|  | 

### Return type

[**ArtistBookingDto**](ArtistBookingDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiArtistBookingsShowDatesShowDateIdGet**
> ArtistBookingDto apiArtistBookingsShowDatesShowDateIdGet(showDateId)

Lister les réservations d'une date

Retourne toutes les réservations d'une date de spectacle. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getRservationsArtistesApi();
final int showDateId = 789; // int | 

try {
    final response = api.apiArtistBookingsShowDatesShowDateIdGet(showDateId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RservationsArtistesApi->apiArtistBookingsShowDatesShowDateIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **showDateId** | **int**|  | 

### Return type

[**ArtistBookingDto**](ArtistBookingDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **apiArtistBookingsShowDatesShowDateIdSendConfirmationsPost**
> ArtistBookingDto apiArtistBookingsShowDatesShowDateIdSendConfirmationsPost(showDateId)

Envoyer les demandes de confirmation

Passe toutes les réservations SELECTED de la date en PENDING_CONFIRMATION. Requiert le rôle MANAGER.

### Example
```dart
import 'package:violette_api_client/api.dart';

final api = VioletteApiClient().getRservationsArtistesApi();
final int showDateId = 789; // int | 

try {
    final response = api.apiArtistBookingsShowDatesShowDateIdSendConfirmationsPost(showDateId);
    print(response);
} on DioException catch (e) {
    print('Exception when calling RservationsArtistesApi->apiArtistBookingsShowDatesShowDateIdSendConfirmationsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **showDateId** | **int**|  | 

### Return type

[**ArtistBookingDto**](ArtistBookingDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

