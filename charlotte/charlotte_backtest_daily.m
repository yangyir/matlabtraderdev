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
testdt = '2024-05-23';
futcode = 'T2409';
freq = '30m';
%
fut = code2instrument(futcode);
data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_30m.mat']);
kellytables = data.strat_govtbondfut_30m;
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


% in case there is no trades carried from previous business date
for i = idx1+1:idx2
    trade = fractal_gentrade2(resstruct,futcode,i,freq,kellytables);
    if ~isempty(trade)
        for j = i:idx2
            ei_j = fractal_truncate(extrainfo,j);
            if j == size(resstruct.px,1) || 
            
            
            
            
            tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',ei_j,...
            'RunRiskManagementBeforeMktClose',false,...
            'KellyTables',kellytables);
            
            
        end
    end
end









