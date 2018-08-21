function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime')
        dtnum = datenum(event.Data.time);
        
        if ~mytimerobj.istime2sleep(dtnum); 
            mytimerobj.refresh;
        end
        
        if mytimerobj.istime2print(dtnum)
            mytimerobj.print('time',dtnum);
        end
        
        if mytimerobj.istime2savemktdata(dtnum)
            mytimerobj.savemktdata('time',dtnum);
        end
        
        if mytimerobj.istime2savetrades(dtnum)
            mytimerobj.savetrades('time',dtnum);
        end
        
        if mytimerobj.istime2loadmktdata(dtnum)
            mytimerobj.loadmktdata('time',dtnum);
        end
        
        if mytimerobj.istime2loadtrades(dtnum)
            mytimerobj.loadtrades('time',dtnum);
        end
        
    elseif strcmpi(mytimerobj.mode_,'replay')
        mytimerobj.refresh;
    end    

end
%end of replay_timer_function