%%
clear
clc
%%
load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
candles = f.data;
%%
% riskmanagement 1 : stoploss1 强制止损线
[opensignal_outside_highest1,opensignal_outside_lowest1,opensignal_highest1,opensignal_lowest1] = fcn_closeposition_v1(candles);
%disposal data 1
% opentimenum | closetimenum | direction | openprice | closeprice | pnl | outsideornot
tradepnl_mat1= fcn_mat2mat_pnl_multiple(opensignal_outside_highest1,opensignal_outside_lowest1,opensignal_highest1,opensignal_lowest1);
pnl1 = tradepnl_mat1(:,6);
ccumpnl1 =  cumsum(pnl1);
sumpnl1 = sum(pnl1);
plot(ccumpnl1);
title('riskmanagement1');
%%
% riskmanagement 2 : stoploss2 强制止损线
[opensignal_outside_highest2,opensignal_outside_lowest2,opensignal_highest2,opensignal_lowest2] = fcn_closeposition_v2(candles);
%disposal data2
tradepnl_mat2= fcn_mat2mat_pnl_multiple(opensignal_outside_highest2,opensignal_outside_lowest2,opensignal_highest2,opensignal_lowest2);
pnl2 = tradepnl_mat2(:,6);
ccumpnl2 =  cumsum(pnl2);
sumpnl2 = sum(pnl2);
plot(ccumpnl2);
title('riskmanagement2');