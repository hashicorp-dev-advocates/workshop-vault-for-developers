package com.hashicorpdevadvocates.paymentsapp;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.context.refresh.ContextRefresher;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class Refresher {

	@Autowired
	private ContextRefresher contextRefresher;

	// Refresh credentials every day
	@Scheduled(initialDelay = 3600000, fixedDelay = 3600000)
	public void refresher() {
		// Add logic if you want to verify secret validity before refresh
		contextRefresher.refresh();
	}

}