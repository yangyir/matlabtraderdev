function [] = stop_timer_fcn(monitorbase,~,event)
%cMonitorBase
    if strcmpi(monitorbase.mode_,'realtime')
        disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',monitorbase.timer_.Name,' stops......']);
    else
        try
            replay_time = monitorbase.getreplaytime;
        catch
            replay_time = [];
        end
        if ~isempty(replay_time)
            disp([datestr(replay_time,'yyyy-mm-dd HH:MM:SS'),' ',monitorbase.timer_.Name,' stops......']);
        else
            disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',monitorbase.timer_.Name,' stops......']);
        end
    end
end
%end of stop_timer_function