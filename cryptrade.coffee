#!/usr/bin/env coffee
# STANDARD LIB
{inspect}        = require 'util'

# THIRD PARTIES
timmy            = require 'timmy'
{System, common} = require 'substrate'
Twitter          = require 'mtwitter'

credentials      = require './credentials'

twit             = new Twitter credentials

{pretty} = common

POOL_SIZE = 6

system = System

  bootstrap: [ require './trader' ]

  workersByMachine: 1 # common.NB_CORES
  decimationTrigger: 10

  config: (agent) ->

    agent.performance ?= 0

    balance: 100000000
    
    portfolio: {}
    history: []

    interval: 1.sec
    iterations: 10

    geekdaq:
      server: 'geekdaq'
      updateInterval: 50
      commissions:
        buy: 0.10
        sell: 0.10
      tickers: [ 'BTC' ]
