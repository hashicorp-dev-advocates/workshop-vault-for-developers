package com.hashicorpdevadvocates.paymentsapp;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.reactive.function.client.ExchangeFilterFunctions;
import org.springframework.web.reactive.function.client.WebClient;

import javax.sql.DataSource;

@SpringBootApplication
@EnableScheduling
@EnableConfigurationProperties(PaymentsAppProperties.class)
public class PaymentsApplication {

	private final Log log = LogFactory.getLog(getClass());

	public static void main(String[] args) {
		SpringApplication.run(PaymentsApplication.class, args);
	}

	@Bean
	@RefreshScope
	DataSource dataSource(DataSourceProperties properties) {
		log.info("rebuild database secrets: " +
				properties.getUsername() +
				"," +
				properties.getPassword()
		);

		return DataSourceBuilder
				.create()
				.url(properties.getUrl())
				.username(properties.getUsername())
				.password(properties.getPassword())
				.build();
	}

	@Bean
	@RefreshScope
	WebClient processorClient(PaymentsAppProperties properties) {
		log.info("rebuild processor secrets: " +
				properties.getProcessor().getUsername() +
				"," +
				properties.getProcessor().getPassword()
		);
		return WebClient.builder()
				.baseUrl(properties.getProcessor().getUrl())
				.filter(
						ExchangeFilterFunctions.basicAuthentication(
								properties.getProcessor().getUsername(),
								properties.getProcessor().getPassword()))
				.build();
	}
}