function [] = stop_timer_fcn(obj,~,event)
    disp([datestr(event.Data.time,'yyyy-mm-dd HH:MM:SS'),' ',obj.name_,' stops......']);
end
%end of stop_timer_function