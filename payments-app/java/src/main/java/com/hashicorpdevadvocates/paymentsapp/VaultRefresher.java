package com.hashicorpdevadvocates.paymentsapp;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.cloud.context.refresh.ContextRefresher;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class VaultRefresher {

	private final Log log = LogFactory.getLog(getClass());

	private final ContextRefresher contextRefresher;

	VaultRefresher(ContextRefresher contextRefresher) {
		this.contextRefresher = contextRefresher;
	}

	@Scheduled(initialDelayString="${secrets.refresh-interval-ms:86400000}",
			fixedDelayString = "${secrets.refresh-interval-ms:86400000}")
	void refresher() {
		contextRefresher.refresh();
		log.info("refresh key-value secret");
	}
}