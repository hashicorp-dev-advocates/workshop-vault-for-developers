package com.hashicorpdevadvocates.paymentprocessor.model;

import com.fasterxml.jackson.annotation.JsonProperty;

import javax.persistence.Entity;

@Entity
public class PaymentRequest {
    private String name;

    @JsonProperty(value = "billing_address")
    private String billingAddress;

    public PaymentRequest(String name, String billingAddress) {
        this.name = name;
        this.billingAddress = billingAddress;
    }

    public String getName() {
        return name;
    }

    public String getBillingAddress() {
        return billingAddress;
    }
}
