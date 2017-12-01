function [] = start_timer_fcn(mdefut,~,event)
    variablenotused(mdefut);
    disp([datestr(event.Data.time),' mde starts......']);
end
%end of start_timer_function