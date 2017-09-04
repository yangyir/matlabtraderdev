function [results,platformOut,futuressettleinfo] = autotrade_intraday_vanilla(valdate,books,strategy,platformIn,vols,varargin)
%description:function to auto hedge or replicate the (synthetic) vanilla
%option positions and calculate the eod pnl/risk of the vanilla option books
%inputs:
%   "books" define the vanilla books, vanilla options with the same
%   underlyings are combined into the same book.

%   strategy defines the trading strategy of the options, e.g. delta hedge
%   one strategy associates with one book only

%   platformIn is the trading platform for the listed underlying futures,
%   it has the information of any carried hedging postions in the past

%read input variables and check the variable's datatypes
p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('ValuationDate',@(x)validateattributes(x,{'numeric','char'},{},'ValuationDate'));
p.addRequired('Product',@(x)validateattributes(x,{'cProduct'},{},'Product'));
p.addRequired('Strategy',@(x)validateattributes(x,{'cStrategy'},{},'Strategy'));
p.addRequired('Platform',@(x)validateattributes(x,{'cTradingPlatform'},{},'Platform'));
p.addRequired('MarketVols',@(x)validateattributes(x,{'cell','cMarketVol'},{},'MarketVols'));
p.addParameter('DataSampling','eod',@(x)validateattributes(x,{'char'},{},'DataSampling'));
p.addParameter('CalcRiskCarry',true,@(x)validateattributes(x,{'logical'},{},'CalcRiskCarry'));
p.addParameter('LiquidityAdjustment',0,@(x)validateattributes(x,{'numeric'},{},'LiquidityAdjustment'));
p.addParameter('MarketMoveBreakEven',0,@(x)validateattributes(x,{'numeric'},{},'MarketMoveBreakEven'));
p.parse(valdate,books,strategy,platformIn,vols,varargin{:});
valdate = datenum(p.Results.ValuationDate);
product = p.Results.Product;
vanillabooks = product.Books;
vanillastrategy = p.Results.Strategy;
platformOut = p.Results.Platform;
marketvols = p.Results.MarketVols;
samplingfreq = p.Results.DataSampling;
if strcmpi(samplingfreq,'eod')
    eodonly = true;
    useintradaybar = false;
    useintradaytick = false;
else
    eodonly = false;
    useintradaybar = false;
    useintradaytick = false;
    if strcmpi(samplingfreq,'intradaybar')
        useintradaybar = true;
    elseif strcmpi(samplingfreq,'intradaytick')
        useintradaytick = true;
    end
end
calccarry = p.Results.CalcRiskCarry;
liqadj = p.Results.LiquidityAdjustment;
breakeveninfo = p.Results.MarketMoveBreakEven;

%calculate the last expiry date of each book
%and get the underlier futures contract of each book
nBook = size(vanillabooks,1);

lastExpiry = zeros(nBook,1);
futures = cell(nBook,1);
for i = 1:nBook
    book_i = vanillabooks{i};
    lastExpiry(i) = datenum(book_i{1}.ExpiryDate);
    futures{i} = book_i{1}.Underlier;
    nSec = size(book_i,1);
    for j = 2:nSec
        expiry_j = datenum(book_i{j}.ExpiryDate);
        if expiry_j > lastExpiry(i)
            lastExpiry(i) = expiry_j;
        end
    end
end

%%
%update the eod timeseries of the underlying futures if required
for i = 1:nBook
    try
        tsobj = futures{i}.getTimeSeriesObj('connection','bloomberg',...
            'frequency','1d');
    catch
        %in case the time series is not locally stored, it needs to be
        %downloaded from the internet server
        fprintf(['init timeseries of ',futures{i}.WindCode,'...\n']);
        tsobjs = futures{i}.initTimeSeries('connection','bloomberg',...
            'datasource','internet',...
            'frequency','1d');
        tsobj = tsobjs{1};
    end
    lastdateentry = datenum(tsobj.getLastDateEntry);
    %update timeseries if and only if the contract hasn't expired yet and
    %also the last date entry of the timeseries is before the valuation
    %date
    if lastdateentry < valdate && valdate <= lastExpiry(i)
        futures{i}.updateTimeSeries('connection','bloomberg',...
            'frequency','1d');
    end
    
    if useintradaybar
        try
            tsobj = futures{i}.getTimeSeriesObj('connection','bloomberg',...
                'frequency','1m');
        catch
            %in case the time series is not locally stored, it needs to be
            %downloaded from the internet server
            tsobjs = futures{i}.initTimeSeries('connection','bloomberg',...
                'datasource','internet',...
                'frequency','1m');
            tsobj = tsobjs{1};
        end
        lastdateentry = datenum(tsobj.getLastDateEntry);
        if lastdateentry < valdate && valdate <= lastExpiry(i)
            futures{i}.updateTimeSeries('connection','bloomberg',...
                'frequency','1m');
        end
    end
    
    if useintradaytick
        try
            tsobj = futures{i}.getTimeSeriesObj('connection','bloomberg','frequency','tick');
        catch
            %in case the time series is not locally stored, it needs to be
            %downloaded from the internet server
            tsobjs = futures{i}.initTimeSeries('connection','bloomberg','datasource','internet','frequency','tick');
            tsobj = tsobjs{1};
        end
        lastdateentry = datenum(tsobj.getLastDateEntry);
        if lastdateentry < valdate && valdate <= lastExpiry(i)
            futures{i}.updateTimeSeries('connection','bloomberg','frequency','tick');
        end
    end
    
