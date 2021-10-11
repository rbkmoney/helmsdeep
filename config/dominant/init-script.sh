#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o errtrace

export CHARSET=UTF-8
export LANG=C.UTF-8

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
              {
                "key": {"symbolic_code": "USD"},
                "value": {"settlement": $(scripts/dominant/create-account.sh USD)}
              },
              {
                "key": {"symbolic_code": "RUB"},
                "value": {"settlement": $(scripts/dominant/create-account.sh RUB)}
              }
            ]
        }
    }}}},

    {"insert": {"object": {"external_account_set": {
        "ref": {"id": 1},
        "data": {
            "name": "Primary",
            "description": "Primary",
            "accounts": [
              {
                "key": {
                  "symbolic_code": "RUB"
                },
                "value": {
                  "income": $(scripts/dominant/create-account.sh RUB),
                  "outcome": $(scripts/dominant/create-account.sh RUB)
                }
              }
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
        "ref": {
          "id": 5
        },
        "data": {
          "name": "Fraudbusters",
          "description": "Fraudbusters!",
          "proxy": {
            "ref": {
              "id": 5
            },
            "additional": []
          },
          "fallback_risk_score": "high"
        }
      }}}},

    {"insert": {"object": {"term_set_hierarchy": {
        "ref": {"id": 1},
        "data": {
            "term_sets": [
              {
                "action_time": [],
                "terms": {
                  "payments": {
                    "currencies": {
                      "value": [
                        {
                          "symbolic_code": "RUB"
                        }
                      ]
                    },
                    "categories": {
                      "value": [
                        {
                          "id": 1
                        }
                      ]
                    },
                    "payment_methods": {
                      "value": [
                        {
                          "id": {
                            "bank_card": {
                              "payment_system": {"id": "MASTERCARD"},
                              "is_cvv_empty": false
                            }
                          }
                        },
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
                                  "amount": 4200000,
                                  "currency": {
                                    "symbolic_code": "RUB"
                                  }
                                }
                              },
                              "lower": {
                                "inclusive": {
                                  "amount": 1000,
                                  "currency": {
                                    "symbolic_code": "RUB"
                                  }
                                }
                              }
                            }
                          }
                        },
                        {
                          "if_": {
                            "condition": {
                              "currency_is": {
                                "symbolic_code": "USD"
                              }
                            }
                          },
                          "then_": {
                            "value": {
                              "upper": {
                                "inclusive": {
                                  "amount": 100000000,
                                  "currency": {
                                    "symbolic_code": "USD"
                                  }
                                }
                              },
                              "lower": {
                                "inclusive": {
                                  "amount": 100,
                                  "currency": {
                                    "symbolic_code": "USD"
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
                                "source": {
                                  "merchant": "settlement"
                                },
                                "destination": {
                                  "system": "settlement"
                                },
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
                                "payment_system": {"id": "MASTERCARD"},
                                "is_cvv_empty": false
                              }
                            }
                          },
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
                                "payment_system": {"id": "MASTERCARD"},
                                "is_cvv_empty": false
                              }
                            }
                          },
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
                        "value": []
                      },
                      "eligibility_time": {
                        "value": {
                          "years": 1
                        }
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
                                      "amount": 1000,
                                      "currency": {
                                        "symbolic_code": "RUB"
                                      }
                                    }
                                  }
                                }
                              }
                            },
                            {
                              "if_": {
                                "condition": {
                                  "currency_is": {
                                    "symbolic_code": "USD"
                                  }
                                }
                              },
                              "then_": {
                                "value": {
                                  "upper": {
                                    "inclusive": {
                                      "amount": 100000000,
                                      "currency": {
                                        "symbolic_code": "USD"
                                      }
                                    }
                                  },
                                  "lower": {
                                    "inclusive": {
                                      "amount": 100,
                                      "currency": {
                                        "symbolic_code": "USD"
                                      }
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
                      "allow": {
                        "constant": true
                      },
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
                              "payment_system": {"id": "MASTERCARD"},
                              "is_cvv_empty": false
                            }
                          }
                        },
                        {
                          "id": {
                            "bank_card": {
                              "payment_system": {"id": "VISA"},
                              "is_cvv_empty": false
                            }
                          }
                        },
                        {
                          "id": {
                            "bank_card": {
                              "payment_system": {"id": "VISA"},
                              "is_cvv_empty": true
                            }
                          }
                        }
                      ]
                    }
                  },
                  "wallets": {
                    "currencies": {
                      "value": [
                        {
                          "symbolic_code": "RUB"
                        }
                      ]
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
                        "value": [
                          {
                            "symbolic_code": "RUB"
                          }
                        ]
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
                              "wallet": 1
                            },
                            "destination": {
                              "wallet": 3
                            },
                            "volume": {
                              "share": {
                                "parts": {
                                  "p": 1,
                                  "q": 1
                                },
                                "of": 1
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
    {"insert": {"object": {"currency": {
        "ref": {"symbolic_code": "USD"},
          "data": {
            "name": "USA Dollars",
            "symbolic_code": "USD",
            "numeric_code": 840,
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

    {"insert": {"object": {"bank_card_category": {
        "ref": {"id": 1},
        "data": {
            "name": "CATEGORY1",
            "description": "ok",
            "category_patterns": [
              "*SOMECATEGORY*"
            ]
          }
    }}}},

    {"insert": {"object": {"bank": {
        "ref": {"id": 1},
        "data": {
            "name": "Bank 1",
            "description": "Bank 1",
            "binbase_id_patterns": [
              "*SOMEBANK*"
            ],
            "bins": [
              "123456"
            ]
          }
    }}}},

    {"insert": {"object": {"provider": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank",
            "description": "Mocketbank",
            "proxy": {
              "ref": {
                "id": 1
              },
              "additional": []
            },
            "accounts": [
              {
                "key": {
                  "symbolic_code": "RUB"
                },
                "value": {
                  "settlement": $(scripts/dominant/create-account.sh RUB)
                }
              },
              {
                "key": {
                  "symbolic_code": "USD"
                },
                "value": {
                  "settlement": $(scripts/dominant/create-account.sh USD)
                }
              }
            ],
            "terms": {
              "payments": {
                "currencies": {
                  "value": [
                    {
                      "symbolic_code": "RUB"
                    },
                    {
                      "symbolic_code": "USD"
                    }
                  ]
                },
                "categories": {
                  "value": [
                    {
                      "id": 1
                    }
                  ]
                },
                "payment_methods": {
                  "value": [
                    {
                      "id": {
                        "bank_card": {
                          "payment_system": {"id": "MASTERCARD"},
                          "is_cvv_empty": false
                        }
                      }
                    },
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
                              "amount": 1000,
                              "currency": {
                                "symbolic_code": "RUB"
                              }
                            }
                          }
                        }
                      }
                    },
                    {
                      "if_": {
                        "condition": {
                          "currency_is": {
                            "symbolic_code": "USD"
                          }
                        }
                      },
                      "then_": {
                        "value": {
                          "upper": {
                            "inclusive": {
                              "amount": 100000000,
                              "currency": {
                                "symbolic_code": "USD"
                              }
                            }
                          },
                          "lower": {
                            "inclusive": {
                              "amount": 100,
                              "currency": {
                                "symbolic_code": "USD"
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
                          },
                          {
                            "source": {
                              "system": "settlement"
                            },
                            "destination": {
                              "provider": "settlement"
                            },
                            "volume": {
                              "share": {
                                "parts": {
                                  "p": 15,
                                  "q": 1000
                                },
                                "of": "operation_amount"
                              }
                            }
                          }
                        ]
                      }
                    },
                    {
                      "if_": {
                        "condition": {
                          "payment_tool": {
                            "bank_card": {
                              "definition": {
                                "payment_system": {
                                  "payment_system_is": {"id": "MASTERCARD"}
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
                          },
                          {
                            "source": {
                              "system": "settlement"
                            },
                            "destination": {
                              "provider": "settlement"
                            },
                            "volume": {
                              "share": {
                                "parts": {
                                  "p": 18,
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
                                  "amount": 1000,
                                  "currency": {
                                    "symbolic_code": "RUB"
                                  }
                                }
                              }
                            }
                          }
                        },
                        {
                          "if_": {
                            "condition": {
                              "currency_is": {
                                "symbolic_code": "USD"
                              }
                            }
                          },
                          "then_": {
                            "value": {
                              "upper": {
                                "inclusive": {
                                  "amount": 100000000,
                                  "currency": {
                                    "symbolic_code": "USD"
                                  }
                                }
                              },
                              "lower": {
                                "inclusive": {
                                  "amount": 100,
                                  "currency": {
                                    "symbolic_code": "USD"
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
                          "amount": 199,
                          "currency": {
                            "symbolic_code": "RUB"
                          }
                        }
                      }
                    },
                    {
                      "if_": {
                        "condition": {
                          "currency_is": {
                            "symbolic_code": "USD"
                          }
                        }
                      },
                      "then_": {
                        "value": {
                          "amount": 100,
                          "currency": {
                            "symbolic_code": "USD"
                          }
                        }
                      }
                    }
                  ]
                },
                "categories": {
                  "value": [
                    {
                      "id": 1
                    }
                  ]
                },
                "payment_methods": {
                  "value": [
                    {
                      "id": {
                        "bank_card": {
                          "payment_system": {"id": "MASTERCARD"},
                          "is_cvv_empty": false
                        }
                      }
                    },
                    {
                      "id": {
                        "bank_card": {
                          "payment_system": {"id": "VISA"},
                          "is_cvv_empty": false
                        }
                      }
                    },
                    {
                      "id": {
                        "bank_card": {
                          "payment_system": {"id": "VISA"},
                          "is_cvv_empty": true
                        }
                      }
                    }
                  ]
                }
              }
            },
            "abs_account": "0000000001",
            "terminal": {
              "value": [
                {
                  "id": 1,
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"provider": {
        "ref": {"id": 2},
        "data": {
            "name": "Mocketbank payouts",
            "description": "No",
            "proxy": {
              "ref": {
                "id": 3
              },
              "additional": {
                "k": "v"
              }
            },
            "identity": "1",
            "accounts": [
              {
                "key": {
                  "symbolic_code": "RUB"
                },
                "value": {
                  "settlement": $(scripts/dominant/create-account.sh RUB)
                }
              }
            ],
            "terms": {
              "wallet": {
                "withdrawals": {
                  "currencies": {
                    "value": [
                      {
                        "symbolic_code": "RUB"
                      }
                    ]
                  },
                  "payout_methods": {
                    "value": [
                      {
                        "id": "wallet_info"
                      }
                    ]
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
              "value": [
                {
                  "id": 3,
                  "priority": 1000
                }
              ]
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
    {"insert": {"object": {"payment_method": {
        "ref": {"id": {"bank_card": {"payment_system": {"id": "MASTERCARD"}}}},
        "data": {
            "name": "Mastercard",
            "description": "Mastercard bank cards"
        }
    }}}},
    {"insert": {"object": {"payout_method": {
        "ref": {
            "id": "wallet_info"
          },
          "data": {
            "name": "Wallet info",
            "description": "Выводы на кошельки мерчантов"
          }
    }}}},
    {"insert": {"object": {"payment_method": {
        "ref": {
            "id": {"bank_card": {"payment_system": {"id": "VISA"},"is_cvv_empty": true}}
          },
          "data": {
            "name": "Visa NOCVV",
            "description": "No"
          }
    }}}},

    {"insert": {"object": {"terminal": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Test Acquiring",
            "description": "Mocketbank Test Acquiring",
            "provider_ref": {
              "id": 1
            }
        }
    }}}},
    {"insert": {"object": {"terminal": {
        "ref": {
          "id": 2
        },
        "data": {
          "name": "Mocketbank Test2 Terminal",
          "description": "Mocketbank Test2 Terminal"
        }
      }}}},
    {"insert": {"object": {"terminal": {
        "ref": {
          "id": 3
        },
        "data": {
          "name": "Mocketbank Payout terminal",
          "description": "No",
          "options": {
            "k": "v"
          },
          "risk_coverage": "high",
          "provider_ref": {
            "id": 2
          }
        }
      }}}},

    {"insert": {"object": {"proxy": {
        "ref": {"id": 1},
        "data": {
            "name": "Mocketbank Proxy",
            "description": "Mocked bank proxy for integration test purposes",
            "url": "http://proxy-mocketbank:8022/proxy/mocketbank",
            "options": {}
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {"id": 3},
        "data": {
            "name": "Mocketbank Proxy Payouts",
            "description": "Proxy test Payouts",
            "url": "http://proxy-mocketbank:8022/proxy/mocketbank/p2p-credit",
            "options": {
              "timer_timeout": "10"
            }
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {"id": 100},
        "data": {
            "name": "Mocket Inspector Proxy",
            "description": "Mocked inspector proxy for integration test purposes",
            "url": "http://proxy-mocket-inspector:8022/proxy/mocket/inspector",
            "options": {"risk_score": "high"}
        }
    }}}},
    {"insert": {"object": {"proxy": {
        "ref": {
          "id": 5
        },
        "data": {
          "name": "Fraudbusters",
          "description": "Fraudbusters",
          "url": "http://fraudbusters:8022/fraud_inspector/v1",
          "options": []
        }
      }}}},

    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 1},
        "data": {
            "name": "Роутинг по валюте",
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
                  "terminal": {
                    "id": 1
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 2},
        "data": {
            "name": "Роутинг по банку-эмитенту",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "payment_tool": {
                        "bank_card": {
                          "definition": {
                            "issuer_bank_is": {
                              "id": 1
                            }
                          }
                        }
                      }
                    }
                  },
                  "terminal": {
                    "id": 2
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 3},
        "data": {
            "name": "Роутинг по стране, выпустившую карту",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "payment_tool": {
                        "bank_card": {
                          "definition": {
                            "issuer_country_is": "mlt"
                          }
                        }
                      }
                    }
                  },
                  "terminal": {
                    "id": 1
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 4},
        "data": {
            "name": "Роутинг по МПС карты",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "payment_tool": {
                        "bank_card": {
                          "definition": {
                            "payment_system": {
                              "payment_system_is": {"id": "MASTERCARD"}
                            }
                          }
                        }
                      }
                    }
                  },
                  "terminal": {
                    "id": 2
                  },
                  "priority": 1000
                }
              ]
            }
        }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 5},
        "data": {
            "name": "Роутинг по типу карты",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "payment_tool": {
                        "bank_card": {
                          "definition": {
                            "category_is": {
                              "id": 1
                            }
                          }
                        }
                      }
                    }
                  },
                  "terminal": {
                    "id": 1
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 6},
        "data": {
            "name": "Роутинг по категории магазина",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "category_is": {
                        "id": 1
                      }
                    }
                  },
                  "terminal": {
                    "id": 2
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 7},
        "data": {
            "name": "Роутинг по URL магазина",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "shop_location_is": {
                        "url": "someurl"
                      }
                    }
                  },
                  "terminal": {
                    "id": 1
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 8},
        "data": {
            "name": "Роутинг по наличию CVV в платеже",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "payment_tool": {
                        "bank_card": {
                          "definition": {
                            "empty_cvv_is": true
                          }
                        }
                      }
                    }
                  },
                  "terminal": {
                    "id": 2
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 9},
        "data": {
            "name": "Роутинг по вероятностям",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "constant": true
                  },
                  "terminal": {
                    "id": 1
                  },
                  "weight": 1,
                  "priority": 1000
                },
                {
                  "allowed": {
                    "constant": true
                  },
                  "terminal": {
                    "id": 2
                  },
                  "weight": 2,
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 10},
        "data": {
            "name": "Роутинг по мерчанту",
            "decisions": {
              "candidates": [
                {
                  "allowed": {
                    "condition": {
                      "party": {
                        "id": "someparty",
                        "definition": {
                          "shop_is": "someshop"
                        }
                      }
                    }
                  },
                  "terminal": {
                    "id": 1
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
    {"insert": {"object": {"routing_rules": {
        "ref": {"id": 11},
        "data": {
            "name": "Роутинг выплат по валюте",
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
                  "terminal": {
                    "id": 3
                  },
                  "priority": 1000
                }
              ]
            }
          }
    }}}},
		{
			"insert": {
				"object": {
					"payment_system": {
						"ref": {
							"id": "MASTERCARD"
						},
						"data": {
							"name": "MASTERCARD",
							"validation_rules": [
								{"card_number": {"checksum": {"luhn": {}}}},
								{"card_number": {"ranges": [{"lower": 16, "upper": 16}]}},
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
					"payment_system": {
						"ref": {
							"id": "NSPK MIR"
						},
						"data": {
							"name": "NSPK MIR",
							"validation_rules": [
								{"card_number": {"checksum": {"luhn": {}}}},
								{"card_number": {"ranges": [{"lower": 16, "upper": 16},{"lower": 19, "upper": 20}]}},
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

    {"insert": {"object": {"payment_institution": {
        "ref": {"id": 1},
        "data": {
            "name": "Test Payment Institution",
            "system_account_set": {"value": {"id": 1}},
            "default_contract_template": {"value": {"id": 1}},
            "default_wallet_contract_template": {"value": {"id": 1}},
            "providers": {"value": [{"id": 1}]},
            "inspector": {"value": {"id": 1}},
            "realm": "test",
            "wallet_system_account_set": {"value": {"id": 1}},
            "residences": ["rus", "aus", "jpn"],
            "identity" : "1",
            "withdrawal_routing_rules" : {"policies": {"id":11},"prohibitions": {"id":8}},
            "payment_routing_rules" : {"policies": {"id":1},"prohibitions": {"id":8}}
        }
    }}}}
]}
END
)

woorl -s "damsel/proto/domain_config.thrift" "http://dominant:8022/v1/domain/repository" Repository Commit 0 "${FIXTURE}"
