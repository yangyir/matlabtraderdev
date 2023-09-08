function [] = replay_timer_fcn(monitorbase,~,event)
%cMonitorBase
    if strcmpi(monitorbase.mode_,'realtime') || strcmpi(monitorbase.mode_,'demo')
        dtnum = datenum(event.Data.time);
    elseif strcmpi(monitorbase.mode_,'replay')
        dtnum = monitorbase.getreplaytime;
    end
        
    slept = monitorbase.istime2sleep(dtnum);
    %note:the status of the object is set via other explict functions
    %defined in the class for replay mode
    if strcmpi(monitorbase.mode_,'realtime')
        if ~slept
            try
                monitorbase.refresh('time',dtnum);
            catch e
                fprintf('%s error when run refresh methods:%s\n',monitorbase.name_,e.message);
                if strcmpi(monitorbase.onerror_,'stop')
                    monitorbase.stop;
                end
            end
        end
    else
        %note, the replay time is updated via the refresh function in
        %replay mode
        try
            monitorbase.refresh('time',dtnum);
        catch e
            fprintf('%s error when run refresh methods:%s\n',monitorbase.name_,e.message);
            if strcmpi(monitorbase.onerror_,'stop')
                monitorbase.stop;
            end
        end
    end
    
    if monitorbase.istime2print(dtnum) && ~slept
        try
            monitorbase.print('time',dtnum);
        catch e
            fprintf('%s error when run print methods:%s\n',monitorbase.name_,e.message);
            if strcmpi(monitorbase.onerror_,'stop')
                monitorbase.stop;
            end
        end
    end
    
    if monitorbase.istime2savemktdata(dtnum)
        try
            monitorbase.savemktdata('time',dtnum);
        catch e
            fprintf('%s error when run savemktdata methods:%s\n',monitorbase.name_,e.message);
            if strcmpi(monitorbase.onerror_,'stop')
                monitorbase.stop;
            end
        end
    end
    
    if monitorbase.istime2savetrades(dtnum)
        try
            monitorbase.savetrades('time',dtnum);
        catch e
            fprintf('%s error when run savetrades methods:%s\n',monitorbase.name_,e.message);
            if strcmpi(monitorbase.onerror_,'stop')
                monitorbase.stop;
            end
        end
    end
    
    if monitorbase.istime2loadmktdata(dtnum)
        try
            monitorbase.loadmktdata('time',dtnum);
        catch e
            fprintf('%s error when run loadmktdata methods:%s\n',monitorbase.name_,e.message);
            if strcmpi(monitorbase.onerror_,'stop')
                monitorbase.stop;
            end
        end
    end
    
    if monitorbase.istime2loadtrades(dtnum)
        try
            monitorbase.loadtrades('time',dtnum);
        catch e
            fprintf('%s error when run loadtrades methods:%s\n',monitorbase.name_,e.message);
            if strcmpi(monitorbase.onerror_,'stop')
                monitorbase.stop;
            end
        end
    end 
    

end
%end of replay_timer_function