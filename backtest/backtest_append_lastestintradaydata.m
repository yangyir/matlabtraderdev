function [] = backtest_append_lastestintradaydata(c,assetname)
%%
info = getassetinfo(assetname);
if strcmpi(info.ExchangeCode,'.SHF')
    exchangecode = 'shfe';
elseif strcmpi(info.ExchangeCode,'.CFE')
    exchangecode = 'cfe';
elseif strcmpi(info.ExchangeCode,'.DCE')
    exchangecode = 'dce';
elseif strcmpi(info.ExchangeCode,'.CZC')
    exchangecode = 'zce';
end

check = regexp(assetname,' ','split');
if iscell(check) && length(check) > 1
    asset_name = check{1};
    for i = 2:length(check), asset_name = [asset_name,check{i}];end
else
    asset_name = check{1};
end
fn = [exchangecode,'_',asset_name,'_generic_1st_1m'];
dir_ = getenv('HOME');
dir_ = [dir_,'backtest\data\'];
%%
clc;
try
    d = load([dir_,fn]);
    px = d.px_1m;
    fprintf('%s\n',datestr(px(1,1)));
    fprintf('%s\n',datestr(px(end,1)));
    startdt = datestr(businessdate(floor(px(end,1))));
    enddt = datestr(today);
catch
    %file not exist
    px = [];
    fprintf('file:"%s" not exist!\n',fn);
    startdt = datestr(getlastbusinessdate - 182);
    enddt = datestr(today);
end
fprintf('append intraday data from:%s\n',startdt);
fprintf('append intraday data to:%s\n',enddt);

%%
if strcmpi(info.AssetType,'eqindex')
    sec = [info.BloombergCode,'1 Index'];
else
    sec = [info.BloombergCode,'1 Comdty'];
end
if datenum(startdt) < datenum(enddt)
    fprintf('download data from Bloomberg......\n');
    data = timeseries(c,sec,{startdt,enddt},1,'trade');
    data = timeseries_window(data,'TradingHours',info.TradingHours,'TradingBreak',info.TradingBreak);
    fprintf('first entry datetime of newly appended data:%s\n',datestr(data(1,1)));
    fprintf('last entry datetime of newly appended data:%s\n',datestr(data(end,1)));
else
    data = [];
end
%%
if isempty(px)
    px_1m = data;
else
    px_1m = [px;data];
end
%%
if datenum(startdt) < datenum(enddt)
    fprintf('save data to local file......\n');
    save([dir_,fn],'px_1m');
end
%%
close all;
timeseries_plot(px_1m,'title',assetname,'dateformat','mmm-yy');
end