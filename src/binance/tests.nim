import httpclient
import json
import strutils
import logging

import rest_api

const api_endpoint:string = "https://api.binance.com/api"


echo getWrapper(api_endpoint&"/v1/ticker/price?symbol=ETHBTC")
#var d:JsonNode = response[0]["symbol"]


#[var query:string = ""
var payload = newMultipartData()
var response = client.post(query, multipart=payload)
debug(response.body)
]#
