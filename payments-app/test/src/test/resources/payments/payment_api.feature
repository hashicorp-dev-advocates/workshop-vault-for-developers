Feature: Payment Records Sent to Processor
  Get and create new payment records

  Scenario: Get a payment record
    Given a payment exists with an ID of 2310d6be-0e80-11ed-861d-0242ac120002
    When I retrieve the payment by ID
    Then the status code is 200
    And response includes the following
      | name            | Red Panda |
      | billing_address | 8 Eastern Himalayas Drive |

  Scenario: Successfully create an encrypted payment record
    Given I pass a payment record with a name prefix of cucumber and billing address of "10 Green Street"
    When I send the payment to the processor
    Then the status code is 201
    And response includes the following
      | status | success, payment information transmitted securely |
    And response does not include the following
      | billing_address | 10 Green Street |

  Scenario: Get a list of payment records
    Given I submitted some payment records
    When I retrieve all payments
    Then the status code is 200