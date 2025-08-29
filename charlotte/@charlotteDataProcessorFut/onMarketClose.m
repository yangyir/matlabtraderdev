function [] = onMarketClose(obj,~,eventData)
% a charlotteDataProcessorFut function
    data = eventData.MarketData;
    t = data.time;
    try
        mode = data.mode;
    catch
        mode = 'realtime';
    end
    
    if strcmpi(mode,'replay')
        return
    end
    
    ncodes = size(obj.codes_,1);
    for i = 1:ncodes
        if obj.fut_categories_(i) <= 3
            hh = hour(t);
            if hh < 9, continue;end
            % data will be saved once the day market is closed after
            % 15:15pm
            try
                if ~isempty(obj.ticks_{i})
                    tickfoldername = [getenv('DATAPATH'),'ticks\',obj.codes_{i},'\'];
                    try
                        cd(tickfoldername);
                    catch
                        mkdir(tickfoldername);
                    end
                    dtstr = datestr(floor(obj.ticks_{i}(1)),'yyyymmdd');
                    filename = [obj.codes_{i},'_',dtstr,'_tick.txt'];
                    cDataFileIO.saveDataToTxtFile([tickfoldername,filename],obj.ticks_{i},{'datetime','trade'},'w',true);
                    fprintf('%s:tick data of %s has been successfully saved...\n',datestr(t),obj.codes_{i});
                    obj.ticks_{i} = [];
                    obj.tickcounts_(i) = 0;
                end
            catch
                fprintf('failed to save tick data on %s....\n',obj.codes_{i});
                continue;
            end
            %
            try
                if ~isempty(obj.candles_m1_{i})
                    barfoldername = [getenv('DATAPATH'),'intradaybar\',obj.codes_{i},'\'];
                    try
                        cd(barfoldername);
                    catch
                        mkdir(barfoldername);
                    end
                    dtstr = datestr(floor(obj.candles_m1_{i}(1,1)),'yyyymmdd');
                    filename = [obj.codes_{i},'_',dtstr,'_1m.txt'];
                    cDataFileIO.saveDataToTxtFile([barfoldername,filename],obj.candles_m1_{i},{'datetime','open','high','low','close'},'w',true);
                    fprintf('%s:intraday bar data of %s has been successfully saved...\n',datestr(t),obj.codes_{i});
                    obj.candles_m1_{i} = [];
                    obj.candles_m1_count_(i) = 0;
                    obj.newset_m1_(i) = 0;
                end
            catch
                fprintf('failed to save intraday bar data on %s....\n',obj.codes_{i});
                continue;
            end
        elseif obj.fut_categories_(i) == 4
            hh = hour(t);
            if hh >= 15, continue;end
            % data will be saved once the evening market is closed after
            % 2:30 am
            try
                if ~isempty(obj.ticks_{i})
                    tickfoldername = [getenv('DATAPATH'),'ticks\',obj.codes_{i},'\'];
                    try
                        cd(tickfoldername);
                    catch
                        mkdir(tickfoldername);
                    end
                    dtstr = datestr(floor(obj.ticks_{i}(1)),'yyyymmdd');
                    filename = [obj.codes_{i},'_',dtstr,'_tick.txt'];
                    cDataFileIO.saveDataToTxtFile([tickfoldername,filename],obj.ticks_{i},{'datetime','trade'},'w',true);
                    fprintf('%s:tick data of %s has been successfully saved...\n',datestr(t),obj.codes_{i});
                    obj.ticks_{i} = [];
                    obj.tickcounts_(i) = 0;
                end
            catch
                fprintf('failed to save tick data on %s....\n',obj.codes_{i});
                continue;
            end
            %
            try
                if ~isempty(obj.candles_m1_{i})
                    barfoldername = [getenv('DATAPATH'),'intradaybar\',obj.codes_{i},'\'];
                    try
                        cd(barfoldername);
                    catch
                        mkdir(barfoldername);
                    end
                    dtstr = datestr(floor(obj.candles_m1_{i}(1,1)),'yyyymmdd');
                    filename = [obj.codes_{i},'_',dtstr,'_1m.txt'];
                    cDataFileIO.saveDataToTxtFile([barfoldername,filename],obj.candles_m1_{i},{'datetime','open','high','low','close'},'w',true);
                    fprintf('%s:intraday bar data of %s has been successfully saved...\n',datestr(t),obj.codes_{i});
                    obj.candles_m1_{i} = [];
                    obj.candles_m1_count_(i) = 0;
                    obj.newset_m1_(i) = 0;
                end
            catch
                fprintf('failed to save intraday bar data on %s....\n',obj.codes_{i});
                continue;
            end
        elseif obj.fut_categories_(i) == 5
            hh = hour(t);
            if hh >= 15, continue;end
            % data will be saved once the evening market is closed after
            % 2:30 am
            try
                if ~isempty(obj.ticks_{i})
                    tickfoldername = [getenv('DATAPATH'),'ticks\',obj.codes_{i},'\'];
                    try
                        cd(tickfoldername);
                    catch
                        mkdir(tickfoldername);
                    end
                    dtstr = datestr(floor(obj.ticks_{i}(1)),'yyyymmdd');
                    filename = [obj.codes_{i},'_',dtstr,'_tick.txt'];
                    cDataFileIO.saveDataToTxtFile([tickfoldername,filename],obj.ticks_{i},{'datetime','trade'},'w',true);
                    fprintf('%s:tick data of %s has been successfully saved...\n',datestr(t),obj.codes_{i});
                    obj.ticks_{i} = [];
                    obj.tickcounts_(i) = 0;
                end
            catch
                fprintf('failed to save tick data on %s....\n',obj.codes_{i});
                continue;
            end
            % note:it is tricky to save intraday bar data in case it trades
            % overnight,
            try
                if ~isempty(obj.candles_m1_{i})
                    barfoldername = [getenv('DATAPATH'),'intradaybar\',obj.codes_{i},'\'];
                    try
                        cd(barfoldername);
                    catch
                        mkdir(barfoldername);
                    end
                    dtstr1 = datestr(floor(obj.candles_m1_{i}(1,1)),'yyyymmdd');
                    dtstr2 = datestr(floor(obj.candles_m1_{i}(end,1)),'yyyymmdd');
                    filename1 = [obj.codes_{i},'_',dtstr1,'_1m.txt'];
                    filename2 = [obj.codes_{i},'_',dtstr2,'_1m.txt'];
                    try
                        data1 = cDataFileIO.loadDataFromTxtFile([barfoldername,filename1]);
                        idx = data1(:,1) < obj.candles_m1_{i}(1,1);
                        data1_existing = data1(idx,1:5);
                    catch
                        data1_existing = [];
                    end
                    idx = obj.candles_m1_{i}(:,1) < floor(obj.candles_m1_{i}(end,1));
                    data1_extra = obj.candles_m1_{i}(idx,1:5);
                    cDataFileIO.saveDataToTxtFile([barfoldername,filename1],...
                        [data1_existing;data1_extra],...
                        {'datetime','open','high','low','close'},'w',true);
                    idx = obj.candles_m1_{i}(:,1) >= floor(obj.candles_m1_{i}(end,1));
                    data2 = obj.candles_m1_{i}(idx,1:5);
                    cDataFileIO.saveDataToTxtFile([barfoldername,filename2],...
                        data2,...
                        {'datetime','open','high','low','close'},'w',true);
                    fprintf('%s:intraday bar data of %s has been successfully saved...\n',datestr(t),obj.codes_{i});
                    obj.candles_m1_{i} = [];
                    obj.candles_m1_count_(i) = 0;
                    obj.newset_m1_(i) = 0;
                end
                
            catch
                fprintf('failed to save intraday bar data on %s....\n',obj.codes_{i});
                continue;
            end
        else
            %do nothing
        end
    end
end