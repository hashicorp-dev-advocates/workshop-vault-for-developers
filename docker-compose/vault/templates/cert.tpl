{{- with pkiCert "pki_int/issue/payments-app" "common_name=payments.hashicorpdevadvocates.com" -}}
{{ .Cert }}{{ .CA }}{{ .Key }}
{{ .Key | trimSpace | writeToFile "/vault-agent/config/certs/payments.key" "" "" "0400" }}
{{ .CA | trimSpace | writeToFile "/vault-agent/config/certs/ca.pem" "" "" "0644" }}
{{ .Cert | trimSpace | writeToFile "/vault-agent/config/certs/payments.crt" "" "" "0644" }}
{{- end -}}