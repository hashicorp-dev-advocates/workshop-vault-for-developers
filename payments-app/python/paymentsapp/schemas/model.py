from marshmallow import Schema, fields
from marshmallow_sqlalchemy import SQLAlchemySchema, auto_field


class Payment(db.Model):
    id = db.Column(db.String(255), primary_key=True)
    name = db.Column(db.String(255),)
    billing_address = db.Column(db.String(255),)
    created_at = db.Column(db.String(255),)


class PaymentSchema(SQLAlchemySchema):
    class Meta:
        model = Payment
        load_instance = True

    billing_address = auto_field()
    created_at = auto_field()
    id = auto_field()
    name = auto_field()


class PaymentRequest(Schema):
    billing_address = fields.String(required=True,)
    name = fields.String(required=True,)


class PaymentResponse(Schema):
    billing_address = fields.String(required=True,)
    created_at = fields.String()
    id = fields.String()
    name = fields.String(required=True,)
    status = fields.String(required=True,)


class ListPaymentsInlineResp(Payment):
    pass
