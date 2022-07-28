package main

import (
	"fmt"
	"net/http"
	"os"
	"regexp"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/nicholasjackson/env"
)

var bindAddress = env.String("BIND_ADDRESS", false, "0.0.0.0:8080", "bind address and port for server, i.e. 0.0.0.0:8080")
var adminUsername = env.String("ADMIN_USERNAME", false, "payments-app", "default username for payments processor")
var adminPassword = env.String("ADMIN_PASSWORD", true, "", "default password for payments processor")

type payment struct {
	Name           string `json:"name"`
	BillingAddress string `json:"billing_address"`
	ID             string `json:"id,omitempty"`
	Status         string `json:"status,omitempty"`
}

func postPayment(c *gin.Context) {
	var newPayment payment

	if err := c.BindJSON(&newPayment); err != nil {
		newPayment.Status = err.Error()
		c.IndentedJSON(http.StatusBadRequest, newPayment)
		return
	}

	address, _ := regexp.Compile(`\d+[ ](?:[A-Za-z0-9.-]+[ ]?)+(?:Avenue|Lane|Road|Boulevard|Drive|Street|Ave|Dr|Rd|Blvd|Ln|St)\.?`)
	if address.MatchString(newPayment.BillingAddress) {
		newPayment.Status = "error, payment information not secure"
		c.IndentedJSON(http.StatusBadRequest, newPayment)
		return
	}

	newPayment.ID = uuid.New().String()
	newPayment.Status = "success, payment information transmitted securely"
	c.IndentedJSON(http.StatusCreated, newPayment)
}

func main() {
	err := env.Parse()
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}

	router := gin.Default()

	authorized := router.Group("/", gin.BasicAuth(gin.Accounts{
		*adminUsername: *adminPassword,
	}))

	authorized.POST("/submit", postPayment)

	router.Run(*bindAddress)
}
