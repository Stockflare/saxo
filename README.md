# Saxo

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'saxo', github: 'stockflare/saxo', tag: '0.1.0'
```

## Usage

This Gem wraps all interactions with The [Saxo](https://www.trade.it/documentation) API into a format that is convenient for our own internal APIs.

Once installed all Saxo actions are objects within the `Saxo` module.  Each object is initialized with the parameters required for the Saxo call and has one `call` method to execute the communications with Saxo.  All objects return the result of the Saxo interaction in a `response` attribute that supports `to_h`

It is expected that most Stockflare use cases will only use the `response.payload` as this is a parsed version of the Saxo response suitable for Stockflare and it is this output that is tested.  For convenience the `response.payload` is delivered as a `Hashie::Mash` to allow for method based access, for instance you can can access the status of the call by using `response.payload.status`.

Additionally a `response.raw` is provided that contains the raw Saxo response.  This is provided for development and debug purposes only.  Upstream users should only rely on the `response.payload` and `response.messages`.  This will allow us to deal with minor breaking changes in the Saxo API (which is currently in QA) without having to make code changes in upstream users.

All Error cases are handled by raising a subclass of `Trading::Errors::TradingException`, this object exposes a number of attributes that can you can `to_h` to the consumer.

### Configuration Values

Two attributes need to be set

```
Saxo.configure do |config|
  config.api_uri = ENV['SAXO_BASE_URI']
  config.app_key = ENV['SAXO_APP_KEY']
end
```

### Brokers

We current support the following broker symbols
```
{
  td: 'TD',
  etrade: 'Etrade',
  scottrade: 'Scottrade',
  fidelity: 'Fidelity',
  schwab: 'Schwab',
  trade_station: 'TradeStation',
  robinhood: 'Robinhood',
  options_house: 'OptionsHouse',
  ib: 'IB',
  tradier: 'Tradier',
  dummy: 'Dummy'
}
```

### Order Actions

```
{
  buy: 'buy',
  sell: 'sell',
  buy_to_cover: 'buyToCover',
  sell_short: 'sellShort'
}
```

### Price Types

```
{
  market: 'market',
  limit: 'limit',
  stop_market: 'stopMarket',
  stop_limit: 'stopLimit'
}
```

### Order Expirations
```
{
  day: 'day',
  gtc: 'gtc'
}
```

Note that the test user does not support type `:gtc`

### Saxo::User::Link

Get a Users oAuth token

Example Call:

```
Saxo::User::Link.new(
  username: username,
  password: password,
  broker: broker
).call.response
```

Successful response:

```
{ raw:   { 'longMessages' => nil,
           'shortMessage' => 'User succesfully linked',
           'status' => 'SUCCESS',
           'token' => '86f1546f42a44f17a60d59937b261397',
           'userId' => '0bf145522335273053ca',
           'userToken' =>
    '6j6rx91SaeuYsHHwxcW%2BsUGn5ZN%2FvfTsmWGLGnr4oPI%3DFahzxUqAhkLGhOyR%2FpxgKw%3D%3D' },
  status: 200,
  payload:   { type: 'success',
               user_id: '0bf145522335273053ca',
               user_token:     '6j6rx91SaeuYsHHwxcW%2BsUGn5ZN%2FvfTsmWGLGnr4oPI%3DFahzxUqAhkLGhOyR%2FpxgKw%3D%3D' },
  messages: ['User succesfully linked'] }
```

Link failure will raise a `Trading::Errors::LoginException` with the following attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Login',
  messages: ['Check your username and password and try again.'] }
```


### Saxo::User::Login

example call:

```
Saxo::User::Login.new(
  user_id: user_id,
  user_token: user_token
).call.response
```

Successful response without security question:

```
{ raw:   { 'accounts' =>
    [{ 'account_number' => 'brkAcct1',
       'name' => 'Individual Account (XX878977484)' }],
           'longMessages' => nil,
           'shortMessage' => 'Credential Successfully Validated',
           'status' => 'SUCCESS',
           'token' => 'ce15f0eb7a9a473eb40687cdf3150479' },
  status: 200,
  payload:   { type: 'success',
               token: 'ce15f0eb7a9a473eb40687cdf3150479',
               accounts:     [{"account_number"=>"brkAcct1",
                "name"=>"Individual Account (XX878977484)",
                "cash"=>nil,
                "power"=>nil,
                "day_return"=>nil,
                "day_return_percent"=>nil,
                "total_return"=>nil,
                "total_return_percent"=>nil,
                "value"=>nil}] },
  messages: ['Credential Successfully Validated'] }
```

Successful response requesting security question

