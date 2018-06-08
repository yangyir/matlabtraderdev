clear
clc

% stoploss_ratio = 0.01:0.01:0.02;
% target_ratio = 0.01 : 0.01 : 0.02;
% freq_used = 2;
% idxused = 3;
% for i= 1:length(stoploss_ratio)
%     for j = 1: length(target_ratio)
%         [pnl(i,j),pWin(i,j),maxpnl(i,j),minpnl(i,j)] = backtest_script_wr_batman_sunq_func(stoploss_ratio(i), target_ratio(j),freq_used,idxused );
%     end
% end

stoploss_ratio = 0.01;
target_ratio = 0.01;
idxused = 1;
freq_used = 1:1:5;

for i = 1:length(freq_used)
    [pnl(i),pWin(i),maxpnl(i),minpnl(i)] = backtest_script_wr_batman_sunq_func(stoploss_ratio, target_ratio,freq_used(i),idxused );
end
    