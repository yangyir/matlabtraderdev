function [ret] = fractal_backtestsummary(varargin)
%factal backtest summary
p = inputParser;
p.addParameter('data',{},@isstruct);
p.addParameter('longtrades',{},@(x) validateattributes(x,{'cTradeOpenArray'},{},'','longtrades'));
p.addParameter('shorttrades',{},@(x) validateattributes(x,{'cTradeOpenArray'},{},'','shorttrades'));
p.addParameter('startdate','',@(x) validateattributes(x,{'char','numeric'},{},'','startdate'));
p.addParameter('enddate','',@(x) validateattributes(x,{'char','numeric'},{},'','enddate'));
p.addParameter('selffinancing',true,@islogical);
p.addParameter('longonly',true,@islogical);
p.addParameter('plot',false,@islogical);
p.parse(varargin{:});
data = p.Results.data;
if isempty(data),error('fractal_backtestsummary:empty data input!!!');end
validtradesb = p.Results.longtrades;
validtradess = p.Results.shorttrades;
startdate = p.Results.startdate;
if isempty(startdate)
    startdate = data.px(1,1);
else
    startdate = datenum(startdate,'yyyy-mm-dd');
end
enddate = p.Results.enddate;
if isempty(enddate)
    enddate = data.px(end,1);
else
    enddate = datenum(enddate,'yyyy-mm-dd');
end
if enddate < startdate, error('fractal_backtestsummay:invalid start/end date inputs!!!');end
% a self-financing strategy, i.e. no extra fund is financed (added) during
% the whole backtesting period
selffinancing = p.Results.selffinancing;
if ~selffinancing, error('fractal_backtestsummary:not implemeneted with non-self financing strategy!!!');end
longonly = p.Results.longonly;
if longonly
    tblalltrades = zeros(validtradesb.latest_,3);
else
    tblalltrades = zeros(validtradesb.latest_+validtradess.latest_,3);
end
for i = 1:validtradesb.latest_
    trade = validtradesb.node_(i);
    idx = find(data.px(:,1) == trade.opendatetime1_,1,'first');
    tblalltrades(i,1) = idx;
    tblalltrades(i,2) = 1;
    tblalltrades(i,3) = i;
end
if ~longonly
    for i = 1:validtradess.latest_
        trade = validtradess.node_(i);
        idx = find(data.px(:,1) == trade.opendatetime1_,1,'first');
        tblalltrades(i+validtradesb.latest_,1) = idx;
        tblalltrades(i+validtradesb.latest_,2) = -1;
        tblalltrades(i+validtradesb.latest_,3) = i;
    end
end
tblalltrades = sortrows(tblalltrades);
doplot = p.Results.plot;
%
strategyprofile = [data.px(:,1),data.px(:,5),0*data.px(:,2:5)];
%1st column:date
%2nd column:underlying close;
%3nd column:strategy net value;
%4th column:strategy buy/short amount of which short is negative;
%5th column:strategy open price;
%6th column:strategy close price;
backtesttrades = cTradeOpenArray;

% from valid trade to a holding timeseris
% a self-financing strategy,i.e.no extra fund is financed during the whole
% process

istart = find(data.px(:,1)>=startdate,1,'first');
iend = find(data.px(:,1)<=enddate,1,'last');
initfund = data.px(istart,5);                                               %use first entry close as the amount of initial fund

firsttradeidx = find(tblalltrades(:,1)>=istart,1,'first');
direction = tblalltrades(firsttradeidx,2);
if direction == 1
    trade = validtradesb.node_(tblalltrades(firsttradeidx,3));
else
    trade = validtradess.node_(tblalltrades(firsttradeidx,3));
end
opendate = trade.opendatetime1_;
idxstart = find(strategyprofile(:,1) == opendate,1,'first');
strategyprofile(istart:idxstart-1,3) = initfund;
if strcmpi(trade.status_,'closed')
    idxend = find(strategyprofile(:,1) == trade.closedatetime1_,1,'first');
else
    idxend = size(strategyprofile,1);
end
amount = initfund/trade.openprice_;
strategyprofile(idxstart:idxend-1,4) = direction*amount;
strategyprofile(idxstart,3) = initfund+amount*direction*(data.px(idxstart,5)-trade.openprice_);
for j = idxstart+1:idxend
    if j < idxend
        strategyprofile(j,3) = strategyprofile(j-1,3)+amount*direction*(data.px(j,5)-data.px(j-1,5));
    else
        strategyprofile(j,3) = strategyprofile(j-1,3)+amount*direction*(trade.closeprice_-data.px(j-1,5));
    end
