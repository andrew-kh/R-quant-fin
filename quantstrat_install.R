# 1. Installation of the quantstrat package
# 
# perform Step 1 from this site http://masterr.org/r/how-to-install-quantstrat/:

install.packages("FinancialInstrument")
install.packages("PerformanceAnalytics")
install.packages("foreach")

#If Step 2 is not working (like in my case), install the remaining packages from GitHub

install.packages("devtools")
library(devtools)
install_github("braverock/blotter")

#If blotter requires xts 0.10 (again, like in my case), install it from GitHub (it's < 0.10 in CRAN)

install_github("joshuaulrich/xts")
install_github("braverock/quantstrat")