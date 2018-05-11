# Binance API

_This is still a work in progress, but you are welcome to contribute_

TODO:
- Secure endpoints
- Websocket streams

## Installation
`nimble install binance`

## Setup
Open a Binance account and create an API key.  
Save the API key and the API secret respectively in the `credentials.nim` file.

## Contributing
Whenever creating a Pull Request, remember to ignore the `credentials.nim` file! If you want to be sure not to forget open the terminal in the main folder where the forked library is and type:  
`git update-index --assume-unchanged binance/credentials.nim`  
Now `credentials.nim` will be ignored automatically.
