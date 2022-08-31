package com.hashicorpdevadvocates.paymentsapp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Bean;
import org.springframework.vault.core.VaultOperations;

import javax.sql.DataSource;

@SpringBootApplication
@EnableConfigurationProperties(PaymentAppProperties.class)
public class PaymentsApplication {

	public static void main(String[] args) {
		SpringApplication.run(PaymentsApplication.class, args);
	}

	@Bean
	@RefreshScope
	DataSource dataSource(DataSourceProperties properties) {
		return DataSourceBuilder.create().url(properties.getUrl()).username(properties.getUsername())
				.password(properties.getPassword()).build();
	}

	@Bean
	@RefreshScope
	PaymentProcessorClient paymentProcessorClient(PaymentAppProperties properties) {
		return new PaymentProcessorClient(properties.getProcessor().getUrl(), properties.getProcessor().getUsername(),
				properties.getProcessor().getPassword());
	}

	@Bean
	PaymentService paymentService(PaymentRepository repository, VaultTransit transit,
			PaymentProcessorClient paymentProcessorClient) {
		return new PaymentService(repository, transit, paymentProcessorClient);
	}

	@Bean
	VaultTransit vaultTransit(VaultOperations vo, PaymentAppProperties properties) {
		return new VaultTransit(vo, properties.getTransit().getPath(), properties.getTransit().getKey());
	}

}