package io.violette.artistbooking.controller;

import io.quarkus.test.InjectMock;
import io.quarkus.test.junit.QuarkusTest;
import io.quarkus.test.security.TestSecurity;
import io.violette.artistbooking.dto.ArtistBookingDto;
import io.violette.artistbooking.dto.CreateBookingRequestDto;
import io.violette.artistbooking.model.BookingStatus;
import io.violette.artistbooking.service.ArtistBookingService;
import io.violette.security.CurrentUserContextProvider;
import io.violette.security.JwtPrincipalInfo;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@QuarkusTest
class ArtistBookingControllerTest {

    @InjectMock
    ArtistBookingService artistBookingService;

    @InjectMock
    CurrentUserContextProvider currentUserContextProvider;

    @Test
    @TestSecurity(user = "ctrl-booking-mgr", roles = {"MANAGER"})
    @DisplayName("POST /artist-bookings en MANAGER crée une sélection et retourne 201")
    void createBooking_whenRoleIsManager_returns201() {
        when(artistBookingService.createBooking(any(CreateBookingRequestDto.class)))
                .thenReturn(dto(11L, 100L, 200L, BookingStatus.SELECTED));

        given()
                .contentType("application/json")
                .body("""
                        {
                          "showDateId": 100,
                          "artistId": 200
                        }
                        """)
                .when().post("/api/artist-bookings")
                .then()
                .statusCode(201)
                .body("id", equalTo(11))
                .body("showDateId", equalTo(100))
                .body("artistId", equalTo(200))
                .body("status", equalTo("SELECTED"));
    }

    @Test
    @TestSecurity(user = "ctrl-booking-artist-forbidden", roles = {"ARTIST"})
    @DisplayName("POST /artist-bookings en ARTIST retourne 403 et ne délègue pas au service")
    void createBooking_whenRoleIsArtist_returns403() {
        given()
                .contentType("application/json")
                .body("""
                        {
                          "showDateId": 100,
                          "artistId": 200
                        }
                        """)
                .when().post("/api/artist-bookings")
                .then()
                .statusCode(403);

        verifyNoInteractions(artistBookingService);
    }

    @Test
    @TestSecurity(user = "ctrl-booking-artist", roles = {"ARTIST"})
    @DisplayName("PATCH /artist-bookings/{id}/respond en ARTIST avec principal retourne 200")
    void respondToRequest_whenRoleIsArtistAndPrincipalExists_returns200() {
        JwtPrincipalInfo principal = new JwtPrincipalInfo("firebase-artist-1", "artist@test.com", "Artiste");
        when(currentUserContextProvider.getCurrentPrincipal()).thenReturn(Optional.of(principal));
        when(artistBookingService.respondToRequest(eq(33L), eq(true), eq(principal)))
                .thenReturn(dto(33L, 101L, 201L, BookingStatus.CONFIRMED));

        given()
                .contentType("application/json")
                .body("{\"accept\":true}")
                .when().patch("/api/artist-bookings/33/respond")
                .then()
                .statusCode(200)
                .body("id", equalTo(33))
                .body("status", equalTo("CONFIRMED"));

        verify(artistBookingService).respondToRequest(33L, true, principal);
    }

    @Test
    @TestSecurity(user = "ctrl-booking-artist-no-principal", roles = {"ARTIST"})
    @DisplayName("GET /artist-bookings/me/pending sans principal retourne 401")
    void getPendingBookings_whenPrincipalIsMissing_returns401() {
        when(currentUserContextProvider.getCurrentPrincipal()).thenReturn(Optional.empty());

        given()
                .when().get("/api/artist-bookings/me/pending")
                .then()
                .statusCode(401);

        verifyNoInteractions(artistBookingService);
    }

    @Test
    @TestSecurity(user = "ctrl-booking-artist-pending", roles = {"ARTIST"})
    @DisplayName("GET /artist-bookings/me/pending avec principal retourne 200 et la liste")
    void getPendingBookings_whenPrincipalExists_returns200AndList() {
        JwtPrincipalInfo principal = new JwtPrincipalInfo("firebase-artist-2", "artist2@test.com", "Artiste 2");
        when(currentUserContextProvider.getCurrentPrincipal()).thenReturn(Optional.of(principal));
        when(artistBookingService.getPendingBookingsForCurrentArtist(principal))
                .thenReturn(List.of(dto(44L, 300L, 400L, BookingStatus.PENDING_CONFIRMATION)));

        given()
                .when().get("/api/artist-bookings/me/pending")
                .then()
                .statusCode(200)
                .body("$", hasSize(1))
                .body("[0].id", equalTo(44))
                .body("[0].status", equalTo("PENDING_CONFIRMATION"));

        verify(artistBookingService).getPendingBookingsForCurrentArtist(principal);
    }

    @Test
    @TestSecurity(user = "ctrl-booking-artist-me", roles = {"ARTIST"})
    @DisplayName("GET /artist-bookings/me avec principal retourne les réservations de l'artiste")
    void getMyBookings_whenPrincipalExists_returns200AndList() {
        JwtPrincipalInfo principal = new JwtPrincipalInfo("firebase-artist-3", "artist3@test.com", "Artiste 3");
        when(currentUserContextProvider.getCurrentPrincipal()).thenReturn(Optional.of(principal));
        when(artistBookingService.getBookingsForCurrentArtist(principal))
                .thenReturn(List.of(dto(45L, 301L, 401L, BookingStatus.CONFIRMED)));

        given()
                .when().get("/api/artist-bookings/me")
                .then()
                .statusCode(200)
                .body("$", hasSize(1))
                .body("[0].id", equalTo(45))
                .body("[0].showDateId", equalTo(301))
                .body("[0].status", equalTo("CONFIRMED"));

        verify(artistBookingService).getBookingsForCurrentArtist(principal);
    }

    private static ArtistBookingDto dto(Long id, Long showDateId, Long artistId, BookingStatus status) {
        return new ArtistBookingDto(
                id,
                showDateId,
                LocalDate.of(2026, 4, 25),
                artistId,
                "Test",
                "Artist",
                null,
                null,
                status,
                null,
                null,
                null,
                null,
                null
        );
    }
}