end

%%
%pop-up the market prices for the underlying on that trading date
futuressettleinfo = cell(nBook,1);
futuresintradayinfo = cell(nBook,1);
vanillapv = zeros(nBook,1);
for i = 1:nBook
    if valdate > lastExpiry(i)
        continue
    end
    previousdate = businessdate(valdate,-1);
    eodsettle = futures{i}.getTimeSeries('connection','bloomberg',...
        'frequency','1d',...
        'fields',{'close','volume'},...
        'fromdate',previousdate,...
        'todate',valdate);
    th = regexp(futures{i}.TradingHours,';','split');
    mktclose = [th{2}(end-4:end),':00'];
    %for the strategy object to use we need to change the date entry of the
    %eod of day settle price
    eodsettle(end,1) = datenum([datestr(valdate),' ',mktclose]);
    futuressettleinfo{i} = struct('Instrument',futures{i},...
        'Time',eodsettle(end,1),...
        'Price',eodsettle(end,2),...
        'Volume',eodsettle(end,3),...
        'PreviousPrice',eodsettle(1,2));
%     fprintf([datestr(futuressettleinfo{i}.Time),':%.2f\n'],futuressettleinfo{i}.Price);
    if ~eodonly
        %we need to find the previous market close
        previousclosetime = datenum([datestr(previousdate),' ',mktclose]) + 1/1440;
        
        if useintradaybar
            intradaybar = futures{i}.getTimeSeries('connection','bloomberg',...
                'frequency','1m',...
                'fields',{'close','volume'},...
                'fromdate',previousclosetime,...
                'todate',[datestr(valdate),' ',mktclose]);
            %we've found an issue within the intraday bar data, i.e. the last
            %trade price for the futures just before the market close around
            %3pm Beijing time is marked as the settle price rather than the
            %close price. for this reason, our backtest process may ignore
            %the last price entry which might lead to significant biased
            %results
            futuresintradayinfo{i} = intradaybar;
        
        elseif useintradaytick
            intradaytick = futures{i}.getTimeSeries('connection','bloomberg',...
                'frequency','tick',...
                'fromdate',previousclosetime,...
                'todate',[datestr(valdate),' ',mktclose]);
            futuresintradayinfo{i} = intradaytick;
            
        end
%         fprintf([datestr(futuresintradayinfo{i}(end,1)),':%.2f\n'],futuresintradayinfo{i}(end,2));
    end
end

%%
%
%first do an end of day valuation
%todo:all the curve and vol object are updated daily and later on we'll
%create a database to download them from there
%once the bootstrap functionality is added to the curve object, curve
%object as long as other objects shall be stored locally and loaded
%everytime for pricing and risk-management
%
model = loadobjfromfile('model_ccbsmc','model');
yc = CreateObj('domestic','yieldcurve','valuationdate',valdate,'Currency','CNY');
for i = 1:nBook
    if valdate > lastExpiry(i)
        continue
    else
        if ~eodonly
            lastprice = futuresintradayinfo{i}(end,2);
        else
            lastprice = futuressettleinfo{i}.Price;
        end
        book_i = vanillabooks{i};
        assetname = book_i{1}.AssetName;
        mktdata = CreateObj([assetname,'_mktdata'],'mktdata',...
                      'valuationdate',yc.ValuationDate,...
                      'assetName',assetname,...
                      'Currency',yc.Currency,...
                      'Type','Forward','Spot',lastprice);
        dictionarypv = CreateObj(['book',num2str(i),'pricedict'],'dictionary',...
            'yieldcurve',yc,'mktdata',mktdata,'vol',marketvols{i},...
            'model',model,'book',book_i,'mode','price');
        respv = CCBPrice(dictionarypv);
        vanillapv(i) = respv.netvalue;
    end
end

%%
%intraday hedging
%platform should be cleared with all exisiting orders and trades
%information for summary purposes
platformOut = platformOut.clearorders;
platformOut = platformOut.cleartrades;
futurespnl = zeros(nBook,1);
fees = zeros(nBook,1);
margin = zeros(nBook,1);

