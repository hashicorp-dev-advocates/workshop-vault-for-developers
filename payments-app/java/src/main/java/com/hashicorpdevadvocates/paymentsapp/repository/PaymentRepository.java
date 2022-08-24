package com.hashicorpdevadvocates.paymentsapp.repository;

import com.hashicorpdevadvocates.paymentsapp.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {}
