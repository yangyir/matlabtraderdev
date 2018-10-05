%%
% initalise all paras
clear
clc
%%
load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
candles = f.data;
[opensignal_highest,opensignal_outside_highest,opensignal_lowest,opensignal_outside_lowest] =fcn_gen_opensignal(candles);
%%
%处理短期高点的伪生成信号outside-highest为开仓信号，当日即可止损
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
% 处理短期低点的伪生成信号outside-lowest为开仓信号，当日即可止损
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
% initalize the datenum
[l,N_opensignal_outside_lowest] = size(opensignal_outside_lowest);
if N_opensignal_outside_lowest>0
    for i =1:N_opensignal_outside_lowest
        opensignal_outside_lowest_datenum = opensignal_outside_lowest{i}.datenum;
    end
end
[l,N_opensignal_outside_highest] = size(opensignal_outside_highest);
if N_opensignal_outside_highest>0
    for i =1:N_opensignal_outside_highest
        opensignal_outside_highest_datenum = opensignal_outside_highest{i}.datenum;
    end
end
[l,N_opensignal_lowest] = size(opensignal_lowest);
if N_opensignal_lowest>0
    for i =1:N_opensignal_lowest
        opensignal_lowest_datenum = opensignal_lowest{i}.datenum;
    end
end
[l,N_opensignal_highest] = size(opensignal_highest);
if N_opensignal_highest>0
    for i =1:N_opensignal_highest
        opensignal_highest_datenum = opensignal_highest{i}.datenum;
    end
end
% riskmanagement1: 用相反方向的中期极点后的短期极点，平仓信号; 强制止损线：短期极点对应的 stoploss1
% 处理开空的信号
if N_opensignal_highest>0
    for i = 1:N_opensignal_highest
        v = find(opensignal_highest{i}.datenum < opensignal_lowest_datenum(:,1));
        if ~isempty(v)     
            vv1 =  find(opensignal_highest{i}.datenum < opensignal_outside_lowest_datenum(:,1));
            vv2= find(v1 > opensignal_outside_lowest_datenum(:,1));
            vv = intersect(vv1,vv2);
            if ~isempty(vv)
                % v(1) close position
                % need to calculate the stoploss1 here
            else
                % vv(1) close position
                % need to calculate the stoploss1 here
            end
        else
            % need to calculate the stoploss1 here
            % if no stoploss1, no signal to close position;
        end
    end
end
% continue to code tomorrow...
            
        
        
        



