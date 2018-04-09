function [] = start_timer_fcn(~,~,event)
    disp([datestr(event.Data.time),' timer starts......']);
end
%end of start_timer_function