function [] = generateNewData(obj)
%a charlotteDataFeedFX function
    try
        ncodes = size(obj.codes_,1);
        data_m15 = cell(ncodes,1);
        data_m30 = cell(ncodes,1);
        data_h1 = cell(ncodes,1);
        data_h4 = cell(ncodes,1);
        
        nupdate_m15 = 0;
        nupdate_m30 = 0;
        nupdate_h1 = 0;
        nupdate_h4 = 0;
                
        if strcmpi(obj.mode_,'realtime')
            for i = 1:ncodes
                for j = 1:4
                    try
                        if j == 1
                            lastrow = readlastrowfromcsvfile(obj.fn_m15_{i});
                        elseif j == 2
                            lastrow = readlastrowfromcsvfile(obj.fn_m30_{i});
                        elseif j == 3
                            lastrow = readlastrowfromcsvfile(obj.fn_h1_{i});
                        elseif j == 4
                            lastrow = readlastrowfromcsvfile(obj.fn_h4_{i});
                        end
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


                    if j == 1 && currentbartime > obj.lastbartime_m15_(i)
                        nupdate_m15 = nupdate_m15 + 1;
                        lastbar_m15 = [currentbartime,str2double(lastrow{3}),str2double(lastrow{4}),str2double(lastrow{5}),str2double(lastrow{6})];
                        pupdated_m15 = [obj.extrainfo_m15_{i}.px;lastbar_m15];
                        [~,einew_m15] = tools_technicalplot1(pupdated_m15,charlotte_freq2nfractal('m15'),0,'volatilityperiod',0,'tolerance',0);
                        data_m15{i} = struct('time',currentbartime,...
                            'freq','m15',...
                            'mode','realtime',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_m15);
                        obj.lastbartime_m15_(i) = currentbartime;
                        obj.extrainfo_m15_{i} = einew_m15;
                    end
                    
                    if j == 2 && currentbartime > obj.lastbartime_m30_(i)
                        nupdate_m30 = nupdate_m30 + 1;
                        lastbar_m30 = [currentbartime,str2double(lastrow{3}),str2double(lastrow{4}),str2double(lastrow{5}),str2double(lastrow{6})];
                        pupdated_m30 = [obj.extrainfo_m30_{i}.px;lastbar_m30];
                        [~,einew_m30] = tools_technicalplot1(pupdated_m30,charlotte_freq2nfractal('m30'),0,'volatilityperiod',0,'tolerance',0);
                        data_m30{i} = struct('time',currentbartime,...
                            'freq','m30',...
                            'mode','realtime',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_m30);
                        obj.lastbartime_m30_(i) = currentbartime;
                        obj.extrainfo_m30_{i} = einew_m30;
                    end

                    if j == 3 && currentbartime > obj.lastbartime_h1_(i)
                        nupdate_h1 = nupdate_h1 + 1;
                        lastbar_h1 = [currentbartime,str2double(lastrow{3}),str2double(lastrow{4}),str2double(lastrow{5}),str2double(lastrow{6})];
                        pupdated_h1 = [obj.extrainfo_h1_{i}.px;lastbar_h1];
                        [~,einew_h1] = tools_technicalplot1(pupdated_h1,charlotte_freq2nfractal('h1'),0,'volatilityperiod',0,'tolerance',0);
                        data_h1{i} = struct('time',currentbartime,...
                            'freq','h1',...
                            'mode','realtime',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_h1);
                        obj.lastbartime_h1_(i) = currentbartime;
                        obj.extrainfo_h1_{i} = einew_h1;
                    end

                    if j == 4 && currentbartime > obj.lastbartime_h4_(i)
                        nupdate_h4 = nupdate_h4 + 1;
                        lastbar_h4 = [currentbartime,str2double(lastrow{3}),str2double(lastrow{4}),str2double(lastrow{5}),str2double(lastrow{6})];
                        pupdated_h4 = [obj.extrainfo_h4_{i}.px;lastbar_h4];
                        [~,einew_h4] = tools_technicalplot1(pupdated_h4,charlotte_freq2nfractal('h4'),0,'volatilityperiod',0,'tolerance',0);
                        data_h4{i} = struct('time',currentbartime,...
                            'freq','h4',...
                            'mode','realtime',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_h4);
                        obj.lastbartime_h4_(i) = currentbartime;
                        obj.extrainfo_h4_{i} = einew_h4;
                    end
                end
                %
            end
            %
        elseif strcmpi(obj.mode_,'replay')
            obj.lastreplayidx_ = obj.lastreplayidx_ + 1;
            try
                replaydt = obj.replaytimevec_(obj.lastreplayidx_);
