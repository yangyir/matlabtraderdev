function [tradepnl_mat_single] = fcn_struct2mat_pnl_single(tradepnl_struct)
% tradepnl_mat:
% opentimenum | closetimenum | direction | openprice | closeprice | pnl | outsideornot
    if ~isempty(tradepnl_struct)
        N_trade = size(tradepnl_struct,2);
        tradepnl_mat_single = zeros(N_trade,7);
        for i = 1:N_trade
            tradepnl_mat_single(i,1) = tradepnl_struct{i}.opentimenum;
            tradepnl_mat_single(i,2) = tradepnl_struct{i}.closetimenum;
            tradepnl_mat_single(i,3) = tradepnl_struct{i}.direction;
            tradepnl_mat_single(i,4) = tradepnl_struct{i}.openprice;
            tradepnl_mat_single(i,5) = tradepnl_struct{i}.closeprice;
            tradepnl_mat_single(i,6) = tradepnl_struct{i}.pnl;
            tradepnl_mat_single(i,7) = tradepnl_struct{i}.outsideornot;
        end
    else
        tradepnl_mat_single =[];
    end
end
