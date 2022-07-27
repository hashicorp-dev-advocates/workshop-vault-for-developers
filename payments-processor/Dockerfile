FROM golang:1.17-alpine

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go build -o /payments-processor

EXPOSE 8080

CMD [ "/payments-processor" ]