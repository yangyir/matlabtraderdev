function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime') || strcmpi(mytimerobj.mode_,'demo')
        dtnum = datenum(event.Data.time);
    elseif strcmpi(mytimerobj.mode_,'replay')
        dtnum = mytimerobj.getreplaytime;
    end
        
    slept = mytimerobj.istime2sleep(dtnum);
    %note:the status of the object is set via other explict functions
    %defined in the class for replay mode
    if strcmpi(mytimerobj.mode_,'realtime')
        if ~slept
            try
                mytimerobj.refresh('time',dtnum);
            catch e
                fprintf('%s error when run refresh methods:%s\n',mytimerobj.name_,e.message);
                if strcmpi(mytimerobj.onerror_,'stop')
                    mytimerobj.stop;
                end
            end
        end
    else
        %note, the replay time is updated via the refresh function in
        %replay mode
        try
            mytimerobj.refresh('time',dtnum);
        catch e
            fprintf('%s error when run refresh methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end
    
    if mytimerobj.istime2print(dtnum) && ~slept
        try
            mytimerobj.print('time',dtnum);
        catch e
            fprintf('%s error when run print methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end
    
    if mytimerobj.istime2savemktdata(dtnum)
        try
            mytimerobj.savemktdata('time',dtnum);
        catch e
            fprintf('%s error when run savemktdata methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end
    
    if mytimerobj.istime2savetrades(dtnum)
        try
            mytimerobj.savetrades('time',dtnum);
        catch e
            fprintf('%s error when run savetrades methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end
    
    if mytimerobj.istime2loadmktdata(dtnum)
        try
            mytimerobj.loadmktdata('time',dtnum);
        catch e
            fprintf('%s error when run loadmktdata methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end
    
    if mytimerobj.istime2loadtrades(dtnum)
        try
            mytimerobj.loadtrades('time',dtnum);
        catch e
            fprintf('%s error when run loadtrades methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end 
    

end
%end of replay_timer_function