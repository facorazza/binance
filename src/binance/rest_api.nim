#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#

#import logging
import httpclient
import json
import strutils
import times

import hmac

include credentials


#[const verboseFormat: string = "[$datetime] $appName > $levelname: "
var cLog = newConsoleLogger(levelThreshold=lvlDebug, fmtStr=verboseFormat)
var fLog = newFileLogger("logs/rest-api.log", levelThreshold=lvlDebug, fmtStr=verboseFormat)
addHandler(cLog)
addHandler(fLog)]#


var client * = newHttpClient()

proc getWrapper *(endpoint:string): (int, JsonNode) =
  #info("GET: "&endpoint)
  let response = client.get(endpoint)
  #debug("Status code: "&response.status)
  if response.status == "200 OK":
    #debug("Body: "&response.body)
    return (200,  parseJson(response.body))
  (response.status.split(' ')[0].parseInt, newJNull())
