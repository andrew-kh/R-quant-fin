#test file for tutorials on datacamp and
#https://quantstrattrader.wordpress.com/category/quantstrat/

library(quantstrat)

Sys.setenv(TZ = "UTC") #doesn't require any libraries
currency("USD")

initdate = "1999-01-01"
from = "2003-01-01"
to = "2015-12-31"

symbols = "SPY"

getSymbols(symbols, from = from, to = to, src = "yahoo", adjust = TRUE)
stock("SPY", currency = "USD", multiplier = 1)

tradesize = 100000
initeq = 100000

strategy.st = portfolio.st = account.st = "firststrat"
rm.strat(strategy.st)

initPortf(portfolio.st, symbols = "SPY", initDate = initdate, currency = "USD")
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

