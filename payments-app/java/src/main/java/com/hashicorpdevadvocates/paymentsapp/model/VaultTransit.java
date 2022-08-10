package com.hashicorpdevadvocates.paymentsapp.model;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.vault.core.VaultOperations;

@Component
public class VaultTransit {
    @Autowired
    VaultOperations vault;

    @Value("${payment.transit.path:transit}")
    private String path;

    @Value("${payment.transit.key:payments-app}")
    private String key;

    public String decrypt(String billingAddress) {
        return vault.opsForTransit(path).decrypt(key, billingAddress);
    }

    public String encrypt(String billingAddress) {
        return vault.opsForTransit(path)
                .encrypt(key, billingAddress);
    }
}
