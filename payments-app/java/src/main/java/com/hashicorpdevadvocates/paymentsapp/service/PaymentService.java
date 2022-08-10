package com.hashicorpdevadvocates.paymentsapp.service;

import com.hashicorpdevadvocates.paymentprocessor.model.PaymentRequest;
import com.hashicorpdevadvocates.paymentprocessor.service.PaymentProcessorService;
import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import com.hashicorpdevadvocates.paymentsapp.repository.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RefreshScope
public class PaymentService implements IPaymentService {
    @Autowired
    private PaymentRepository paymentRepository;

    @Value("${payment.processor.url}")
    private String url;

    @Value("${payment.processor.username}")
    private String username;

    @Value("${payment.processor.password}")
    private String password;

    @Override
    public List<Payment> list() {
        List<Payment> payments = new ArrayList<>();
        paymentRepository.findAll().forEach(payments::add);
        return payments;
    }

    @Override
    public Optional<Payment> get(UUID id) {
        return paymentRepository.findById(id);
    }

    // TODO: Encrypt billing address using Vault Transit Secrets Engine
    @Override
    public ResponseEntity<Payment> create(PaymentRequest payment) {
        PaymentProcessorService paymentProcessor = new PaymentProcessorService(
                url, username, password
        );
        ResponseEntity<Payment> paid = paymentProcessor.submitPayment(
                    payment.getName(), payment.getBillingAddress());
        if (paid.getStatusCode().is2xxSuccessful()) {
            paid.getBody().setCreatedAt(new Date());
            paymentRepository.save(paid.getBody());
        }
        return new ResponseEntity<>(paid.getBody(), paid.getStatusCode());
    }
}
