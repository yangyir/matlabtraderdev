function [] = stop_timer_fcn(~,~,event)
    disp([datestr(event.Data.time),' timer stops......']);
end
%end of stop_timer_function