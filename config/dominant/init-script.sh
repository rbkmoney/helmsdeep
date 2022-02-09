#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o errtrace

export CHARSET=UTF-8
export LANG=C.UTF-8

TEST_SYSTEM_ACCOUNT_SET=$(scripts/dominant/create-account.sh RUB)
TEST_WALLET_SYSTEM_ACCOUNT_SET=$(scripts/dominant/create-account.sh RUB)
TEST_EXTERNAL_ACCOUNT_SET_INCOME=$(scripts/dominant/create-account.sh RUB)
TEST_EXTERNAL_ACCOUNT_SET_OUTCOME=$(scripts/dominant/create-account.sh RUB)
MOCKET_BANK_PAYOUT_PROVIDER_ACCOUNT=$(scripts/dominant/create-account.sh RUB)
MOCKET_BANK_PAYMENT_PROVIDER_ACCOUNT=$(scripts/dominant/create-account.sh RUB)

FIXTURE=$(cat <<END
{"ops": [

    {"insert": {"object": {"system_account_set": {
      "ref": {"id": 1},
      "data": {
          "name": "Тестовый системный счёт",
          "description": "Системный счёт, используемый для тестирования",
          "accounts": [
            {
              "key": {"symbolic_code": "RUB"},
              "value": {"settlement": ${TEST_SYSTEM_ACCOUNT_SET}}
            }
          ]
      }
    }}}},

    {"insert": {"object": {"system_account_set": {
      "ref": {"id": 2},
      "data": {
          "name": "Тестовый системный счёт для кошельков",
          "description": "Системный счёт, используемый для тестирования кошельков",
          "accounts": [
            {
              "key": {"symbolic_code": "RUB"},
              "value": {"settlement": ${TEST_WALLET_SYSTEM_ACCOUNT_SET}}
            }
          ]
      }
    }}}},

    {"insert": {"object": {"external_account_set": {
      "ref": {"id": 1},
      "data": {
          "name": "Внешние тестовые счета",
          "description": "Внешние счета, используемые в тестовом окружении",
          "accounts": [
            {
              "key": {"symbolic_code": "RUB"},
              "value": {
                "income": ${TEST_EXTERNAL_ACCOUNT_SET_INCOME},
                "outcome": ${TEST_EXTERNAL_ACCOUNT_SET_INCOME}
              }
            }
          ]
        }
    }}}},

    {"insert": {"object": {"category": {
      "ref": {"id": 1},
      "data": {
          "name": "Тестовая ТСП",
          "description": "Категория для тестирования ТСП",
          "type": "test"
      }
    }}}},

    {
      "insert": {
        "object": {
          "country": {
              "ref": {"id": "rus"},
              "data": { "name": "Российская Федерация"}
    }}}},

    {"insert": {"object": {
      "currency": {
        "ref": {"symbolic_code": "RUB"},
        "data": {
            "name": "Российский рубль",
            "numeric_code": 643,
            "symbolic_code": "RUB",
            "exponent": 2
        }
    }}}},

    {"insert": {"object": {"term_set_hierarchy": {
        "ref": {"id": 1},
        "data": {
          "name": "Набор условий для тестового окружения",
            "term_sets": [
              {
                "action_time": [],
                "terms": {
                  "payments": {
                    "currencies": {
                      "value": [{"symbolic_code": "RUB"}]
                    },
                    "categories": {
                      "value": [{"id": 1}]
                    },
                    "payment_methods": {
                      "value": [
                        {
                          "id": {
                            "bank_card": {
                              "payment_system": {"id": "VISA"},
                              "is_cvv_empty": false
                            }
                          }
                        }
                      ]
                    },
                    "cash_limit": {
                      "decisions": [
                        {
                          "if_": {
                            "condition": {
                              "currency_is": {
                                "symbolic_code": "RUB"
                              }
                            }
                          },
                          "then_": {
                            "value": {
                              "upper": {
                                "exclusive": {
                                  "amount": 100000000,
                                  "currency": {
                                    "symbolic_code": "RUB"
                                  }
                                }
                              },
                              "lower": {
                                "inclusive": {
                                  "amount": 100,
                                  "currency": {
                                    "symbolic_code": "RUB"
                                  }
                                }
                              }
                            }
                          }
                        }
                      ]
                    },
                    "fees": {
                      "decisions": [
                        {
                          "if_": {
                            "condition": {
                              "currency_is": {
                                "symbolic_code": "RUB"
                              }
                            }
                          },
                          "then_": {
                            "value": [
                              {
                                "source": {"merchant": "settlement"},
                                "destination": {"system": "settlement"},
                                "volume": {
                                  "share": {
                                    "parts": {
                                      "p": 45,
                                      "q": 1000
                                    },
                                    "of": "operation_amount"
                                  }
                                }
                              }
                            ]
                          }
                        }
                      ]
                    },
                    "holds": {
                      "payment_methods": {
                        "value": [
                          {
                            "id": {
                              "bank_card": {
                                "payment_system": {"id": "VISA"},
                                "is_cvv_empty": false
                              }
                            }
                          }
                        ]
                      },
                      "lifetime": {
                        "value": {
                          "seconds": 10000
                        }
                      }
                    },
                    "refunds": {
                      "payment_methods": {
                        "value": [
                          {
                            "id": {
                              "bank_card": {
                                "payment_system": {"id": "VISA"},
                                "is_cvv_empty": false
                              }
                            }
                          }
                        ]
                      },
                      "fees": {
                        "value": [
                          {
                            "source": { "merchant": "settlement"},
                            "destination": { "system": "settlement"},
                            "volume": {
                              "fixed": {
                                "cash": {
                                  "amount": 15000,
                                  "currency": {"symbolic_code": "RUB"}
                                }
                              }
                            }
                          }
                        ]
                      },
                      "eligibility_time": {
                        "value": {"years": 1}
                      },
                      "partial_refunds": {
                        "cash_limit": {
                          "decisions": [
                            {
                              "if_": {
                                "condition": {
                                  "currency_is": {"symbolic_code": "RUB"}
                                }
                              },
                              "then_": {
                                "value": {
                                  "upper": {
                                    "exclusive": {
                                      "amount": 10000000,
                                      "currency": {"symbolic_code": "RUB"}
                                    }
                                  },
                                  "lower": {
                                    "inclusive": {
                                      "amount": 100,
                                      "currency": {"symbolic_code": "RUB"}
                                    }
                                  }
                                }
                              }
                            }
                          ]
                        }
                      }
                    },
                    "chargebacks": {
                      "allow": {"constant": true},
                      "fees": {
                        "value": [
                          {
                            "source": {
                              "merchant": "settlement"
                            },
                            "destination": {
                              "provider": "settlement"
                            },
                            "volume": {
                              "share": {
                                "parts": {
                                  "p": 1,
                                  "q": 1
                                },
                                "of": "operation_amount"
                              }
                            }
                          }
                        ]
                      },
                      "eligibility_time": {
                        "value": {
                          "years": 1
                        }
                      }
                    }
                  },
                  "recurrent_paytools": {
                    "payment_methods": {
                      "value": [
                        {
                          "id": {
                            "bank_card": {
                              "payment_system": {"id": "VISA"},
                              "is_cvv_empty": false
                            }
                          }
                        }
                      ]
                    }
                  },
                  "wallets": {
                    "currencies": {
                      "value": [{"symbolic_code": "RUB"}]
                    },
                    "wallet_limit": {
                      "value": {
                        "upper": {
                          "inclusive": {
                            "amount": 10000000,
                            "currency": {
                              "symbolic_code": "RUB"
                            }
                          }
                        },
                        "lower": {
                          "inclusive": {
                            "amount": -1000000000,
                            "currency": {
                              "symbolic_code": "RUB"
                            }
                          }
                        }
                      }
                    },
                    "withdrawals": {
                      "currencies": {
                        "value": [{"symbolic_code": "RUB"}]
                      },
                      "cash_limit": {
                        "value": {
                          "upper": {
                            "inclusive": {
                              "amount": 10000000,
                              "currency": {
                                "symbolic_code": "RUB"
                              }
                            }
                          },
                          "lower": {
                            "inclusive": {
                              "amount": 10000000,
                              "currency": {
                                "symbolic_code": "RUB"
                              }
                            }
                          }
                        }
                      },
                      "cash_flow": {
                        "value": [
                          {
                            "source": {
                              "provider": "settlement"
                            },
                            "destination": {
                              "merchant": "settlement"
                            },
                            "volume": {
                              "share": {
                                "parts": {
                                  "p": 1,
                                  "q": 1
                                },
                                "of": "operation_amount"
                              }
                            }
                          }
                        ]
                      }
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
          "name": "Шаблон контракта для тестирования",
          "description": "Только для тестового окружения",
          "terms": {"id": 1}
        }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 1},
        "data": {
            "name": "Платежи через Мокетбанк",
            "description": "Платёжный провайдер для тестового окружения",
            "proxy": {
              "ref": {"id": 1},
              "additional": []
            },
            "accounts": [
              {
                "key": {"symbolic_code": "RUB"},
                "value": {
                  "settlement": ${MOCKET_BANK_PAYMENT_PROVIDER_ACCOUNT}
                }
              }
            ],
            "terms": {
              "payments": {
                "currencies": {
                  "value": [{"symbolic_code": "RUB"}]
                },
                "categories": {
                  "value": [{"id": 1}]
                },
                "payment_methods": {
                  "value": [
                    {
                      "id": {
                        "bank_card": {
                          "payment_system": {"id": "VISA"},
                          "is_cvv_empty": false
                        }
                      }
                    }
                  ]
                },
                "cash_limit": {
                  "decisions": [
                    {
                      "if_": {
                        "condition": {
                          "currency_is": {
                            "symbolic_code": "RUB"
                          }
                        }
                      },
                      "then_": {
                        "value": {
                          "upper": {
                            "exclusive": {
                              "amount": 10000000,
                              "currency": {
                                "symbolic_code": "RUB"
                              }
                            }
                          },
                          "lower": {
                            "inclusive": {
                              "amount": -1000000000,
                              "currency": {
                                "symbolic_code": "RUB"
                              }
                            }
                          }
                        }
                      }
                    }
                  ]
                },
                "cash_flow": {
                  "decisions": [
                    {
                      "if_": {
                        "condition": {
                          "payment_tool": {
                            "bank_card": {
                              "definition": {
                                "payment_system": {
                                  "payment_system_is": {"id": "VISA"}
                                }
                              }
                            }
                          }
                        }
                      },
                      "then_": {
                        "value": [
                          {
                            "source": {
                              "provider": "settlement"
                            },
                            "destination": {
                              "merchant": "settlement"
                            },
                            "volume": {
                              "share": {
                                "parts": {
                                  "p": 1,
                                  "q": 1
                                },
                                "of": "operation_amount"
                              }
                            }
                          }
                        ]
                      }
                    }
                  ]
                },
                "holds": {
                  "lifetime": {
                    "value": {
                      "seconds": 10000
                    }
                  }
                },
                "refunds": {
                  "cash_flow": {
                    "value": [
                      {
                        "source": {
                          "merchant": "settlement"
                        },
                        "destination": {
                          "provider": "settlement"
                        },
                        "volume": {
                          "share": {
                            "parts": {
                              "p": 1,
                              "q": 1
                            },
                            "of": "operation_amount"
                          }
                        }
                      }
                    ]
                  },
                  "partial_refunds": {
                    "cash_limit": {
                      "decisions": [
                        {
                          "if_": {
                            "condition": {
                              "currency_is": {
                                "symbolic_code": "RUB"
                              }
                            }
                          },
                          "then_": {
                            "value": {
                              "upper": {
                                "exclusive": {
                                  "amount": 10000000,
                                  "currency": {
                                    "symbolic_code": "RUB"
                                  }
                                }
                              },
                              "lower": {
                                "inclusive": {
                                  "amount": 100,
                                  "currency": {
                                    "symbolic_code": "RUB"
                                  }
                                }
                              }
                            }
                          }
                        }
                      ]
                    }
                  }
                }
              },
              "recurrent_paytools": {
                "cash_value": {
                  "decisions": [
                    {
                      "if_": {
                        "condition": {
                          "currency_is": {
                            "symbolic_code": "RUB"
                          }
                        }
                      },
                      "then_": {
                        "value": {
                          "amount": 100,
                          "currency": {
                            "symbolic_code": "RUB"
                          }
                        }
                      }
                    }
                  ]
                },
                "categories": {
                  "value": [{"id": 1}]
                },
                "payment_methods": {
                  "value": [
                    {
                      "id": {
                        "bank_card": {
                          "payment_system": {"id": "VISA"},
                          "is_cvv_empty": false
                        }
                      }
                    }
                  ]
                }
              }
            },
            "abs_account": "0000000001",
            "terminal": {
              "value": [{"id": 1, "priority": 1000}]
            }
          }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 2},
        "data": {
            "name": "Выплаты через Мокетбанк",
            "description": "Выплатной провайдер для тестового окружения",
            "proxy": {
              "ref": {"id": 2},
              "additional": []
            },
            "accounts": [
              {
                "key": {"symbolic_code": "RUB"},
                "value": {
                  "settlement": ${MOCKET_BANK_PAYOUT_PROVIDER_ACCOUNT}
                }
              }
            ],
            "terms": {
              "wallet": {
                "withdrawals": {
                  "currencies": {
                    "value": [{"symbolic_code": "RUB"}]
                  },
                  "payout_methods": {
                    "value": [{ "id": "wallet_info" }]
                  },
                  "cash_limit": {
                    "value": {
                      "upper": {
                        "inclusive": {
                          "amount": 10000000,
                          "currency": {
                            "symbolic_code": "RUB"
                          }
                        }
                      },
                      "lower": {
                        "inclusive": {
                          "amount": 0,
                          "currency": {
                            "symbolic_code": "RUB"
                          }
                        }
                      }
                    }
                  },
                  "cash_flow": {
                    "value": []
                  }
                }
              }
            },
            "terminal": {
              "value": [{"id": 2, "priority": 1000}]
            }
        }
    }}}},

    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": {"payment_system": {"id": "VISA"}}}},
        "data": {
            "name": "VISA",
            "description": "VISA bank cards"
        }
    }}}},

    {"insert": {"object": {"payout_method": {
        "ref": {"id": "wallet_info"},
        "data": {
          "name": "Выплаты на кошельки",
          "description": "Выплаты на кошельки"
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 1},
        "data": {
            "name": "Эквайринговый терминал Мокетбанка",
            "description": "Должен использоваться только в тестовом окружении",
            "provider_ref": {"id": 1}
        }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 2},
        "data": {
          "name": "Выплатной терминал Мокетбанка",
          "description": "Должен использоваться только в тестовом окружении",
          "provider_ref": {"id": 2}
        }
      }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 1},
        "data": {
            "name": "Прокси к платёжному адаптеру Мокетбанка",
            "description": "Должен использоваться только в тестовом окружении",
            "url": "http://proxy-mocketbank:8022/proxy/mocketbank",
            "options": {}
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 2},
        "data": {
            "name": "Прокси к выплатному адаптеру Мокетбанка",
            "description": "Должен использоваться только в тестовом окружении",
            "url": "http://proxy-mocketbank:8022/proxy/mocketbank/p2p-credit",
            "options": {
              "timer_timeout": "10"
            }
        }
    }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 3},
        "data": {
            "name": "Прокси к тестовому антифроду",
            "description": "Должен использоваться только в тестовом окружении",
            "url": "http://proxy-mocket-inspector:8022/proxy/mocket/inspector",
            "options": {"risk_score": "high"}
        }
    }}}},

    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 1},
        "data": {
            "name": "Правила проведения тестовых платежей",
            "decisions": {
              "delegates": [
                {
                  "allowed": {"constant": true},
                  "ruleset": {"id": 2}
                }
              ]
            }
          }
    }}}},

    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 2},
        "data": {
            "name": "Правила проведения тестовых платежей в рублях",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "currency_is": {
                        "symbolic_code": "RUB"
                      }
                    }
                  },
                  "terminal": {"id": 1},
                  "priority": 1000
                }
              ]
            }
          }
    }}}},

    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 3},
        "data": {
            "name": "Правила проведения тестовых выплат",
            "decisions": {
              "delegates": [
                {
                  "allowed": {"constant": true},
                  "ruleset": {"id": 4}
                }
              ]
            }
          }
    }}}},

    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 4},
        "data": {
            "name": "Правила проведения тестовых выплат в рублях",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "currency_is": {
                        "symbolic_code": "RUB"
                      }
                    }
                  },
                  "terminal": {"id": 2},
                  "priority": 1000
                }
              ]
            }
          }
    }}}},

    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 5},
        "data": {
            "name": "Правила запретов в тесовом окружении",
            "decisions": {
              "candidates": []
            }
          }
    }}}},

		{
			"insert": {
				"object": {
					"payment_system": {
						"ref": {
							"id": "VISA"
						},
						"data": {
							"name": "VISA",
							"validation_rules": [
								{"card_number": {"checksum": {"luhn": {}}}},
								{"card_number": {"ranges": [{"lower": 13, "upper": 13},{"lower": 16, "upper": 16}]}},
								{"cvc": {"length": {"lower": 3, "upper": 3}}},
								{"exp_date": {"exact_exp_date": {}}}
							]
						}
					}
				}
			}
		},

    {
      "insert": {
        "object": {
          "payment_system_legacy": {
              "ref": {
                  "id": "visa"
              },
            "data": {
              "id": "VISA"
            }
          }
        }
      }
    },

    {"insert": {"object": {"inspector": {
        "ref": {"id": 1},
        "data": {
            "name": "Тестовый антифрод",
            "description": "Должен использоваться только в тестовом окружении",
            "proxy": {
                "ref": {"id": 3},
                "additional": {}
            }
        }
    }}}},

    {"insert": {"object": {"payment_institution": {
        "ref": {"id": 1},
        "data": {
            "name": "НКО Тест",
            "system_account_set": {"value": {"id": 1}},
            "default_contract_template": {"value": {"id": 1}},
            "default_wallet_contract_template": {"value": {"id": 1}},
            "inspector": {"value": {"id": 1}},
            "realm": "test",
            "wallet_system_account_set": {"value": {"id": 2}},
            "residences": ["rus"],
            "payment_routing_rules" : {"policies": {"id":1},"prohibitions": {"id":5}},
            "withdrawal_routing_rules" : {"policies": {"id":3},"prohibitions": {"id":5}}
        }
    }}}},

    {"insert": {"object": {"globals": {
        "ref": {},
        "data": {
            "external_account_set": {"value": {"id": 1}},
            "payment_institutions": [{"id": 1}]
        }
    }}}}
]}
END
)

woorl -s "damsel/proto/domain_config.thrift" "http://dominant:8022/v1/domain/repository" Repository Commit 0 "${FIXTURE}"