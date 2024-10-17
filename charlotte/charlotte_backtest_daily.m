function [alltrades,carriedtrades,unwindedtrades] = charlotte_backtest_daily(varargin)

%func to load existing trade if there is any
%func to generate new trade if there is a prop signal
%func to backtest the existing / newly-generated trade
%backtest is on a daily basis
%as to be inline with the code, we use the calendar time starting from
%09:00 an until 02:30 the next day (if it is needed)
%func inputs:
%   fut code (char), e.g. i2501
%   test date (char), e.g. 2024-09-06
%   freq (char), e.g.'30m',only '5m', '15m', '30m'(default value) and
%   '1440m' are supported
%   kelly tables directory(char)
%
%logic for newly-generated trades
%1.logic for trended trades
%   It is important to note that there could be unsuccessfully breaches of the
%   fractal barrier with trended condition satisfied, and these trades are
%   generated in realtime trading but exclueded from the current framework
%   of kelly calculation. We shall use this new framework to calculate and
%   analyse the stats of those trades.
%2.logic for non-trended trades
%   this shall be the same with the current backtest framework
%
%
%sample inputs:
% testdt = '2024-05-23';
% futcode = 'TL2409';
% freq = '30m';
%
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.addParameter('date','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.addParameter('carriedtrade',{},@(x) validateattributes(x,{'cTradeOpen'},{},'','carriedtrade'));    
p.parse(varargin{:});
futcode = p.Results.code;
testdt = p.Results.date;
freq = p.Results.frequency;
carriedtrade = p.Results.carriedtrade;

fut = code2instrument(futcode);
if strcmpi(fut.asset_name,'govtbond_10y') || strcmpi(fut.asset_name,'govtbond_30y')
    if strcmpi(freq,'30m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_30m.mat']);
        kellytables = data.strat_govtbondfut_30m;
        nfractal = 4;
        tickratio = 0.5;
    elseif strcmpi(freq,'15m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_15m.mat']);
        kellytables = data.strat_govtbondfut_15m;
        nfractal = 4;
        tickratio = 0.5;
    elseif strcmpi(freq,'5m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_5m.mat']);
        kellytables = data.strat_govtbondfut_5m;
        nfractal = 6;
        tickratio = 0;
    end
elseif ~isempty(strfind(fut.asset_name,'eqindex'))
    nfractal = 4;
    tickratio = 0.5;
else
    nfractal = 4;
    tickratio = 0.5;
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\strat_comdty_i.mat']);
    kellytables = data.strat_comdty_i;
end
%        
%
[~,extrainfo] = charlotte_loaddata('futcode',futcode,'frequency',freq);
%
dt1 = [testdt,' 09:00:00'];
dt2 = [datestr(dateadd(datenum(testdt,'yyyy-mm-dd'),'1d'),'yyyy-mm-dd'),' 02:30:00'];
dt1num = datenum(dt1,'yyyy-mm-dd HH:MM:SS');
dt2num = datenum(dt2,'yyyy-mm-dd HH:MM:SS');
idx1 = find(extrainfo.px(:,1) < dt1num,1,'last');
idx2 = find(extrainfo.px(:,1) <= dt2num,1,'last');
%

