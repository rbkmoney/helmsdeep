#!/bin/sh

/opt/test_transaction/bin/test_transaction http://keycloak-http demo_merchant Parolec0 http://apigateway \
        -4 \
        -p 3000 -r 3 \
        --connect-timeout 1000 --send-timeout 500 --recv-timeout 10000 \
        --test-shop-id "1" \
        --create-test-shop --test-payment-inst-id 1 --test-category-id 1 \
        --login-warn 4000 --get-my-party-warn 2400 --get-first-shop-warn 2000 \
        --create-invoice-warn 18000 --tokenize-card-warn 600 --create-payment-warn 1800 --fulfill-invoice-warn 18000
