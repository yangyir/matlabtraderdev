function [] = start_timer_fcn(obj,~,event)
    if strcmpi(obj.mode_,'realtime')
        disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.timer_.Name,' starts......']);
    else
        replay_time = obj.getreplaytime;
        
        if ~isempty(replay_time)
            disp([datestr(replay_time,'yyyy-mm-dd HH:MM:SS'),' ',obj.timer_.Name,' starts......']);
        else
            disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.timer_.Name,' starts......']);
        end
    end
end
%end of start_timer_function