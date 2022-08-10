package com.hashicorpdevadvocates.paymentsapp.model;

import org.springframework.beans.factory.annotation.Autowired;

import javax.persistence.AttributeConverter;

public class VaultTransitConverter implements AttributeConverter<String, String> {
    @Autowired
    VaultTransit vault;

    @Override
    public String convertToDatabaseColumn(String billingAddress) {
        return billingAddress;
    }

    @Override
    public String convertToEntityAttribute(String billingAddress) {
        if (billingAddress.startsWith("vault:")) {
            return vault.decrypt(billingAddress);
        }
        return billingAddress;
    }
}
