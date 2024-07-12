function [tblpnl,tblout,statsout] = charlotte_gensingleassetprofile(varargin)
%
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('assetname','',@ischar);
p.addParameter('frequency','intraday',@ischar);
p.addParameter('extratrades',false,@islogical);
p.parse(varargin{:});
%
assetname = p.Results.assetname;
freq = p.Results.frequency;
if ~(strcmpi(freq,'intraday') || strcmpi(freq,'daily') || strcmpi(freq,'intraday-5m') || strcmpi(freq,'intraday-15m')) 
    error('charlotte_gensingleassetprofile:invalid frequency input, either be intraday or daily')
end

if strcmpi(assetname,'govtbond_10y') || strcmpi(assetname,'govtbond_30y') || strcmpi(assetname,'govtbond_05y')
    if strcmpi(freq,'intraday-5m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_5m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_5m;
    elseif strcmpi(freq,'intraday-15m')
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_15m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_15m;
    else
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\govtbondfut\tblreport_govtbondfut_30m.mat']);
        tbl_report_ = data.tblreport_govtbondfut_30m;
    end
elseif strcmpi(assetname,'eqindex_300') || strcmpi(assetname,'eqindex_50') || ...
        strcmpi(assetname,'eqindex_500') || strcmpi(assetname,'eqindex_1000')
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\eqindexfut\tblreport_eqindexfut.mat']);
    tbl_report_ = data.tblreport_eqindexfut;
else
    data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\comdty\tbl_report_comdty_i.mat']);
    tbl_report_ = data.tbl_report_comdty_i;
end

keepextratrades = p.Results.extratrades;

idxasset = strcmpi(tbl_report_.assetname,assetname);
tblasset = tbl_report_(idxasset,:);

if isempty(tblasset)
    fprintf('gensingleassetprofile:assetname %s not found in table...\n',assetname);
    tblpnl = [];
    tblout = [];
    statsout = [];
    return;
end

ntrades = size(tblasset,1);
%use3 is to indicate whether it is an extra trade
use3 = tblasset.use2;
if ~keepextratrades
    count = 1;
    while count < ntrades
        if tblasset.use2(count) == 0
            count = count + 1;
        else
%             if tblasset.use2(count) == 1
            closedt = tblasset.closedatetime(count);
            for i = count+1:ntrades
                if tblasset.use2(i) == 0, continue;end
                opendt_ = tblasset.opendatetime(i);
                if opendt_ < closedt
                    use3(i) = 0;
                else
                    count = i;
                    break
                end
            end
            if i >= ntrades, count = i;end
        end
    end
end
tblout = tblasset(logical(use3),:);
tblout.opendatetime = datestr(tblout.opendatetime,'yyyy-mm-dd HH:MM');
tblout.closedatetime = datestr(tblout.closedatetime,'yyyy-mm-dd HH:MM');
%
firstopendt = tblasset.opendatetime(1);
if hour(firstopendt) > 15
    firstopendt = dateadd(floor(firstopendt),'1b');
elseif hour(firstopendt) < 9
    wknum = weekday(firstopendt);
    if wknum == 7
        firstopendt = dateadd(floor(firstopendt),'1b');
    else
        firstopendt = floor(firstopendt);
    end
else
    firstopendt = floor(firstopendt);
end
%
lastclosedt = tblasset.closedatetime(end);
if hour(lastclosedt) > 15
    lastclosedt = dateadd(floor(lastclosedt),'1b');
elseif hour(lastclosedt) < 9
    wknum = weekday(lastclosedt);
    if wknum == 7
        lastclosedt = dateadd(floor(lastclosedt),'1b');
    else
        lastclosedt = floor(lastclosedt);
    end
else
    lastclosedt = floor(lastclosedt);
end

dts = gendates('fromdate',firstopendt,'todate',lastclosedt);
ndts = length(dts);

openbd = tblasset.opendatetime;
closebd = tblasset.closedatetime;
for i = 1:length(openbd)
    if hour(openbd(i)) > 15
        openbd(i) = dateadd(floor(openbd(i)),'1b');
    elseif hour(openbd(i)) < 9
        wknum = weekday(openbd(i));
        if wknum == 7
            openbd(i) = dateadd(floor(openbd(i)),'1b');
        else
            openbd(i) = floor(openbd(i));
        end
    else
        openbd(i) = floor(openbd(i));
    end
end
%
for i = 1:length(closebd)
    if hour(closebd(i)) > 15
        closebd(i) = dateadd(floor(closebd(i)),'1b');
    elseif hour(closebd(i)) < 9
        wknum = weekday(closebd(i));
        if wknum == 7
            closebd(i) = dateadd(floor(closebd(i)),'1b');
        else
            closebd(i) = floor(closebd(i));
        end
    else
        closebd(i) = floor(closebd(i));
    end
end

tradesbyday = cell(ndts,4);
%the 3rd column is for newly-openned trades
%the 4th column is for carried trades
for i = 1:ndts
    tradesbyday{i,1} = dts(i);
    tradesbyday{i,2} = datestr(dts(i),'yyyy-mm-dd');
    idxopen_i = openbd == dts(i) & use3 == 1;
    trades_i = tblasset(idxopen_i,:);
    tradesbyday{i,3} = trades_i;
    %
    idxcarry_i = openbd < dts(i) & closebd >= dts(i) & use3 == 1;
    tradescarry_i = tblasset(idxcarry_i,:);
    tradesbyday{i,4} = tradescarry_i;
end
%
startnotional = 0;
runningnotional = zeros(ndts,1);
runningrets = zeros(ndts,1);
for i = 1:ndts
    if isempty(tradesbyday{i,3}) && isempty(tradesbyday{i,4})
        %neither open trades nor carry trades
        if i == 1
            runningnotional(i) = startnotional;
            runningrets(i) = 1;
        else
            runningnotional(i) = runningnotional(i-1);
            runningrets(i) = runningrets(i-1);
        end
        continue;
    end
    %
    pnl_open_i = 0;
    ret_open_i = 0;
    if  ~isempty(tradesbyday{i,3})
        opentradeinfo = tradesbyday{i,3};
        closedt_i = opentradeinfo.closedatetime;
        for j = 1:size(closedt_i,1)
            if closedt_i(j) <= dts(i) + 2/3
                %trades close on the same day
                pnl_open_i = pnl_open_i + opentradeinfo.pnlrel(j)*opentradeinfo.opennotional(j);
                ret_open_i = ret_open_i + opentradeinfo.pnlrel(j);
            else
                %trades carried furher and pnl is adjusted to the close
                %price as of the cob date
                code_j = opentradeinfo.code{j};
                data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'dailybar\',code_j,'_daily.txt']);
                idx = find(data(:,1) == dts(i),1,'first');
                cp_j = data(idx,5);
                pnl_open_i = pnl_open_i + opentradeinfo.opennotional(j)*opentradeinfo.direction(j)*(cp_j-opentradeinfo.openprice(j))/opentradeinfo.openprice(j);
                ret_open_i = ret_open_i + opentradeinfo.direction(j)*(cp_j-opentradeinfo.openprice(j))/opentradeinfo.openprice(j);
            end 
        end
    end
    %
    pnl_carry_i = 0;
    ret_carry_i = 0;
    if ~isempty(tradesbyday{i,4})
        carrytradesinfo = tradesbyday{i,4};
        closedt_i = carrytradesinfo.closedatetime;
        for j = 1:size(closedt_i,1)
            code_j = carrytradesinfo.code{j};
            data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'dailybar\',code_j,'_daily.txt']);
            cp_jminus1 = data(find(data(:,1) == dts(i-1),1,'first'),5);
            cp_j = data(find(data(:,1) == dts(i),1,'first'),5);
            if closedt_i(j) <= dts(i) + 2/3
                %trades close on the same day
                tradeclose = carrytradesinfo.openprice(j)+carrytradesinfo.openprice(j)*carrytradesinfo.pnlrel(j)/carrytradesinfo.direction(j); 
                pnl_carry_i = pnl_carry_i + carrytradesinfo.opennotional(j)*carrytradesinfo.direction(j)*(tradeclose-cp_jminus1)/carrytradesinfo.openprice(j);
                ret_carry_i = ret_carry_i + carrytradesinfo.direction(j)*(tradeclose-cp_jminus1)/carrytradesinfo.openprice(j);
            else
                %trades carried further
                pnl_carry_i = pnl_carry_i + carrytradesinfo.opennotional(j)*carrytradesinfo.direction(j)*(cp_j-cp_jminus1)/carrytradesinfo.openprice(j);
                ret_carry_i = ret_carry_i + carrytradesinfo.direction(j)*(cp_j-cp_jminus1)/carrytradesinfo.openprice(j);
            end
        end
    end
    if i == 1
        runningnotional(i) = pnl_open_i + pnl_carry_i;
        runningrets(i) = ret_open_i + ret_carry_i;
    else
        try
            runningnotional(i) = runningnotional(i-1) + pnl_open_i + pnl_carry_i;
            runningrets(i) = runningrets(i-1) + ret_open_i + ret_carry_i;
        catch
            'haha';
        end
    end
end
%
%stats
maxnotional = runningnotional;
maxrets = runningrets;
for i = 1:length(maxnotional)
    maxnotional(i) = max(runningnotional(1:i));
    maxrets(i) = max(runningrets(1:i));
    if maxnotional(i) < 0
        maxnotional(i) = 0;
    end
    if maxrets(i) < 0
        maxrets(i) = 0;
    end
end
drawdown = runningnotional - maxnotional;
drawdownrets = runningrets - maxrets;
dtstr = datestr(dts,'yyyy-mm-dd');

tblpnl = table(dts,dtstr,runningnotional,maxnotional,drawdown,runningrets,maxrets,drawdownrets);

maxdrawdown = min(drawdown);maxdrawdownrets = min(drawdownrets);
vardrawdown = quantile(drawdown,0.01);vardrawdownrets = quantile(drawdownrets,0.01);
notionalchg = runningnotional(2:end)-runningnotional(1:end-1);retschg = runningrets(2:end)-runningrets(1:end-1);
varpnl = quantile(notionalchg,0.01);varrets = quantile(retschg,0.01);
avgpnl = mean(notionalchg);avgrets = mean(retschg);
stdpnl = std(notionalchg);stdrets = std(retschg);
sharpratio = sqrt(252)*avgpnl/stdpnl;

% trade level analysis
tradepnlvec = tblout.opennotional.*tblout.pnlrel;
cumtradepnlvec = cumsum(tradepnlvec);
maxtradecumpnlvec = cumtradepnlvec;
for i = 1:length(maxtradecumpnlvec)
    maxtradecumpnlvec(i) = max(cumtradepnlvec(1:i));
    if maxtradecumpnlvec(i) < 0
        maxtradecumpnlvec(i) = 0;
    end
end
tradepnldrawdown = cumtradepnlvec - maxtradecumpnlvec;
[winp_running,R_running,kelly_running] = calcrunningkelly(tradepnlvec);
%
traderetvec = tblout.pnlrel;
cumtraderetvec = cumsum(traderetvec);
maxtradecumretvec = cumtraderetvec;
for i = 1:length(maxtradecumretvec)
    maxtradecumretvec(i) = max(cumtraderetvec(1:i));
    if maxtradecumretvec(i) < 0
        maxtradecumretvec(i) = 0;
    end
end
traderetdrawdown = cumtraderetvec - maxtradecumretvec;
%
statsout = struct('maxpnldrawdown',maxdrawdown,...
    'varpnldrawdown',vardrawdown,...
    'varpnl',varpnl,...
    'avgpnl',avgpnl,...
    'stdpnl',stdpnl,...
    'sharpratio',sharpratio,...
    'maxtradepnldrawdown',min(tradepnldrawdown),...
    'vartradepnldrawdown',quantile(tradepnldrawdown,0.01),...
    'avgtradepnl',mean(tradepnlvec),...
    'stdtradepnl',std(tradepnlvec),...
    'N',length(tradepnlvec),...
    'W',winp_running(end),...
    'R',R_running(end),...
    'K',kelly_running(end),...
    'maxretdrawdown',maxdrawdownrets,...
    'varretsdrawdown',vardrawdownrets,...
    'varret',varrets,...
    'avgret',avgrets,...
    'stdret',stdrets,...
    'maxtraderetdrawdown',min(traderetdrawdown),...
    'vartraderetdrawdown',quantile(traderetdrawdown,0.01));



end

