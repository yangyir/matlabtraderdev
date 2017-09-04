%test_cStrategyDeltaNeutral
clc;
fprintf('running "test_cStrategyDeltaNeutral.m......"\n');
futures = cContract('AssetName','gold','Tenor','1612');

%%
option = CreateObj('option','security','SecurityName','EUROPEAN',...
    'Underlier',futures,'IssueDate','2016-10-21',...
    'ExpiryDate','2016-11-30',...
    'Strike',1.05,'OptionType','Call','Notional',5e7);
book = {option};
platform = cTradingPlatform;

%%
usetick = 0;
teststart = datenum(option.IssueDate);
testend = businessdate(today,-1);

%
if usetick == 1
    freq = 'tick';
else
    freq = '1m';
end

cob = teststart;
cobprev = businessdate(cob,-1);
while cob <= testend
    if cob == datenum(option.IssueDate)
        onIssueDate = 1;
    else
        onIssueDate = 0;
    end
    mktclose = [datestr(cob,'yyyy-mm-dd'),' 15:00:00'];
    if usetick == 1
        data = futures.getTimeSeries('Frequency','tick','Connection','Bloomberg',...
            'FromDate',[datestr(cobprev,'yyyy-mm-dd'),' 21:00:00'],...
            'ToDate',mktclose);
    else
        data = futures.getTimeSeries('Frequency','1m','Connection','Bloomberg',...
            'Fields',{'Close','Volume'},...
            'FromDate',[datestr(cobprev,'yyyy-mm-dd'),' 21:00:00'],...
            'ToDate',mktclose);
    end
    
    mktclose = datenum(mktclose,'yyyy-mm-dd HH:MM:SS');
    timediff = abs(data(:,1)-mktclose);
    [~,idxEOD] = min(timediff);
        
    n = size(data,1);
    for i = 1:n
        if i == idxEOD && onIssueDate == 1
            for j = size(book,1)
                book{j}.ReferenceSpot = data(i,2);
            end
        end
        %
        strategy = cStrategyDeltaNeutral('Book',book);
        futuresinfo = struct('Instrument',futures,'Time',data(i,1),...
            'Price',data(i,2),'Volume',data(i,3));
        order = strategy.genorder('UnderlierInfo',futuresinfo,'TradingPlatform',platform);
        if ~isempty(order)
            n = size(platform.gettrades,1);
            tradeid = ['trade',num2str(n+1)];
            platform = platform.sendorder('Order',order,'tradeid',tradeid);
        end
        
    end
    
    %
%     orders = platform.getorders;
%     for i = 1:size(orders,1)
%         orders{i}.print;
%     end
    
    trades = platform.gettrades;
    for i = 1:size(trades,1)
        trades{i}.print;
    end
    platform.printpositions;
    pnl = platform.calcpnl(futuresinfo);
    fprintf(['on ',datestr(cob,'yyyymmdd'),' the cumulative pnl is ',num2str(pnl),'.\n']);
    
    %clear the trades and order
    platform = platform.clearorders;
    platform = platform.cleartrades;
    
    cobprev = cob;
    cob = businessdate(cob,1);
    
    
end

fprintf('test done!\n');









