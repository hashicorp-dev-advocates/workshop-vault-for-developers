package com.hashicorpdevadvocates.paymentsapp.controller;

import com.hashicorpdevadvocates.paymentprocessor.model.PaymentRequest;
import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import com.hashicorpdevadvocates.paymentsapp.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;
import java.util.UUID;

@RestController
@RefreshScope
public class PaymentController {
    @Autowired
    private PaymentService paymentService;

    @GetMapping("/payments")
    public Collection<Payment> getPayments() {
        return paymentService.list();
    }

    @GetMapping(path="/payments/{id}")
    public ResponseEntity<Payment> getPaymentById(@PathVariable("id") UUID id) {
        return ResponseEntity.of(paymentService.get(id));
    }

    @PostMapping(path="/payments")
    public ResponseEntity<Payment> createExpenses(@RequestBody PaymentRequest payment) {
        return paymentService.create(payment);
    }
}
