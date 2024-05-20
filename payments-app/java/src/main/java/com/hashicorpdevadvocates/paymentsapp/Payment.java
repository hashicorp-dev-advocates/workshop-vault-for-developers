package com.hashicorpdevadvocates.paymentsapp;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.Instant;

record Payment(String id,
			   String name,
			   @JsonProperty(value = "billing_address") String billingAddress,
			   @JsonProperty(value = "created_at") Instant createdAt,
			   String status) {
}