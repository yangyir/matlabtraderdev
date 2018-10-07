%%
% riskmanagement2: 用相反方向的中期极点后的短期极点，平仓信号; 强制止损线：短期极点对应的 stoploss2
% initalise all paras
clear
clc
%%
load('b_RBTK8_1d.mat');
% date| open |high |low |close |volume |oi
candles = f.data;
[opensignal_highest,opensignal_outside_highest,opensignal_lowest,opensignal_outside_lowest] =fcn_gen_opensignal_v2(candles);
%%
%处理短期高点的伪生成信号outside-highest为开仓信号，当日即可止损
[l,N_opensignal_outside_highest] = size(opensignal_outside_highest);
if N_opensignal_outside_highest>0
    for i = 1:N_opensignal_outside_highest
        if ~isnan(opensignal_outside_highest{i}.openprice)
            % short position at openprice
            opensignal_outside_highest{i}.closetimenum = opensignal_outside_highest{i}.opentimenum;
            opensignal_outside_highest{i}.closetimestr = opensignal_outside_highest{i}.opentimestr; 
            opensignal_outside_highest{i}.closeprice= opensignal_outside_highest{i}.stoploss;
            opensignal_outside_highest{i}.pnl= (opensignal_outside_highest{i}.closeprice - opensignal_outside_highest{i}.openprice)*opensignal_outside_highest{i}.direction*opensignal_outside_highest{i}.N_position;
        end
    end
end
%%
% 处理短期低点的伪生成信号outside-lowest为开仓信号，当日即可止损
[l,N_opensignal_outside_lowest] = size(opensignal_outside_lowest);
if N_opensignal_outside_lowest>0
    for i = 1:N_opensignal_outside_lowest
        if ~isnan(opensignal_outside_lowest{i}.openprice)
            % long position at openprice
            opensignal_outside_lowest{i}.closetimenum = opensignal_outside_lowest{i}.opentimenum;
            opensignal_outside_lowest{i}.closetimestr = opensignal_outside_lowest{i}.opentimestr;
            opensignal_outside_lowest{i}.closeprice= opensignal_outside_lowest{i}.stoploss;
            opensignal_outside_lowest{i}.pnl= (opensignal_outside_lowest{i}.closeprice - opensignal_outside_lowest{i}.openprice)*opensignal_outside_lowest{i}.direction*opensignal_outside_lowest{i}.N_position;
        end
    end
end
%%
% initalize the datenum
[l,N_opensignal_outside_lowest] = size(opensignal_outside_lowest);
if N_opensignal_outside_lowest>0
    for i =1:N_opensignal_outside_lowest
        opensignal_outside_lowest_datenum(i,1) = opensignal_outside_lowest{i}.opentimenum;
    end
end
[l,N_opensignal_outside_highest] = size(opensignal_outside_highest);
if N_opensignal_outside_highest>0
    for i =1:N_opensignal_outside_highest
        opensignal_outside_highest_datenum(i,1) = opensignal_outside_highest{i}.opentimenum;
    end
end
[l,N_opensignal_lowest] = size(opensignal_lowest);
if N_opensignal_lowest>0
    for i =1:N_opensignal_lowest
        opensignal_lowest_datenum(i,1) = opensignal_lowest{i}.opentimenum;
    end
end
[l,N_opensignal_highest] = size(opensignal_highest);
if N_opensignal_highest>0
    for i =1:N_opensignal_highest
        opensignal_highest_datenum(i,1) = opensignal_highest{i}.opentimenum;
    end
