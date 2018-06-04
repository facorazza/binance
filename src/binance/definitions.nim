#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#


type
  SymbolStatus {.pure.} = enum
    PreTrading = "PRE_TRADING",
    Trading = "TRADING",
    PostTrading = "POST_TRADING",
    EndOfDay = "END_OF_DAY",
    Halt = "HALT",
    AuctionMatch = "AUCTION_MATCH",
    Break = "BREAK"

type
  SymbolType {.pure.} = enum
    Spot = "SPOT"

type
  OrderStatus {.pure.} = enum
    New = "NEW",
    PartiallyFilled = "PARTIALLY_FILLED",
    Filled = "FILLED",
    Canceled = "CANCELED",
    PendingCancel = "PENDING_CANCEL", # Currently unused
    Rejected = "REJECTED",
    Expired = "EXPIRED"

type
  OrderType {.pure.} = enum
    Limit = "LIMIT",
    Market = "MARKET",
    StopLoss = "STOP_LOSS",
    StopLossLimit = "STOP_LOSS_LIMIT",
    TakeProfit = "TAKE_PROFIT",
    TakeProfitLimit = "TAKE_PROFIT_LIMIT",
    LimitMaker = "LIMIT_MAKER"

type
  OrderSide {.pure.} = enum
    Buy = "BUY",
    Sell = "SELL"

type
  TimeInForce {.pure.} = enum
    GoodTillCanceled = "GTC",
    ImmediateOrCancel = "IOC",
    FillOrKill = "FOK"

type
  CandlestickInterval {.pure.} = enum
    CandlestickInterval1Minute = "1m",
    CandlestickInterval3Minutes = "3m",
    CandlestickInterval5Minutes = "5m",
    CandlestickInterval15Minutes = "15m",
    CandlestickInterval30Minutes = "30m",
    CandlestickInterval1Hour = "1h",
    CandlestickInterval2Hours = "2h",
    CandlestickInterval4Hours = "4h",
    CandlestickInterval6Hours = "6h",
    CandlestickInterval8Hours = "8h",
    CandlestickInterval12Hours = "12h",
    CandlestickInterval1Day = "1d",
    CandlestickInterval3Days = "3d",
    CandlestickInterval1Week = "1w",
    CandlestickInterval1Month = "1M"

type
  RateLimitTypes {.pure.} = enum
    Requests = "REQUESTS",
    Orders = "ORDERS"

type
  RateLimitIntervals {.pure.} = enum
    Second = "SECOND",
    Minute = "MINUTE",
    Day = "DAY"

type
  ResponseType {.pure.} = enum
    Ack = "ACK",
    Result = "RESULT",
    Full = "FULL"
