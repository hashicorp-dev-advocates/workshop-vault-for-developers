package com.hashicorpdevadvocates.paymentsapp;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;

@RefreshScope
@ConfigurationProperties(prefix = "payment")
@Data
class PaymentAppProperties {

	private Processor processor = new Processor();

	private Transit transit = new Transit();

	@Data
	static class Processor {

		private String url;

		private String username;

		private String password;

	}

	@Data
	static class Transit {

		private String path = "transit";

		private String key = "payments-app";

	}

}