end
%%
% riskmanagement1: 用相反方向的中期极点后的短期极点，平仓信号; 强制止损线：短期极点对应的 stoploss2
% 处理开空的信号
if N_opensignal_highest>0
    for i = 1:N_opensignal_highest
        v = find(opensignal_highest{i}.opentimenum < opensignal_lowest_datenum(:,1));
        if ~isempty(v) 
            if ~isempty(opensignal_outside_lowest)  
                vv1 =  find(opensignal_highest{i}.opentimenum < opensignal_outside_lowest_datenum(:,1));
                vv2= find(opensignal_lowest_datenum(v(1,1),1) > opensignal_outside_lowest_datenum(:,1));
                vv = intersect(vv1,vv2);
            else
                vv=[];
            end
            if ~isempty(vv)
                % close position at vv(1,1)
                opensignal_highest{i}.closetimenum = opensignal_outside_lowest{vv(1,1)}.opentimenum;
                opensignal_highest{i}.closetimestr = datestr(opensignal_outside_lowest{vv(1,1)}.opentimenum);
                opensignal_highest{i}.closeprice = opensignal_outside_lowest{vv(1,1)}.openprice;
                opensignal_highest{i}.pnl = (opensignal_highest{i}.closeprice - opensignal_highest{i}.openprice)*opensignal_highest{i}.direction*opensignal_highest{i}.N_position;     
            else
                % close position at v(1,1)
                opensignal_highest{i}.closetimenum = opensignal_lowest{v(1,1)}.opentimenum;
                opensignal_highest{i}.closetimestr = datestr(opensignal_lowest{v(1,1)}.opentimenum);
                opensignal_highest{i}.closeprice = opensignal_lowest{v(1,1)}.openprice;
                opensignal_highest{i}.pnl = (opensignal_highest{i}.closeprice - opensignal_highest{i}.openprice)*opensignal_highest{i}.direction*opensignal_highest{i}.N_position;    
            end
        end 
            startlocation = find (candles(:,1)==opensignal_highest{i}.opentimenum);
            if isnan(opensignal_highest{i}.pnl)
                stoplosslocation = find(candles(startlocation:end,3)>= opensignal_highest{i}.stoploss2);
            else
                lastlocation = find (candles(:,1)==opensignal_highest{i}.closetimenum);
                stoplosslocation = find(candles(startlocation:lastlocation,3)>= opensignal_highest{i}.stoploss2);
            end
            if ~isempty(stoplosslocation)
                opensignal_highest{i}.closetimenum = candles(stoplosslocation(1,1)+startlocation-1,1);
                opensignal_highest{i}.closetimestr = datestr(candles(stoplosslocation(1,1)+startlocation-1,1));
                opensignal_highest{i}.closeprice = opensignal_highest{i}.stoploss2;
                opensignal_highest{i}.pnl = (opensignal_highest{i}.closeprice - opensignal_highest{i}.openprice)*opensignal_highest{i}.direction*opensignal_highest{i}.N_position;
            end
            v=[];vv=[];vv1=[];vv2=[];
    end
end
%%

% riskmanagement1: 用相反方向的中期极点后的短期极点，平仓信号; 强制止损线：短期极点对应的 stoploss2
% 处理开多的信号
if N_opensignal_lowest>0
    for i = 1:N_opensignal_lowest
        v = find(opensignal_lowest{i}.opentimenum < opensignal_highest_datenum(:,1));
        if ~isempty(v)     
            if ~isempty(opensignal_outside_highest)
                vv1 =  find(opensignal_lowest{i}.opentimenum < opensignal_outside_highest_datenum(:,1));
                vv2= find(opensignal_highest_datenum(v(1,1),1) > opensignal_outside_highest_datenum(:,1));
                vv = intersect(vv1,vv2);
            else
                vv=[];
            end   
            if ~isempty(vv) 
                % close position at vv(1,1)
                opensignal_lowest{i}.closetimenum = opensignal_outside_highest{vv(1,1)}.opentimenum;
                opensignal_lowest{i}.closetimestr = datestr(opensignal_outside_highest{vv(1,1)}.opentimenum);
                opensignal_lowest{i}.closeprice = opensignal_outside_highest{vv(1,1)}.openprice;
                opensignal_lowest{i}.pnl = (opensignal_lowest{i}.closeprice - opensignal_lowest{i}.openprice)*opensignal_lowest{i}.direction*opensignal_lowest{i}.N_position;     
            else
                % close position at v(1,1)
                opensignal_lowest{i}.closetimenum = opensignal_highest{v(1,1)}.opentimenum;
                opensignal_lowest{i}.closetimestr = datestr(opensignal_highest{v(1,1)}.opentimenum);
                opensignal_lowest{i}.closeprice = opensignal_highest{v(1,1)}.openprice;
                opensignal_lowest{i}.pnl = (opensignal_lowest{i}.closeprice - opensignal_lowest{i}.openprice)*opensignal_lowest{i}.direction*opensignal_lowest{i}.N_position;
            end
        end 
            startlocation = find (candles(:,1)==opensignal_lowest{i}.opentimenum);
            if isnan(opensignal_lowest{i}.pnl)
                stoplosslocation = find(candles(startlocation:end,4)<= opensignal_lowest{i}.stoploss2);
            else
                lastlocation = find (candles(:,1)==opensignal_lowest{i}.closetimenum);
                stoplosslocation = find(candles(startlocation:lastlocation,4)<= opensignal_lowest{i}.stoploss2);
            end
            if ~isempty(stoplosslocation)
                opensignal_lowest{i}.closetimenum = candles(stoplosslocation(1,1)+startlocation-1,1);
                opensignal_lowest{i}.closetimestr = datestr(candles(stoplosslocation(1,1)+startlocation-1,1));
                opensignal_lowest{i}.closeprice = opensignal_lowest{i}.stoploss2;
                opensignal_lowest{i}.pnl = (opensignal_lowest{i}.closeprice - opensignal_lowest{i}.openprice)*opensignal_lowest{i}.direction*opensignal_lowest{i}.N_position;
            end
            v=[];vv=[];vv1=[];vv2=[];
    end
end


            
         
        
        



