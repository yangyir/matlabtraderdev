function backtestresults = backtest_vanilla(product,strategy,varargin)
%function to test either 1) the hedging performance of a vanilla product
%or 2) a trading strategy based on synthetic vanilla options
%backtest logic: issue the same product on a daily basis and generate its
%profit & loss profile over its trading period. In case we have N backtest
%days, we shall issue N products with N different PnL profile. Use this
%PnL profile to draw the PnL distribution statistics. 

%backtest input control variables
p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Product',@(x)validateattributes(x,{'cProduct'},{},'','Product'));
p.addRequired('Strategy',@(x)validateattributes(x,{'cStrategy'},{},'','Strategy'));
%over the backtesting period which is between the "FromDate" and the "EndDate"
p.addParameter('FromDate',{},@(x)validateattributes(x,{'numeric','char'},{},'','FromDate'));
p.addParameter('ToDate',{},@(x)validateattributes(x,{'numeric','char'},{},'','ToDate'));
%"DataSampling" controls the market data sampling frequency used for
%backtesting. Generally the end of day(EOD) data is always required for PnL
%calculation. However, the intraday bar data or even tick data can be used
%to check the performance of intraday hedging / speculation.
p.addParameter('DataSampling','eod',@(x)validateattributes(x,{'char'},{},'','DataSampling'));
%"LiquidityAdjustment" defines the futures liquidity cost,i.e.how many tick
%size. 0 means no liquidy adjustment and futures can be always trade at the
%current market trade price
p.addParameter('LiquidityAdjustment',0,@(x)validateattributes(x,{'numeric'},{},'','LiquidityAdjustment'));
p.addParameter('PrintResults',false,@(x)validateattributes(x,{'logical'},{},'','PrintResults'));
%todo
%other backtest control parameters to follow

p.parse(product,strategy,varargin{:});
product = p.Results.Product;
strategy = p.Results.Strategy;
fromdate = p.Results.FromDate;
if isempty(fromdate)
    error('backtest_vanilla:missing FromDate!')
end
fromdate = datenum(fromdate);
todate = p.Results.ToDate;
if isempty(todate)
    error('backtest_vanilla:missing ToDate!')
end
todate = datenum(todate);
datafreq = p.Results.DataSampling;
if ~(strcmpi(datafreq,'eod') || strcmpi(datafreq,'intradaybar') || strcmpi(datafreq,'intradaytick'))
    error('backtest_vanilla:invalid input of DataSampling,shall be eod,intradaybar or intradaytick')
end
ntickadj = p.Results.LiquidityAdjustment;
printresults = p.Results.PrintResults;

if isholiday(fromdate)
    fromdate = businessdate(fromdate,1);
end

if isholiday(todate)
    todate = businessdate(todate,-1);
end

books = product.Books;
productnotional = product.Notional;
productissuedate = product.IssueDate;
lastexpiry = product.ExpiryDate;

nbook = size(books,1);
% strategies = cell(nbook,1);
marketvols = cell(nbook,1);

%create a trading platform for each product
platform = cTradingPlatform;

todate = min(todate,lastexpiry);
obsdates = gendates('fromdate',fromdate,'todate',todate);
nobs = size(obsdates,1);
%1st column date
%2nd column cumulative futures pnl (of notional)
%3rd column margin (of notional)
%4th column cumulative vanilla pnl (of notional)
producttradinginfo = zeros(nobs,4);
iobs = 0;
fees = 0;

