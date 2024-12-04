function [tblrollrecord,tbl2check_] = charlotte_backtest_all(varargin)
%
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('assetname','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.parse(varargin{:});
%
assetname = p.Results.assetname;
freq = p.Results.frequency;
if ~(strcmpi(freq,'1440m') || strcmpi(freq,'daily') || strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'30m')) 
    error('charlotte_backtest_all:invalid frequency input, either be 5m,15m,30m,1440m or daily')
end

if strcmpi(assetname,'govtbond_10y') || strcmpi(assetname,'govtbond_30y') || strcmpi(assetname,'govtbond_05y')
    if strcmpi(freq,'5m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_5m.mat']);
        kellytables = data.strat_govtbondfut_5m;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_5m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_5m;
    elseif strcmpi(freq,'15m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_15m.mat']);
        kellytables = data.strat_govtbondfut_15m;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_15m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_15m;
    elseif strcmpi(freq,'30m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\strat_govtbondfut_30m.mat']);
        kellytables = data.strat_govtbondfut_30m;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_30m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_30m;
    end
elseif strcmpi(assetname,'eqindex_300') || strcmpi(assetname,'eqindex_50') || ...
        strcmpi(assetname,'eqindex_500') || strcmpi(assetname,'eqindex_1000')
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\strat_eqindexfut.mat']);
    kellytables = data.strat_eqindexfut;
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\tblreport_eqindexfut.mat']);
    tbl_report_ = data.tblreport_eqindexfut;
elseif isfx(assetname)
    if ~strcmpi(freq,'daily')
        error('charlotte_gensingleassetprofile:only daily frequency is supported for fx...')
    end
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_daily.mat']);
    kellytables = data.strat_fx_daily;
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\tbl_report_fx_daily.mat']);
    tbl_report_ = data.tbl_report_fx_daily;
else
    if strcmpi(freq,'30m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\strat_comdty_i.mat']);
        kellytables = data.strat_comdty_i;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\tbl_report_comdty_i.mat']);
        tbl_report_ = data.tbl_report_comdty_i;
    elseif strcmpi(freq,'1440m') || strcmpi(freq,'daily')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\strat_comdty_daily.mat']);
        kellytables = data.strat_comdty_daily;
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\tbl_report_comdty_daily.mat']);
        tbl_report_ = data.tbl_report_comdty_daily;
    end
end



idxasset = strcmpi(tbl_report_.assetname,assetname);
codelistunique = unique(tbl_report_.code(idxasset,:));

ncode = length(codelistunique);
datefrom = zeros(ncode,1);
dateto = zeros(ncode,1);
for i = 1:ncode
    [datefrom(i),dateto(i)] = irene_findactiveperiod('code',codelistunique{i},'frequency',freq);
end
%
unwindedtrades_ = cTradeOpenArray;
tbl2check_ = {};
uts = cell(ncode,1);
parfor i = 1:ncode
    [ut_i,~] = charlotte_backtest_period('code',codelistunique{i},...
        'fromdate',datestr(datefrom(i),'yyyy-mm-dd'),...
        'todate',datestr(dateto(i),'yyyy-mm-dd'),...
        'frequency',freq,...
        'kellytables',kellytables,'showlogs',false,'figureidx',4,'doplot',false);
    uts{i} = ut_i;
end

datefrom = datestr(datefrom,'yyyy-mm-dd');
dateto = datestr(dateto,'yyyy-mm-dd');
tblrollrecord = table(codelistunique,datefrom,dateto);

for i = 1:ncode
    ut_i = uts{i};
    for j = 1:ut_i.latest_
        unwindedtrades_.push(ut_i.node_(j));
    end
end

if unwindedtrades_.latest_ > 0
    n = unwindedtrades_.latest_;
    code = cell(n,1);
    direction = zeros(n,1);
    opendatetime = cell(n,1);
    openprice = zeros(n,1);
    closedatetime = cell(n,1);
    closeprice = zeros(n,1);
    opennotional = zeros(n,1);
    opensignal = cell(n,1);
    closestr = cell(n,1);
    closepnl = zeros(n,1);
    pnlrel = zeros(n,1);
    use2 = ones(n,1);
    for i = 1:n
        t_i = unwindedtrades_.node_(i);
        code{i} = t_i.code_;
        direction(i) = t_i.opendirection_;
        opendatetime{i} = t_i.opendatetime2_;
        openprice(i) = t_i.openprice_;
        closedatetime{i} = t_i.closedatetime2_;
        closeprice(i) = t_i.closeprice_;
        opensignal{i} = t_i.opensignal_.mode_;
        closestr{i} = t_i.closestr_;
        closepnl(i) = t_i.closepnl_;
        opennotional(i) = t_i.instrument_.tick_size * t_i.openprice_;
        pnlrel(i) = closepnl(i)/opennotional(i);
    end
    tbl2check_ = table(code,direction,opendatetime,openprice,closedatetime,closeprice,opensignal,opennotional,closestr,closepnl,pnlrel,use2);
end

end