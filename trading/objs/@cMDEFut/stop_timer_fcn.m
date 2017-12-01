function [] = stop_timer_fcn(mdefut,~,event)
    variablenotused(mdefut);
    disp([datestr(event.Data.time),' mde stops......']);
end
%end of stop_timer_function