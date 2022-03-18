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
                if strcmpi(mytimerobj.onerror_,'stop')
                    mytimerobj.stop;
                end
            end
        elseif flag == 2
            n_index = size(mytimerobj.codes_index_,1);
            n_sector = size(mytimerobj.codes_sector_,1);
            latest_index = mytimerobj.conn_.ds_.wsq(mytimerobj.codes_index_,'rt_latest');
            latest_sector = mytimerobj.conn_.ds_.wsq(mytimerobj.codes_sector_,'rt_latest');
            for i = 1:n_index
                if isnan(mytimerobj.intradaybarriers_conditional_index_(i,1)) && ...
                        latest_index(i) >= mytimerobj.intradaybarriers_conditional_index_(i,1) + 0.001
                    fprintf('%s:index breachup\n',mytimerobj.codes_index_{i}(1:end-3));
                end
                if isnan(mytimerobj.intradaybarriers_conditional_index_(i,2)) && ...
                        latest_index(i) <= mytimerobj.intradaybarriers_conditional_index_(i,2) - 0.001
                    fprintf('%s:index breachdn\n',mytimerobj.codes_index_{i}(1:end-3));
                end
            end
            %
            for i = 1:n_sector
                if isnan(mytimerobj.intradaybarriers_conditional_sector_(i,1)) && ...
                        latest_sector(i) >= mytimerobj.intradaybarriers_conditional_sector_(i,1) + 0.001
                    fprintf('%s:sector breachup\n',mytimerobj.codes_sector_{i}(1:end-3));
                end
                if isnan(mytimerobj.intradaybarriers_conditional_sector_(i,2)) && ...
                        latest_sector(i) <= mytimerobj.intradaybarriers_conditional_sector_(i,2) - 0.001
                    fprintf('%s:sector breachdn\n',mytimerobj.codes_sector_{i}(1:end-3));
                end
            end
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