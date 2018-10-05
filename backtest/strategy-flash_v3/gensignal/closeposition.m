% initalise all paras
%%
clear
clc
%%
load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
candles = f.data;
[opensignal_highest,opensignal_outside_highest,opensignal_lowest,opensignal_outside_lowest] = fcn_gen_opensignal(candles);
%%
%处理短期低点的伪生成信号outside-highest为开仓信号，当日即可止损
[l,N_opensignal_outside_highest] = size(opensignal_outside_highest);
if N_opensignal_outside_highest>0
    for i = 1:N_opensignal_outside_highest
        if opensignal_outside_highest{i}.open <opensignal_outside_highest{i}.target
            % short position at openprice
            opensignal_outside_highest{i}.closetimenum = opensignal_outside_highest{i}.opentimenum;
            opensignal_outside_highest{i}.closetimestr = opensignal_outside_highest{i}.opentimestr;
            opensignal_outside_highest{i}.openprice= opensignal_outside_highest{i}.open;
            opensignal_outside_highest{i}.closeprice= opensignal_outside_highest{i}.stoploss;
            opensignal_outside_highest{i}.pnl= opensignal_outside_highest{i}.open - opensignal_outside_highest{i}.stoploss;
        elseif opensignal_outside_highest{i}.open >= opensignal_outside_highest{i}.target && opensignal_outside_highest{i}.open < opensignal_outside_highest{i}.stoploss
             % short position at targetprice
            opensignal_outside_highest{i}.closetimenum = opensignal_outside_highest{i}.opentimenum;
            opensignal_outside_highest{i}.closetimestr = opensignal_outside_highest{i}.opentimestr;
            opensignal_outside_highest{i}.openprice= opensignal_outside_highest{i}.target;
            opensignal_outside_highest{i}.closeprice= opensignal_outside_highest{i}.stoploss;
            opensignal_outside_highest{i}.pnl= opensignal_outside_highest{i}.target - opensignal_outside_highest{i}.stoploss;
        elseif opensignal_outside_highest{i}.open >= opensignal_outside_highest{i}.stoploss
            opensignal_outside_highest{i}.pnl= 0;
        end
    end
end
%%
% 在中期低点后的短期低点， 或者中期高点后的短期高点，止盈止损
[l,N_opensignal_outside_lowest] = size(opensignal_outside_lowest);
if N_opensignal_outside_lowest>0
    for i = 1:N_opensignal_outside_lowest
        if opensignal_outside_lowest{i}.open >opensignal_outside_lowest{i}.target
            % long position at openprice
            opensignal_outside_lowest{i}.closetimenum = opensignal_outside_lowest{i}.opentimenum;
            opensignal_outside_lowest{i}.closetimestr = opensignal_outside_lowest{i}.opentimestr;
            opensignal_outside_lowest{i}.openprice= opensignal_outside_lowest{i}.open;
            opensignal_outside_lowest{i}.closeprice= opensignal_outside_lowest{i}.stoploss;
            opensignal_outside_lowest{i}.pnl= -opensignal_outside_lowest{i}.open +opensignal_outside_lowest{i}.stoploss;
        elseif opensignal_outside_lowest{i}.open <= opensignal_outside_lowest{i}.target && opensignal_outside_lowest{i}.open > opensignal_outside_lowest{i}.stoploss
             % long position at targetprice
            opensignal_outside_lowest{i}.closetimenum = opensignal_outside_lowest{i}.opentimenum;
            opensignal_outside_lowest{i}.closetimestr = opensignal_outside_lowest{i}.opentimestr;
            opensignal_outside_lowest{i}.openprice= opensignal_outside_lowest{i}.target;
            opensignal_outside_lowest{i}.closeprice= opensignal_outside_lowest{i}.stoploss;
            opensignal_outside_lowest{i}.pnl= -opensignal_outside_lowest{i}.target + opensignal_outside_lowest{i}.stoploss;
        elseif opensignal_outside_lowest{i}.open <= opensignal_outside_lowest{i}.stoploss
            opensignal_outside_lowest{i}.pnl= 0;
        end
    end
end
%%
