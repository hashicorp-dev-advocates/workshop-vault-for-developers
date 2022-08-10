package com.hashicorpdevadvocates.paymentsapp.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.hibernate.annotations.Type;

import javax.persistence.*;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "payments")
public class Payment {

    @Id
    @Type(type="org.hibernate.type.UUIDCharType")
    private UUID id;

    private String name;

    @Column(name = "billing_address")
    @JsonProperty("billing_address")
    @Convert(converter = VaultTransitConverter.class)
    private String billingAddress;

    @Column(name = "created_at")
    private Date createdAt;

    @Transient
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private String status;

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBillingAddress() {
        return billingAddress;
    }

    public void setBillingAddress(String billingAddress) {
        this.billingAddress = billingAddress;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date date) {
        this.createdAt = date;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
