package com.hashicorpdevadvocates.paymentsapp.service;

import com.hashicorpdevadvocates.paymentprocessor.model.PaymentRequest;
import com.hashicorpdevadvocates.paymentprocessor.service.PaymentProcessorService;
import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import com.hashicorpdevadvocates.paymentsapp.model.VaultTransit;
import com.hashicorpdevadvocates.paymentsapp.repository.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class PaymentService implements IPaymentService {
    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private VaultTransit vault;

    @Autowired
    private PaymentProcessorService paymentProcessor;

    @Override
    public Collection<Payment> list() {
        return new ArrayList<>(paymentRepository.findAll());
    }

    @Override
    public Optional<Payment> get(UUID id) {
        return paymentRepository.findById(id);
    }

    @Override
    public ResponseEntity<Payment> create(PaymentRequest payment) {
        ResponseEntity<Payment> paid = paymentProcessor.submitPayment(
                payment.getName(),
                vault.encrypt(payment.getBillingAddress()));

        if (paid.getStatusCode().is2xxSuccessful()) {
            Objects.requireNonNull(paid.getBody()).setCreatedAt(new Date());
            paymentRepository.save(paid.getBody());
        }
        return new ResponseEntity<>(paid.getBody(), paid.getStatusCode());
    }
}
