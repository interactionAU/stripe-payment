# Make payments

This application can is a demo for making apyments using stripe.

In order to make payments you need to have a STRIPE_ACCOUNT_ID and STRIPE_SECRET_KEY.

You can place these values in the .env file.

```
STRIPE_ACCOUNT_ID=acct_1J2K3L4K5J6L7K8J9
STRIPE_SECRET_KEY=sk_test_51J2K3L4K5J6L7K8J9
```

STRIPE_ACCOUNT_ID can be retrived when you onboard as a new customer through stripe-connected-account-onboarding app.

STRIPE_SECRET_KEY can be retrived from the stripe dashboard.(Contact Isuru for the secret key)

You currently set any value for payments at "/" route in myapp.rb file.


## Run the sample

1. Build the server

~~~
bundle install
~~~

2. Run the server

~~~
ruby myapp.rb -o 0.0.0.0
~~~

3. Go to [http://localhost:3000](http://localhost:3000)
