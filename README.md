# Binance API

_This is still a work in progress, but you are welcome to contribute_

TODO:
- Withdrawal API
- Websocket streams

## Installation
`nimble install binance`

## Setup
Open a Binance account and create an API key.  
Create two directories called `logs` and `keys` in the same directory where you'll be executing the program from. Inside `keys` create two files called `api.key` and `secret.key`. Save your generated API key in the former and you secret key in the latter.

## Example
```
import binance

const apiKey = slurp("./keys/api.key")
const secretKey = slurp("./keys/secret.key")
let b = newBinanceApi(apiKey, secretKey)


if b.ping():
  echo "The server is online."
else:
  echo "The server is offline."
```

## Contributing
Please, do!
