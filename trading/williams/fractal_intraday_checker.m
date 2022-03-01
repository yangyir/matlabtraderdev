function [tblb,tbls,trades,pnl,resstruct] = fractal_intraday_checker(code,varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('type','',@ischar);
p.addParameter('plot',false,@islogical);
p.addParameter('direction',[],@isnumeric);
p.parse(varargin{:});
type = p.Results.type;
doplot = p.Results.plot;
direction = p.Results.direction;

%load the data
isequity = isinequitypool(code);
if isequity
    fn = [getenv('onedrive'),'\matlabdev\equity\',code,'\',code,'.mat'];
    data = load(fn);
    cp = data.data;
else
    if strcmpi(code,'gzhy')
        path = [getenv('onedrive'),'\ea\govtbond\'];
        xlfn = 'wind_gyhy10y_yield.xlsx';
        [num,~,~] = xlsread([path,xlfn]);
        num(:,1) = x2mdate(num(:,1));
        idx = ~(isnan(num(:,2)) | isnan(num(:,3)) | isnan(num(:,4)) | isnan(num(:,5)));
        cp = num(idx,1:5);
    else
        instrument = code2instrument(code);
        assetinfo = getassetinfo(instrument.asset_name);
        shortcode = lower(assetinfo.WindCode);
        fn = [getenv('onedrive'),'\matlabdev\',assetinfo.AssetType,...
            '\',shortcode,'\',code,'.mat'];
        data = load(fn);
        cp = data.data;
    end
end
if isempty(cp),error('fractal_intraday_checker:invalid code input or data not stored');end
%generate trades and table
[tblb,tbls,trades,~,resstruct] = fractal_filter({code},{cp},type,direction,doplot);
%
%backtest trade performance
n = trades.latest_;
pnl = cell(n,2);
for i = 1:n
    trade = trades.node_(i);
    j = trade.id_;
    d = resstruct{1};
    %
    for k = j+1:size(d.px,1)
        extrainfo = fractal_genextrainfo(d,k);
        if k == size(d.px,1)
            extrainfo.latestopen = d.px(k,5);
            extrainfo.latestdt = d.px(k,1);
        else
            extrainfo.latestopen = d.px(k+1,2);
            extrainfo.latestdt = d.px(k+1,1);
        end
        if strcmpi(trade.status_,'closed'),break;end
        tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(tradeout)
            pnl{i,1} = tradeout.closepnl_;
            pnl{i,2} = tradeout.closestr_;
            break
        elseif isempty(tradeout) && k == size(d.px,1)
            pnl{i,1} = trade.runningpnl_;
            pnl{i,2} = 'timeseries limit reached';
        end
    end
end
% disp(pnl);
end