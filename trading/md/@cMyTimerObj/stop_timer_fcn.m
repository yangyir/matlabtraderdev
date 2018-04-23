function [] = stop_timer_fcn(obj,~,event)
    disp([datestr(event.Data.time),' ',obj.name_,' stops......']);
end
%end of stop_timer_function