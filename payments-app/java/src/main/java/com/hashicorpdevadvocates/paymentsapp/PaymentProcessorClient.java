package com.hashicorpdevadvocates.paymentsapp;

import org.springframework.http.*;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

class PaymentProcessorClient {

	private final WebClient webClient;

	public PaymentProcessorClient(WebClient client) {
		this.webClient = client;
	}

	public ResponseEntity<Payment> submitPayment(String name, String billingAddress) {
		PaymentRequest request = new PaymentRequest(name, billingAddress);
		final HttpStatus[] status = new HttpStatus[1];
		String URI_SUBMIT = "/submit";
		Payment paid = webClient.post().uri(URI_SUBMIT).body(
				Mono.just(request), PaymentRequest.class)
				.exchangeToMono(response -> {
					status[0] = (HttpStatus) response.statusCode();
					return response.bodyToMono(Payment.class);
				}).block();
		return new ResponseEntity<>(paid, status[0]);
	}

}
