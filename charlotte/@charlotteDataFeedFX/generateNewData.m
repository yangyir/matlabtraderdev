function [] = generateNewData(obj)
%a charlotteDataFeedFX function
    try
        ncodes = size(obj.codes_,1);
        data = cell(ncodes,1);
        nupdate = 0;
        
        if strcmpi(obj.mode_,'realtime')
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
                    nupdate = nupdate + 1;
                    data_i = struct('time',currentbartime,...
                        'open',str2double(lastrow{3}),...
                        'high',str2double(lastrow{4}),...
                        'low',str2double(lastrow{5}),...
                        'close',str2double(lastrow{6}),...
                        'freq',obj.freq_{i},...
                        'mode','realtime');
                    data{i} = data_i;
                    obj.lastbartime_(i) = currentbartime;
                end
            end
        elseif strcmpi(obj.mode_,'replay')
            %the code shall be tricky to handle different freq
            for i = 1:ncodes
                try
                    lastrow = obj.replaydata_{i}(obj.replaycounts_(i)+1,:);
                catch
                    lastrow = [];
                end
                
                if isempty(lastrow)
                    continue;
                end
                
                currentbartime = lastrow(1);

                
                if currentbartime > obj.lastbartime_(i)
                    nupdate = nupdate + 1;
                    data_i = struct('time',currentbartime,...
                        'open',lastrow(2),...
                        'high',lastrow(3),...
                        'low',lastrow(4),...
                        'close',lastrow(5),...
                        'freq',obj.freq_{i},...
                        'mode','replay');
                    data{i} = data_i;
                    obj.lastbartime_(i) = currentbartime;
                    obj.replaycounts_(i) = obj.replaycounts_(i) + 1;
                end
            end             
        end
        %
        if nupdate > 0
        % event triggered
            notify(obj, 'NewDataArrived', charlotteDataFeedEventData(data));
        end
        
        if strcmpi(obj.mode_,'replay')
            stopFlag = true;
            for i = 1:ncodes
                try
                    lastrow = obj.replaydata_{i}(obj.replaycounts_(i)+1,:);
                catch
                    lastrow = [];
                end
                if ~isempty(lastrow)
                    currentbartime = lastrow(1);
                    if currentbartime < obj.replaydateto_
                        stopFlag = false;
                        break
                    end
                end
            end
            if stopFlag
                obj.stop;
                return
            end
        end
        
    catch ME
        % error event triggered
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData(ME.message));
    end
end