#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'petri'
Twitter          = require 'mtwitter'
eyes             = require 'eyes'
trader           = require './trader'
credentials      = require './credentials'

twit             = new Twitter credentials

{pretty} = common
log = console.log 

POOL_SIZE = 6

config =

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

# money allocator
allocMoney = ->


  config.balance 

system = System

  bootstrap: [ trader ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10

  # callback called when a new agent is created
  config: (agent) ->
    log "Cryptrade.master.config: #{agent.id}"
    agent.performance ?= 0

    ##########################

    balance: allocMoney()
    
    portfolio: {}
    history: []

    interval: 1.sec
    iterations: 10

    geekdaq: config.geekdaq

  # called AFTER the agent has been removed from database,
  # and BEFORE a new agent is automatically spawned
  onExit: ({agent, code, signal}) ->
    log "Cryptrade.master.onExit: #{agent.id}"

  onFork: ({agent, fork}) ->
    log "Cryptrade.master.onFork: #{agent.id}"