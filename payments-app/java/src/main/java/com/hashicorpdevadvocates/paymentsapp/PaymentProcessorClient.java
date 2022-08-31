package com.hashicorpdevadvocates.paymentsapp;

import org.springframework.http.*;
import org.springframework.web.reactive.function.client.ExchangeFilterFunctions;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

class PaymentProcessorClient {

	private final String URI_SUBMIT = "/submit";

	private WebClient webClient;

	public PaymentProcessorClient(String url, String username, String password) {
		this.webClient = WebClient.builder().baseUrl(url)
				.filter(ExchangeFilterFunctions.basicAuthentication(username, password)).build();
	}

	public ResponseEntity<Payment> submitPayment(String name, String billingAddress) {
		PaymentRequest request = new PaymentRequest(name, billingAddress);
		final HttpStatus[] status = new HttpStatus[1];
		Payment paid = webClient.post().uri(URI_SUBMIT).body(Mono.just(request), PaymentRequest.class)
				.exchangeToMono(response -> {
					status[0] = response.statusCode();
					return response.bodyToMono(Payment.class);
				}).block();
		return new ResponseEntity<>(paid, status[0]);
	}

}
