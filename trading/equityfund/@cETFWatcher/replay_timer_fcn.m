function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime') || strcmpi(mytimerobj.mode_,'demo')
        dtnum = datenum(event.Data.time);
    elseif strcmpi(mytimerobj.mode_,'replay')
        error('not implemented yet')
%         dtnum = mytimerobj.getreplaytime;
    end
        
    flag = mytimerobj.istime2refresh('time',dtnum);
    %note:the status of the object is set via other explict functions
    %defined in the class for replay mode
    if strcmpi(mytimerobj.mode_,'realtime')
        if flag
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
        error('not implemented yet')
%         %note, the replay time is updated via the refresh function in
%         %replay mode
%         try
%             mytimerobj.refresh('time',dtnum);
%         catch e
%             fprintf('%s error when run refresh methods:%s\n',mytimerobj.name_,e.message);
%             if strcmpi(mytimerobj.onerror_,'stop')
%                 mytimerobj.stop;
%             end
%         end
    end
    
    if flag
        try
            mytimerobj.print('time',dtnum);
        catch e
            fprintf('%s error when run print methods:%s\n',mytimerobj.name_,e.message);
            if strcmpi(mytimerobj.onerror_,'stop')
                mytimerobj.stop;
            end
        end
    end
    

end
%end of replay_timer_function