```
{ raw:   { 'challengeImage' => nil,
           'errorFields' => nil,
           'informationLongMessage' => nil,
           'informationShortMessage' => 'Send',
           'informationType' => 'SECURITY_QUESTION',
           'longMessages' => nil,
           'securityQuestion' => "What is your mother's maiden name",
           'securityQuestionOptions' => [],
           'shortMessage' => nil,
           'status' => 'INFORMATION_NEEDED',
           'token' => '7994ee5d86bc4a168d450f268a7cd17b' },
  status: 200,
  payload:   { type: 'verify',
               challenge: 'question',
               token: '7994ee5d86bc4a168d450f268a7cd17b',
               data: { question: "What is your mother's maiden name", answers: [] } },
  messages: [] }
```

Successful response requesting image style security question

The `encoded` image is Base64 encoded

```
{ raw:   { 'challengeImage' =>
    'iVBORw0KGgoAAAANSUhEUgAAAc4AA....',
           'errorFields' => nil,
           'informationLongMessage' => nil,
           'informationShortMessage' => nil,
           'informationType' => 'SECURITY_QUESTION',
           'longMessages' => nil,
           'securityQuestion' =>
    'Two card index numbers are shown in the image below. Please enter them without spaces to proceed.',
           'securityQuestionOptions' => [],
           'shortMessage' => nil,
           'status' => 'INFORMATION_NEEDED',
           'token' => '99db99b421df419c9d02907dff146e2c' },
  status: 200,
  payload:   { type: 'verify',
               challenge: 'image',
               token: '99db99b421df419c9d02907dff146e2c',
               data:     { encoded:       'iVBORw0KGgoAAAANSUhEUgAAAc4AAAA....' } },
  messages: [] }
```

Login failure will raise a `Trading::Errors::LoginException` with the following attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Login',
  messages: ['Check your username and password and try again.'] }
```

### Saxo::User::Verify

Example Call

```
Saxo::User::Verify.new(
  token: <token from Saxo::User::Login>,
  answer: answer
).call.response
```

All success responses are identical to `Saxo::User::Login`

If the user provides a bad answer then the response will be a success asking another question.

A failure will raise a `Trading::Errors::LoginException` with the similar attributes:
```
{ type: :error,
  code: 500,
  description: 'Could Not Complete Your Request',
  messages: ['Your session has expired. Please try again'] }
```

### Saxo::User::Account

Get the current financial state of an account

Example Call

```
Saxo::User::Account.new(
  token: <token from Saxo::User::Login>,
  account_number: account_number
).call.response
```

Example response

```
{:raw=>
  {"availableCash"=>1204.06,
   "buyingPower"=>2408.12,
   "dayAbsoluteReturn"=>78.42,
   "dayPercentReturn"=>3.25,
   "longMessages"=>nil,
   "shortMessage"=>"Account Overview successfully fetched",
   "status"=>"SUCCESS",
   "token"=>"3e40016b846f4d20a4b7102a1949f893",
   "totalAbsoluteReturn"=>14486.67,
   "totalPercentReturn"=>22.84,
   "totalValue"=>76489.23},
 :status=>200,
 :payload=>
  {"type"=>"success",
   "cash"=>1204.06,
   "power"=>2408.12,
   "day_return"=>78.42,
   "day_return_percent"=>3.25,
   "total_return"=>14486.67,
   "total_return_percent"=>22.84,
   "value"=>22.84,
   "token"=>"3e40016b846f4d20a4b7102a1949f893"},
 :messages=>["Account Overview successfully fetched"]}
```


A failure will raise a `Trading::Errors::LoginException` with the similar attributes:
```
{ type: :error,
  code: 500,
  description: 'Could Not Complete Your Request',
  messages: ['Your session has expired. Please try again'] }
```

### Saxo::User::Logout

Example call:
```
Saxo::User::Logout.new(
  token: <token from previous login>
).call.response
```

Successful logout response

```
{ raw: { 'longMessages' => nil, 'shortMessage' => nil, 'status' => 'SUCCESS', 'token' => '765b7e4056334a27a9b65033b889878e' },
  status: 200,
  payload: { type: 'success', token: '765b7e4056334a27a9b65033b889878e', accounts: nil },
  messages: [] }
```

Failed Logout will raise a `Trading::Errors::LoginException` with similar attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Complete Your Request',
  messages: ['Your session has expired. Please try again'] }
```

### Saxo::User::Refresh

Used to stop a users token from expiring, does not send you a new token

Example Call:

```
Saxo::User::Refresh.new(
  token: token
).call.response
```

Successful Response:

