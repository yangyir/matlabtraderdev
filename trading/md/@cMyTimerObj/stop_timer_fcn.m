function [] = stop_timer_fcn(obj,~,event)
    if strcmpi(obj.mode_,'realtime')
        disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.name_,' stops......']);
    else
        if ~isempty(obj.replay_time2_)
            disp([obj.replay_time2_,' ',obj.name_,' stops......']);
        else
            disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.name_,' stops......']);
        end
    end
end
%end of stop_timer_function