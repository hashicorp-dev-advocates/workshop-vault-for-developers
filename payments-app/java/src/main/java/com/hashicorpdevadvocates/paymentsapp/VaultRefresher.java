package com.hashicorpdevadvocates.paymentsapp;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.cloud.context.refresh.ContextRefresher;
import org.springframework.context.annotation.Profile;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.vault.core.lease.SecretLeaseContainer;
import org.springframework.vault.core.lease.event.SecretLeaseExpiredEvent;

@Component
@Profile("!default")
public class VaultRefresher {

	private final Log log = LogFactory.getLog(getClass());

	private final ContextRefresher contextRefresher;

	VaultRefresher(
			SecretLeaseContainer leaseContainer,
			ContextRefresher contextRefresher) {
		final Log log = LogFactory.getLog(getClass());

		this.contextRefresher = contextRefresher;

		leaseContainer.addLeaseListener(event -> {
			if (event instanceof SecretLeaseExpiredEvent) {
					contextRefresher.refresh();
					log.info("application refreshes database credentials");
				}
		});
	}

	@Scheduled(initialDelayString="${secrets.refresh-interval-ms}",
			fixedDelayString = "${secrets.refresh-interval-ms}")
	void refresher() {
		contextRefresher.refresh();
		log.info("application refreshes key-value secret");
	}
}