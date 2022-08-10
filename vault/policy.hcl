path "secret/*" {
  capabilities = ["read"]
}

path "payments/database/creds/*" {
  capabilities = ["read"]
}

path "payments/secrets/*" {
  capabilities = ["read"]
}

path "transit/encrypt/payments-app" {
  capabilities = ["update"]
}

path "transit/decrypt/payments-app" {
  capabilities = ["update"]
}