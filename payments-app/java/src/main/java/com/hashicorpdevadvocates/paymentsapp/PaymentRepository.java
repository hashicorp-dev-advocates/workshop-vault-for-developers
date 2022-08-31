package com.hashicorpdevadvocates.paymentsapp;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

interface PaymentRepository extends JpaRepository<Payment, UUID> {

}
