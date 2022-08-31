package com.hashicorpdevadvocates.paymentsapp;

import lombok.RequiredArgsConstructor;

import javax.persistence.AttributeConverter;

@RequiredArgsConstructor
class VaultTransitConverter implements AttributeConverter<String, String> {

	private final VaultTransit vault;

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
