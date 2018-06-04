#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#


import logging
import httpclient
import json
import strutils
import times
import tables
import hmac


# Set up loggers
const verboseFormat: string = "[$datetime] $appName > $levelname: "
var cLog = newConsoleLogger(levelThreshold=lvlDebug, fmtStr=verboseFormat)
var fLog = newFileLogger("./logs/rest-api.log", levelThreshold=lvlDebug, fmtStr=verboseFormat)
addHandler(cLog)
addHandler(fLog)


# Define variables and constants
const api_endpoint:string = "https://api.binance.com"
var client = newHttpClient()


# Rest API methods

proc httpRequest(b:BinanceApi, requestMethod:string, secure:bool=false, endpoint:string, payload:TableRef): (int, JsonNode) =
  var parameters: string = ""
  var multipart = newMultipartData()
  if secure:
    client.headers = newHttpHeaders({"X-MBX-APIKEY" : b.apiKey})

    payload["timestamp"] = intToStr(toInt(epochTime()*1000))

    for key, value in payload:
      parameters &= key&"="&value&"&"
      multipart[key] = value
    parameters.removeSuffix('&')
    debug("Payload: "&parameters)

    let signature = toLowerAscii(hmac_sha256(b.secretKey, parameters))
    parameters &= "&signature="&signature
    multipart["signature"] = signature

  var response: Response
  case requestMethod:
  of "GET":
    if secure:
      info("signed GET: "&api_endpoint&endpoint)
      response = client.get(url=api_endpoint&endpoint&"?"&parameters)
    else:
      info("GET: "&api_endpoint&endpoint)
      response = client.get(api_endpoint&endpoint)
  of "POST":
    info("signed POST: "&api_endpoint&endpoint)
    response = client.post(url=api_endpoint&endpoint, multipart=multipart)
  of "PUT":
    info("signed PUT: "&api_endpoint&endpoint)
    response = client.request(url=api_endpoint&endpoint, httpMethod=HttpPut)
  of "DELETE":
    info("signed DELETE: "&api_endpoint&endpoint)
    response = client.request(url=api_endpoint&endpoint, httpMethod=HttpDelete)

  debug("Status code: "&response.status)
  debug("Body: "&response.body)
  result = (response.status.split(' ')[0].parseInt, parseJson(response.body))

proc httpRequest(b:BinanceApi, requestMethod:string, endpoint:string, payload:TableRef): (int, JsonNode) =
  return b.httpRequest(requestMethod, secure=false, endpoint, payload)

proc httpRequest(b:BinanceApi, requestMethod:string, secure:bool, endpoint:string): (int, JsonNode) =
  return b.httpRequest(requestMethod, secure, endpoint, payload=newTable[string,string]())

proc httpRequest(b:BinanceApi, requestMethod:string, endpoint:string): (int, JsonNode) =
  return b.httpRequest(requestMethod, secure=false, endpoint, payload=newTable[string,string]())


# General endpoints

proc ping*(b:BinanceApi): bool =
  # Test connectivity
  let (status_code, _) = b.httpRequest("GET", "/api/v1/ping")
  if status_code == 200: true
  else: false

proc time*(b:BinanceApi): (int, int) =
  # Check server time
  let (status_code, response) = b.httpRequest("GET", "/api/v1/time")
  if status_code == 200: return (200, response["serverTime"].getInt())
  else: return (status_code, -1)

proc exchangeInfo*(b:BinanceApi): (int, JsonNode) =
  # Exchange information
  result = b.httpRequest("GET", "/api/v1/exchangeInfo")


# Market Data Endpoints

proc orderBook*(b:BinanceApi, symbol:string, limit:int16=100): (int, JsonNode) =
  # Order book
  assert(limit in [5, 10, 20, 50, 100, 500, 1000], "Invalid limit value: "&intToStr(limit))

  result = b.httpRequest("GET", "/api/v1/depth?symbol="&symbol&"&limit="&intToStr(limit))

proc recentTrades*(b:BinanceApi, symbol:string, limit:int16=500): (int, JsonNode) =
  # Recent trades list
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMax 500.")

  result = b.httpRequest("GET", "/api/v1/trades?symbol="&symbol&"&limit="&intToStr(limit))

proc olderTrades*(b:BinanceApi, symbol:string, limit:int16=500, fromId:int32): (int, JsonNode) =
  # Old trade lookup
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/historicalTrades?symbol="&symbol&"&limit="&intToStr(limit)&"&fromId="&intToStr(fromId))

