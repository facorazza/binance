#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#

include binance/definitions

type
  BinanceApi = ref object
    apiKey:string
    secretKey:string
    #recvWindow:int32
    #timeInForce:TimeInForce
    #responseType:ResponseType

proc newBinanceApi*(apiKey:string="", secretKey:string="", recvWindow:int32=5000, timeInForce:TimeInForce=TimeInForce.GoodTillCanceled, responseType:ResponseType=ResponseType.Ack): BinanceApi =
  new(result)
  result.apiKey = apiKey
  result.secretKey = secretKey
  #result.recvWindow = recvWindow
  #result.timeInForce = timeInForce
  #result.responseType = responseType


include binance/rest_api
