package io.violette.integration;

import io.quarkus.test.junit.QuarkusTestProfile;

/**
 * Profil de test d'intégration : substitue le profil test (H2) par MySQL réel via Quarkus Dev Services.
 * Dev Services démarre automatiquement un conteneur MySQL (Testcontainers) quand Docker est disponible.
 * Utilisé exclusivement par les classes *IT.java — exécutées avec {@code mvn verify -DskipITs=false}.
 */
public class MySQLIntegrationTestProfile implements QuarkusTestProfile {

    @Override
    public String getConfigProfile() {
        return "integration";
    }
}
