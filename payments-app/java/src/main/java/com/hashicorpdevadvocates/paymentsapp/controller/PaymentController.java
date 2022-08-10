package com.hashicorpdevadvocates.paymentsapp.controller;

import com.hashicorpdevadvocates.paymentprocessor.model.PaymentRequest;
import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import com.hashicorpdevadvocates.paymentsapp.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
public class PaymentController {
    @Autowired
    private PaymentService paymentService;

    @GetMapping("/payments")
    public List<Payment> getPayments() {
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
