function [] = replay_timer_fcn(mytimerobj,~,event)
%cAShareWindIndustries
    if strcmpi(mytimerobj.mode_,'realtime') || strcmpi(mytimerobj.mode_,'demo')
        dtnum = datenum(event.Data.time);
    elseif strcmpi(mytimerobj.mode_,'replay')
        error('not implemented yet')
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
            latest_index = mytimerobj.conn_.ds_.wsq(mytimerobj.codes_index_,'rt_date,rt_time,rt_latest');
            if hour(dtnum) == 14 && minute(dtnum) >= 55
                runhighlowonly = false;
            else
                runhighlowonly = true;
            end
            for i = 1:n_index
                %
                variables = mytimerobj.getvariables('code',mytimerobj.codes_index_{i});
                %update the lastest daily candle and intraday candle if needed
                ei = variables.ei;
                try
                    ei.px(end,:) = [ei.px(end,1),ei.px(end,2),max(ei.px(end,3),latest_index(i,3)),min(ei.px(end,4),latest_index(i,3)),latest_index(i,3)];
                catch e
                    fprintf('cAShareWindIndustries:replay_timer_fcn:error in update index candles of %s;%s\n',mytimerobj.names_index_{i},e.message);
                end
                dtstr = datestr(dtnum,'yy-mm-dd:HH:MM');
                [signal_d,op_d] = fractal_signal_unconditional(ei,0.001,2);
                if ~isempty(op_d) && op_d.use
                    if signal_d(1) == 1
                        fprintf('%s:d-breachup:%s:%8.2f with barrier_d at %8.2f (%s)(%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),ei.px(end,5),signal_d(2),op_d.comment,mytimerobj.names_index_{i});
                    elseif signal_d(1) == -1
                        fprintf('%s:d-breachdn:%s:%8.2f with barrier_d at %8.2f (%s)(%s)\n',dtstr,mytimerobj.codes_index_{i}(1:end-3),ei.px(end,5),signal_d(3),op_d.comment,mytimerobj.names_index_{i});
                    end
                    hasbreach = true;         
                end
                %
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
                            fprintf('%s:bullish closed:%s(%s)\n',tradeout.code_,tradeout.riskmanager_.closestr_,mytimerobj.names_index_{i});
                        else
                            fprintf('%s:bearish closed:%s(%s)\n',tradeout.code_,tradeout.riskmanager_.closestr_,mytimerobj.names_index_{i});
                        end
                        hasclosed = true;
                    end
                end
            end
            if hasbreach, fprintf('\n'); end
            if hasclosed, fprintf('\n'); end
            %
        end
    else
        error('not implemented yet')
%         %note, the replay time is updated via the refresh function in
%         %replay mode
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