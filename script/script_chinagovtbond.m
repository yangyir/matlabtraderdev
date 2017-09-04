%%
%download/update timeseries from bloomberg server
t1509 = cContract('assetname','govtbond_10y','tenor','1509');
t1512 = cContract('assetname','govtbond_10y','tenor','1512');
t1603 = cContract('assetname','govtbond_10y','tenor','1603');
t1606 = cContract('assetname','govtbond_10y','tenor','1606');
t1609 = cContract('assetname','govtbond_10y','tenor','1609');
t1612 = cContract('assetname','govtbond_10y','tenor','1612');
t1703 = cContract('assetname','govtbond_10y','tenor','1703');
t1706 = cContract('assetname','govtbond_10y','tenor','1706');
futures = {t1509;t1512;t1603;t1606;t1609;t1612;t1703;t1706};
nFutures = size(futures,1);
for i = 1:nFutures
    timeseries_update(futures{i},'TickDataUpdate',false);
end

%%
%retrieve data fields from local file
fprintf('retrieve data from local files.......\n');
fields = {'time','open','high','low','close','volume','openint'};
nFields = length(fields);
tsintraday = cell(nFutures,2);
tsdaily = cell(nFutures,2);
for i = 1:nFutures
    tsintraday{i,1} = futures{i}.BloombergCode;
    tsintraday{i,2} = futures{i}.getTimeSeries('connection','bloomberg','frequency','1m');
    %
    tsdaily{i,1} = futures{i}.BloombergCode;
    tsdaily{i,2} = futures{i}.getTimeSeries('connection','bloomberg','frequency','1d');
end
fprintf('all data loaded from local files......\n');

%%
%plot timeseries
fieldName = 'close';
contractName = 'TFTH7 Comdty';

fieldIdx = strcmpi(fields,fieldName)*(1:nFields)';
for i = 1:nFutures
    if strcmpi(tsintraday{i,1},contractName)
        contractIdx = i;
        break
    end
end

%plot the price
fprintf(['plot time series of ',fieldName,' of ',contractName,'......\n']);
timeseries_plot([tsintraday{contractIdx,2}(:,1),tsintraday{contractIdx,2}(:,fieldIdx)],...
    'dateformat','mmm-yy',...
    'title',['1-minute intraday ',fieldName,' of ',contractName]);

fieldName = 'volume';
fieldIdx = strcmpi(fields,fieldName)*(1:nFields)';
fprintf(['plot time series of ',fieldName,' of ',contractName,'......\n']);
timeseries_plot([tsintraday{contractIdx,2}(:,1),tsintraday{contractIdx,2}(:,fieldIdx)],...
    'dateformat','mmm-yy',...
    'title',['1-minute intraday ',fieldName,' of ',contractName]);

%%
%check the roll dates
fprintf('check the roll dates of the govtbond futures......\n');
fieldName = 'volume';
fieldIdx = strcmpi(fields,fieldName)*(1:nFields)';
nRolls = 0;
%first to count the number of rolls between futures, i.e. if the futures
%expired in the past, it has to be rolled. In addition, we need to check
%whether the 1st live futures' trading volume is still bigger than the
%2nd live futures' trading volume
for i = 1:nFutures
    if futures{i}.Expiry < today
        nRolls = nRolls+1;
    end
end
nRollsOld = nRolls;
for i = nRollsOld+1:nFutures-1
    [~,idx1,idx2] = intersect(tsdaily{i,2}(:,1),tsdaily{i+1,2}(:,1));
    volumeDiff = tsdaily{i,2}(idx1,fieldIdx) - tsdaily{i+1,2}(idx2,fieldIdx);
    rollIdx = find(volumeDiff>0);
    if rollIdx(end) == size(volumeDiff,1)
        %the roll hasn't happen yet since the 1st live futures
        %nothing to do
    else
        nRolls = nRolls+1;
    end
end
clear nRollsOld
    
