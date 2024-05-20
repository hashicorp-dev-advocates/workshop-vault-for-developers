package com.hashicorpdevadvocates.paymentsapp;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.simple.JdbcClient;
import org.springframework.stereotype.Controller;
import org.springframework.vault.core.VaultTemplate;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.time.Instant;
import java.util.*;

@Controller
@ResponseBody
class PaymentController {

	private final JdbcClient db;
	private final PaymentProcessorClient paymentProcessor;
	private final VaultTransit vaultTransit;

	PaymentController(DataSource dataSource,
					  WebClient client,
					  PaymentsAppProperties paymentsAppProperties,
					  VaultTemplate vaultTemplate) {
		this.db = JdbcClient.create(dataSource);
		this.paymentProcessor = new PaymentProcessorClient(client);
		this.vaultTransit = new VaultTransit(paymentsAppProperties, vaultTemplate);
	}

	@GetMapping("/payments")
	Collection<Payment> getPayments() {
		return this.db
				.sql("SELECT * FROM payments")
				.query((rs, rowNum) -> new Payment(
						rs.getString("id"),
						rs.getString("name"),
						rs.getString("billing_address"),
						rs.getTimestamp("created_at").toInstant(),
						rs.getString("status")
				))
				.list();
	}

	@GetMapping("/payments/{id}")
	Collection<Payment> getPaymentByID(@PathVariable String id) {
		return this.db
				.sql(String.format("SELECT * FROM payments WHERE id = '%s'", id))
				.query((rs, rowNum) -> new Payment(
						rs.getString("id"),
						rs.getString("name"),
						rs.getString("billing_address").startsWith("vault") ?
								vaultTransit.decrypt(rs.getString("billing_address")) :
								rs.getString("billing_address"),
						rs.getTimestamp("created_at").toInstant(),
						rs.getString("status")
				)).list();
	}

	@PostMapping(path = "/payments",
			consumes = MediaType.APPLICATION_JSON_VALUE,
			produces = MediaType.APPLICATION_JSON_VALUE)
	Collection<Payment> createPayment(@RequestBody Payment request) {
		var id = UUID.randomUUID().toString();
		var timestamp = Instant.now();

		ResponseEntity<Payment> paid = paymentProcessor.submitPayment(
				request.name(),
				vaultTransit.encrypt(request.billingAddress()));

		if (paid.getStatusCode().is2xxSuccessful() && paid.getBody() != null) {
			var paymentComplete = paid.getBody();
			var statement = String.format(
					"INSERT INTO payments(id, name, billing_address, created_at, status) "
							+ "VALUES('%s', '%s', '%s', '%s', '%s')",
					id,
					paymentComplete.name(),
					paymentComplete.billingAddress(),
					timestamp.toString(),
					paymentComplete.status());
			this.db.sql(statement).update();
		} else {
			throw new ResponseStatusException(
					HttpStatus.INTERNAL_SERVER_ERROR, "could not process payment");
		}
		return this.db
				.sql(String.format("SELECT * FROM payments WHERE id = '%s'", id))
				.query((rs, rowNum) -> new Payment(
						rs.getString("id"),
						rs.getString("name"),
						vaultTransit.decrypt(rs.getString("billing_address")),
						rs.getTimestamp("created_at").toInstant(),
						rs.getString("status")
				)).list();
	}
}
