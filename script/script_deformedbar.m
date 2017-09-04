
%
assetName = 'deformed bar';
tenor1 = '1701';
tenor2 = '1705';
contract1 = cContract('assetname',assetName,'tenor',tenor1);
contract2 = cContract('assetname',assetName,'tenor',tenor2);
% timeseries_update(contract1,'TickUpdateFlag',false);
% timeseries_update(contract2,'TickUpdateFlag',false);

fieldName = 'close,volume';
volume1 = contract1.getTimeSeries('connection','bloomberg','fields',fieldName,...
    'frequency','1d');
volume2 = contract2.getTimeSeries('connection','bloomberg','fields',fieldName,...
    'frequency','1d');
[t,idx1,idx2] = intersect(volume1(:,1),volume2(:,1));
volume1minus2 = [t,volume1(idx1,end)-volume2(idx2,end)];
tRoll = find(volume1minus2(:,end)>0);
if tRoll(end) == size(volume1minus2,1)
    fprintf('the contract has not rolled yet.\n');
else
    tRoll = volume1minus2(tRoll(end)+1,1);
    fprintf(['the roll date is ',datestr(tRoll),'\n']);
end



%check the intraday 1m bar information from the roll date onwards
fprintf('download the intraday 1m bar info since the roll date......\n');
tLastBd = businessdate(today,-1);
intradayData = contract2.getTimeSeries('connection','bloomberg',...
    'fields',fieldName,...
    'frequency','1m','fromdate',tRoll,'todate',tLastBd);
%note:there is still data ISSUE in BLOOMBERG intraday end of day price as
%it is quoted as the settle price rather than the close price. however, the
%daily price is quoted as the close price as set in the BLOOMBERG terminal
intradayData = [intradayData,floor(intradayData(:,1))];
businessDays = sort(unique(intradayData(:,end)));
[t,idx1,idx2] = intersect(businessDays,volume2(:,1));
officialClose = [t,volume2(idx2,2:3)];
%now replace the intradayData with the correct close price
fprintf('replace the intraday data with the correct end of day close price...\n');
for i = 1:size(officialClose,1)
    officialCloseTime = datenum([datestr(officialClose(i,1)),' 14:59:00']);
    idx = find(intradayData(:,1)==officialCloseTime);
    if isempty(idx)
        fprintf([datestr(officialCloseTime),'\n']);
        error('internal error!')
    end
    intradayData(idx,2) = officialClose(i,2);
end
timeseries_plot(intradayData(:,1:2),'dateformat','dd-mmm');

%
tradingHours = regexp(contract2.TradingHours,';','split');
tradingWindow = 0;
for i = 1:3
    if ~strcmpi(tradingHours{i},'n/a')
        hhstart = str2double(tradingHours{i}(1:2));
        mmstart = str2double(tradingHours{i}(4:5));
        hhend = str2double(tradingHours{i}(7:8));
        mmend = str2double(tradingHours{i}(10:11));
        if hhend < 9 && hhend > 0
            tradingWindow = tradingWindow+(hhend+24)*60+mmend-(hhstart*60+mmstart);
        else
            tradingWindow = tradingWindow+hhend*60+mmend-(hhstart*60+mmstart);
        end
    end
end

mktOpen = [tradingHours{1}(1:5),':00'];
mktClose = [tradingHours{2}(end-4:end),':00'];
if ~strcmpi(tradingHours{3},'n/a')
    mktOpenPM = [tradingHours{3}(1:5),':00'];
% ? ? mktClosePM = [tradingHours{3}(end-4:end),':00'];
end
% for i = 1:size(officialClose,1)
for i = 1:1
    if i == 1
        fromTime = [datestr(officialClose(i,1)),' ',mktOpen];
    else
        fromTime = [datestr(officialClose(i-1,1)),' ',mktOpenPM];
    end
    toTime = [datestr(officialClose(i,1)),' ',mktClose];
    intradayData_i = timeseries_window(intradayData,'FromDate',fromTime,...
        'ToDate',toTime,'TradingHours',contract2.TradingHours,...
        'TradingBreak',rb1705.TradingBreak);
    ret_i = [intradayData_i(2:end,1),log(intradayData_i(2:end,2)./intradayData_i(1:end-1,2))];
    timeseries_plot(intradayData_i(:,1:2),'dateformat','HH:MM');
    timeseries_plot(ret_i,'dateformat','HH:MM');
    
    %the following script is the intraday straddle part,which later will be
    %consolidated into some standlone function form
    tradingPlatform = cTradingPlatform;
    windowLength = 15;
    lambda = 0.94;
    retRef = mean(ret_i(1:windowLength-1,2));
    tmp = zeros(size(intradayData_i,1)-windowLength,2);
    volRef = std(ret_i(1:windowLength-1,2));
    tmp(1,1) = ret_i(windowLength-1,1);
    tmp(1,2) = volRef;
    for j = windowLength+1:size(intradayData_i,1)
        ret_j = ret_i(j-1,2);
        volRef = volRef^2*lambda+(1-lambda)*ret_j^2;
        volRef = sqrt(volRef);
        tmp(j-windowLength+1,1) = ret_i(j-1,1);
        tmp(j-windowLength+1,2) = volRef;
    end
    timeseries_plot(tmp,'dateformat','HH:MM');
end

