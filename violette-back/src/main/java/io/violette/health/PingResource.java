package io.violette.health;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;

@Path("/ping")
@Tag(name = "Health", description = "Endpoints de santé et diagnostic")
public class PingResource {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Operation(summary = "Vérifie que l'application est démarrée", description = "Retourne le statut et la version du backend Violette.")
    public Response ping() {
        return Response.ok(new PingResponse("pong", "1.0.0")).build();
    }

    public record PingResponse(String status, String version) {}
}
