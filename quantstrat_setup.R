#test file for tutorials on datacamp and
#https://quantstrattrader.wordpress.com/category/quantstrat/

library(quantstrat)

Sys.setenv(TZ = "UTC") #doesn't require any libraries
currency("USD")

initdate = "1999-01-01"
from = "2003-01-01"
to = "2015-12-31"

symbols = "CEMB"

getSymbols(symbols, from = from, to = to, src = "yahoo", adjust = TRUE)
stock(symbols, currency = "USD", multiplier = 1)

tradesize = 100000
initeq = 100000

strategy.st = portfolio.st = account.st = "firststrat"
rm.strat(strategy.st)

initPortf(portfolio.st, symbols = symbols, initDate = initdate, currency = "USD")
initAcct(account.st, portfolios = portfolio.st, initDate = initdate, currency = "USD", initEq = initeq)
initOrders(portfolio.st, initDate = initdate)
strategy(strategy.st, store = TRUE)

spy_sma = SMA(x = Cl(SPY), n = 200)
spy_rsi = RSI(price = Cl(SPY), n = 3)

add.indicator(strategy = strategy.st,
              name = "SMA",
              arguments = list(x = quote(Cl(mktdata)), n = 200),
              label = "SMA200"
              )

add.indicator(strategy = strategy.st,
              name = "SMA",
              arguments = list(x = quote(Cl(mktdata)), n = 50),
              label = "SMA50"
)

add.indicator(strategy = strategy.st,
              name = "RSI",
              arguments = list(price = quote(Cl(mktdata)), n = 3),
              label = "RSI_3"
)

#result = applyIndicators(strategy = strategy.st, mktdata = Cl(DATA))
#result = applyIndicators(strategy = strategy.st, mktdata = OHLC(DATA))

#HLC(CEMB["2017-05-25/2017-05-30"])


add.signal(strategy = strategy.st, name = "sigComparison",
           arguments = list(columns = c("SMA50","SMA200"), relationship = "gt"),
           label = "longfilter")

add.signal(strategy = strategy.st, name = "sigCrossover",
           arguments = list(columns = c("SMA50","SMA200"), relationship = "lt"),
           label = "filterexit")

add.signal(strategy = strategy.st, name = "sigThreshold",
           arguments = list(column = "DVO_2_126", relationship = "lt", threshold = 20, cross = FALSE),
           label = "longthreshold")

add.signal(strategy = strategy.st, name = "sigThreshold",
           arguments = list(column = "DVO_2_126", relationship = "gt", threshold = 80, cross = TRUE),
           label = "thresholdexit")

#result_w_sig = applySignals(strategy = strategy.st, mktdata = result)

add.signal(strategy = strategy.st, name = "sigFormula",
           arguments = list(formula = "longfilter & longthreshold", cross = TRUE),
           label = "longentry")

add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "thresholdexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")

add.rule(strategy.st, name = "ruleSignal", 
         arguments=list(sigcol = "longentry", sigval = TRUE, orderqty = 1,
                        ordertype = "market", orderside = "long",
                        replace = FALSE, prefer = "Open"),
         type = "enter")
