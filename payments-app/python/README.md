# paymentsapp

## OpenAPI 3.0 Generated Flask project

All the routes are defined in 'project/api' folder.
Each route parses the request and calls the corresponding function in the 'project/impl' directory passing all the parameters and request body as function arguments.

To run this project:
```
pip install -r requirements.txt
export FLASK_APP='paymentsapp'
export FLASK_ENV=development
flask run
```