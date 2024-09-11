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
    elseif strcmpi(freq,'15m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_15m.mat']);
        kellytables = data.strat_govtbondfut_15m;
        nfractal = 4;
    elseif strcmpi(freq,'5m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_5m.mat']);
        kellytables = data.strat_govtbondfut_5m;
        nfractal = 6;
    end
elseif ~isempty(strfind(fut.asset_name,'eqindex'))
    nfractal = 4;
else
    nfractal = 4;
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
    if i == idx1+1;
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
            runflag = j == idx2;
                
            tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                'usecandlelastonly',false,...
                'debug',false,...
                'updatepnlforclosedtrade',true,...
                'extrainfo',ei_j,...
                'RunRiskManagementBeforeMktClose',runflag,...
                'KellyTables',kellytables);
        
            if ~isempty(tradeout)
                tradeout.status_ = 'closed';
                unwindedtrades.push(tradeout);
                break
            else
                output = fractal_signal_unconditional2('extrainfo',ei_j,...
                   'ticksize',fut.tick_size,...
                   'nfractal',nfractal,...
                   'assetname',fut.asset_name,...
                   'kellytables',kellytables);
               if ~isempty(output)
                   if output.directionkellied == 0
                       trade.status_ = 'closed';
                       trade.riskmanager_.status_ = 'closed';
                       trade.riskmanager_.closestr_ = 'kelly is too low';
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








