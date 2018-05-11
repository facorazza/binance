#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#

#import logging
import json
import strutils

import binance/rest_api

#[const verboseFormat: string = "[$datetime] $appName > $levelname: "
var cLog = newConsoleLogger(levelThreshold=lvlDebug, fmtStr=verboseFormat)
var fLog = newFileLogger("logs/binance-api.log", levelThreshold=lvlDebug, fmtStr=verboseFormat)
addHandler(cLog)
addHandler(fLog)
]#
const api_endpoint:string = "https://api.binance.com/api"

include binance/definitions


# General endpoints

proc ping*: bool =
  # Test connectivity
  let (status_code, _) = getWrapper(api_endpoint&"/v1/ping")
  if status_code == 200: true
  else: false

proc time*: (int, int) =
  # Check server time
  let (status_code, response) = getWrapper(api_endpoint&"/v1/time")
  if status_code == 200: return (200, response["serverTime"].getInt())
  else: return (status_code, -1)

proc exchangeInfo*: (int, JsonNode) =
  # Exchange information
  getWrapper(api_endpoint&"/v1/exchangeInfo")


# Market Data Endpoints

proc orderBook*(symbol:string, limit:int16 = 100): (int, JsonNode) =
  # Order book
  assert(limit in [5, 10, 20, 50, 100, 500, 1000], "Invalid limit value: "&intToStr(limit))

  getWrapper(api_endpoint&"/v1/depth?symbol="&symbol&"&limit="&intToStr(limit))

proc recentTrades*(symbol:string, limit:int16 = 500): (int, JsonNode) =
  # Recent trades list
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMax 500.")

  getWrapper(api_endpoint&"/v1/trades?symbol="&symbol&"&limit="&intToStr(limit))

proc olderTrades*(symbol:string, limit:int16 = 500, fromId:int32): (int, JsonNode) =
  # Old trade lookup
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/historicalTrades?symbol="&symbol&"&limit="&intToStr(limit)&"&fromId="&intToStr(fromId))

proc olderTrades*(symbol:string, limit:int16 = 500): (int, JsonNode) =
  # Old trade lookup
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/historicalTrades?symbol="&symbol&"&limit="&intToStr(limit))

proc aggrTrades*(symbol:string, fromId:int32, startTime:int32, limit:int16 = 500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert(startTime > 0, "Invalid startTime: "&intToStr(startTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&startTime="&intToStr(startTime)&"&limit="&intToStr(limit))

proc aggrTrades*(symbol:string, fromId:int32, endTime:int32, limit:int16 = 500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert(endTime > 0, "Invalid endTime: "&intToStr(endTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&endTime="&intToStr(endTime)&"&limit="&intToStr(limit))

proc aggrTrades*(symbol:string, startTime:int32, limit:int16 = 500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(startTime > 0, "Invalid startTime: "&intToStr(startTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&startTime="&intToStr(startTime)&"&limit="&intToStr(limit))

proc aggrTrades*(symbol:string, endTime:int32, limit:int16 = 500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(endTime > 0, "Invalid endTime: "&intToStr(endTime))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&endTime="&intToStr(endTime)&"&limit="&intToStr(limit))

proc aggrTrades*(symbol:string, fromId:int32, startTime:int32, endTime:int32): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert(endTime-startTime < 24*36000000, "Invalid startTime-endTime: \nMax intervall is 24h.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&startTime="&intToStr(startTime)&"&endTime="&intToStr(endTime))

proc aggrTrades*(symbol:string, startTime:int32, endTime:int32): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(endTime-startTime < 24*36000000, "Invalid startTime-endTime: \nMax intervall is 24h.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&startTime="&intToStr(startTime)&"&endTime="&intToStr(endTime))

proc aggrTrades*(symbol:string, fromId:int32, limit:int16 = 500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert(fromId > 0, "Invalid fromId: "&intToStr(fromId))
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&fromId="&intToStr(fromId)&"&limit="&intToStr(limit))

proc aggrTrades*(symbol:string, limit:int16 = 500): (int, JsonNode) =
  # Compressed/Aggregate trades list
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/aggTrades?symbol="&symbol&"&limit="&intToStr(limit))

proc candlesticks*(symbol:string, interval:CandlestickInterval, limit:int16 = 500, startTime:int32, endTime:int32): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit)&"&startTime="&intToStr(startTime)&"&endTime="&intToStr(endTime))

proc candlesticks*(symbol:string, interval:CandlestickInterval, limit:int16 = 500, startTime:int32): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit)&"&startTime="&intToStr(startTime))

proc candlesticks*(symbol:string, interval:CandlestickInterval, limit:int16 = 500, endTime:int32): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit)&"&endTime="&intToStr(endTime))

proc candlesticks*(symbol:string, interval:CandlestickInterval, limit:int16 = 500): (int, JsonNode) =
  # Kline/Candlestick data
  assert((limit > 0) and (limit <= 500), "Invalid limit value: "&intToStr(limit)&"|\nMin 1, Max 500.")

  getWrapper(api_endpoint&"/v1/klines?symbol="&symbol&"&interval="&intToStr(0)&"&limit="&intToStr(limit))

proc ticker24hStats*(symbol:string): (int, JsonNode) =
  # 24hr ticker price change statistics
  getWrapper(api_endpoint&"/v1/ticker/24hr?symbol="&symbol)

proc ticker24hStats*: (int, JsonNode) =
  # 24hr ticker price change statistics
  getWrapper(api_endpoint&"/v1/ticker/24hr")

proc tickerPrice*(symbol:string): (int, JsonNode) =
  # Symbol price ticker
  getWrapper(api_endpoint&"/v1/ticker/price?symbol="&symbol)

proc tickerPrice*: (int, JsonNode) =
  # Symbol price ticker
  getWrapper(api_endpoint&"/v1/ticker/price")

proc orderBookTicker*(symbol:string): (int, JsonNode) =
  # Symbol order book ticker
  getWrapper(api_endpoint&"/v1/ticker/bookTicker?symbol="&symbol)

proc orderBookTicker*: (int, JsonNode) =
  # Symbol order book ticker
  getWrapper(api_endpoint&"/v1/ticker/bookTicker")


# Account Endpoints