rollDates = zeros(nRolls,3);
%3 columns in 'rollDates',the first column defines the roll date,i.e. the
%date on which the second futures' trading volume exceed the first one, the
%2nd column defines the row idx for the first futures in its daily data matrix
%3rd column defines the row idx for the second futures in its daily data
%matrix
volumeCompare = cell(nRolls,1);
%volumeCompare records all the volume information for pair futures on the
%same cob date
for i = 1:nRolls
    [t,idx1,idx2] = intersect(tsdaily{i,2}(:,1),tsdaily{i+1,2}(:,1));
    volumeCompare{i} = [t,tsdaily{i,2}(idx1,fieldIdx),...
        tsdaily{i+1,2}(idx2,fieldIdx),...
        tsdaily{i,2}(idx1,fieldIdx)-tsdaily{i+1,2}(idx2,fieldIdx)];
    rollIdx = find(volumeCompare{i}(:,end)>0);
    rollIdx = rollIdx(end)+1;
    rollDates(i,1) = volumeCompare{i}(rollIdx,1);
    rollDates(i,2) = find(tsdaily{i,2}(:,1)==rollDates(i,1));
    rollDates(i,3) = find(tsdaily{i+1,2}(:,1)==rollDates(i,1));
end

%check the daily price change and roll with replicated continuous futures
fprintf('roll the futures......\n');
fieldName = 'close';
fieldName2 = 'volume';
fieldIdx = strcmpi(fields,fieldName)*(1:nFields)';
fieldIdx2 = strcmpi(fields,fieldName2)*(1:nFields)';
nPrice = rollDates(1,2);
%for the 2nd roll onwards,the number of observations are the date counts
%bewtween the last roll date and the following roll date
for i = 2:nRolls
    nPrice = nPrice + rollDates(i,2)-rollDates(i-1,3);
end
nPrice = nPrice + size(tsdaily{nRolls+1,2},1)-rollDates(nRolls,3);
%take the volume weighted average price of the 1st and 2nd contract on the roll
%dates
prices = zeros(nPrice,2);
prices(1:rollDates(1,2),1) = tsdaily{1,2}(1:rollDates(1,2),1);
prices(1:rollDates(1,2)-1,2) = tsdaily{1,2}(1:rollDates(1,2)-1,fieldIdx);
%sanity check that the dates are the same
if tsdaily{1,2}(rollDates(1,2),1) ~= tsdaily{2,2}(rollDates(1,3),1)
    error('internal error!pls check with the code!')
end
px1 = tsdaily{1,2}(rollDates(1,2),fieldIdx);
px2 = tsdaily{2,2}(rollDates(1,3),fieldIdx);
volume1 = tsdaily{1,2}(rollDates(1,2),fieldIdx2);
volume2 = tsdaily{2,2}(rollDates(1,3),fieldIdx2);
prices(rollDates(1,2),2) = (px1*volume1+px2*volume2)/(volume1+volume2);
count = rollDates(1,2);
for i = 2:nRolls
    %column for time
    prices(count+1:count+rollDates(i,2)-rollDates(i-1,3),1) = ...
        tsdaily{i,2}(rollDates(i-1,3)+1:rollDates(i,2),1);
    %column for selected field
    prices(count+1:count+rollDates(i,2)-rollDates(i-1,3)-1,2) = ...
        tsdaily{i,2}(rollDates(i-1,3)+1:rollDates(i,2)-1,fieldIdx);
    
    %sanity check
    if tsdaily{i,2}(rollDates(i,2),1) ~= tsdaily{i+1,2}(rollDates(i,3),1)
        error('internal error!pls check with the code!')
    end

    px1 = tsdaily{i,2}(rollDates(i,2),fieldIdx);
    px2 = tsdaily{i+1,2}(rollDates(i,3),fieldIdx);
    volume1 = tsdaily{i,2}(rollDates(i,2),fieldIdx2);
    volume2 = tsdaily{i+1,2}(rollDates(i,3),fieldIdx2);
    prices(count+rollDates(i,2)-rollDates(i-1,3),2) = ...
        (px1*volume1+px2*volume2)/(volume1+volume2);
    count = count + rollDates(i,2)-rollDates(i-1,3);
