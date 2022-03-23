function [info] = GROUSE_movielens(maxrank, stepsize, maxCycles, validation)
if nargin==4
    Xtrue = readtable('/RealData/data_movielens1m_1000rating.csv', 'HeaderLines',1);
    Xmask = readtable('/RealData/data_movielens1m_traintest.csv', 'HeaderLines',1);
    [Ximp, time] = GROUSE_call(Xmask, maxrank, stepsize, maxCycles);
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
        [Ximp, time] = GROUSE_call(Xmask, maxrank, stepsize, maxCycles);
        Xmask = table2array(Xmask);
        Ximp = trunc_rating(Ximp, 5, 1);
        [mae, rmse] = comp_error(Ximp, Xtrue', Xmask');
        info(i,1) = mae;
        info(i,2) = rmse;
        info(i,3) = time;
    end
end
end