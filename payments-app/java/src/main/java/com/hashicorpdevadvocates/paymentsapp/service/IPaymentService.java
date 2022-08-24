package com.hashicorpdevadvocates.paymentsapp.service;

import com.hashicorpdevadvocates.paymentprocessor.model.PaymentRequest;
import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import org.springframework.http.ResponseEntity;

import java.util.Collection;
import java.util.Optional;
import java.util.UUID;

public interface IPaymentService {
    Collection<Payment> list();
    Optional<Payment> get(UUID id);
    ResponseEntity<Payment> create(PaymentRequest payment);
}
