% updated on 20180608, used to backtest w_r_batman 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear
% clc
% 
% stoploss_ratio = 0.01:0.01:0.02;
% target_ratio = 0.01 : 0.01 : 0.02;
% freq_used = 2;
% idxused = 3;
% M= length(stoploss_ratio);
% N = length(target_ratio);
% pnl = zeros (M, N);
% pWin = zeros (M, N);
% maxpnl = zeros (M, N);
% minpnl = zeros (M, N);
% ntrade = zeros (M, N)
% for i= 1:M
%     for j = 1: N
%         [pnl(i,j),pWin(i,j),maxpnl(i,j),minpnl(i,j),ntrade(i,j)] = backtest_script_wr_batman_sunq_func(stoploss_ratio(i), target_ratio(j),freq_used,idxused );
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
clc
stoploss_ratio = 0.01;
target_ratio = 0.01;
idxused = 4;
freq_used = 1:1:5;
num = length(freq_used);
pnl = zeros ( num,1);
pWin = zeros(num,1);
maxpnl =zeros(num,1);
minpnl = zeros(num,1);
ntrade = zeros(num,1);
for i = 1:num
    [pnl(i,1),pWin(i,1),maxpnl(i,1),minpnl(i,1),ntrade(i,1)] = backtest_script_wr_batman_sunq_func(stoploss_ratio, target_ratio,freq_used(i),idxused );
end
    