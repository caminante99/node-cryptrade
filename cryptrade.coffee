#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
{Petri, common} = require 'petri'
Twitter          = require 'mtwitter'
eyes             = require 'eyes'
ROOT             = require('./trader').toString()
credentials      = require './credentials'

twit             = new Twitter credentials

{pretty, repeat, every, pick, sha1} = common
log = console.log 

POOL_SIZE = 6

config =

  traders: 2

  keywords: [
    'bitcoins'
    'bitcoin'
    '#bitcoin'
    'btc'
    '$btc'
    '#btc'
    'cryptocurrency'
    'cryptocurrencies'
    'mtgox'
    'bitstamp'
  ]

  geekdaq:
    server: 'geekdaq'
    updateInterval: 50
    commissions:
      buy: 0.10
      sell: 0.10
    tickers: [ 'BTC' ]

  balance: 100000000


Petri ->

  log """                                        
\t,---.               |                  |     
\t|    ,---.,   .,---.|--- ,---.,---.,---|,---.
\t|    |    |   ||   ||    |    ,---||   ||---'
\t`---'`    `---||---'`---'`    `---^`---'`---'
\t          `---'|                       
\t                      Cryptocurrency Trading   

  """

  # storage for trading models
  pool = {}
  pool[ROOT.toString()] = 1

  # Initialization of the trading pool
  @spawn() for i in [0...config.traders]

  balance = 100000

  @on 'exit', =>
    log "Trader exited"
    @spawn()

  @on 'ready', (onComplete) ->
    log "Trader ready, configuring.."
    onComplete
      src: pick pool
      balance: balance * 0.1
      portfolio: {}
      history: []
      geekdaq: config.geekdaq

  @on 'data', (reply, src, msg) ->
    id = sha1 src
    name = id[-4..] + id[..4]
    switch msg.cmd
      when 'log'
        console.log "Trader (#{name}): #{msg.msg}"
      when 'results'
        pool[src] = msg.balance
      else
        console.log "Trader (#{name}): unknow cmd #{pretty msg}"
    #agent.source = source
    # store the agent
    # if fork: do something

  every 3.sec =>

    log "Cryptrade: broadcasting news"

    news = twitter: {}

    for keyword in config.keywords
      news.twitter[keyword] = Math.round Math.random 10

    @broadcast news