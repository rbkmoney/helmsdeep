import Config

config :tester, :flows, %{
  default_flow: %{
    interval: 500,
    auth: %{
      base_url: "http://keycloak-http",
      realm: "external",
      user: "demo_merchant",
      password: "Parolec0"
    },
    payment_api: %{
      base_url: "http://test-transaction-gateway/v2"
    },
    flow: Tester.Flow.Payment,
    options: %{
      bank_card: %{
        card_number: "4242424242424242",
        exp_date: "08/27",
        cvv: "323",
        card_holder: "Artemius Weinerschnitzel"
      },
      amount: 1000,
      currency: "RUB",
      request_timeout: 15000
    }
  }
}