end
strategyprofile(idxstart,5) = trade.openprice_;
strategyprofile(idxend,6) = trade.closeprice_;
backtesttrades.push(trade);
%
i = firsttradeidx;
if selffinancing
    while i < size(tblalltrades,1)
        direction = tblalltrades(i,2);
        if direction == 1
            trade = validtradesb.node_(tblalltrades(i,3));
        else
            trade = validtradess.node_(tblalltrades(i,3));
        end
        if i > firsttradeidx
            idxstart = find(strategyprofile(:,1) == trade.opendatetime1_,1,'first');
            if idxstart > iend
                break
            end
            strategyprofile(idxend+1:idxstart-1,3) = strategyprofile(idxend,3);
            if strcmpi(trade.status_,'closed')
                idxend = find(strategyprofile(:,1) == trade.closedatetime1_,1,'first');
            else
                idxend = size(strategyprofile,1);
            end
            amount = strategyprofile(idxstart-1,3)/trade.openprice_;
            strategyprofile(idxstart:idxend-1,4) = direction*amount;
            strategyprofile(idxstart,3) = strategyprofile(idxstart-1,3)+amount*direction*(data.px(idxstart,5)-trade.openprice_);
            for j = idxstart+1:idxend
                if j > iend
                    break
                end
                if j < idxend
                    strategyprofile(j,3) = strategyprofile(j-1,3)+amount*direction*(data.px(j,5)-data.px(j-1,5));
                else
                    strategyprofile(j,3) = strategyprofile(j-1,3)+amount*direction*(trade.closeprice_-data.px(j-1,5));
                end
            end
            strategyprofile(idxstart,5) = trade.openprice_;
            strategyprofile(idxend,6) = trade.closeprice_;
            backtesttrades.push(trade);
        end
        %
        for j = i+1:size(tblalltrades,1)
            direction = tblalltrades(j,2);
            if direction == 1
                tradenext = validtradesb.node_(tblalltrades(j,3));
            else
                tradenext = validtradess.node_(tblalltrades(j,3));
            end
            if tradenext.opendatetime1_ < trade.closedatetime1_            %omit the trade if the previous trade is still alive in self-financing strategy
                continue;
            elseif tradenext.opendatetime1_ >= trade.closedatetime1_       %move to next new trade if its open date is beyond the previous close date
                break
            end
        end
        i = j;
    end
    if idxend < size(strategyprofile,1)
        strategyprofile(idxend+1:end,3) = strategyprofile(idxend,3);
    end    
end
%
% do plot
plotmat = [strategyprofile(istart:iend,1),strategyprofile(istart:iend,2:3),strategyprofile(istart:iend,4:end)];
if doplot
    plot(plotmat(:,2),'b');
    hold on;
    plot(plotmat(:,3),'r');hold off;
    legend('undering','strategy','fontsize',10);
    xtick = get(gca,'XTick');
    nxtick = length(xtick);
    xticklabel = cell(nxtick,1);
    for i = 1:nxtick
        if xtick(i) > size(plotmat,1), continue;end
        if xtick(i) == 0
            xticklabel{i} = datestr(plotmat(1,1),'dd-mmm-yy');
        else
            xticklabel{i}= datestr(plotmat(xtick(i),1),'dd-mmm-yy');
        end
    end
    set(gca,'XTickLabel',xticklabel,'fontsize',8);
    grid on;
    if longonly
        title('long only','fontsize',12);
    else
        title('long/short','fontsize',12);
    end
end
%
% statistics
numoftrades = backtesttrades.latest_;
numoftradesb = 0;
tradestemp = cTradeOpenArray;
for i = 1:numoftrades
    if backtesttrades.node_(i).opendirection_ == 1
        numoftradesb = numoftradesb + 1;
    end
    trade = backtesttrades.node_(i);
    tradetemp = trade.copy;
    tradetemp.closepnl_ = tradetemp.closepnl_/tradetemp.openprice_/100;
    tradestemp.push(tradetemp);
end
numoftradess = numoftrades - numoftradesb;
%1. kelly ratio
[ratio,W,winavgpnl,lossavgpnl] = kellyratio(tradestemp);
%2. sharp ratio
rets = plotmat(2:end,3)./plotmat(1:end-1,3)-1;
sharpratio = sqrt(252)*mean(rets)/std(rets);
%3. max drawdown
[drawdown,drawdownids] = maxdrawdown(plotmat(:,3));
[drawdown_,drawdownids_] = maxdrawdown(plotmat(:,2));
%4.annualreturn
nyears = (plotmat(end,1)-plotmat(1,1))/365.25;
aret = (plotmat(end,3)/plotmat(1,3))^(1/nyears)-1;
%5. alpha
alpha = aret-((plotmat(end,2)/plotmat(1,2))^(1/nyears)-1);

% output
ret.code = trade.instrument_.code_wind;
ret.name = trade.instrument_.asset_name;
ret.strategyprofile = plotmat;
ret.trades = backtesttrades;
ret.numoftrades = numoftrades;
ret.numoftradesb = numoftradesb;
ret.numoftradess = numoftradess;
ret.kellyratio = ratio;
ret.winprop = W;
ret.winavgpnl = winavgpnl;
ret.lossavgpnl = lossavgpnl;
ret.sharpratio = sharpratio;
ret.maxdrawdown = -drawdown;
ret.maxdrawdownperiodlength = drawdownids(end)-drawdownids(1);
ret.underlyingmaxdrawdown = -drawdown_;
ret.underlyingmaxdrawdownperiodlength = drawdownids_(end)-drawdownids_(1);
ret.annualreturn = aret;
ret.alpha = alpha;
ret.recordyears = nyears;

end