alltrades = cTradeOpenArray;
carriedtrades = cTradeOpenArray;
unwindedtrades = cTradeOpenArray;
% in case there is no trades carried from previous business date
i = idx1+1;
while i <= idx2
    if i == idx1+1
        if ~isempty(carriedtrade) && ~strcmpi(carriedtrade.status_,'closed')
            trade = carriedtrade;
        else
            trade = fractal_gentrade2(extrainfo,futcode,i,freq,kellytables);
        end
    else
        trade = fractal_gentrade2(extrainfo,futcode,i,freq,kellytables);
    end
    if ~isempty(trade)
        alltrades.push(trade);
        for j = i:idx2
            ei_j = fractal_truncate(extrainfo,j);
            if j == idx2
                ei_j.latestopen = extrainfo.px(j,5);
                ei_j.latestdt = extrainfo.px(j,1);
            else
                ei_j.latestopen = extrainfo.px(j+1,2);
                ei_j.latestdt = extrainfo.px(j+1,1);
            end
            %
            runflag = false;
            if trade.oneminb4close1_ == 914
                %govtbond
                if strcmpi(freq,'30m')
                    if hour(ei_j.px(end,1)) == 15, runflag = true;end
                elseif strcmpi(freq,'15m')
                    if hour(ei_j.px(end,1)) == 15, runflag = true;end
                elseif strcmpi(freq,'5m')
                    if hour(ei_j.px(end,1)) == 15 && minute(ei_j.px(end,1)) == 10, runflag = true;end
                end
            elseif trade.oneminb4close1_ == 899 && isnan(trade.oneminb4close2_)
                if ~strcmpi(freq,'30m'), error('charlotte_backtest_daily:invalid freq input....');end
                if hour(ei_j.px(end,1)) == 14 && minute(ei_j.px(end,1)) == 30, runflag = true;end
            elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 1379
                if ~strcmpi(freq,'30m'), error('charlotte_backtest_daily:invalid freq input....');end
                if (hour(ei_j.px(end,1)) == 14 && minute(ei_j.px(end,1)) == 30) || ...
                        (hour(ei_j.px(end,1)) == 22 && minute(ei_j.px(end,1)) == 30)
                    runflag = true;
                end
            elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 59
                if ~strcmpi(freq,'30m'), error('charlotte_backtest_daily:invalid freq input....');end
                if (hour(ei_j.px(end,1)) == 14 && minute(ei_j.px(end,1)) == 30) || ...
                        (hour(ei_j.px(end,1)) == 0 && minute(ei_j.px(end,1)) == 30)
                    runflag = true;
                end
            elseif trade.oneminb4close1_ == 899 && trade.oneminb4close2_ == 149
                if ~strcmpi(freq,'30m'), error('charlotte_backtest_daily:invalid freq input....');end
                if (hour(ei_j.px(end,1)) == 14 && minute(ei_j.px(end,1)) == 30) || ...
                        (hour(ei_j.px(end,1)) == 2 && minute(ei_j.px(end,1)) == 30)
                    runflag = true;
                end
            end
                
            tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                'usecandlelastonly',false,...
                'debug',false,...
                'updatepnlforclosedtrade',true,...
                'extrainfo',ei_j,...
                'RunRiskManagementBeforeMktClose',runflag,...
                'KellyTables',kellytables,...
                'CompulsoryCheckForConditional',true);
        
            if ~isempty(tradeout)
                tradeout.status_ = 'closed';
                unwindedtrades.push(tradeout);
                break
            else
                output = fractal_signal_unconditional2('extrainfo',ei_j,...
                   'ticksize',fut.tick_size,...
                   'nfractal',nfractal,...
                   'assetname',fut.asset_name,...
                   'kellytables',kellytables,...
                   'ticksizeratio',tickratio);
               if ~isempty(output)
                   if output.directionkellied == 0 && (strcmpi(output.op.comment,trade.opensignal_.mode_) || ...
                           (~strcmpi(output.op.comment,trade.opensignal_.mode_) && ...
                           (output.kelly < 0 || isnan(output.kelly))))
                       trade.status_ = 'closed';
                       trade.riskmanager_.status_ = 'closed';
                       trade.riskmanager_.closestr_ = ['kelly is too low: ',num2str(output.kelly)];
                       trade.runningpnl_ = 0;
                       trade.closeprice_ = ei_j.latestopen;
                       trade.closedatetime1_ = ei_j.latestdt;
                       trade.closepnl_ = trade.opendirection_*(trade.closeprice_-trade.openprice_) /fut.tick_size * fut.tick_value;
                       tradeout = trade;
                       unwindedtrades.push(tradeout);
                       break
                   end
               end
               %
               output2 = fractal_signal_conditional2('extrainfo',ei_j,...
                   'ticksize',fut.tick_size,...
                   'nfractal',nfractal,...
                   'assetname',fut.asset_name,...
                   'kellytables',kellytables,...
                   'ticksizeratio',tickratio);
               if ~isempty(output2)
                   if output2.directionkellied == 0
                       trade.status_ = 'closed';
                       trade.riskmanager_.status_ = 'closed';
                       trade.riskmanager_.closestr_ = ['conditional kelly is too low: ',num2str(output2.kelly)];
                       trade.runningpnl_ = 0;
                       trade.closeprice_ = ei_j.latestopen;
                       trade.closedatetime1_ = ei_j.latestdt;
                       trade.closepnl_ = trade.opendirection_*(trade.closeprice_-trade.openprice_) /fut.tick_size * fut.tick_value;
                       tradeout = trade;
                       unwindedtrades.push(tradeout);
                       break
                   end
               end
               
            end    
        end
        i = j+1;
    else
        
        
        
        i = i+1;
    end
    if i > idx2 && ~isempty(trade) && strcmpi(trade.status_,'set')
        carriedtrades.push(trade);
    end
end
%
%sanity check
sanityflag = alltrades.latest_ == carriedtrades.latest_ + unwindedtrades.latest_ && ...
    (carriedtrades.latest_ == 0 || carriedtrades.latest_ == 1);
if ~sanityflag
    error('charlotte_backtest_daily:check required')
end









