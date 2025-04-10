function [] = generateNewData(obj)
%a charlotteDataFeedFX function
    try
        ncodes = size(obj.codes_,1);
        data = cell(ncodes,1);
        nupdate = 0;
        for i = 1:ncodes
            lastrow = readlastrowfromcsvfile(obj.fn_{i});
            
            if isempty(lastrow), continue; end
            
            currentbardate = lastrow{1};
            currentbardatestr = [currentbardate(1:4),currentbardate(6:7),currentbardate(9:10)];
            currentbartimestr = lastrow{2};
            currentbartime = datenum([currentbardatestr,' ',currentbartimestr],'yyyymmdd HH:MM');
            
            if currentbartime > obj.lastbartime_(i)
                obj.lastbartime_(i) = currentbartime;
                nupdate = nupdate + 1;
                data_i = struct('time',currentbartime,...
                    'open',lastrow{3},...
                    'high',lastrow{4},...
                    'low',lastrow{5},...
                    'close',lastrow{6});
                data{i} = data_i;
            end
        end
        
        if nupdate > 0
        % event triggered
            notify(obj, 'NewDataArrived', MarketDataEventData(data));
        end
    catch ME
        % ´¥·¢´íÎóÊÂ¼ş
        notify(obj, 'ErrorOccurred', ...
            ErrorEventData(ME.message));
    end
end