library(quantmod)
library(data.table)
library(timeDate)
library(rvest)

# get list of SP500 tickers
url <- "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
SP500 <- url %>%
  html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/div/table[1]') %>%
  html_table()

# Dow Jones Industrial Average
names=as.matrix(read.csv("names.txt", header=FALSE, sep="\t"))[,1]

#' get SnP500 data
#' 
#' Loads returns of SnP500 stocks with tickers in \code{name} from \code{start_date} until
#' \code{end_date}.
#' 
get_SnP <- function(names, start_date, end_date = NULL){

  if (is.null(end_date)) end_date <- substr(Sys.time(), start = 1, stop = 10)

  dates <- timeSequence(as.Date(start_date), as.Date(end_date))
  # dates <- dates[isWeekday(dates)]
  data <- data.table(date = as.character(dates))
  fail <- NULL

  for (ticker in names){
    cat("Downloading time series for symbol '", ticker, "' ...\n", sep = "")
    tryCatch({
      S <- as.data.table(getSymbols(ticker, auto.assign=F, from = as.Date(start_date)))[, 1 : 2]
      S[, index := as.character(index)]
      data <- merge(data, S, by.x = 'date', by.y = 'index', all.x = T)},
      error = function(e){
        cat('Failed to download time series for symbol ', ticker, '...\n', sep = '')
        fail <- c(fail, ticker)})
  }
  if(length(fail) >0) cat('Failed to download time series for symbols', fail, sep = ' ' )
  data
}

start_date <- "2001-01-27"
end_date <- "2021-01-26"
SnP500 <- get_SnP(names, start_date, end_date)


# remove weekends
weekend_id <- apply(is.na(SnP500[, -1]), 1, all)
SnP500 <- SnP500[!weekend_id, ]

# we are interested in the logreturns of the stocks
log_returns <- data.frame(date = SnP500[-1, date], log(SnP500[-1, -1]) - log(SnP500[-nrow(SnP500), -1]))

# save
write.csv2(log_returns, 'RealData/log_return_DJIA.csv', row.names = F)
write.csv2(SnP500, file = 'RealData/price_DJIA.csv', row.names = FALSE)

price = as.matrix(SnP500[,2:31])
logreturn = as.matrix(log_returns[,2:31])
# construct datasets for prediction
# concatenation for predicting tomorrows price
n = dim(price)[1]
stocks_pred = array(0, dim = c(n-1,60))
stocks_pred[,1:30] = price[-n,]
stocks_pred[,31:60] = price[-1,]
write.csv(stocks_pred, file = 'RealData/pred_price_DJIA.csv', row.names = F)

n = dim(logreturn)[1]
logreturn_pred = array(0, dim = c(n-1,60))
logreturn_pred[,1:30] = logreturn[-n,]
logreturn_pred[,31:60] = logreturn[-1,]
write.csv(logreturn_pred, file = 'RealData/pred_log_return_DJIA.csv', row.names = F)

