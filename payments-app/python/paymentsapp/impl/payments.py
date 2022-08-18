import json
from schemas import PaymentSchema


def ListPayments():
    """

    """

    # Implement your business logic here
    # All the parameters are present in the options argument

    return json.dumps([{
        "billing_address": "<string>",
        "created_at": "<string>",
        "id": "<string>",
        "name": "<string>",
        "status": "<string>",
    }]), 200


def CreatePayment(body):
    """

    :param body: The parsed body of the request
    """

    # Implement your business logic here
    # All the parameters are present in the options argument

    return json.dumps({
        "billing_address": "<string>",
        "created_at": "<string>",
        "id": "<string>",
        "name": "<string>",
        "status": "<string>",
    }), 200


def GetPayment(options):
    """
    :param options: A dictionary containing all the paramters for the Operations
        options["id"]: Unique ID for payment record

    """

    payment = PaymentSchema()

    # Implement your business logic here
    # All the parameters are present in the options argument

    return json.dumps({
        "billing_address": "<string>",
        "created_at": "<string>",
        "id": "<string>",
        "name": "<string>",
        "status": "<string>",
    }), 200