```
{ raw:   { 'longMessages' => nil,
           'shortMessage' => nil,
           'status' => 'SUCCESS',
           'token' => 'ed34e745c7714be6936370cb1026f33e' },
  status: 200,
  payload:   { type: 'success',
               token: 'ed34e745c7714be6936370cb1026f33e',
               accounts: nil },
  messages: [] }
```

Failed Logout will raise a `Trading::Errors::LoginException` with similar attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Complete Your Request',
  messages: ['Your session has expired. Please try again'] }
```

### Saxo::Position::Get

Example Call

```
Saxo::Positions::Get.new(
  token: token,
  account_number: account_number
).call.response
```

Successful response:

```
{ raw:   { 'currentPage' => 0,
           'longMessages' => nil,
           'positions' =>
    [{ 'costbasis' => 103.34,
       'holdingType' => 'LONG',
       'lastPrice' => 112.34,
       'quantity' => 1.0,
       'symbol' => 'AAPL',
       'symbolClass' => 'EQUITY_OR_ETF',
       'todayGainLossDollar' => 3.0,
       'todayGainLossPercentage' => 0.34,
       'totalGainLossDollar' => 9.0,
       'totalGainLossPercentage' => 1.2 },
      ...
     ],
           'shortMessage' => 'Position successfully fetched',
           'status' => 'SUCCESS',
           'token' => 'd3e72226aad646cea9e2d6177bd50953',
           'totalPages' => 1 },
  status: 200,
  payload:   { positions:     [{ quantity: 1, price: 103.34, ticker: 'AAPL', instrument_class: 'equity_or_etf', change: 9.0, holding: 'long' },
                               { quantity: -1, price: 103.34, ticker: 'IBM', instrument_class: 'equity_or_etf', change: 9.0, holding: 'short' },
                               { quantity: 1, price: 103.34, ticker: 'GE', instrument_class: 'equity_or_etf', change: 9.0, holding: 'short' },
                               { quantity: 1, price: 103.34, ticker: 'MSFT', instrument_class: 'equity_or_etf', change: 9.0, holding: 'long' }],
               pages: 1,
               page: 0,
               token: d3e72226aad646cea9e2d6177bd50953},
  messages: ['Position successfully fetched'] }
```

Failed Call will raise a `Trading::Errors::PositionException` with similar attributes:

```
{ type: :error,
  code: 500,
  description: 'Could Not Fetch Your Positions',
  messages:   ['The account foooooobaaarrrr is not valid or not active anymore.'] }
```

### Saxo::Order::Preview

Example call:

```
Saxo::Order::Preview.new(
  token: token,
  account_number: account_number,
  order_action: :buy,
  quantity: 10,
  ticker: 'aapl',
  price_type: :market,
  expiration: :day
).call.response
```

Successful response:

```
{ raw:   { 'ackWarningsList' => [],
           'longMessages' => nil,
           'orderDetails' =>
    { 'orderSymbol' => 'aapl',
      'orderAction' => 'Buy',
      'orderQuantity' => 10.0,
      'orderExpiration' => 'Day',
      'orderPrice' => 'Market',
      'orderValueLabel' => 'Estimated Cost',
      'orderMessage' => 'You are about to place a market order to buy AAPL',
      'lastPrice' => '19.0',
      'bidPrice' => '18.0',
      'askPrice' => '22.0',
      'timestamp' => 'Fri Feb 12 08:51:25 EST 2016',
      'estimatedOrderValue' => 25.0,
      'estimatedTotalValue' => 28.5,
      'buyingPower' => 1234.0,
      'longHoldings' => 12.0,
      'estimatedOrderCommission' => 3.5 },
           'orderId' => 1,
           'shortMessage' => nil,
           'status' => 'REVIEW_ORDER',
           'token' => '140784ef96214a5186041abebdfe038a',
           'warningsList' => [] },
  status: 200,
  payload:   { 'type' => 'review',
               'ticker' => 'aapl',
               'order_action' => :buy,
               'quantity' => 10,
               'expiration' => :day,
               'price_label' => 'Market',
               'value_label' => 'Estimated Cost',
               'message' => 'You are about to place a market order to buy AAPL',
               'last_price' => 19.0,
               'bid_price' => 18.0,
               'ask_price' => 22.0,
               'timestamp' => 1455285085,
               'buying_power' => 1234.0,
               'estimated_commission' => 3.5,
               'estimated_value' => 25.0,
               'estimated_total' => 28.5,
               'warnings' => [],
               'must_acknowledge' => [],
               'amount' => nil,
               'token' => '140784ef96214a5186041abebdfe038a' },
  messages: [] }

