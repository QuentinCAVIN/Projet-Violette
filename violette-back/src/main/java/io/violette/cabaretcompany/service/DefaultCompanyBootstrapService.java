package io.violette.cabaretcompany.service;

import io.quarkus.runtime.StartupEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Bootstrap temporaire v0.4.0 :
 * tente de créer la compagnie unique "Dream's Production" au démarrage si possible.
 * La vraie gestion de compagnies sera livrée en v0.5.0.
 */
@ApplicationScoped
public class DefaultCompanyBootstrapService {

    private static final Logger LOG = LoggerFactory.getLogger(DefaultCompanyBootstrapService.class);

    @Inject
    CabaretCompanyService cabaretCompanyService;

    @Transactional
    void onStart(@Observes StartupEvent event) {
        var company = cabaretCompanyService.ensureDefaultCompanyExists();
        if (company != null) {
            LOG.info("Default company bootstrap ready: id={} name={}", company.getId(), company.getName());
        }
    }
}
