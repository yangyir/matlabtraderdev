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
%             try
%                 mytimerobj.riskmanagement;
%             catch e
%                 fprintf('%s error when run riskmanagement methods:%s\n',mytimerobj.name_,e.message);
%                 if strcmpi(mytimerobj.onerror_,'stop'), mytimerobj.stop;end
%             end
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
                try
                    if ~isnan(mytimerobj.intradaybarriers_conditional_index_(i,1)) && ...
                            latest_index(i,3) >= mytimerobj.intradaybarriers_conditional_index_(i,1) + 0.001
                        dtnum = datenum([num2str(latest_index(i,1)),' ',num2str(latest_index(i,2))],'yyyymmdd HHMMSS');
                        dtstr = datestr(dtnum,'yyyy-mm-dd:HH:MM');
                        fprintf('%s:intraday breachUP:%s:%4.3f (%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),latest_index(i,3),mytimerobj.names_index_{i});
                        hasbreach = true;
                    end
                    if ~isnan(mytimerobj.intradaybarriers_conditional_index_(i,2)) && ...
                            latest_index(i,3) <= mytimerobj.intradaybarriers_conditional_index_(i,2) - 0.001
                        dtnum = datenum([num2str(latest_index(i,1)),' ',num2str(latest_index(i,2))],'yyyymmdd HHMMSS');
                        dtstr = datestr(dtnum,'yyyy-mm-dd:HH:MM');
                        fprintf('%s:intraday breachDN:%s:%4.3f (%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),latest_index(i,3),mytimerobj.names_index_{i});
                        hasbreach = true;
                    end
                catch
                    fprintf('cETFWatcher:error in loop of index......\n');
                end
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
                        fprintf('%s:closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
                        hasclosed = true;
                    end
                end
            end
            %
            for i = 1:n_sector
                try
                    if strcmpi(mytimerobj.codes_sector_{i}(1:end-3),'512800'),continue;end
                    if strcmpi(mytimerobj.codes_sector_{i}(1:end-3),'512880'),continue;end
                    if ~isnan(mytimerobj.intradaybarriers_conditional_sector_(i,1)) && ...
                            latest_sector(i,3) >= mytimerobj.intradaybarriers_conditional_sector_(i,1) + 0.001
                        dtnum = datenum([num2str(latest_sector(i,1)),' ',num2str(latest_sector(i,2))],'yyyymmdd HHMMSS');
                        dtstr = datestr(dtnum,'yyyy-mm-dd:HH:MM');
                        fprintf('%s:intraday breachUP:%s:%4.3f (%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),latest_sector(i,3),mytimerobj.names_sector_{i});
                        hasbreach = true;
                    end
                    if ~isnan(mytimerobj.intradaybarriers_conditional_sector_(i,2)) && ...
                            latest_sector(i,3) <= mytimerobj.intradaybarriers_conditional_sector_(i,2) - 0.001
                        dtnum = datenum([num2str(latest_sector(i,1)),' ',num2str(latest_sector(i,2))],'yyyymmdd HHMMSS');
                        dtstr = datestr(dtnum,'yyyy-mm-dd:HH:MM');
                        fprintf('%s:intraday breachDN:%s:%4.3f (%s)\n',dtstr,mytimerobj.codes_sector_{i}(1:end-3),latest_sector(i,3),mytimerobj.names_sector_{i});
                        hasbreach = true;
                    end
                catch
                    fprintf('cETFWatcher:error in loop of sector......\n');
                end
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
                        fprintf('%s:closed:%s\n',tradeout.code_,tradeout.riskmanager_.closestr_);
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