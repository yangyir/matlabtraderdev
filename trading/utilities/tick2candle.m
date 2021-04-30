function [candlesout] = tick2candle(code,datein)
    instrument = code2instrument(code);
    tickpath = [getenv('datapath'),'ticks\',code,'\'];
    tickfile = [code,'_',datestr(datein,'yyyymmdd'),'_tick.txt'];
    try
        tickdata = cDataFileIO.loadDataFromTxtFile([tickpath,tickfile]);
    catch
        candlesout = [];
        fprintf('tick2candle:load tick data of %s failed\n',code);
        return
    end
    %
    buckets = getintradaybuckets2('date',datein,...
                'frequency','1m',...
                'tradinghours',instrument.trading_hours,...
                'tradingbreak',instrument.trading_break);
    datestr_start = datestr(floor(buckets(1,1)),'yyyy-mm-dd');
    datestr_end = datestr(floor(buckets(end,1)),'yyyy-mm-dd');
    
    candlesout = [buckets,zeros(length(buckets),4)];
    
    %category1:equity index
    %category2:govtbond
    %category3:commodity without evening trading sessions
    %category4:commodity with evening trading sessions but not traded overnight
    %category5:commodity with evening trading sessions and traded overnight 
    category = getfutcategory(instrument);
    
    if category > 3
        num21_00_00_ = datenum([datestr_start,' 21:00:00']);
        num21_00_0_5_ = datenum([datestr_start,' 21:00:0.5']);
    end
    
%     if category == 5
%         num00_00_00_ = datenum([datestr_end,' 00:00:00']);
%         num00_00_0_5_ = datenum([datestr_end,' 00:00:0.5']);
%     end
    
    nintervals = size(instrument.break_interval,1);
    datenum_open = zeros(nintervals,1);
    datenum_close = zeros(nintervals,1);
    blankstr = ' ';   
    for i = 1:nintervals
        datenum_open(i,1) = datenum([datestr_start,blankstr,instrument.break_interval{i,1}]);
        if category ~= 5
            datenum_close(i,1) = datenum([datestr_start,blankstr,instrument.break_interval{i,2}]);
        else
            if i == nintervals
                datenum_close(i,1) = datenum([datestr_end,blankstr,instrument.break_interval{i,2}]);
            else
                datenum_close(i,1) = datenum([datestr_start,blankstr,instrument.break_interval{i,2}]);
            end
        end
    end
    
    nticks = size(tickdata,1);
    candles_count_ = 0;
    for i = 1:nticks
        t = tickdata(i,1);
        px_trade = tickdata(i,2);
        %note:tick to candle rule
        %open bracket on the left and close bracket on the right
        if category > 3
            if t == num21_00_00_, t = num21_00_0_5_;end
        end
        
        %ignore the tick in case the tick time is in break-time
        usetick = 1;
        for k = 1:nintervals-1
            if t > datenum_close(k) && t <= datenum_open(k+1)
                usetick = 0;
                break
            end
        end
        if ~usetick, continue; end
        
        equalorNot = (round(buckets(2:end) *10e+07) == round(t*10e+07));
        if sum(sum(equalorNot)) == 0
            idx = buckets(1:end-1) < t & buckets(2:end) >= t;
        else
            idx = buckets(1:end-1) <t & equalorNot;
        end
        this_bucket = buckets(idx);
        
        if ~isempty(this_bucket)
            this_count = find(buckets == this_bucket);
        else
            if t > buckets(end)
                this_count = size(buckets,1);
            else
                this_count = [];
            end
        end
        
        if ~isempty(this_count)
            if this_count ~= candles_count_
                candles_count_ = this_count;
                newset = true;
                %note:once newset_ is set to TRUE,
                %candles_count moves to the idx of the current
                %candle to be feeded in. As a result, the previous
                %candle has been fully feeded in.
            else
                newset = false;
            end
            
            candlesout(this_count,5) = px_trade;
            
            if newset
                candlesout(this_count,2) = px_trade;   %px_open
                candlesout(this_count,3) = px_trade;   %px_high
                candlesout(this_count,4) = px_trade;   %px_low
                %NOTE:20190422
                %SOMETIMES we miss ticks for a certain bucket for illiquid
                %and the candle bucket will thus have zero entries; we need
                %to fix this by replacing zero entries with the last price
                %as of the previous candles
                if this_count > 1 && sum(candlesout(this_count-1,2:5)) == 0
                    try
                        lastclose = candlesout(this_count-2,5);
                    catch
                        lastclose = px_trade;
                    end
                    candlesout(this_count-1,2:5) = lastclose;
                end                
            else
                high = candlesout(this_count,3);
                low = candlesout(this_count,4);
                if px_trade > high, candlesout(this_count,3) = px_trade; end
                if px_trade < low, candlesout(this_count,4) = px_trade;end
            end
        end
    end
    %
    % save files
    coldefs = {'datetime','open','high','low','close'};
    intradaypath = [getenv('datapath'),'intradaybar\',code,'\'];
    if category == 5
        %commodity traded overnight requires 2 files for candle storage
        fn1 = [code,'_',datestr(datestr_start,'yyyymmdd'),'_1m.txt'];
        fn2 = [code,'_',datestr(datestr_end,'yyyymmdd'),'_1m.txt'];
        try
            data1 = cDataFileIO.loadDataFromTxtFile([intradaypath,fn1]);
            idx1 = data1(:,1)<datenum_open(1,1) & sum(data1(:,2:end),2) ~=0;
            datacarry = data1(idx1,:);
        catch
            datacarry = [];
        end
        idx2 = candlesout(:,1) < datenum(datestr_end) & sum(candlesout(:,2:end),2) ~=0;
        datasaved1 = [datacarry;candlesout(idx2,:)];
        if ~isempty(datasaved1)
            cDataFileIO.saveDataToTxtFile([intradaypath,fn1],datasaved1,coldefs,'w',true);
        end
        idx3 = candlesout(:,1) >= datenum(datestr_end) & sum(candlesout(:,2:end),2) ~=0;
        datasaved2 = candlesout(idx3,:);
        if ~isempty(datasaved2)
            cDataFileIO.saveDataToTxtFile([intradaypath,fn2],datasaved2,coldefs,'w',true);
        end
    else
        fn1 = [code,'_',datestr(datestr_start,'yyyymmdd'),'_1m.txt'];
        idx1 = sum(candlesout(:,2:end),2) ~=0;
        datasaved1 = candlesout(idx1,:);
        if ~isempty(datasaved1)
            cDataFileIO.saveDataToTxtFile([intradaypath,fn1],datasaved1,coldefs,'w',true);
        end
    end
        
    fprintf('tick2candle:done with %s\n',code);      
end