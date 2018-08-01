function [] = replay_timer_fcn(mytimerobj,~,event)
    if strcmpi(mytimerobj.mode_,'realtime')
        dtnum = datenum(event.Data.time);
        hh = hour(dtnum);
        mm = minute(dtnum) + hh*60;
        
        if weekday(dtnum) == 1
            %market definitely closes on Sunday
            mytimerobj.status_ = 'sleep';
        elseif weekday(dtnum) == 7
            %for Friday evening market
            %rule if the next Monday is a public holiday, the market closes
            dnum = floor(dtnum);
            nextMonday = dnum + 2;
            if isholiday(nextMonday)
                mytimerobj.status_ = 'sleep';
            else
                if mm <= mytimerobj.mm_02_30_
                    mytimerobj.status_ = 'working';
                else
                    mytimerobj.status_ = 'sleep';
                end
            end
        else
            %weekday = 2,3,4,5,6
            dnum = floor(dtnum);
            if isholiday(dnum)
                mytimerobj.status_ = 'sleep';
            else
                if (mm > mytimerobj.mm_02_40_ && mm <  mytimerobj.mm_08_50_) || ...
                        (mm > mytimerobj.mm_11_30_ && mm < mytimerobj.mm_13_00_) || ...
                        (mm > mytimerobj.mm_15_15_ && mm < mytimerobj.mm_21_00_)
                    mytimerobj.status_ = 'sleep';
                else
                    mytimerobj.status_ = 'working';
                end
            end
        end
        
        if strcmpi(mytimerobj.status_,'working')
            mytimerobj.refresh;
        end
             
    elseif strcmpi(mytimerobj.mode_,'replay')
        mytimerobj.refresh;
    end    

end
%end of replay_timer_function