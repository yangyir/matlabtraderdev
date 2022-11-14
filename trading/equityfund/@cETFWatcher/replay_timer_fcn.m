function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime') || strcmpi(mytimerobj.mode_,'demo')
        dtnum = datenum(event.Data.time);
    elseif strcmpi(mytimerobj.mode_,'replay')
        error('not implemented yet')
%         dtnum = mytimerobj.getreplaytime;
    end
        
    flag = mytimerobj.istime2refresh('time',dtnum);
    %note:the status of the object is set via other explict functions
    %defined in the class for replay mode
    if strcmpi(mytimerobj.mode_,'realtime')
        if flag == 1
            try
                mytimerobj.refresh('time',dtnum);
            catch e
                fprintf('%s error when run refresh methods:%s\n',mytimerobj.name_,e.message);
                if strcmpi(mytimerobj.onerror_,'stop'),mytimerobj.stop;end
            end
            %
        elseif flag == 2
            hasbreach = false;
            hasclosed = false;
            n_index = size(mytimerobj.codes_index_,1);
            n_sector = size(mytimerobj.codes_sector_,1);
            latest_index = mytimerobj.conn_.ds_.wsq(mytimerobj.codes_index_,'rt_date,rt_time,rt_latest');
            latest_sector = mytimerobj.conn_.ds_.wsq(mytimerobj.codes_sector_,'rt_date,rt_time,rt_latest');
            if hour(dtnum) == 14 && minute(dtnum) >= 55
                runhighlowonly = false;
            else
                runhighlowonly = true;
            end
            for i = 1:n_index
                if strcmpi(mytimerobj.codes_index_{i}(1:end-3),'159781'),continue;end
                if strcmpi(mytimerobj.codes_index_{i}(1:end-3),'159782'),continue;end
                %
                variables = mytimerobj.getvariables('code',mytimerobj.codes_index_{i}(1:end-3));
                %new change by yangyiran on 20220825
                %if and only if daily status is conditional long/short or
                %unconditional long/short