%                 fprintf('current replay time:%s\n', datestr(replaydt,'yyyymmdd HH:MM'));
            catch
                obj.stop;
            end

            endofreplay = obj.lastreplayidx_ == length(obj.replaytimevec_);
            
            for i = 1:ncodes
                for j = 1:4
                    try
                        if j == 1    
                            lastrow2 = find(obj.replaydata_m15_{i}(:,1) <= replaydt,1,'last')-1;
                        elseif j == 2
                            lastrow2 = find(obj.replaydata_m30_{i}(:,1) <= replaydt,1,'last')-1;
                        elseif j == 3
                            lastrow2 = find(obj.replaydata_h1_{i}(:,1) <= replaydt,1,'last')-1;
                        elseif j == 4
                            lastrow2 = find(obj.replaydata_h4_{i}(:,1) <= replaydt,1,'last')-1;
                        end
                        if endofreplay
                            lastrow2 = lastrow2 + 1;
                        end
                    catch
                        lastrow2 = [];
                    end
                    if isempty(lastrow2), continue; end

                    if j == 1
                        currentbartime2 = obj.replaydata_m15_{i}(lastrow2,1);
                        lastrowdata = obj.replaydata_m15_{i}(lastrow2,:);
                    elseif j == 2
                        currentbartime2 = obj.replaydata_m30_{i}(lastrow2,1);
                        lastrowdata = obj.replaydata_m30_{i}(lastrow2,:);
                    elseif j == 3
                        currentbartime2 = obj.replaydata_h1_{i}(lastrow2,1);
                        lastrowdata = obj.replaydata_h1_{i}(lastrow2,:);
                    elseif j == 4
                        currentbartime2 = obj.replaydata_h4_{i}(lastrow2,1);
                        lastrowdata = obj.replaydata_h4_{i}(lastrow2,:);
                    end

                    if j == 1 && currentbartime2 > obj.lastbartime_m15_(i)
                        nupdate_m15 = nupdate_m15 + 1;
                        lastbar_m15 = lastrowdata(1:5);
                        pupdated_m15 = [obj.extrainfo_m15_{i}.px;lastbar_m15];
                        [~,einew_m15] = tools_technicalplot1(pupdated_m15,charlotte_freq2nfractal('m15'),0,'volatilityperiod',0,'tolerance',0);
                        data_m15{i} = struct('time',currentbartime2,...
                            'freq','m15',...
                            'mode','replay',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_m15);
                        obj.lastbartime_m15_(i) = currentbartime2;
                        obj.extrainfo_m15_{i} = einew_m15;
                    end

                    if j == 2 && currentbartime2 > obj.lastbartime_m30_(i)
                        nupdate_m30 = nupdate_m30 + 1;
                        lastbar_m30 = lastrowdata(1:5);
                        pupdated_m30 = [obj.extrainfo_m30_{i}.px;lastbar_m30];
                        [~,einew_m30] = tools_technicalplot1(pupdated_m30,charlotte_freq2nfractal('m30'),0,'volatilityperiod',0,'tolerance',0);
                        data_m30{i} = struct('time',currentbartime2,...
                            'freq','m30',...
                            'mode','replay',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_m30);
                        obj.lastbartime_m30_(i) = currentbartime2;
                        obj.extrainfo_m30_{i} = einew_m30;
                    end

                    if j == 3 && currentbartime2 > obj.lastbartime_h1_(i)
                        nupdate_h1 = nupdate_h1 + 1;
                        lastbar_h1 = lastrowdata(1:5);
                        pupdated_h1 = [obj.extrainfo_h1_{i}.px;lastbar_h1];
                        [~,einew_h1] = tools_technicalplot1(pupdated_h1,charlotte_freq2nfractal('h1'),0,'volatilityperiod',0,'tolerance',0);
                        data_h1{i} = struct('time',currentbartime2,...
                            'freq','h1',...
                            'mode','replay',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_h1);
                        obj.lastbartime_h1_(i) = currentbartime2;
                        obj.extrainfo_h1_{i} = einew_h1;
                    end

                    if j == 4 && currentbartime2 > obj.lastbartime_h4_(i)
                        nupdate_h4 = nupdate_h4 + 1;
                        lastbar_h4 = lastrowdata(1:5);
                        pupdated_h4 = [obj.extrainfo_h4_{i}.px;lastbar_h4];
                        [~,einew_h4] = tools_technicalplot1(pupdated_h4,charlotte_freq2nfractal('h4'),0,'volatilityperiod',0,'tolerance',0);
                        data_h4{i} = struct('time',currentbartime2,...
                            'freq','h4',...
                            'mode','replay',...
                            'code',obj.codes_{i},...
                            'extrainfo',einew_h4);
                        obj.lastbartime_h4_(i) = currentbartime2;
                        obj.extrainfo_h4_{i} = einew_h4;
                    end

                end
            end
            %
        end

        if nupdate_m15 > 0
            % event triggered
            notify(obj,'CandleUpdated_M15', charlotteDataFeedEventData(data_m15));
        end
      
        if nupdate_m30 > 0
            % event triggered
            notify(obj,'CandleUpdated_M30', charlotteDataFeedEventData(data_m30));
        end

        if nupdate_h1 > 0
            % event triggered
            notify(obj,'CandleUpdated_H1', charlotteDataFeedEventData(data_h1));
        end

        if nupdate_h4 > 0
            % event triggered
            notify(obj,'CandleUpdated_H4', charlotteDataFeedEventData(data_h4));
        end
        
        
    catch ME
        % error event triggered
        notify(obj, 'ErrorOccurred',charlotteErrorEventData(ME.message));
    end
end