function [] = stop_timer_fcn(obj,~,event)
%cAShareWindIndustries
    if strcmpi(obj.mode_,'realtime')
        disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.timer_.Name,' stops......']);
    else
        if ~isempty(obj.replay_time2_)
            disp([obj.replay_time2_,' ',obj.timer_.Name,' stops......']);
        else
            disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.timer_.Name,' stops......']);
        end
    end
end
%end of stop_timer_function