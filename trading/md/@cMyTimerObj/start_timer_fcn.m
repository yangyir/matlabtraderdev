function [] = start_timer_fcn(obj,~,event)
    disp([datestr(event.Data.time),' ',obj.name_,' starts......']);
end
%end of start_timer_function