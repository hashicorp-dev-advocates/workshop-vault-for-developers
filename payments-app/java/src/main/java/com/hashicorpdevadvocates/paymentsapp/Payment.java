package com.hashicorpdevadvocates.paymentsapp;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "payments")
@Data
public class Payment {

	@Id
	@Type(type = "org.hibernate.type.UUIDCharType")
	private UUID id;

	private String name;

	@Column(name = "billing_address")
	@JsonProperty("billing_address")
	@Convert(converter = VaultTransitConverter.class)
	private String billingAddress;

	@Column(name = "created_at")
	@JsonProperty("created_at")
	private Date createdAt;

	@Transient
	@JsonInclude(JsonInclude.Include.NON_NULL)
	private String status;

}
