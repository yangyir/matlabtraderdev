function [flag] = istime2sleep(mdefx,t)
%cmdefx    
%unfortunately fx money never sleeps
%it trades from 4am on monday till 4am on saturday
%it sleeps from 4am saturday to 4am next monday then

    wday = weekday(t);
    if wday == 1
        %suday
        flag = 1;
        mdefx.status_ = 'sleep';
    elseif wday == 2
        %monday
        hh = hour(t);
        if hh >= 4
            flag = 0;
            mdefx.status_ = 'working';
        else
            flag = 1;
            mdefx.status_ = 'sleep';
        end
    elseif wday == 7
        %saturday
        hh = hour(t);
        if hh >= 4
            flag = 1;
            mdefx.status_ = 'sleep';
        else
            flag = 0;
            mdefx.status_ = 'working';
        end
    else
        flag = 0;    
        mdefx.status_ = 'working';
    end

end

