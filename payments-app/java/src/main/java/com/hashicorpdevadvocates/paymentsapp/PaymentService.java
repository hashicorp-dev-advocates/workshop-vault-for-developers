package com.hashicorpdevadvocates.paymentsapp;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
class PaymentService {

	private final PaymentRepository paymentRepository;

	private final VaultTransit vault;

	private final PaymentProcessorClient paymentProcessor;

	Collection<Payment> list() {
		return new ArrayList<>(paymentRepository.findAll());
	}

	Optional<Payment> get(UUID id) {
		return paymentRepository.findById(id);
	}

	ResponseEntity<Payment> create(PaymentRequest payment) {
		ResponseEntity<Payment> paid = paymentProcessor.submitPayment(payment.name(),
				vault.encrypt(payment.billingAddress()));

		if (paid.getStatusCode().is2xxSuccessful()) {
			Objects.requireNonNull(paid.getBody()).setCreatedAt(new Date());
			paymentRepository.save(paid.getBody());
		}
		return new ResponseEntity<>(paid.getBody(), paid.getStatusCode());
	}

}
