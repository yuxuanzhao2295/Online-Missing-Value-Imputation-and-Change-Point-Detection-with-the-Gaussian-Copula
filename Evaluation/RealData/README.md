## Movielens1M subset data
[The movielens1M data](https://grouplens.org/datasets/movielens/1m/) is available online. Here we include the subset of Movielens1m data containing all movies with more than 1000 ratings in file "data_movielens1m_1000rating.csv".
The "data_movielens1m_traintest.csv" is the dataset after masking 10% observation as validation set for choosing hyperparameters.
Files "data_movielens1m_maksed_j.csv" for j=1,...,10 are the datasets after additionally masking 10% observation as test set using different seeds.

## Stocks data
Original stock prices are put in "price_DJIA.csv" and the log-returns are put in "log_return_DJIA.csv". 
Files "pred_price_DJIA.csv" and "pred_log_return_DJIA" are the enlarged datasets with every row containing yesterday's data and today's data.