end
%process after the last roll date
prices(count+1:end,1) = tsdaily{nRolls+1,2}(rollDates(nRolls,3)+1:end,1);
prices(count+1:end,2) = tsdaily{nRolls+1,2}(rollDates(nRolls,3)+1:end,fieldIdx);
fprintf('plot timeseries of the price of the continuous futures......\n');
timeseries_plot(prices,'dateformat','mmm-yy',...
    'title','daily price of the continuous govtbond futures');

fprintf('plot timeseries of the daily price variance of the continuous futures......\n');
ret = [prices(2:end,1),log(prices(2:end,2)./prices(1:end-1,2))];
variance = [ret(:,1),ret(:,2).^2];
timeseries_plot(variance,'dateformat','mmm-yy',...
    'title','daily variance of the continuous govtbond futures');

%%
%check the spread behaviour around the roll dates
%user input
checkIdx = nRolls;

rollPeriodIdx = rollDates(checkIdx,2)-2:rollDates(checkIdx,2)+2;
rollPeriod = tsdaily{checkIdx,2}(rollPeriodIdx,1);
%check the intraday price and volume data during the roll period
rollPeriodData = cell(2,1);
for i = 1:2
    rollPeriodData{i} = futures{checkIdx+i-1}.getTimeSeries('connection','bloomberg',...
        'frequency','1m',...
        'FromDate',[datestr(rollPeriod(1)),' 09:15:00'],...
        'ToDate',[datestr(rollPeriod(end)),' 15:15:00']);
end
fieldName = 'close';
fieldIdx = strcmpi(fields,fieldName)*(1:nFields)';
[t,idx1,idx2] = intersect(rollPeriodData{1}(:,1),rollPeriodData{2}(:,1));
rollPeriodSpread = [t,rollPeriodData{1}(idx1,fieldIdx),...
    rollPeriodData{2}(idx2,fieldIdx),...
    rollPeriodData{1}(idx1,fieldIdx)-rollPeriodData{2}(idx2,fieldIdx)];

close all;
timeseries_plot([rollPeriodSpread(:,1),rollPeriodSpread(:,2)],...
    'dateformat','dd-mmm',...
    'title',['price of ',futures{checkIdx}.BloombergCode]);

timeseries_plot([rollPeriodSpread(:,1),rollPeriodSpread(:,3)],...
    'dateformat','dd-mmm',...
    'title',['price of ',futures{checkIdx+1}.BloombergCode]);

timeseries_plot([rollPeriodSpread(:,1),rollPeriodSpread(:,4)],...
    'dateformat','dd-mmm',...
    'title',['spread between ',futures{checkIdx}.WindCode,' and ',...
    futures{checkIdx+1}.BloombergCode]);

%%
%garch model vol estimation
nForecastPeriod = 30;
modelGarch = garch(1,1);
modelCalibrated = estimate(modelGarch,ret(:,2));
vF1 = forecast(modelCalibrated,nForecastPeriod,'Y0',ret(:,2));
vF2 = forecast(modelCalibrated,nForecastPeriod);

figure
plot(variance(:,2),'Color',[.7,.7,.7])
hold on
plot(size(variance,1)+1:size(variance,1)+nForecastPeriod,vF1,'r','LineWidth',2);
plot(size(variance,1)+1:size(variance,1)+nForecastPeriod,vF2,':','LineWidth',2);
title('Forecasted Conditional Variances')
legend('Observed','Forecasts with Presamples',...
		'Forecasts without Presamples','Location','NorthEast')
hold off

%%
%naive intraday trading strategy
%trade with the volatility rather than the direction of the underlying
%i.e.once the previous daily volatility is higher than a certain level
%create a synthetic straddle position o/w create a synthetic short straddle
%position with strict stop-loss control


    


