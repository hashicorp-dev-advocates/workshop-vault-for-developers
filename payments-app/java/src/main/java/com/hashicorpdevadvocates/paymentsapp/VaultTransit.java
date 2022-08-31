package com.hashicorpdevadvocates.paymentsapp;

import lombok.RequiredArgsConstructor;
import org.springframework.vault.core.VaultOperations;

@RequiredArgsConstructor
class VaultTransit {

	private final VaultOperations vault;

	private final String path;

	private final String key;

	String decrypt(String billingAddress) {
		return vault.opsForTransit(path).decrypt(key, billingAddress);
	}

	String encrypt(String billingAddress) {
		return vault.opsForTransit(path).encrypt(key, billingAddress);
	}

}
