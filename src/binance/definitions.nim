#
#          Nim's Unofficial Library
#        (c) Copyright 2018 Federico A. Corazza
#
#    See the file "LICENSE", included in this
#    distribution, for details about the copyright.
#


type
  SymbolStatus= enum
    PreTrading = "PRE_TRADING",
    Trading = "TRADING",
    PostTrading = "POST_TRADING",
    EndOfDay = "END_OF_DAY",
    Halt = "HALT",
    AuctionMatch = "AUCTION_MATCH",
    Break = "BREAK"

type
  SymbolType = enum
    Spot = "SPOT"

type
  OrderStatus = enum
    New = "NEW",
    PartiallyFilled = "PARTIALLY_FILLED",
    Filled = "FILLED",
    Canceled = "CANCELED",
    PendingCancel = "PENDING_CANCEL", # Currently unused
    Rejected = "REJECTED",
    Expired = "EXPIRED"

type
  OrderTypes = enum
    Limit = "LIMIT",
    Market = "MARKET",
    StopLoss = "STOP_LOSS",
    StopLossLimit = "STOP_LOSS_LIMIT",
    TakeProfit = "TAKE_PROFIT",
    TakeProfitLimit = "TAKE_PROFIT_LIMIT",
    LimitMaker = "LIMIT_MAKER"

type
  OrderSide = enum
    Buy = "BUY",
    Sell = "SELL"

type
  TimeInForce = enum
    GoodTillCanceled = "GTC",
    ImmediateOrCancel = "IOC",
    FillOrKill = "FOK"

type
  CandlestickInterval = enum
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
  RateLimitTypes = enum
    Requests = "REQUESTS",
    Orders = "ORDERS"

type
  RateLimitIntervals = enum
    Second = "SECOND",
    Minute = "MINUTE",
    Day = "DAY"
