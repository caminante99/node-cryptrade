

module.exports = (options={}) ->

  {failure, warn, success, info, debug}  = @logger
  emit = @emit
  src = @src
  onMsg = @on

  path                 = require 'path'
  colors               = require 'colors'
  geekdaq              = require 'geekdaq'
  {mutable, clone}     = require 'evolve'
  petri                = require 'petri'
  Market = require 'market'
   
  {P, copy, pretty, round2, round3, randInt, every, after} = petri.common
  byluck = P

  # Errors have a cost
  penalty = 10000
  ERR = petri.errors (value, msg) -> penalty -= value ; msg

  #################
  # ROBOT ACCOUNT #
  #################
  account =
    username : 'test'
    portfolio: options.portfolio ? {}
    balance  : options.balance   ? 0
    history  : options.history   ? []

  market = new Market 
    server        : options.geekdaq.server
    updateInterval: options.geekdaq.updateInterval
    commissions   : options.geekdaq.commissions
    tickers       : options.geekdaq.tickers
    accounts      : [ account ]
  
  # LISTEN AND PRINT DEBUG EVENTS FROM THE VIRTUAL MARKET
  market.on 'debug', (msg) -> debug msg.grey

  stats = ->
    performance: 0
    balance: account.balance
 
  Model =

    # PENALTIES
    NOT_ENOUGH_MONEY: -5
    NOT_IN_PORTFOLIO: -10
    NOT_ENOUGH_SHARES: -20


    # COSTS
    FORKING: -10

    # COMMISSIONS
    BUY: -10
    SELL: -10

    # REWARDS
    BONUS: +10 # Bonus given after a benefit

  wasAbleToSpend = (amount) ->
    # don't consume when no more energy
    return no if (amount < 0) and (amount > account.balance)
    account.balance += amount
    yes


  # LISTEN TO ERRORS, APPLY PENALTY FOR CRITICAL ERRORS
  # BY REMOVING ##MO#N#E#Y## ENERGY FROM THE AGENT'S BALANCE
  market.on 'error', (code, msg) ->
    wasAbleToSpend Model[code]
    #market.transfert account.username, energyModel[code]
    warn msg.red

  market.start()

  every 2.sec -> 
    packet = stats()
    packet.cmd = 'results'
    emit packet

  after 30.sec process.exit

  after 10.sec -> clone 
    src       : src
    ratio     : 0.01
    iterations:  2
    onComplete: (fork) ->
      debug "sending fork"
      emit 
        cmd: 'fork'
        src: fork

  do trade = ->
    orders = []
    if byluck mutable 1.0
      if wasAbleToSpend Model.BUY
        $BTC = market.ticker options.geekdaq.tickers[0]
        orders.push
          type   : if mutable(byluck 0.5) then 'buy' else 'sell'
          ticker : $BTC
          price  : $BTC.price
          amount : mutable 10000
    market.execute 
      username: account.username
      orders: orders
      onComplete: (err) ->

        # check if the error is on our side or no
        if err
          options.balance -= 10

        after 1.sec trade