```

Any messages in  `payload.warnings` must be displayed to the user.

any messages in `payload.must_acknowledge` must be shown to the user with check boxes that they must acknowledge

### Saxo::Order::Place

Place an order previously reviewed by `Saxo::Order::Preview`

Example Call

```
Saxo::Order::Place.new(
  token: preview_token
).call.response
```

Example response

```
{ raw:   { 'broker' => 'your broker',
           'confirmationMessage' =>
    'Your order message 4049c988b1422d52217af9 to buy 10 shares of aapl at market price has been successfully transmitted to your broker at 12/02/16 1:19 PM EST.',
           'longMessages' => ['Transmitted succesfully to your broker'],
           'orderInfo' =>
    { 'universalOrderInfo' =>
      { 'action' => 'buy',
        'quantity' => '10',
        'symbol' => 'aapl',
        'price' => { 'type' => 'market' },
        'expiration' => 'day' },
      'action' => 'Buy',
      'quantity' => 10,
      'symbol' => 'aapl',
      'price' =>
      { 'type' => 'Market',
        'last' => 19.0,
        'bid' => 18.0,
        'ask' => 22.0,
        'timestamp' => '2016-02-12T18:19:20Z' },
      'expiration' => 'Good For The Day' },
           'orderNumber' => '4049c988b1422d52217af9',
           'shortMessage' => 'Order Successfully Submitted',
           'status' => 'SUCCESS',
           'timestamp' => '12/02/16 1:19 PM EST',
           'token' => 'dc2427db16d244e7967857cc140cf011' },
  status: 200,
  payload:   { 'type' => 'success',
               'ticker' => 'aapl',
               'order_action' => :buy,
               'quantity' => 10,
               'expiration' => :day,
               'price_label' => 'Market',
               'message' =>
    'Your order message 4049c988b1422d52217af9 to buy 10 shares of aapl at market price has been successfully transmitted to your broker at 12/02/16 1:19 PM EST.',
               'last_price' => 19.0,
               'bid_price' => 18.0,
               'ask_price' => 22.0,
               'price_timestamp' => 1_455_301_160,
               'timestamp' => 1_329_416_340,
               'order_number' => '4049c988b1422d52217af9',
               'token' => 'dc2427db16d244e7967857cc140cf011' },
  messages: ['Order Successfully Submitted'] }
```

Failed Call will raise a `Trading::Errors::OrderException` with similar attributes:

```
{:type=>:error,
 :code=>500,
 :broker_code=>600,
 :description=>"Could Not Complete Your Request",
 :messages=>["Your session has expired. Please try again"]}
