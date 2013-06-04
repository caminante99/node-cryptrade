

module.exports = (options={}) ->

  {failure, alert, success, info, debug}  = @logger
  emit = @emit
  source = @source

  path                 = require 'path'
  colors               = require 'colors'
  geekdaq              = require 'geekdaq'
  {mutable, clone}     = require 'evolve'
  petri                = require 'petri'
 
  {P, copy, pretty, round2, round3, randInt}    = petri.common
  byluck = P

  repeat = (t,f) -> setInterval f, t
  wait  = (t) -> (f) -> setInterval f, t

  warn = alert # I should open an issue for this - 'alert' really sucks

  # Errors have a cost
  penalty = 10000
  ERR = petri.errors (value, msg) -> penalty -= value ; msg

  #demoDir = path.normalize "#{__dirname}/../examples/trading/"
  #console.log "modules: #{demoDir}"
  Market = require 'market'

  ################
  # DATA SOURCES #
  ################
  news =
    headlines: ->
      for i in [1..5]
        if P 0.1
          "Bitcoin is crashing"
        else if P 0.8
          "What is Bitcoin?"
        else
          "Bitcoin on the rise"


  #################
  # ROBOT ACCOUNT #
  #################
  account =
    username : 'test'
    portfolio: options.portfolio ? {}
    balance  : options.balance   ? 0
    history  : options.history   ? []

  ########################
  # VIRTUAL STOCK MARKET #
  ####################################################################
  # For the moment we use a random market which is just for debug    #
  # since it doesn't follow any realistic model/rules                #
  ####################################################################
  market = new Market 
    server        : options.geekdaq.server
    updateInterval: options.geekdaq.updateInterval
    commissions   : options.geekdaq.commissions
    tickers       : options.geekdaq.tickers
    accounts      : [ account ]
  
  # LISTEN AND PRINT DEBUG EVENTS FROM THE VIRTUAL MARKET
  market.on 'debug', (msg) => debug msg.grey

 
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

  # LISTEN TO ERRORS, APPLY PENALTY FOR CRITICAL ERRORS
  # BY REMOVING ##MO#N#E#Y## ENERGY FROM THE AGENT'S BALANCE
  market.on 'error', (code, msg) =>
    @transfert Model[code]
    #market.transfert account.username, energyModel[code]
    alert msg.red

  market.start()

  # we count the iterations: this is used by the decimation process
  iterations = 0

  do constrain = =>
    debug "constraining agent.."
    wait(options.interval) constrain

  # an iteration 
  iterations = 0
  do main = =>

    ##########
    # ENERGY #
    ##########
    # Comptue how much energy should be put in the agent



    # SHARING #
    # energy can be shared among individuals



    #############################
    # TAXES AND RANDOM EXPENSES #
    ################################################################
    # By simulating random expenses and taxes, we give no "rest"   #
    # to the agents, so they will always have to seek new money    #
    # without limit (wealthy agents will have more taxes/expenses) #
    ################################################################
    
    ###################
    # WORLD WIDE NEWS #
    ###################
    latestNews = news.headlines()

    ################
    # REPRODUCTION #
    ################################################################
    # Altough all the code can be mutated, since we choose to have #
    # the environment and the algorithm in the same source file,   #
    # we use the 'mutable' tag to only mutate parts of the code    #
    ################################################################

    if ++iterations >= options.iterations #byluck mutable 0.50
      if @transfert Model.FORKING
        debug "reproducing"
        clone 
          src       : @source
          ratio     : 0.01
          iterations:  2
          onComplete: (src) =>
            debug "sending fork event"
            performance = 100
            @emit fork:
              src: src
              performance: performance
            wait(200) -> 
              warn "exiting after fork"
              process.exit 0
      else
        warn "exiting immediately after #{iterations} iterations"
        process.exit 0
    
    ###################
    # BUY/SELL STOCKS #
    ###################
    orders = []
    if byluck mutable 1.0
      if @transfert Model.BUY

        $BTC = market.ticker options.geekdaq.tickers[0]

        # AVALAIBLE VOLUME
        orders.push
          type   : if mutable(byluck 0.5) then 'buy' else 'sell'
          ticker : $BTC
          price  : $BTC.price
          amount : mutable 10000


    # ask the market to execute our orders
    market.execute 
      username: account.username
      orders: orders
      onComplete: (err) => wait(options.interval) main
  {}
