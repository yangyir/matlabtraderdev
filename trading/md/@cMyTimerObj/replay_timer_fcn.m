function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime')
        dtnum = datenum(event.Data.time);
    else
        error('cMyTimerObj:replay_timer_fcn:invalid mode')
    end

    hh = hour(dtnum);
    mm = minute(dtnum) + hh*60;

    %for friday evening market
    if isholiday(floor(dtnum))
        if weekday(dtnum) == 7 && mm >= 180
            mytimerobj.status_ = 'sleep';
            return
        elseif weekday(dtnum) == 7 && mm < 180
            %do nothing
        else
            mytimerobj.status_ = 'sleep';
            return
        end
    end

    if (mm >= 0 && mm < 540) || ...
            (mm > 690 && mm < 810) || ...
            (mm > 915 && mm < 1260) || ...
            (mm > 1410 && mm < 1440)
        %market closed for sure
        mytimerobj.status_ = 'sleep';          
        return
    end
    mytimerobj.status_ = 'working';

    mytimerobj.refresh;

end
%end of replay_timer_function