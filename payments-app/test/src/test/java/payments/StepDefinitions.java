package payments;

import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import io.restassured.response.ValidatableResponse;
import io.restassured.specification.RequestSpecification;

import java.util.Map;
import java.util.UUID;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.not;

public class StepDefinitions {
    private Response response;
    private ValidatableResponse json;
    private RequestSpecification request;

    private String paymentId;
    private String name;
    private String billingAddress;

    private String ENDPOINT = "http://localhost:8081/payments";

    @Given("a payment exists with an ID of {word}")
    public void a_payment_exists_with_an_id_of(String id) {
        paymentId = id;
        request = given();
    }

    @Given("I pass a payment record with a name prefix of {word} and billing address of {string}")
    public void i_pass_an_encrypted_payment_record(String prefix, String address) {
        name = String.format("%s-%s", prefix, UUID.randomUUID());
        billingAddress = address;
        request = given();
    }

    @Given("I submitted some payment records")
    public void i_submitted_some_payment_records() {
        request = given();
    }

    @When("I retrieve the payment by ID")
    public void i_retrieve_the_payment_by_id() {
        response = request.when().get(String.format("%s/%s", ENDPOINT, paymentId));
    }

    @When("I send the payment to the processor")
    public void i_send_the_payment_to_the_processor() {
        String requestBody = String.format(
                "{\"name\":\"%s\"," +
                        "\"billing_address\":\"%s\"}", name, billingAddress);
        request.contentType(ContentType.JSON).body(requestBody);
        response = request.when().post(ENDPOINT);
    }

    @When("I retrieve all payments")
    public void i_retrieve_all_payments() {
        response = request.when().get(ENDPOINT);
    }

    @Then("the status code is {int}")
    public void the_status_code_is(int statusCode) {
        json = response.then().statusCode(statusCode);
    }

    @And("response includes the following")
    public void response_includes_the_following(Map<String, String> responseFields) {
        for (Map.Entry<String, String> field : responseFields.entrySet()) {
            json.body(field.getKey(), equalTo(field.getValue()));
        }
    }

    @And("response does not include the following")
    public void response_does_not_include_the_following(Map<String, String> responseFields) {
        for (Map.Entry<String, String> field : responseFields.entrySet()) {
            json.body(field.getKey(), not(field.getValue()));
        }
    }
}
