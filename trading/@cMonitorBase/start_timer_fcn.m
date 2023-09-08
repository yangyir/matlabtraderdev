function [] = start_timer_fcn(monitorbase,~,event)
%cMonitorBase
    if strcmpi(monitorbase.mode_,'realtime')
        disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',monitorbase.timer_.Name,' starts......']);
    else
        try
            replay_time = monitorbase.getreplaytime;
        catch
            replay_time = [];
        end
        
        if ~isempty(replay_time)
            disp([datestr(replay_time,'yyyy-mm-dd HH:MM:SS'),' ',monitorbase.timer_.Name,' starts......']);
        else
            disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',monitorbase.timer_.Name,' starts......']);
        end
    end
end
%end of start_timer_function