function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime')
        dtnum = datenum(event.Data.time);
        flag = mytimerobj.issleep(dtnum);
        if ~flag 
            mytimerobj.refresh;
        end
        
        if mytimerobj.printflag_
            mytimerobj.print;
        end
        
    elseif strcmpi(mytimerobj.mode_,'replay')
        mytimerobj.refresh;
    end    

end
%end of replay_timer_function