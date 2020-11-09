#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o errtrace

FIXTURE=$(cat <<END
{"ops": [

    {"insert": {"object": {"globals": {
        "ref": {},
        "data": {
            "system_account_set": {"value": {"id": 1}},
            "external_account_set": {"value": {"id": 1}},
            "inspector": {"value": {"id": 1}}
        }
    }}}},

    {"insert": {"object": {"system_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(scripts/dominant/create-account.sh RUB)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"external_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "income": $(scripts/dominant/create-account.sh RUB),
                    "outcome": $(scripts/dominant/create-account.sh RUB)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"inspector": {
        "ref": {"id": 1},
        "data": {
            "name": "Kovalsky",
            "description": "World famous inspector Kovalsky at your service!",
            "proxy": {
                "ref": {"id": 100},
                "additional": {
                    "risk_score": "high"
                }
            }
        }
    }}}},

    {"insert": {"object": {"inspector": {
        "ref": {"id": 5},
        "data": {
            "name": "Fraudbusters",
            "description": "Fraudbusters!",
            "proxy": {
                "ref": {"id": 5}
            }
        }
    }}}},

    {"insert": {"object": {"term_set_hierarchy": {
        "ref": {"id": 1},
        "data": {
            "term_sets": [
                {
                    "action_time": {},
                    "terms": {
                        "payments": {
                            "currencies": {"value": [
                                {"symbolic_code": "RUB"}
                            ]},
                            "categories": {"value": [
                                {"id": 1}
                            ]},
                            "payment_methods": {"value": [
                                {"id": {"bank_card": {"payment_system": "visa"}}},
                                {"id": {"bank_card": {"payment_system": "mastercard"}}}
                            ]},
                            "cash_limit": {"decisions": [
                                {
                                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                                    "then_": {"value": {
                                        "lower": {"inclusive": {"amount": 1000, "currency": {"symbolic_code": "RUB"}}},
                                        "upper": {"exclusive": {"amount": 4200000, "currency": {"symbolic_code": "RUB"}}}
                                    }}
                                }
                            ]},
                            "fees": {"decisions": [
                                {
                                    "if_": {"condition": {"currency_is": {"symbolic_code": "RUB"}}},
                                    "then_": {"value": [
                                        {
                                            "source": {"merchant": "settlement"},
                                            "destination": {"system": "settlement"},
                                            "volume": {"share": {"parts": {"p": 45, "q": 1000}, "of": "operation_amount"}}
                                        }
                                    ]}
                                }
                            ]},
                            "holds": {
                                "payment_methods": {"value": [
                                    {"id": {"bank_card": {"payment_system": "visa"}}},
                                    {"id": {"bank_card": {"payment_system": "mastercard"}}}
                                ]},
                                "lifetime": {"value": {"seconds": 10}}
                            },
                            "refunds": {
                                "payment_methods": {"value": [
                                    {"id": {"bank_card": {"payment_system": "visa"}}},
                                    {"id": {"bank_card": {"payment_system": "mastercard"}}}
                                ]},
                                "fees": {"value": [
                                ]}
                            }
                        }
                    }
                }
            ]
        }
    }}}},

    {"insert": {"object": {"contract_template": {
        "ref": {"id": 1},
        "data": {
            "terms": {"id": 1}
        }
    }}}},

    {"insert": {"object": {"currency": {
        "ref": {"symbolic_code": "RUB"},
        "data": {
            "name": "Russian rubles",
            "numeric_code": 643,
            "symbolic_code": "RUB",
            "exponent": 2
        }
    }}}},

    {"insert": {"object": {"category": {
        "ref": {"id": 1},
        "data": {
            "name": "Basic test category",
            "description": "Basic test category for mocketbank provider",
            "type": "test"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": {"payment_system": "visa"}}},
        "data": {
            "name": "VISA",
            "description": "VISA bank cards"
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": {"payment_system": "mastercard"}}},
        "data": {
            "name": "Mastercard",
            "description": "Mastercard bank cards"
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank",
            "description": "Mocketbank",
            "terminal": {"value": [
                {"id": 1}
            ]},
            "proxy": {
                "ref": {"id": 1},
                "additional": {}
            },
            "abs_account": "0000000001",
            "terms": {
                "payments": {
                    "currencies": {"value": [
                        {"symbolic_code": "RUB"}
                    ]},
                    "categories": {"value": [
                        {"id": 1}
                    ]},
                    "payment_methods": {"value": [
                        {"id": {"bank_card": {"payment_system": "visa"}}},
                        {"id": {"bank_card": {"payment_system": "mastercard"}}}
                    ]},
                    "cash_limit": {"value": {
                        "lower": {"inclusive": {"amount": 1000, "currency": {"symbolic_code": "RUB"}}},
                        "upper": {"exclusive": {"amount": 10000000, "currency": {"symbolic_code": "RUB"}}}
                    }},
                    "cash_flow": {"decisions": [
                        {
                            "if_": {"condition":
                                {"payment_tool": {"bank_card": {"definition": {"payment_system_is": "visa"}}}}
                            },
                            "then_": {"value": [
                                {
                                    "source": {"provider": "settlement"},
                                    "destination": {"merchant": "settlement"},
                                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "operation_amount"}}
                                },
                                {
                                    "source": {"system": "settlement"},
                                    "destination": {"provider": "settlement"},
                                    "volume": {"share": {"parts": {"p": 15, "q": 1000}, "of": "operation_amount"}}
                                }
                            ]}
                        },
                        {
                            "if_": {"condition":
                                {"payment_tool": {"bank_card": {"definition": {"payment_system_is": "mastercard"}}}}
                            },
                            "then_": {"value": [
                                {
                                    "source": {"provider": "settlement"},
                                    "destination": {"merchant": "settlement"},
                                    "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "operation_amount"}}
                                },
                                {
                                    "source": {"system": "settlement"},
                                    "destination": {"provider": "settlement"},
                                    "volume": {"share": {"parts": {"p": 18, "q": 1000}, "of": "operation_amount"}}
                                }
                            ]}
                        }
                    ]},
                    "holds": {
                        "lifetime": {"value": {"seconds": 3600}}
                    },
                    "refunds": {
                        "cash_flow": {"value": [
                            {
                                "source": {"merchant": "settlement"},
                                "destination": {"provider": "settlement"},
                                "volume": {"share": {"parts": {"p": 1, "q": 1}, "of": "operation_amount"}}
                            }
                        ]}
                    }
                }
            },
            "accounts": [
                {"key": {"symbolic_code": "RUB"}, "value": {
                    "settlement": $(scripts/dominant/create-account.sh RUB)
                }}
            ]
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Test Acquiring",
            "description": "Mocketbank Test Acquiring"
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Proxy",
            "description": "Mocked bank proxy for integration test purposes",
            "url": "http://proxy-mocketbank-api:8022/proxy/mocketbank",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 5},
        "data": {
            "name": "Fraudbusters",
            "description": "Fraudbusters",
            "url": "XXX",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 100},
        "data": {
            "name": "Mocket Inspector Proxy",
            "description": "Mocked inspector proxy for integration test purposes",
            "url": "http://proxy-mocket-inspector-api:8022/proxy/mocket/inspector",
            "options": {"risk_score": "high"}
        }
    }}}},

    {"insert": {"object": {"payment_institution": {
        "ref": {"id": 1},
        "data": {
            "name": "Test Payment Institution",
            "system_account_set": {"value": {"id": 1}},
            "default_contract_template": {"value": {"id": 1}},
            "providers": {"value": [{"id": 1}]},
            "inspector": {"value": {"id": 5}},
            "realm": "test",
            "residences": ["rus", "aus", "jpn"]
        }
    }}}}
]}
END
)

woorl -s "damsel/proto/domain_config.thrift" "http://dominant:8022/v1/domain/repository" Repository Commit 0 "${FIXTURE}"
