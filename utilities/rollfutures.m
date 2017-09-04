function results = rollfutures(asset,varargin)
%function to roll futures based on the trading volume, i.e.the 2nd futures'
%trading volume exceeds the 1st futures would be treat as an indicator 
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('AssetName',@ischar);
p.addParameter('LengthOfPeriod','',@ischar);
p.addParameter('CalcDailyReturn',true,@islogical);
p.addParameter('CalibrateVolModel',true,@islogical);
p.addParameter('PrintResults',false,@islogical);
p.addParameter('UpdateTimeSeries',true,@islogical);
p.addParameter('PlotConditonalVariance',false,@islogical);
p.addParameter('ForecastPeriod',21,@isnumeric);
p.parse(asset,varargin{:});
assetName = p.Results.AssetName;
lengthOfPeriod = p.Results.LengthOfPeriod;
calcDailyReturn = p.Results.CalcDailyReturn;
calibrateVolModel = p.Results.CalibrateVolModel;
printResults = p.Results.PrintResults;
updateTimeSeries = p.Results.UpdateTimeSeries;
plotConditionalVariance = p.Results.PlotConditonalVariance;
nForecastPeriod = p.Results.ForecastPeriod;

if calibrateVolModel && ~calcDailyReturn
    error('rollfutures:vol model can be only estimated given daily returns')
end

if strcmpi(assetName,'govtbond_5y') || strcmpi(assetName,'govtbond_10y') ||...
        strcmpi(assetName,'eqindex_300') || strcmpi(assetName,'eqindex_50') ||...
        strcmpi(assetName,'eqindex_500')
    isFinancial = true;
else
    isFinancial = false;
end

if ~isholiday(today)
    hh = hour(now);
    if hh > 16 && hh < 21   %market is still closed
        dateTo = today;
    else
        if isFinancial
            if hh <= 15
                dateTo = businessdate(today,-1);
            else
                dateTo = today;
            end
        else
            dateTo = businessdate(today,-1);
        end
    end
else
    dateTo = businessdate(today,-1);
end