for i = 1:nBook
    if valdate > lastExpiry(i)
        continue
    end
    
    if eodonly
        data = [futuressettleinfo{i}.Time,...
            futuressettleinfo{i}.Price,...
            futuressettleinfo{i}.Volume];
    else
        data = futuresintradayinfo{i};
    end
    
    if eodonly
        infoType = 'eod';
    else
        if useintradaybar
            infoType = 'bar';
        elseif useintradaytick
            infoType = 'tick';
        end
    end
    
    refprice = futuressettleinfo{i}.PreviousPrice;
    for k = 1:size(data,1)
        underlierinfo = struct('Instrument',futures{i},...
            'Time',data(k,1),...
            'Price',data(k,2),...
            'Volume',data(k,3),...
            'ReferencePrice',refprice,...
            'Type',infoType);
        
        [order,retbreakeven] = vanillastrategy.genorder('book',vanillabooks{i},...
            'underlierinfo',underlierinfo,...
            'tradingplatform',platformOut,...
            'underliervol',marketvols{i},...
            'liquidityadjustment',liqadj,...
            'marketmovebreakeven',breakeveninfo);
        
        if ~isempty(order)
            ntrades = size(platformOut.gettrades,1);
            tradeid = ['trade',num2str(ntrades+1)];
            
            %assuming the order is fully executated here
            %check whether the order itself is to close all existing
            %positions and we need to calcuate the unwind close position pnl
            posBefore = platformOut.getposition('instrument',futures{i});
            if ~isempty(posBefore)
                if posBefore.pVolume == order.pVolumeOriginal && ~strcmpi(order.pOffsetFlag,'open')
                    if strcmpi(posBefore.pDirection,'buy')
                        futurespnl(i) = futurespnl(i)+(order.pPrice-posBefore.pPrice)*posBefore.pVolume*futures{i}.ContractSize;
                    else
                        futurespnl(i) = futurespnl(i)+(posBefore.pPrice-order.pPrice)*posBefore.pVolume*futures{i}.ContractSize;
                    end
                end
            end
            
            %send the order to the trading platform for executation
            platformOut = platformOut.sendorder('order',order','tradeid',tradeid);
            
            %update the reference spot and breakeveninfo
            if vanillastrategy.UseBreakEvenReturn
                refprice = data(k,2);
                breakeveninfo = retbreakeven;
            end
            
        end
    end
    
    if eodonly
        futuresinfo = futuressettleinfo{i};
    else
        futuresinfo = struct('Instrument',futuressettleinfo{i}.Instrument,...
        'Time',data(end,1),...
        'Price',data(end,2),...
        'Volume',data(end,3),...
        'PreviousPrice',futuressettleinfo{i}.PreviousPrice);
    end
    
    % the pnl shall be added with the carried position pnl
    futurespnl(i) = futurespnl(i) + platformOut.calcpnl(futuresinfo);
    % the transaction costs of the trades
    fees(i) = platformOut.calctransactioncost('instrument',futures{i});
    % the pnl shall be substracted with the transaction cost
    futurespnl(i) = futurespnl(i) - fees(i);
    % the margin calculation
    margin(i) = platformOut.calcmargin(futuresinfo);
end

%present the results
rowhandles = cell(nBook+1,1);
for i = 1:nBook
    rowhandles{i} = ['book',num2str(i)];
end
rowhandles{nBook+1} = 'total';
vanillapv = [vanillapv;sum(vanillapv)];
futurespnl = [futurespnl;sum(futurespnl)];
fees = [fees;sum(fees)];
margin = [margin;sum(margin)];

%%
%EOD risk calculation
%we need to compute the carry information of the vanilla book
%we use the settle price to calculate the carry risk
vanillacarrypv = zeros(nBook,1);
vanillacarrydelta = zeros(nBook,1);
vanillacarrygamma = zeros(nBook,1);
vanillatheta = zeros(nBook,1);

if calccarry
    carrydate = businessdate(valdate,1);
    ycdecay = yc.DecayYieldCurve('DecayDate',carrydate);
    for i = 1:nBook
        if valdate > lastExpiry(i)
            continue
        else
        lastprice = futuressettleinfo{i}.Price;
        book_i = vanillabooks{i};
        assetname = book_i{1}.AssetName;
        mktdatadecay = CreateObj([assetname,'_decayedmktdata'],'mktdata',...
            'valuationdate',ycdecay.ValuationDate,...
            'assetName',assetname,...
            'Currency',ycdecay.Currency,...
            'Type','Forward','Spot',lastprice);
        dictionarydecay = CreateObj(['book',num2str(i),'spotgammadict'],'dictionary',...
            'yieldcurve',ycdecay,'mktdata',mktdatadecay,'vol',marketvols{i},...
            'model',model,'book',book_i,'mode','spotgamma-cash');
        resdecay = CCBPrice(dictionarydecay);
        vanillacarrypv(i) = resdecay.netvalue;
        vanillatheta(i) = vanillacarrypv(i) - vanillapv(i);
        vanillacarrydelta(i) = resdecay.spotdelta;
        vanillacarrygamma(i) = resdecay.spotgamma;
        end
    end
    
    vanillacarrypv = [vanillacarrypv;sum(vanillacarrypv)];
    vanillacarrydelta = [vanillacarrydelta;sum(vanillacarrydelta)];
    vanillacarrygamma = [vanillacarrygamma;sum(vanillacarrygamma)];
    vanillatheta = [vanillatheta;sum(vanillatheta)];

end
    

if ~calccarry
    results = table(vanillapv,futurespnl,fees,margin,'RowNames',rowhandles);
else
    results = table(vanillapv,futurespnl,fees,margin,vanillacarrypv,...
        vanillacarrydelta,vanillacarrygamma,vanillatheta,'RowNames',rowhandles);
end
    
end %end of function