```

## Saxo::Order::Status

Get the status of all user orders or get the status of a single order

Example Call

```
Saxo::Order::Place.new(
  token: preview_token,
  account_number,
  order_number
).call.response
```

Omit the `order_number` to get the status of all orders for the account

Example response
```
{:raw=>
  {"accountNumber"=>"brkAcct1",
   "longMessages"=>nil,
   "orderStatusDetailsList"=>
    [{"groupOrderId"=>nil,
      "groupOrderType"=>"null",
      "groupOrders"=>[],
      "orderExpiration"=>"DAY",
      "orderLegs"=>
       [{"action"=>"BUY",
         "filledQuantity"=>0,
         "fills"=>[],
         "orderedQuantity"=>5000,
         "priceInfo"=>
          {"bracketLimitPrice"=>0.0,
           "conditionFollowPrice"=>nil,
           "conditionPrice"=>0.0,
           "conditionSymbol"=>nil,
           "conditionType"=>nil,
           "initialStopPrice"=>0.0,
           "limitPrice"=>0.0,
           "stopPrice"=>0.0,
           "trailPrice"=>0.0,
           "triggerPrice"=>0.0,
           "type"=>"MARKET"},
         "symbol"=>"CMG"}],
      "orderNumber"=>"123",
      "orderStatus"=>"OPEN",
      "orderType"=>"EQ"},
     {"groupOrderId"=>nil,
      "groupOrderType"=>"null",
      "groupOrders"=>[],
      "orderExpiration"=>"GTC",
      "orderLegs"=>
       [{"action"=>"SELL_SHORT",
         "filledQuantity"=>6000,
         "fills"=>
          [{"price"=>123.45,
            "quantity"=>6000,
            "timestamp"=>"01/01/15 12:34 PM EST"}],
         "orderedQuantity"=>10000,
         "priceInfo"=>
          {"bracketLimitPrice"=>0.0,
           "conditionFollowPrice"=>nil,
           "conditionPrice"=>0.0,
           "conditionSymbol"=>nil,
           "conditionType"=>nil,
           "initialStopPrice"=>0.0,
           "limitPrice"=>67.89,
           "stopPrice"=>123.45,
           "trailPrice"=>0.0,
           "triggerPrice"=>0.0,
           "type"=>"STOP_LIMIT"},
         "symbol"=>"MCD"}],
      "orderNumber"=>"456",
      "orderStatus"=>"PART_FILLED",
      "orderType"=>"EQ"}],
   "shortMessage"=>"Order statuses successfully fetched",
   "status"=>"SUCCESS",
   "token"=>"bba1c52b409245afb86919b9c3d7b898"},
 :status=>200,
 :payload=>
 {"type"=>"success",
  "orders"=>
   [{"ticker"=>"cmg",
     "order_action"=>:buy,
     "filled_quantity"=>0,
     "filled_price"=>0.0,
     "order_number"=>"123",
     "quantity"=>5000,
     "expiration"=>:day,
     "status"=>:open},
    {"ticker"=>"mcd",
     "order_action"=>:sell_short,
     "filled_quantity"=>6000,
     "filled_price"=>123.45,
     "order_number"=>"456",
     "quantity"=>10000,
     "expiration"=>:gtc,
     "status"=>:part_filled}],
  "token"=>"3384aeb24c2143f5b78ee3e1311a40eb"}
```
## Saxo::Order::Cancel

Cancel an unfulfilled order.  The payload is identical to `Saxo::Order::Status` in that it return the order status of the cancelled order

Example Call

```
Saxo::Order::Cancel.new(
  token: preview_token,
  account_number,
  order_number
).call.response
```


Example response
```
{:raw=>
  {"accountNumber"=>"brkAcct1",
   "longMessages"=>nil,
   "orderStatusDetailsList"=>
    [{"groupOrderId"=>nil,
      "groupOrderType"=>"null",
      "groupOrders"=>[],
      "orderExpiration"=>"GTC",
      "orderLegs"=>
       [{"action"=>"BUY",
         "filledQuantity"=>0,
         "fills"=>[],
         "orderedQuantity"=>275000,
         "priceInfo"=>
          {"bracketLimitPrice"=>0.0,
           "conditionFollowPrice"=>nil,
           "conditionPrice"=>0.0,
           "conditionSymbol"=>nil,
           "conditionType"=>nil,
           "initialStopPrice"=>0.0,
           "limitPrice"=>0.0,
           "stopPrice"=>0.0,
           "trailPrice"=>0.0,
           "triggerPrice"=>0.0,
           "type"=>"MARKET"},
         "symbol"=>"FTFY"}],
      "orderNumber"=>"456",
      "orderStatus"=>"PENDING_CANCEL",
      "orderType"=>"EQ"}],
   "shortMessage"=>"Order statuses successfully fetched",
   "status"=>"SUCCESS",
   "token"=>"d9c45bb6223f425c865ed7c88042ad1f"},
 :status=>200,
 :payload=>
  {"type"=>"success",
   "orders"=>
    [{"ticker"=>"ftfy",
      "order_action"=>:buy,
      "filled_quantity"=>0,
      "filled_price"=>0.0,
      "order_number"=>"456",
      "quantity"=>275000,
      "expiration"=>:gtc,
      "status"=>:pending_cancel}],
   "token"=>"d9c45bb6223f425c865ed7c88042ad1f"},
 :messages=>["Order statuses successfully fetched"]}
```


### Saxo::Instrument::Details

Saxo does not in fact suppoert this call and the result is synthesised by calling the Stockflare api-price.  This call exists to allow for a identical trading flow across all broker integrations.

Example Call

```
Saxo::Order::Cancel.new(
  token: preview_token,
  ticker: "aapl"
).call.response
```

Example response

```
{:raw=>{"aapl"=>{"la"=>97.21, "t"=>"2016-06-14T14:26:02-05:00", "c"=>-0.13, "b"=>97.22, "a"=>97.23, "h"=>98.47, "l"=>96.75, "v"=>2414084}},
 :status=>200,
 :payload=>
  {"type"=>"success",
   "broker_id"=>nil,
   "ticker"=>"aapl",
   "last_price"=>97.21,
   "bid_price"=>97.22,
   "ask_price"=>97.23,
   "order_size_max"=>10000.0,
   "order_size_min"=>1.0,
   "order_size_step"=>1.0,
   "allow_fractional_shares"=>false,
   "timestamp"=>1465929667,
   "warnings"=>[],
   "must_acknowledge"=>[],
   "token"=>"873ab208e937460fa8b84ebe68c364d8"},
 :messages=>[]}
```
