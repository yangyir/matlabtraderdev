function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime')
        dtnum = datenum(event.Data.time);
        hh = hour(dtnum);
        mm = minute(dtnum) + hh*60;
        %for friday evening market
        if isholiday(floor(dtnum))
            if weekday(dtnum) == 7 && mm >= 180
                %after 2:30pm on saturday am
                mytimerobj.status_ = 'sleep';
                return
            elseif weekday(dtnum) == 7 && mm < 180
                %do nothing
            else
                mytimerobj.status_ = 'sleep';
                return
            end
        end

        %critical time
        % 02:30 am -> 150   all market close
        % 09:00 am -> 540   futures market open
        % 11:30 am -> 690   futures/stock market close
        % 01:00 pm -> 780   futures/stock market reopen
        % 03:15 pm -> 915   futures close
        % 09:00 pm -> 1260  futures reppen
        if (mm > 150 && mm < 540) || ...
                (mm > 690 && mm < 780) || ...
                (mm > 915 && mm < 1260)
            %market closed for sure
            mytimerobj.status_ = 'sleep';          
            return
        end
        mytimerobj.status_ = 'working';
        mytimerobj.refresh;
        
    elseif strcmpi(mytimerobj.mode_,'replay')
%         mytimerobj.status_ = 'working';
        mytimerobj.refresh;
    else
        error('cMyTimerObj:replay_timer_fcn:invalid mode')
    end    

end
%end of replay_timer_function