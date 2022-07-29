package com.hashicorpdevadvocates.paymentsapp.repository;

import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {}
