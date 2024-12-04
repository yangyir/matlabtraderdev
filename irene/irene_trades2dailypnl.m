function [tblpnl,tblout,statsout] = irene_trades2dailypnl(varargin)
%utility function to generate the daily pnl profile given a list of trades
%with the same underlier on the same day
%e.g cases of copper and alumimum trades on the same day are not supported
%
p = inputParser;
p.addParameter('tradestable',[],@istable);
p.addParameter('extratrades',false,@islogical);
p.addParameter('frequency','30m',@ischar);
p.parse(varargin{:});

tblasset = p.Results.tradestable;
keepextratrades = p.Results.extratrades;
freq = p.Results.frequency;

ntrades = size(tblasset,1);
use3 = ones(ntrades,1);

if strcmpi(freq,'daily') || strcmpi(freq,'1440m')
    tblasset.opendatetime = datenum(tblasset.opendatetime,'yyyy-mm-dd');
    tblasset.closedatetime = datenum(tblasset.closedatetime,'yyyy-mm-dd');
else
    tblasset.opendatetime = datenum(tblasset.opendatetime,'yyyy-mm-dd HH:MM');
    tblasset.closedatetime = datenum(tblasset.closedatetime,'yyyy-mm-dd HH:MM');
end


if ~keepextratrades
    count = 1;
    while count < ntrades
        if tblasset.use2(count) == 0
            count = count + 1;
        else
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
if strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'30m')
    tblout.opendatetime = datestr(tblout.opendatetime,'yyyy-mm-dd HH:MM');
    tblout.closedatetime = datestr(tblout.closedatetime,'yyyy-mm-dd HH:MM');
elseif strcmpi(freq,'daily') || strcmpi(freq,'1440m')
    tblout.opendatetime = datestr(tblout.opendatetime,'yyyy-mm-dd');
    tblout.closedatetime = datestr(tblout.closedatetime,'yyyy-mm-dd');
end
%
firstopendt = tblasset.opendatetime(1);
if strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'30m')
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
end
%
lastclosedt = tblasset.closedatetime(end);
if strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'30m')
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
end
%
if isfx(tblasset.code{1})
    data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'globalmacro\',assetname,'_daily.txt']);
    idx = data(:,1) >= firstopendt & data(:,1) <= lastclosedt;
    dts = data(idx,1);
else
    dts = gendates('fromdate',firstopendt,'todate',lastclosedt);
end
ndts = length(dts);
openbd = tblasset.opendatetime;
closebd = tblasset.closedatetime;
if strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'30m')
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
            if strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'30m')
                if closedt_i(j) <= dts(i) + 2/3
                    %trades close on the same day
                    pnl_open_i = pnl_open_i + opentradeinfo.pnlrel(j)*opentradeinfo.opennotional(j);
                    ret_open_i = ret_open_i + opentradeinfo.pnlrel(j);
                else
                    %trades carried furher and pnl is adjusted to the close
                    %price as of the cob date
                    code_j = opentradeinfo.code{j};
                    if isfx(code_j)
                        data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'globalmacro\',code_j,'_daily.txt']);
                    else
                        data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'dailybar\',code_j,'_daily.txt']);
                    end
                    idx = find(data(:,1) == dts(i),1,'first');
                    cp_j = data(idx,5);
                    pnl_open_i = pnl_open_i + opentradeinfo.opennotional(j)*opentradeinfo.direction(j)*(cp_j-opentradeinfo.openprice(j))/opentradeinfo.openprice(j);
                    ret_open_i = ret_open_i + opentradeinfo.direction(j)*(cp_j-opentradeinfo.openprice(j))/opentradeinfo.openprice(j);
                end
            else
                if closedt_i(j) <= dts(i)
                    %trades close on the same day
                    pnl_open_i = pnl_open_i + opentradeinfo.pnlrel(j)*opentradeinfo.opennotional(j);
                    ret_open_i = ret_open_i + opentradeinfo.pnlrel(j);
                else
                    %trades carried furher and pnl is adjusted to the close
                    %price as of the cob date
                    code_j = opentradeinfo.code{j};
                    if isfx(code_j)
                        data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'globalmacro\',code_j,'_daily.txt']);
                    else
                        data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'dailybar\',code_j,'_daily.txt']);
                    end
                    idx = find(data(:,1) == dts(i),1,'first');
                    cp_j = data(idx,5);
                    pnl_open_i = pnl_open_i + opentradeinfo.opennotional(j)*opentradeinfo.direction(j)*(cp_j-opentradeinfo.openprice(j))/opentradeinfo.openprice(j);
                    ret_open_i = ret_open_i + opentradeinfo.direction(j)*(cp_j-opentradeinfo.openprice(j))/opentradeinfo.openprice(j);
                end
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
            if isfx(code_j)
                data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'globalmacro\',code_j,'_daily.txt']);
            else
                data = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'dailybar\',code_j,'_daily.txt']);
            end
            cp_jminus1 = data(find(data(:,1) == dts(i-1),1,'first'),5);
            cp_j = data(find(data(:,1) == dts(i),1,'first'),5);
            if strcmpi(freq,'5m') || strcmpi(freq,'15m') || strcmpi(freq,'30m')
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
            else
                if closedt_i(j) <= dts(i)
                    %trades close on the same day
                    tradeclose = carrytradesinfo.openprice(j)+carrytradesinfo.openprice(j)*carrytradesinfo.pnlrel(j)/carrytradesinfo.direction(j); 
                    if isempty(cp_jminus1)
                        cp_jminus1 = data(find(data(:,1) <= dts(i-1),1,'last'),5);
                    end
                    pnl_carry_i = pnl_carry_i + carrytradesinfo.opennotional(j)*carrytradesinfo.direction(j)*(tradeclose-cp_jminus1)/carrytradesinfo.openprice(j);
                    ret_carry_i = ret_carry_i + carrytradesinfo.direction(j)*(tradeclose-cp_jminus1)/carrytradesinfo.openprice(j);
                else
                    %trades carried further
                    if isempty(cp_jminus1)
                        cp_jminus1 = data(find(data(:,1) <= dts(i-1),1,'last'),5);
                    end
                    if isempty(cp_j)
                        cp_j = cp_jminus1;
                    end
                    pnl_carry_i = pnl_carry_i + carrytradesinfo.opennotional(j)*carrytradesinfo.direction(j)*(cp_j-cp_jminus1)/carrytradesinfo.openprice(j);
                    ret_carry_i = ret_carry_i + carrytradesinfo.direction(j)*(cp_j-cp_jminus1)/carrytradesinfo.openprice(j);
                end
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
%
end