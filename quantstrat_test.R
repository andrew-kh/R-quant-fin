library(quantstrat)

Sys.setenv(TZ = "UTC") #doesn't require any libraries
currency("USD")

initdate = "1992-01-01"
from = "1995-01-01"
to = "2017-05-01"

symbols = "IBM"

getSymbols(symbols, from = from, to = to, src = "yahoo", adjust = TRUE)
stock(symbols, currency = "USD", multiplier = 1)

#write.csv2(as.data.frame(IBM), file = "IBM.csv", row.names = TRUE)

tradesize = 100000
initeq = 100000

strategy.st <- portfolio.st <- account.st <- "TestStrat"

rm.strat(strategy.st)

initPortf(portfolio.st, symbols = symbols, initDate = initdate, currency = "USD")
initAcct(account.st, portfolios = portfolio.st, initDate = initdate, currency = "USD", initEq = initeq)
initOrders(portfolio.st, initDate = initdate)
strategy(strategy.st, store = TRUE)

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

DVO <- function(HLC, navg = 2, percentlookback = 126) {
  
  # Compute the ratio between closing prices to the average of high and low
  ratio <- Cl(HLC)/((Hi(HLC) + Lo(HLC))/2)
  
  # Smooth out the ratio outputs using a moving average
  avgratio <- SMA(ratio, n = navg)
  
  # Convert ratio into a 0-100 value using runPercentRank function
  out <- runPercentRank(avgratio, n = percentlookback, exact.multiplier = 1) * 100
  colnames(out) <- "DVO"
  return(out)
}

add.indicator(strategy = strategy.st, name = "DVO", 
              arguments = list(HLC = quote(HLC(mktdata)), navg = 2, percentlookback = 126),
              label = "DVO_2_126")

#write.csv2(as.data.frame(test), file = "IBM_test_ind.csv", row.names = TRUE)

add.signal(strategy.st, name = "sigComparison", 
           
           # we are interested in the relationship between the SMA50 and the SMA200
           arguments = list(columns = c("SMA50", "SMA200"), 
                            
                            # particularly, we are interested when the SMA50 is greater than the SMA200
                            relationship = "gt"),
           
           # label this signal longfilter
           label = "longfilter")

add.signal(strategy.st, name = "sigCrossover",
           
           # we're interested in the relationship between the SMA50 and the SMA200
           arguments = list(columns = c("SMA50", "SMA200"),
                            
                            # the relationship is that the SMA50 crosses under the SMA200
                            relationship = "lt"),
           
           # label it filterexit
           label = "filterexit")

add.signal(strategy.st, name = "sigThreshold", 
           
           # use the DVO_2_126 column
           arguments = list(column = "DVO_2_126", 
                            
                            # the threshold is 20
                            threshold = 20, 
                            
                            # we want the oscillator to be under this value
                            relationship = "lt", 
                            
                            # we're interested in every instance that the oscillator is less than 20
                            cross = FALSE), 
           
           # label it longthreshold
           label = "longthreshold")

add.signal(strategy.st, name = "sigThreshold", 
           
           # reference the column of DVO_2_126
           arguments = list(column = "DVO_2_126", 
                            
                            # set a threshold of 80
                            threshold = 80, 
                            
                            # the oscillator must be greater than 80
                            relationship = "gt", 
                            
                            # we are interested only in the cross
                            cross = TRUE), 
           
           # label it thresholdexit
           label = "thresholdexit")

add.signal(strategy.st, name = "sigFormula",
           
           # specify that longfilter and longthreshold must be TRUE
           arguments = list(formula = "longfilter & longthreshold", 
                            
                            # specify that cross must be TRUE
                            cross = TRUE),
           
           # label it longentry
           label = "longentry")

add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "filterexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")

add.rule(strategy.st, name = "ruleSignal", 
         arguments = list(sigcol = "thresholdexit", sigval = TRUE, orderqty = "all", 
                          ordertype = "market", orderside = "long", 
                          replace = FALSE, prefer = "Open"), 
         type = "exit")

add.rule(strategy.st, name = "ruleSignal", 
         
         # use the longentry column as the sigcol
         arguments=list(sigcol = "longentry", 
                        
                        # set sigval to TRUE
                        sigval = TRUE, 
                        
                        # set orderqty to 1
                        orderqty = 1,
                        
                        # use a market type of order
                        ordertype = "market",
                        
                        # take the long orderside
                        orderside = "long",
                        
                        # do not replace other signals
                        replace = FALSE, 
                        
                        # buy at the next day's opening price
                        prefer = "Open"),
         
         # this is an enter type rule, not an exit
         type = "enter")

out <- applyStrategy(strategy = strategy.st, portfolios = portfolio.st)
updatePortf(portfolio.st)
daterange <- time(getPortfolio(portfolio.st)$summary)[-1]
updateAcct(account.st, daterange)
updateEndEq(account.st)
tstats <- tradeStats(Portfolios = portfolio.st)
write.csv2(tstats, file = "IBM_stats.csv", row.names = TRUE)