%                 if ~(variables.status_d == 1 || variables.status_d == 2 ||...
%                         variables.status_d == -1 || variables.status_d == -2)
%                     continue;
%                 end
                %update the lastest daily candle and intraday candle if needed
                ei_d = variables.ei_d;
                ei_i = variables.ei_i;
                try
                    ei_d.px(end,:) = [ei_d.px(end,1),ei_d.px(end,2),max(ei_d.px(end,3),latest_index(i,3)),min(ei_d.px(end,4),latest_index(i,3)),latest_index(i,3)];
                    ei_i.px(end,:) = [ei_i.px(end,1),ei_i.px(end,2),max(ei_i.px(end,3),latest_index(i,3)),min(ei_i.px(end,4),latest_index(i,3)),latest_index(i,3)];
                catch e
                    fprintf('cETFWatcher:replay_timer_fcn:error in update index candles of %s;%s\n',mytimerobj.names_index_{i},e.message);
                end
                dtnum = datenum([num2str(latest_sector(i,1)),' ',num2str(latest_sector(i,2))],'yyyymmdd HHMMSS');
                dtstr = datestr(dtnum,'yy-mm-dd:HH:MM');
                [signal_d,op_d] = fractal_signal_unconditional(ei_d,0.001,2);
                if ~isempty(op_d) && op_d.use
                    if signal_d(1) == 1
                        fprintf('%s:d-breachup:%s:%4.3f with barrier_d at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),ei_d.px(end,5),signal_d(2),op_d.comment,mytimerobj.names_index_{i});
                    elseif signal_d(1) == -1
                        fprintf('%s:d-breachdn:%s:%4.3f with barrier_d at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),ei_d.px(end,5),signal_d(3),op_d.comment,mytimerobj.names_index_{i});
                    end
                    hasbreach = true;
                else
                    [signal_i,op_i] = fractal_signal_unconditional(ei_i,0.001,4);
                    if ~isempty(op_i) && op_i.use
                        if signal_i(1) == 1
                            fprintf('%s:i-breachup:%s:%4.3f with barrier_i at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),ei_i.px(end,5),signal_i(2),op_i.comment,mytimerobj.names_index_{i});
                        elseif signal_i(1) == -1
                            fprintf('%s:i-breachdn:%s:%4.3f with barrier_i at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),ei_i.px(end,5),signal_i(3),op_i.comment,mytimerobj.names_index_{i});
                        end
                        hasbreach = true;
                    end           
                end
%                 [signal,op] = fractal_signal_unconditional(ei_d,0.001,2);
%                 if ~isempty(op) && op.use
%                     
%                 end
                %
%                 try
%                     if variables.status_d == 2 && ~isnan(variables.cb_d(1)) &&...
%                             latest_index(i,3) >= variables.cb_d(1) + 0.001
%                         dtnum = datenum([num2str(latest_index(i,1)),' ',num2str(latest_index(i,2))],'yyyymmdd HHMMSS');
%                         dtstr = datestr(dtnum,'yy-mm-dd:HH:MM');
%                         fprintf('%s:daily breachUP:%s:%4.3f with barrier_d at (%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),latest_index(i,3),variables.cb_d(1),mytimerobj.names_index_{i});
%                         hasbreach = true;
%                     end
%                     if variables.status_d == 1 && ~isnan(variables.cb_i(1)) && ...
%                             latest_index(i,3) >= variables.cb_i(1) + 0.001
%                         dtnum = datenum([num2str(latest_index(i,1)),' ',num2str(latest_index(i,2))],'yyyymmdd HHMMSS');
%                         dtstr = datestr(dtnum,'yy-mm-dd:HH:MM');
%                         fprintf('%s:intraday breachUP:%s:%4.3f with barrier_i at (%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),latest_index(i,3),variables.cb_i(1),mytimerobj.names_index_{i});
%                         hasbreach = true;
%                     end
%                     if variables.status_d == -2 && ~isnan(variables.cb_d(2)) &&...
%                             latest_index(i,3) <= variables.cb_d(2) - 0.001
%                         dtnum = datenum([num2str(latest_index(i,1)),' ',num2str(latest_index(i,2))],'yyyymmdd HHMMSS');
%                         dtstr = datestr(dtnum,'yy-mm-dd:HH:MM');
%                         fprintf('%s:d-breachdn:%s:%4.3f with barrier_d at %4.3f (%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),latest_index(i,3),variables.cb_d(2),mytimerobj.names_index_{i});
%                         hasbreach = true;
%                     end
%                     if  variables.status_d == -1 && ~isnan(variables.cb_i(2)) && ...
%                             latest_index(i,3) <= variables.cb_i(2) - 0.001
%                         dtnum = datenum([num2str(latest_index(i,1)),' ',num2str(latest_index(i,2))],'yyyymmdd HHMMSS');
%                         dtstr = datestr(dtnum,'yy-mm-dd:HH:MM');
%                         fprintf('%s:i-breachdn:%s:%4.3f with barrier_i at %4.3f (%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),latest_index(i,3),variables.cb_i(2),mytimerobj.names_index_{i});
%                         hasbreach = true;
%                     end
%                 catch
%                     fprintf('cETFWatcher:error in loop of index......\n');
%                 end
                trade = mytimerobj.pos_index_{i};
                if ~isempty(trade)
                    trade.status_ = 'set';
                    trade.riskmanager_.status_ = 'set';
                    extrainfo = mytimerobj.dailybarstruct_index_{i};
                    extrainfo.p = extrainfo.px;
                    extrainfo.latestopen = extrainfo.px(end,5);
                    extrainfo.latestdt = extrainfo.px(end,1);                              
                    tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',false,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',extrainfo,...
                        'runhighlowonly',runhighlowonly);
                    if ~isempty(tradeout)
                        if tradeout.opendirection_ == 1
                            fprintf('%s:bullish closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
                        else
                            fprintf('%s:bearish closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
                        end
                        hasclosed = true;
                    end
                end
            end
            %
            for i = 1:n_sector
                if strcmpi(mytimerobj.codes_sector_{i}(1:end-3),'512800'),continue;end
                if strcmpi(mytimerobj.codes_sector_{i}(1:end-3),'512880'),continue;end
                %
                variables = mytimerobj.getvariables('code',mytimerobj.codes_sector_{i}(1:end-3));
                %
                if ~(variables.status_d == 1 || variables.status_d == 2 ||...
                        variables.status_d == -1 || variables.status_d == -2)
                    continue;
                end
                %update the lastest daily candle and intraday candle if needed
                ei_d = variables.ei_d;
                ei_i = variables.ei_i;
                try
                    ei_d.px(end,:) = [ei_d.px(end,1),ei_d.px(end,2),max(ei_d.px(end,3),latest_sector(i,3)),min(ei_d.px(end,4),latest_sector(i,3)),latest_sector(i,3)];
                    ei_i.px(end,:) = [ei_i.px(end,1),ei_i.px(end,2),max(ei_i.px(end,3),latest_sector(i,3)),min(ei_i.px(end,4),latest_sector(i,3)),latest_sector(i,3)];
                catch e
                    fprintf('cETFWatcher:replay_timer_fcn:error in update sector candles of %s;%s\n',mytimerobj.names_sector_{i},e.message);
                end
                dtnum = datenum([num2str(latest_sector(i,1)),' ',num2str(latest_sector(i,2))],'yyyymmdd HHMMSS');
                dtstr = datestr(dtnum,'yy-mm-dd:HH:MM');
                [signal_d,op_d] = fractal_signal_unconditional(ei_d,0.001,2);
                if ~isempty(op_d) && op_d.use
                    if signal_d(1) == 1
                        fprintf('%s:d-breachup:%s:%4.3f with barrier_d at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),ei_d.px(end,5),signal_d(2),op_d.comment,mytimerobj.names_sector_{i});
                    elseif signal_d(1) == -1
                        fprintf('%s:d-breachdn:%s:%4.3f with barrier_d at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),ei_d.px(end,5),signal_d(3),op_d.comment,mytimerobj.names_sector_{i});
                    end
                    hasbreach = true;
                else
                    [signal_i,op_i] = fractal_signal_unconditional(ei_i,0.001,4);
                    if ~isempty(op_i) && op_i.use
                        if signal_i(1) == 1
                            fprintf('%s:i-breachup:%s:%4.3f with barrier_i at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),ei_i.px(end,5),signal_i(2),op_i.comment,mytimerobj.names_sector_{i});
                        elseif signal_i(1) == -1
                            fprintf('%s:i-breachdn:%s:%4.3f with barrier_i at %4.3f (%s)(%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),ei_i.px(end,5),signal_i(3),op_i.comment,mytimerobj.names_sector_{i});
                        end
                        hasbreach = true;
                    end           
                end
                
                
%                 try
%                     if variables.status_d == 2 && ~isnan(variables.cb_d(1)) &&...
%                             latest_sector(i,3) >= variables.cb_d(1) + 0.001
%                         
%                         fprintf('%s:daily breachUP:%s:%4.3f with barrier_d at (%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),latest_sector(i,3),variables.cb_d(1),mytimerobj.names_sector_{i});
%                         hasbreach = true;
%                     end
%                     if variables.status_d == 1 && ~isnan(variables.cb_i(1)) && ...
%                             latest_sector(i,3) >= variables.cb_i(1) + 0.001
%                         
%                         fprintf('%s:intraday breachUP:%s:%4.3f with barrier_i at (%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),latest_sector(i,3),variables.cb_i(1),mytimerobj.names_sector_{i});
%                         hasbreach = true;
%                     end
%                     if variables.status_d == -2 && ~isnan(variables.cb_d(2)) &&...
%                             latest_sector(i,3) <= variables.cb_d(2) - 0.001
%                         
%                         fprintf('%s:daily breachDN:%s:%4.3f with barrier_d at %4.3f (%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),latest_sector(i,3),variables.cb_d(2),mytimerobj.names_sector_{i});
%                         hasbreach = true;
%                     end
%                     if  variables.status_d == -1 && ~isnan(variables.cb_i(2)) && ...
%                             latest_sector(i,3) <= variables.cb_i(2) - 0.001
%                         
%                         fprintf('%s:intraday breachDN:%s:%4.3f with barrier_i at %4.3f (%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),latest_sector(i,3),variables.cb_d(1),mytimerobj.names_sector_{i});
%                         hasbreach = true;
%                     end
%                 catch
%                     fprintf('cETFWatcher:error in loop of sector......\n');
%                 end
                trade = mytimerobj.pos_sector_{i};
                if ~isempty(trade)
                    trade.status_ = 'set';
                    trade.riskmanager_.status_ = 'set';
                    extrainfo = mytimerobj.dailybarstruct_sector_{i};
                    extrainfo.p = extrainfo.px;
                    extrainfo.latestopen = extrainfo.px(end,5);
                    extrainfo.latestdt = extrainfo.px(end,1);
                    tradeout = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',false,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',extrainfo,...
                        'runhighlowonly',runhighlowonly);
                    if ~isempty(tradeout)
                        if tradeout.opendirection_ == 1
                            fprintf('%s:bullish closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
                        else
                            fprintf('%s:bearish closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
                        end
                        hasclosed = true;
                    end
                end
            end
            if hasbreach, fprintf('\n'); end
            if hasclosed, fprintf('\n'); end
        end
        
    else
        error('not implemented yet')
%         %note, the replay time is updated via the refresh function in
%         %replay mode
%         try
%             mytimerobj.refresh('time',dtnum);
%         catch e
%             fprintf('%s error when run refresh methods:%s\n',mytimerobj.name_,e.message);
%             if strcmpi(mytimerobj.onerror_,'stop')
%                 mytimerobj.stop;
%             end
%         end
    end
    
    if flag == 1
        try
            mytimerobj.print('time',dtnum);
        catch e
            fprintf('%s error when run print methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end
    

end
%end of replay_timer_function