proc olderTrades*(b:BinanceApi, symbol:string, limit:int16=500): (int, JsonNode) =
  # Old trade lookup
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/historicalTrades?symbol="&symbol&"&limit="&intToStr(limit))

proc aggrTrades*(b:BinanceApi, symbol:string, fromId:int32, startTime:int32, limit:int16=500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert(startTime > 0, "Invalid startTime: "&intToStr(startTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&startTime="&intToStr(startTime)&"&limit="&intToStr(limit))

proc aggrTrades*(b:BinanceApi, symbol:string, fromId:int32, endTime:int32, limit:int16=500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert(endTime > 0, "Invalid endTime: "&intToStr(endTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&endTime="&intToStr(endTime)&"&limit="&intToStr(limit))

proc aggrTrades*(b:BinanceApi, symbol:string, startTime:int32, limit:int16=500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(startTime > 0, "Invalid startTime: "&intToStr(startTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&startTime="&intToStr(startTime)&"&limit="&intToStr(limit))

proc aggrTrades*(b:BinanceApi, symbol:string, endTime:int32, limit:int16=500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(endTime > 0, "Invalid endTime: "&intToStr(endTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&endTime="&intToStr(endTime)&"&limit="&intToStr(limit))

proc aggrTrades*(b:BinanceApi, symbol:string, fromId:int32, startTime:int32, endTime:int32): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert(endTime-startTime < 24*36000000, "Invalid startTime-endTime: \nMax intervall is 24h.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&startTime="&intToStr(startTime)&"&endTime="&intToStr(endTime))

proc aggrTrades*(b:BinanceApi, symbol:string, startTime:int32, endTime:int32): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(endTime-startTime < 24*36000000, "Invalid startTime-endTime: \nMax intervall is 24h.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&startTime="&intToStr(startTime)&"&endTime="&intToStr(endTime))

proc aggrTrades*(b:BinanceApi, symbol:string, fromId:int32, limit:int16=500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&limit="&intToStr(limit))

proc aggrTrades*(b:BinanceApi, symbol:string, limit:int16=500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/aggTrades?symbol="&symbol&"&limit="&intToStr(limit))

proc candlesticks*(b:BinanceApi, symbol:string, interval:CandlestickInterval, limit:int16=500, startTime:int32, endTime:int32): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit)&"&startTime="&intToStr(startTime)&"&endTime="&intToStr(endTime))

proc candlesticks*(b:BinanceApi, symbol:string, interval:CandlestickInterval, limit:int16=500, startTime:int32): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit)&"&startTime="&intToStr(startTime))

proc candlesticks*(b:BinanceApi, symbol:string, interval:CandlestickInterval, limit:int16=500, endTime:int32): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit)&"&endTime="&intToStr(endTime))

proc candlesticks*(b:BinanceApi, symbol:string, interval:CandlestickInterval, limit:int16=500): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  result = b.httpRequest("GET", "/api/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit))

proc ticker24hStats*(b:BinanceApi, symbol:string): (int, JsonNode) =
  # 24hr ticker price change statistics
  result = b.httpRequest("GET", "/api/v1/ticker/24hr?symbol="&symbol)

proc ticker24hStats*(b:BinanceApi): (int, JsonNode) =
  # 24hr ticker price change statistics
  result = b.httpRequest("GET", "/api/v1/ticker/24hr")

proc tickerPrice*(b:BinanceApi, symbol:string): (int, JsonNode) =
  # Symbol price ticker
  result = b.httpRequest("GET", "/api/v1/ticker/price?symbol="&symbol)

proc tickerPrice*(b:BinanceApi): (int, JsonNode) =
  # Symbol price ticker
  result = b.httpRequest("GET", "/api/v1/ticker/price")

proc orderBookTicker*(b:BinanceApi, symbol:string): (int, JsonNode) =
  # Symbol order book ticker
  result = b.httpRequest("GET", "/api/v1/ticker/bookTicker?symbol="&symbol)

proc orderBookTicker*(b:BinanceApi): (int, JsonNode) =
  # Symbol order book ticker
  result = b.httpRequest("GET", "/api/v1/ticker/bookTicker")


# Account Endpoints

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, newClientOrderId:string, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # LIMIT
  assert(orderType == OrderType.Limit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newClientOrderId"] = newClientOrderId
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # LIMIT
  assert(orderType == OrderType.Limit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, newClientOrderId:string, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # MARKET
  assert(orderType == OrderType.Market, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["newClientOrderId"] = newClientOrderId
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # MARKET
  assert(orderType == OrderType.Market, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, newClientOrderId:string, stopPrice:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # STOP_LOSS, TAKE_PROFIT
  assert(orderType == OrderType.StopLoss or orderType == OrderType.TakeProfit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["newClientOrderId"] = newClientOrderId
  payload["stopPrice"] = $stopPrice
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, stopPrice:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # STOP_LOSS, TAKE_PROFIT
  assert(orderType == OrderType.StopLoss or orderType == OrderType.TakeProfit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["stopPrice"] = $stopPrice
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, newClientOrderId:string, stopPrice:float, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # STOP_LOSS_LIMIT, TAKE_PROFIT_LIMIT
  assert(orderType == OrderType.StopLossLimit or orderType == OrderType.TakeProfitLimit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newClientOrderId"] = newClientOrderId
  payload["stopPrice"] = $stopPrice
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, stopPrice:float, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # STOP_LOSS_LIMIT, TAKE_PROFIT_LIMIT
  assert(orderType == OrderType.StopLossLimit or orderType == OrderType.TakeProfitLimit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["stopPrice"] = $stopPrice
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, price:float, newClientOrderId:string, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # LIMIT_MAKER
  assert(orderType == OrderType.LimitMaker, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newClientOrderId"] = newClientOrderId
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc newOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, price:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Send in a new order.
  # LIMIT_MAKER
  assert(orderType == OrderType.LimitMaker, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, newClientOrderId:string, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # LIMIT
  assert(orderType == OrderType.Limit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newClientOrderId"] = newClientOrderId
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # LIMIT
  assert(orderType == OrderType.Limit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, newClientOrderId:string, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # MARKET
  assert(orderType == OrderType.Market, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["newClientOrderId"] = newClientOrderId
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # MARKET
  assert(orderType == OrderType.Market, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, newClientOrderId:string, stopPrice:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # STOP_LOSS, TAKE_PROFIT
  assert(orderType == OrderType.StopLoss or orderType == OrderType.TakeProfit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["newClientOrderId"] = newClientOrderId
  payload["stopPrice"] = $stopPrice
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, stopPrice:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # STOP_LOSS, TAKE_PROFIT
  assert(orderType == OrderType.StopLoss or orderType == OrderType.TakeProfit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["stopPrice"] = $stopPrice
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, newClientOrderId:string, stopPrice:float, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # STOP_LOSS_LIMIT, TAKE_PROFIT_LIMIT
  assert(orderType == OrderType.StopLossLimit or orderType == OrderType.TakeProfitLimit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newClientOrderId"] = newClientOrderId
  payload["stopPrice"] = $stopPrice
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, quantity:float, price:float, stopPrice:float, icebergQty:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # STOP_LOSS_LIMIT, TAKE_PROFIT_LIMIT
  assert(orderType == OrderType.StopLossLimit or orderType == OrderType.TakeProfitLimit, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["timeInForce"] = $timeInForce
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["stopPrice"] = $stopPrice
  payload["icebergQty"] = $icebergQty
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, price:float, newClientOrderId:string, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # LIMIT_MAKER
  assert(orderType == OrderType.LimitMaker, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newClientOrderId"] = newClientOrderId
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc testNewOrder*(b:BinanceApi, symbol:string, side:OrderSide, orderType:OrderType, quantity:float, price:float, newOrderRespType:ResponseType, recvWindow:int32): (int, JsonNode) =
  # Test new order creation and signature/recvWindow long. Creates and validates a new order but does not send it into the matching engine..
  # LIMIT_MAKER
  assert(orderType == OrderType.LimitMaker, "Wrong order type or parameters.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["side"] = $side
  payload["orderType"] = $orderType
  payload["quantity"] = $quantity
  payload["price"] = $price
  payload["newOrderRespType"] = $newOrderRespType
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("POST", true, "/api/v3/order/test", payload)

proc queryOrder*(b:BinanceApi, symbol:string, orderId:int32, recvWindow:int32=5000): (int, JsonNode) =
  # Check an order's status.
  # Either orderId or origClientOrderId must be sent.
  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["orderId"] = $orderId
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("GET", true, "/api/v3/order", payload)

proc queryOrder*(b:BinanceApi, symbol:string, origClientOrderId:string, recvWindow:int32=5000): (int, JsonNode) =
  # Check an order's status.
  # Either orderId or origClientOrderId must be sent.
  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["origClientOrderId"] = $origClientOrderId
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("GET", true, "/api/v3/order", payload)

proc cancelOrder*(b:BinanceApi, symbol:string, orderId:int32, newClientOrderId:string, recvWindow:int32=5000): (int, JsonNode) =
  # Cancel an active order.
  # Either orderId or origClientOrderId must be sent.
  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["orderId"] = $orderId
  payload["newClientOrderId"] = $newClientOrderId
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("DELETE", true, "/api/v3/order", payload)

proc cancelOrder*(b:BinanceApi, symbol:string, orderId:int32, origClientOrderId:string, newClientOrderId:string, recvWindow:int32=5000): (int, JsonNode) =
  # Cancel an active order.
  # Either orderId or origClientOrderId must be sent.
  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["origClientOrderId"] = $origClientOrderId
  payload["newClientOrderId"] = $newClientOrderId
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("DELETE", true, "/api/v3/order", payload)

proc cancelOrder*(b:BinanceApi, symbol:string, orderId:int32, recvWindow:int32=5000): (int, JsonNode) =
  # Cancel an active order.
  # Either orderId or origClientOrderId must be sent.
  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["orderId"] = $orderId
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("DELETE", true, "/api/v3/order", payload)

proc cancelOrder*(b:BinanceApi, symbol:string, origClientOrderId:string, recvWindow:int32=5000): (int, JsonNode) =
  # Cancel an active order.
  # Either orderId or origClientOrderId must be sent.
  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["origClientOrderId"] = $origClientOrderId
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("DELETE", true, "/api/v3/order", payload)

proc currentOpenOrders*(b:BinanceApi, symbol:string, recvWindow:int32=5000): (int, JsonNode) =
  # Get all open orders on a symbol. Careful when accessing this with no symbol.
  # If the symbol is not sent, orders for all symbols will be returned in an array.
  # When all symbols are returned, the number of requests counted against the rate limiter is equal to the number of symbols currently trading on the exchange.
  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("GET", true, "/api/v3/openOrders", payload)

proc getAllOrders*(b:BinanceApi, symbol:string, orderId:int32, limit:int=500, recvWindow:int32=5000): (int, JsonNode) =
  # Get all account orders; active, canceled, or filled.
  # If orderId is set, it will get orders >= that orderId. Otherwise most recent orders are returned.
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["orderId"] = $orderId
  payload["limit"] = $limit
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("GET", true, "/api/v3/allOrders", payload)

proc accountInfo*(b:BinanceApi, recvWindow:int32=5000): (int, JsonNode) =
  # Get current account information.
  var payload = newTable[string, string]()
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("GET", true, "/api/v3/account", payload)

proc accountTradeList*(b:BinanceApi, symbol:string, limit:int=500, fromId:int32, recvWindow:int32=5000): (int, JsonNode) =
  # Get trades for a specific account and symbol.
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  var payload = newTable[string, string]()
  payload["symbol"] = symbol
  payload["limit"] = $limit
  payload["fromId"] = $fromId
  payload["recvWindow"] = $recvWindow

  result = b.httpRequest("GET", true, "/api/v3/myTrades", payload)


# User data stream endpoints

proc startUserDataStream*(b:BinanceApi): (int, string) =
  # Start a new user data stream. The stream will close after 60 minutes unless a keepalive is sent.
  let (status_code, response) = b.httpRequest("POST", "/api/v1/userDataStream")
  if status_code == 200: return (200, response["listenKey"].getStr())
  else: return (status_code, "")

proc keepaliveUserDataStream*(b:BinanceApi, listenKey:string): int =
  # Keepalive a user data stream to prevent a time out. User data streams will close after 60 minutes. It's recommended to send a ping about every 30 minutes.
  var payload = newTable[string, string]()
  payload["listenKey"] = listenKey

  let (status_code, _) = b.httpRequest("PUT", "/api/v1/userDataStream", payload)
  return status_code

proc closeUserDataStream*(b:BinanceApi, listenKey:string): int =
  # Close out a user data stream.
  var payload = newTable[string, string]()
  payload["listenKey"] = listenKey

  let (status_code, _) = b.httpRequest("DELETE", "/api/v1/userDataStream", payload)
  return status_code


# Filters
