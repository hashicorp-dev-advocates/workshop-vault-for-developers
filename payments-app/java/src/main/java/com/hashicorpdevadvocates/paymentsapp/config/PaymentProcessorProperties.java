package com.hashicorpdevadvocates.paymentsapp.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Component;

@Component
@RefreshScope
public class PaymentProcessorProperties {
    private String url;
    private String username;
    private String password;

    public PaymentProcessorProperties(@Value("${payment.processor.url}") String url,
                                      @Value("${payment.processor.username}") String username,
                                      @Value("${payment.processor.password}") String password) {
        this.url = url;
        this.username = username;
        this.password = password;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}