%list all futures contracts
%and select futures contracts that are within the period of interest 
%
assetInfo = getassetinfo(assetName);
windCode = assetInfo.WindCode;
exchangeCode = assetInfo.ExchangeCode;
contractName = listcontracts(assetName);
contractList = cell(length(contractName),1);
expiries = zeros(length(contractName),1);
count = 0;
for i = 1:length(contractName)
    n = length(contractName{i});
    tenor = contractName{i}(length(windCode)+1:n-length(exchangeCode));
    contractList{i} = cContract('AssetName',assetName,'Tenor',tenor);
    %alternatively we can call the following code to generate the
    %contractList, i.e.
    %contractList{i} = windcode2contract(contractNames(i)(1:end-length(exchangeCode));
    try
        expiries(i) = contractList{i}.Expiry;
        count = count + 1;
    catch
        %in case the expiry is failed to pop-up, it could be either the
        %contract list of the asset is not updated yet or there could be
        %some database issue which we can create a work around to solve it
        asset = cAsset('AssetName',assetName,'ContractListUpdateFlag',true);
        try
            expiries(i) = contractList{i}.Expiry;
            count = count + 1;
        catch
            %expiry still not poped-up and we need a work-around here
            %todo:pop all special cases into one general function later on
            if strcmpi(assetName,'govtbond_5y')
                tenor = contractList{i}.Tenor;
                futCode = getfutcode(str2double(tenor(end-1:end)));
                assetInfo = getassetinfo(assetName);
                bbgCode = assetInfo.BloombergCode;
                sec = [bbgCode,futCode,tenor(2),' Comdty'];
                c = bbgconnect;
                data = getdata(c,sec,'last_tradeable_dt');
                try
                    expiries(i) = data.last_tradeable_dt;
                    count = count + 1;
                    c.close;
                catch
                    fprintf('\t%s not found via bloomberg search\n',sec);
                    c.close;
                    continue;
                end                
            else
                continue
            end
%             continue
        end
        asset.ContractListUpdateFlag = false;    
    end
    
    if expiries(i) < dateTo
        status = 'dead';
    else
        status = 'live';
    end
    try
        tsobj = contractList{i}.getTimeSeriesObj('Connection','Bloomberg',...
            'Frequency','1d');
        lastentry = datenum(tsobj.getLastDateEntry);
        %note:for the live contract we will update the timeseries in case
        %it is neeeded. However,we will always update the timeseries of an
        %expired contract in case the dataset is not complete for various
        %reasons
        if strcmpi(status,'live') && lastentry < dateTo && updateTimeSeries
            contractList{i}.updateTimeSeries('Connection','Bloomberg',...
                'Frequency','1d');
        elseif strcmpi(status,'dead') && lastentry < expiries(i)
            contractList{i}.updateTimeSeries('Connection','Bloomberg',...
                'Frequency','1d');
        end
    catch
        %note:in case the timeseries object cannot be found via calling the
        %'getTimeSeriesObj' method of a cContract object, it indicates that
        %the timeseries is not initialized yet and thus 'initTimeSeries'
        %method of a cContract object needs to be called
        contractList{i}.initTimeSeries('Connection','Bloomberg',...
            'Frequency','1d',...
            'DataSource','internet');
    end
end

contractList = contractList(1:count);
%
%note:we'd better re-produce the continouous futures(index) from its first
%contract and then cut off from the obsevation period start date
firstFuturesIdx = 1;

for i = firstFuturesIdx:length(contractList)
%     expiry = contractList{i}.Expiry;
    if expiries(i) > dateTo
        break
    end
end

lastFuturesIdx = i;
%check whether the first list futures which expires after the last business
%date has been rolled or not
if i < length(contractList)
    idx1 = i;
    idx2 = idx1+1;
    vol1 = contractList{idx1}.getTimeSeries('Connection','bloomberg',...
        'Fields',{'close','oi'},'FromDate',dateTo,'ToDate',dateTo,...
        'frequency','1d');
    vol2 = contractList{idx2}.getTimeSeries('Connection','bloomberg',...
        'Fields',{'close','oi'},'FromDate',dateTo,'ToDate',dateTo,...
        'frequency','1d');
    if vol1(1,end) < vol2(1,end)
        lastFuturesIdx = lastFuturesIdx+1;
    end
end

futures = cell(lastFuturesIdx-firstFuturesIdx+1,1);
for i = 1:length(futures)
    futures{i} = contractList{i+firstFuturesIdx-1};
end

%download daily data into local file and load it into memory
volumeData = cell(length(futures),1);
for i = 1:length(futures)
    expiry = futures{i}.Expiry;
    fromDate = expiry - 365;
    toDate = min(expiry,dateTo);
    try
        volumeData{i} = futures{i}.getTimeSeries('Connection','bloomberg',...
            'Fields',{'close','oi'},'FromDate',fromDate,...
            'ToDate',toDate,'frequency','1d');
    catch
        %in case the data is missing or invalid
        continue;
    end
        
    %--- some data analysis here to remove the NaNs
    if ~isempty(volumeData{i})    
        idx = ~isnan(volumeData{i}(:,2));
        volumeData{i} = volumeData{i}(idx,:);
    end
    
end

%build continous futures with taking account of rolling futures
rollInfo = cell(length(futures)-1,6);
for i = 1:length(futures)-1
    data1 = volumeData{i};
    data2 = volumeData{i+1};
    if isempty(data1) || isempty(data2)
        continue
    else
        [t,idx1,idx2] = intersect(data1(:,1),data2(:,1));
        volumediff = [t,data1(idx1,end)-data2(idx2,end)];
        %in case of bad quality data and there is no overlap between
        %contract prices and volume
        if isempty(volumediff)
            continue
        end
        tRoll = find(volumediff(:,end)>0);
        if isempty(tRoll)
            continue
        end
        if tRoll(end) == size(volumediff,1)
            continue
        end
        tRoll = volumediff(tRoll(end)+1,1);
        rollInfo{i,1} = tRoll;
        rollInfo{i,2} = find(data1(:,1) == tRoll);
        rollInfo{i,3} = find(data2(:,1) == tRoll);
        rollInfo{i,4} = futures{i}.WindCode;
        rollInfo{i,5} = futures{i+1}.WindCode;
        rollInfo{i,6} = datestr(tRoll);
    end    
end

rollFirstIdx = 1;
i=rollFirstIdx;
while i < size(rollInfo,1)
    for i = rollFirstIdx:size(rollInfo,1)
        if isempty(rollInfo{i,1})
            rollFirstIdx = i+1;
            break
        end
    end
%     check = true;
end
% rollInfo = rollInfo(rollFirstIdx:end,:);

count = 0;
for i = rollFirstIdx:size(rollInfo,1)
    if isempty(rollInfo{i,1})
        continue
    end
    
    if i ==  1 && ~isempty(rollInfo{i,1})
        count = count + rollInfo{i,2};
    elseif i > 1 && isempty(rollInfo{i-1,1})
        count = count + rollInfo{i,2};
    else
        count = count + rollInfo{i,2} - rollInfo{i-1,3};
    end
end
count = count + size(volumeData{end},1)-rollInfo{end,3};
continousFutures = zeros(count,3);
idx = 0;
%on the roll date, we choose the 
for i = rollFirstIdx:size(rollInfo,1)
    if isempty(rollInfo{i,1})
        continue
    end
    if i == 1 && ~isempty(rollInfo{i,1})
        idx = idx+rollInfo{i,2};
        continousFutures(1:idx,1:2) = volumeData{i}(1:idx,1:2);
        continousFutures(idx,3) = 1;%roll date indicator
    elseif i > 1 && isempty(rollInfo{i-1,1})
        idx = idx + rollInfo{i,2};
        continousFutures(1:idx,1:2) = volumeData{i}(1:idx,1:2);
        continousFutures(idx,3) = 1;%roll date indicator
    else
        numNewEntry = rollInfo{i,2} - rollInfo{i-1,3};
        continousFutures(idx+1:idx+numNewEntry,1:2) = volumeData{i}(rollInfo{i-1,3}+1:rollInfo{i,2},1:2);
        continousFutures(idx+numNewEntry,3) = 1;%roll date indicator
        idx = idx + numNewEntry;
    end
end
numNewEntry = size(volumeData{end},1)-rollInfo{end,3};
continousFutures(idx+1:idx+numNewEntry,1:2) = volumeData{end}(rollInfo{end,3}+1:size(volumeData{end},1),1:2);

if calcDailyReturn
    %we record the close price as of the first futures contract on the roll
    %date and we record the close price as of the second futures contract
    %on the next business date after the roll date
    ret = [continousFutures(2:end,1),log(continousFutures(2:end,2)./continousFutures(1:end-1,2))];
    for i = 1:size(rollInfo,1)
        if ~isempty(rollInfo{i,1})
            tRoll = rollInfo{i,1};
            idx1 = rollInfo{i,2};
            idx2 = rollInfo{i,3};
            %sanity check to make sure that both prices on recored on the
            %same business date
            if volumeData{i}(idx1,1) ~= tRoll || ...
                    volumeData{i+1}(idx2,1) ~= tRoll
                error('internal error')
            end
            %we'd take the return of the second futures contract after the
            %roll date
            if idx2 == size(volumeData{i+1},1)
                continue;
            end
            ret2 = log(volumeData{i+1}(idx2+1,2)/volumeData{i+1}(idx2,2));
            idx = find(ret(:,1) == tRoll)+1;
            ret(idx,2) = ret2;
        end
    end
    if ~isempty(lengthOfPeriod)
        dateFrom = dateadd(dateTo,['-',lengthOfPeriod]);
        ret = timeseries_window(ret,'FromDate',dateFrom,'ToDate',dateTo);
    end
    
end


if calibrateVolModel
    %specify an AR(1) model for the conditional mean of the returns and
    %GARCH(1,1) model for the conditional variance, this is a model of the
    %form r_t = c + AR{1}*r_{t-1}+ebsilon_t
    %where ebsilon_t = sigma_t*z_t
    %and
    %sigma_t^2=k+GARCH{1}*sigma_{t-1}^2+ARCH{1}*ebsilon_{t-1}^2
    %where z_t is an i.i.d standardized Gaussian process
    model = arima('ARLags',1,'Variance',garch(1,1));
    modelEstimate = estimate(model,ret(:,2),'print',printResults);
    %infer and plot the conditional variance and standard residuals. Also
    %output loglikelihood objective function values
    %[E,V] = infer(Mdl,Y) infers residuals and conditional variances of a
    %univariate AR|MA model fit to data Y
    paramGarch = modelEstimate.Variance.GARCH{1};
    paramArch = modelEstimate.Variance.ARCH{1};
    paramConst = modelEstimate.Variance.Constant;
    lv = sqrt(252*paramConst/(1-paramGarch-paramArch));
    
    [E0,V0,~] = infer(modelEstimate,ret(:,2));
    if plotConditionalVariance
        stdResidual = E0./sqrt(V0);
        close all;
        subplot(2,1,1);
        xx = 1:1:size(V0,1);
        plot(xx,V0);
        title(['Conditional Variance (',assetName,')']);
        if ~isempty(lengthOfPeriod)
            xlabel(['number of days since ',datestr(dateFrom)]);
        else
            xlabel(['number of days since ',datestr(ret(1,1))]);
        end
        subplot(2,1,2);
        qqplot(stdResidual);
    end
    
    %forecast variance for a month period
    [Y,YMSE,V] = forecast(modelEstimate,nForecastPeriod,'Y0',ret(:,2),'E0',E0,'V0',V0);
    upper = Y + 1.96*sqrt(YMSE);
    lower = Y - 1.96*sqrt(YMSE);
    fv = sqrt(sum(V)/nForecastPeriod*252);
    
    hv = std(ret(end-nForecastPeriod+1:end,2))*sqrt(252);
    lambda = modelEstimate.Variance.GARCH{1};
    ewmav = abs(ret(end-nForecastPeriod+1,2));
    for i = 2:nForecastPeriod
        ewmav = ewmav^2*lambda+ret(end-nForecastPeriod+i,2)^2*(1-lambda);
        ewmav = sqrt(ewmav);
    end
    ewmav = ewmav*sqrt(252);
    
    forecastResults = struct('LongTermAnnualVol',lv,...
        'HistoricalAnnualVol',hv,...
        'EWMAAnnualVol',ewmav,...
        'ForecastedAnnualVol',fv,...
        'ForecastedVariance',V,...
        'ForecastedReturn',Y,...
        'ForecastedReturnError',YMSE);
    
    if plotConditionalVariance
        N = size(E0,1);
        figure
        subplot(2,1,1)
        plot(E0,'Color',[.75,.75,.75])
        hold on
        plot(N+1:N+nForecastPeriod,Y,'r','LineWidth',2)
        plot(N+1:N+nForecastPeriod,[upper,lower],'k--','LineWidth',1.5)
        xlim([0,N+nForecastPeriod])
        title(['Forecasted Returns (',assetName,')'])
        hold off
        subplot(2,1,2)
        plot(V0,'Color',[.75,.75,.75])
        hold on
        plot(N+1:N+nForecastPeriod,V,'r','LineWidth',2);
        xlim([0,N+nForecastPeriod])
        title(['Forecasted Conditional Variances (',assetName,')'])
        hold off
    end
end

if calcDailyReturn && ~calibrateVolModel 
    results = struct('Contracts',{futures},...
        'ContinousFutures',{continousFutures},...
        'RollInfo',{rollInfo},...
        'DailyReturn',{ret},...
        'ForecastResults',{forecastResults});
elseif calcDailyReturn && calibrateVolModel
    results = struct('Contracts',{futures},...
        'ContinousFutures',{continousFutures},...
        'RollInfo',{rollInfo},...
        'DailyReturn',{ret},...
        'VolModel',modelEstimate,...
         'ForecastResults',{forecastResults});
else
    results = struct('Contracts',{futures},...
        'ContinousFutures',{continousFutures},...
        'RollInfo',{rollInfo},...
         'ForecastResults',{forecastResults});
end
    

end