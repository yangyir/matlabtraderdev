function [] = start_timer_fcn(obj,~,event)
    if strcmpi(obj.mode_,'realtime')
        disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.timer_.Name,' starts......']);
    else
        if ~isempty(obj.replay_time2_)
            disp([obj.replay_time2_,' ',obj.timer_.Name,' starts......']);
        else
            disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.timer_.Name,' starts......']);
        end
    end
end
%end of start_timer_function