function [tblb,tbls,trades,pnl,resstruct] = fractal_daily_checker(code,varargin)

isequity = isinequitypool(code);
iscomdtyindex = isincomdtyindex(code);
isglobalmacro = isinglobalmacro(code);

if ~isglobalmacro
    if ~isequity && ~iscomdtyindex
        %     error('fractal_daily_checker:invalid code input:only equity is supported')
        instrument = code2instrument(code);
        if ~isempty(instrument.asset_name) && isa(instrument,'cStock')
            isequity = true;
        elseif ~isempty(instrument.asset_name) && isa(instrument,'cFutures')
            assetinfo = getassetinfo(instrument.asset_name);
            if strcmpi(assetinfo.AssetType,'eqindex')
                isequity = true;
            else
                iscomdtyindex = true;
            end
        else
            if strcmpi(code,'gzhy') || strcmpi(code,'gzhy_30y') || strcmpi(code,'tb01y') || strcmpi(code,'tb03y') || ...
                    strcmpi(code,'tb05y') || strcmpi(code,'tb07y') || strcmpi(code,'tb10y') || ...
                    strcmpi(code,'tb30y')
                isequity = false;
                iscomdtyindex = false;
            else
                assetinfo = getassetinfo(instrument.asset_name);
                if ~strcmpi(assetinfo.AssetType,'agriculture')
                    error('fractal_daily_checker:invalid code input:%s not supported',assetinfo.AssetType);
                end
            end
        end
    end
end

p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('type','',@ischar);
p.addParameter('plot',false,@islogical);
p.addParameter('direction',[],@isnumeric);
p.addParameter('usefractalupdate',1,@isnumeric);
p.addParameter('usefibonacci',1,@isnumeric);
p.addParameter('fromdate',{},@(x) validateattributes(x,{'char','numeric'},{},'','fromdate'));
p.addParameter('todate',{},@(x) validateattributes(x,{'char','numeric'},{},'','todate'));
p.addParameter('nfractal',[],@isnumeric);

p.parse(varargin{:});
type = p.Results.type;
doplot = p.Results.plot;
direction = p.Results.direction;
usefracalupdateflag = p.Results.usefractalupdate;
usefibonacciflag = p.Results.usefibonacci;
dt1 = p.Results.fromdate;
if ~isempty(dt1) && ischar(dt1), dt1 = datenum(dt1);end
dt2 = p.Results.todate;
if ~isempty(dt2) && ischar(dt2), dt2 = datenum(dt2);end
nfractal = p.Results.nfractal;
if isempty(nfractal), nfractal = 2;end

%load the data
if ~isglobalmacro
    fn = [code,'_daily.txt'];
    if isequity
        if strcmpi(code(1),'5') || strcmpi(code(1),'1')
            cp = cDataFileIO.loadDataFromTxtFile(['C:\Database\AShare\ETFs\',fn]);
        elseif strcmpi(code,'000300.SH') || strcmpi(code,'000016.SH') || strcmpi(code,'000905.SH') || ...
                strcmpi(code,'000852.SH') || strcmpi(code, '399006.SZ') || strcmpi(code, '000688.SH') || ...
                strcmpi(code,'000015.SH') || strcmpi(code,'000001.SH')
            cp = cDataFileIO.loadDataFromTxtFile(['C:\Database\AShare\Index\',fn]);
        elseif isa(instrument,'cFutures')
            cp = cDataFileIO.loadDataFromTxtFile(fn);
        else
            cp = cDataFileIO.loadDataFromTxtFile(['C:\Database\AShare\SingleStock\',fn]);
        end
    else
        cp = cDataFileIO.loadDataFromTxtFile(fn);
    end
else
    if isfx(code) || strcmpi(code,'UK100') || strcmpi(code,'AUS200') || strcmpi(code,'J225') || ...
        strcmpi(code,'GER30m') || strcmpi(code,'SPX500m') || strcmpi(code,'HK50')
        data = load([getenv('onedrive'),'\Documents\fx_mt4\',code,'_MT4_D1.mat']);
        cp = data.data;
    else
        fn = [code,'_daily.txt'];
        datadir_ = [getenv('datapath'),'globalmacro\'];
        cp = cDataFileIO.loadDataFromTxtFile([datadir_,fn]);
    end
end
if isempty(cp), error('fractal_daily_checker:invalid code input or data not stored');end

[tblb,tbls,trades,~,resstruct] = fractal_filter({code},{cp},type,direction,doplot,dt1,dt2,1440,nfractal);

%backtest trade performance
n = trades.latest_;
pnl = cell(n,2);
for i = 1:n
    trade = trades.node_(i);
    j = trade.id_;
    d = resstruct{1};
    %
    trade.riskmanager_.setusefractalupdateflag(usefracalupdateflag);
    trade.riskmanager_.setusefibonacciflag(usefibonacciflag);
    if j == size(d.px,1)
        trade.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',true,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',d);
        pnl{i,1} = trade.runningpnl_;
        continue;
    end
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


end