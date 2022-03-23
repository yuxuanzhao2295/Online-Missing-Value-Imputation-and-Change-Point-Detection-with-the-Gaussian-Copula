function [err_return, err_price] = main_onlieKFMC_predict_stocks(rank_list, beta_list, n_train, BATCH_SIZE, npass)
lr = size(rank_list,1);
lb = size(beta_list,1);
err_return = zeros(lr,lb, 4);
err_price = zeros(lr,lb, 4);
for i = 1:3
    for j = 1:3
        rank = rank_list(1,i);
        beta = beta_list(1,j);
        [e_return, e_price, ~, ~] = onlineKFMC_predict_stock(rank, beta, n_train, BATCH_SIZE, npass);
        err_return(i,j,:) = e_return;
        err_price(i,j,:) = e_price;
    end
end
end
