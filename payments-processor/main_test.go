package main

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
)

func SetUpRouter() *gin.Engine {
	router := gin.Default()
	return router
}

func TestSuccessfulPayment(t *testing.T) {
	r := SetUpRouter()
	r.POST("/submit", postPayment)
	testPayment := payment{
		Name:           "test",
		BillingAddress: "ODkgQmFtYm9vIFJvYWQK",
		Number:         "1234-5678-9012",
	}
	jsonValue, _ := json.Marshal(testPayment)
	req, _ := http.NewRequest("POST", "/submit", bytes.NewBuffer(jsonValue))

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusCreated, w.Code)
}

func TestErrorPaymentPlaintextAddress(t *testing.T) {
	r := SetUpRouter()
	r.POST("/submit", postPayment)
	testPayment := payment{
		Name:           "test",
		BillingAddress: "89 Bamboo Rd",
	}
	jsonValue, _ := json.Marshal(testPayment)
	req, _ := http.NewRequest("POST", "/submit", bytes.NewBuffer(jsonValue))

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestErrorPaymentPlaintextCardNumber(t *testing.T) {
	r := SetUpRouter()
	r.POST("/submit", postPayment)
	testPayment := payment{
		Name:   "test",
		Number: "1234-5678-9012-3456",
	}
	jsonValue, _ := json.Marshal(testPayment)
	req, _ := http.NewRequest("POST", "/submit", bytes.NewBuffer(jsonValue))

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	assert.Equal(t, http.StatusBadRequest, w.Code)
}
