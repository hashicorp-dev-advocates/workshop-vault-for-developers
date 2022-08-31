package com.hashicorpdevadvocates.paymentsapp;

import lombok.RequiredArgsConstructor;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;
import java.util.UUID;

@RestController
@RefreshScope
@RequiredArgsConstructor
class PaymentController {

	private final PaymentService paymentService;

	@GetMapping("/payments")
	Collection<Payment> getPayments() {
		return paymentService.list();
	}

	@GetMapping(path = "/payments/{id}")
	ResponseEntity<Payment> getPaymentById(@PathVariable("id") UUID id) {
		return ResponseEntity.of(paymentService.get(id));
	}

	@PostMapping(path = "/payments")
	ResponseEntity<Payment> createExpenses(@RequestBody PaymentRequest payment) {
		return paymentService.create(payment);
	}

}
