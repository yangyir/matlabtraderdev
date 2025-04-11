function [] = generateNewData(obj)
%a charlotteDataFeedFX function
    try
        ncodes = size(obj.codes_,1);
        data = cell(ncodes,1);
        nupdate = 0;
        for i = 1:ncodes
            try
                lastrow = readlastrowfromcsvfile(obj.fn_{i});
            catch ME
                notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData(ME.message));
                lastrow = '';
            end
     
            if isempty(lastrow), continue; end
            
            currentbardate = lastrow{1};
            currentbardatestr = [currentbardate(1:4),currentbardate(6:7),currentbardate(9:10)];
            currentbartimestr = lastrow{2};
            currentbartime = datenum([currentbardatestr,' ',currentbartimestr],'yyyymmdd HH:MM');
            
            if currentbartime > obj.lastbartime_(i)
                obj.lastbartime_(i) = currentbartime;
                nupdate = nupdate + 1;
                data_i = struct('time',currentbartime,...
                    'open',str2double(lastrow{3}),...
                    'high',str2double(lastrow{4}),...
                    'low',str2double(lastrow{5}),...
                    'close',str2double(lastrow{6}));
                data{i} = data_i;
            end
        end
        
        if nupdate > 0
        % event triggered
            notify(obj, 'NewDataArrived', charlotteDataFeedEventData(data));
        end
    catch ME
        % error event triggered
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData(ME.message));
    end
end