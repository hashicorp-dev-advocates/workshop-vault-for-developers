package com.hashicorpdevadvocates.paymentsapp;

import com.fasterxml.jackson.annotation.JsonProperty;

record PaymentRequest(String name, @JsonProperty(value = "billing_address") String billingAddress) {
}
