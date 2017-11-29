function [] = start_timer_fcn(strategy,~,event)
    disp([datestr(event.Data.time),' ',strategy.name_,' starts......']);
end