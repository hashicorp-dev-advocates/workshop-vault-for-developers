package com.hashicorpdevadvocates.paymentprocessor.service;

import com.hashicorpdevadvocates.paymentprocessor.model.PaymentRequest;
import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.ExchangeFilterFunctions;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class PaymentProcessorService {
    private final String URI_SUBMIT = "/submit";

    private WebClient webClient;

    public PaymentProcessorService(String url,
                                   String username,
                                   String password) {
        this.webClient = WebClient.builder()
                .baseUrl(url)
                .filter(ExchangeFilterFunctions.basicAuthentication(username, password))
                .build();
    }

    public ResponseEntity<Payment> submitPayment(String name, String billingAddress) {
        PaymentRequest request = new PaymentRequest(name, billingAddress);
        final HttpStatus[] status = new HttpStatus[1];
        Payment paid = webClient.post()
                .uri(URI_SUBMIT)
                .body(Mono.just(request), PaymentRequest.class)
                .exchangeToMono(response -> {
                    status[0] = response.statusCode();
                    return response.bodyToMono(Payment.class);
                }).block();
        return new ResponseEntity<>(paid, status[0]);
    }
}
