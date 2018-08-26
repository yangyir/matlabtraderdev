function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime')
        dtnum = datenum(event.Data.time);
    elseif strcmpi(mytimerobj.mode_,'replay')
        dtnum = mytimerobj.getreplaytime;
    end
        
    flag = mytimerobj.istime2sleep(dtnum);
    %note:the status of the object is set via other explict functions
    %defined in the class for replay mode
    if strcmpi(mytimerobj.mode_,'realtime')
        if ~flag
%             mytimerobj.status_ = 'sleep';
%         else
%             mytimerobj.status_ = 'working';
            mytimerobj.refresh;
        end
    else
        %note, the replay time is updated via the refresh function in
        %replay mode
%         if flag
%             mytimerobj.status_ = 'sleep';
%         else
%             mytimerobj.status_ = 'working';
%         end
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
    

end
%end of replay_timer_function