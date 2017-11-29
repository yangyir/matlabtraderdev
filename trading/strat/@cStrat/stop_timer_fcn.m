function [] = stop_timer_fcn(strategy,~,event)
    disp([datestr(event.Data.time),' ',strategy.name_,' stops......']);
end