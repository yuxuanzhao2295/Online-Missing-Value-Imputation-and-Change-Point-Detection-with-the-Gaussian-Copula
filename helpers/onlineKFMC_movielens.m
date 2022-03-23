function [info] = onlineKFMC_movielens(rank, beta, npass_batch, npass_total, validation)
if nargin==5
    Xtrue = readtable('/RealData/data_movielens1m_1000rating.csv', 'HeaderLines',1);
    Xmask = readtable('/RealData/data_movielens1m_traintest.csv', 'HeaderLines',1);
    [Ximp, time] = onlineKFMC_call(Xmask, rank, beta, 121, npass_batch, npass_total);
    Xtrue = table2array(Xtrue);
    Xmask = table2array(Xmask);
    Ximp = trunc_rating(Ximp, 5, 1);
    [mae, rmse] = comp_error(Ximp, Xtrue', Xmask');

    info = zeros(3,1);
    info(1,1) = mae;
    info(2,1) = rmse;
    info(3,1) = time;
else
    Xtrue = readtable('/RealData/data_movielens1m_traintest.csv', 'HeaderLines',1);
    Xtrue = table2array(Xtrue);
    info = zeros(10, 3);
    for i = 1:10
        Xmask = readtable(['/RealData/data_movielens1m_masked_',num2str(i),'.csv'], 'HeaderLines',1);
        [Ximp, time] = onlineKFMC_call(Xmask, rank, beta, 121, npass_batch, npass_total);
        Xmask = table2array(Xmask);
        Ximp = trunc_rating(Ximp, 5, 1);
        [mae, rmse] = comp_error(Ximp, Xtrue', Xmask');
        info(i,1) = mae;
        info(i,2) = rmse;
        info(i,3) = time;
    end
end
end