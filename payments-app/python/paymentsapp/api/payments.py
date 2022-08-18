from flask import Blueprint, request
from webargs.flaskparser import parser
from marshmallow import Schema, fields
from ..schemas import model
from .. import impl

bp = Blueprint('payments', __name__)


@bp.route('/payments', methods=['get'])
def ListPayments():

    return impl.payments.ListPayments()


@bp.route('/payments', methods=['post'])
def CreatePayment():

    schema = model.PaymentRequest()

    body = parser.parse(schema, request, location='json')

    return impl.payments.CreatePayment(body)


@bp.route('/payments/<id>', methods=['get'])
def GetPayment(id):

    options = {}
    options["id"] = id

    return impl.payments.GetPayment(options)
