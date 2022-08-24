package com.hashicorpdevadvocates.paymentsapp;

import com.hashicorpdevadvocates.paymentprocessor.service.PaymentProcessorService;
import com.hashicorpdevadvocates.paymentsapp.config.PaymentProcessorProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Bean;

import javax.sql.DataSource;

@SpringBootApplication
public class PaymentsApplication {
	public static void main(String[] args) {
		SpringApplication.run(PaymentsApplication.class, args);
	}

	@Bean
	@RefreshScope
	DataSource dataSource(DataSourceProperties properties) {
		return DataSourceBuilder
				.create()
				.url(properties.getUrl())
				.username(properties.getUsername())
				.password(properties.getPassword())
				.build();
	}

	@Bean
	@RefreshScope
	PaymentProcessorService processorService(PaymentProcessorProperties properties) {
		return new PaymentProcessorService(
				properties.getUrl(),
				properties.getUsername(),
				properties.getPassword()
		);
	}
}