valdate = fromdate;
marketmovebreakeven = NaN;
%loop through business days until product expiry
while valdate <= min(todate,lastexpiry)
    %create vol objects for each underlier
    for j = 1:nbook
        sec = books{j}{1};
        %todo:
        %we shall load the vol object from the server on a daily basis
        %here we assume the product is using the same volatility as on
        %the issue date for hedging purpose
        volhandle = ['marketvol_',lower(sec.AssetName),'_',...
            datestr(productissuedate,'yyyymmdd')];
        marketvols{j} = loadobjfromfile(volhandle,'vol');
    end
    
    [resultstable,platform,futuressettleinfo] = autotrade_intraday_vanilla(...
        valdate,product,strategy,platform,marketvols,...
        'LiquidityAdjustment',ntickadj,...
        'DataSampling',datafreq,...
        'MarketMoveBreakEven',marketmovebreakeven);
    
    if strategy.UseBreakEvenReturn
        marketmovebreakeven = abs(resultstable.vanillatheta(1:end-1))*2./...
            abs(resultstable.vanillacarrygamma(1:end-1));
        marketmovebreakeven = 0.1*sqrt(marketmovebreakeven);
    end
    
    %calc and break-down pnl
    pnl_i = resultstable.futurespnl(end);   %cummulative pnl of futures
    vanillapv = resultstable.vanillapv(end);
    margin = resultstable.margin(end);
    fees = fees + resultstable.fees(end);
    
    deltapnl = zeros(nbook,1);
    gammapnl = zeros(nbook,1);
    thetapnl = zeros(nbook,1);
    vanillapnl = zeros(nbook,1);
    use = ones(nbook+1,1);
    use(end) = 0;
    
    if valdate > fromdate
        %pnl breakdown of the vanilla book
        for j = 1:nbook
            if isempty(futuressettleinfo{j})
                %the book shall expired
                use(j) = 0;
                continue;
            end
            settle = futuressettleinfo{j}.Price;
            previoussettle = previoussettleinfo{j}.Price;
            ret = (settle-previoussettle)/previoussettle;
            %vanilla options daily pnl breakdown
            deltapnl(j) = ret*previousresultstable.vanillacarrydelta(j);
            gammapnl(j) = 0.5*ret^2*previousresultstable.vanillacarrygamma(j)*100;
            thetapnl(j) = previousresultstable.vanillatheta(j);
            %vanilla options daily pnl
            vanillapnl(j) = resultstable.vanillapv(j) - previousresultstable.vanillapv(j);
        end
    end
    
    if printresults && valdate == productissuedate
        issuepv = resultstable.vanillapv(end);
        fprintf(['\nissue a product on ',datestr(productissuedate,'yyyymmdd'),...
            ' at ',num2str(round(issuepv/productnotional,4)),'...\n']);
    end
    
    if valdate == productissuedate || valdate == fromdate
        %on the issue date the vanilla pnl is the pv of the vanillas
        pnl_futures = pnl_i/productnotional;
        pnl_vanilla = 0.0;
        pnl_total = pnl_futures + pnl_vanilla;
    else
        pnl_futures = pnl_i/productnotional - sum(use.*previousresultstable.futurespnl)/productnotional;
        %we short options here
        pnl_vanilla = -sum(vanillapnl)/productnotional;
        pnl_total = pnl_futures + pnl_vanilla;
    end
    
    if printresults
        fprintf(['\t',datestr(valdate,'yyyymmdd'),...
            '->total daily pnl:%0.4f',...
            ': vanilla daily pnl:%0.4f',...
            ': futures daily pnl:%0.4f',...
            '; futures margin:%0.4f\n'],...
            pnl_total,...
            pnl_vanilla,...
            pnl_futures,...
            margin/productnotional);
    end
    
    if printresults
        trades = platform.gettrades;
        for i = 1:size(trades,1)
            fprintf('\t');
            trades{i}.print;
        end
        fprintf('\n');
    end
    
    iobs = iobs + 1;
    producttradinginfo(iobs,1) = valdate;
    producttradinginfo(iobs,2) = pnl_i/productnotional;
    producttradinginfo(iobs,3) = margin/productnotional;
    producttradinginfo(iobs,4) = (issuepv-vanillapv)/productnotional;
    
    previoussettleinfo = futuressettleinfo;
    previousresultstable = resultstable;
    valdate = businessdate(valdate,1);
    
end

%collecting results
backtestresults = struct('netvalue',issuepv/productnotional,...
    'maxmargin',max(producttradinginfo(:,3)),...
    'maxpnl',max(producttradinginfo(:,2)+producttradinginfo(:,4)),...
    'minpnl',min(producttradinginfo(:,2)+producttradinginfo(:,4)),...
    'futurespnl',producttradinginfo(end,2),...
    'vanillapnl',producttradinginfo(end,4),...
    'totalpnl',producttradinginfo(end,2)+producttradinginfo(end,4),...
    'fees',fees,...
    'nobs',nobs);

fprintf(['product issued on ',datestr(productissuedate,'yyyymmdd'),...
    '->netvalue:%0.4f',...
    '; vanillapnl:%0.4f',...
    '; futurespnl:%0.4f',...
    '; maxmargin:%0.4f'...
    '; fees:%4.2f',...
    '; nobs:%d.\n'],...
    backtestresults.netvalue,...
    backtestresults.vanillapnl,...
    backtestresults.futurespnl,...
    backtestresults.maxmargin,...
    backtestresults.fees,...
    backtestresults.nobs);

end %end of function