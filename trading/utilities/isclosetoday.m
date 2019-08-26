function flag = isclosetoday(timeopen,dtnum)
    if ~(isnumeric(timeopen) && isnumeric(dtnum))
        error('isclosetoday:invalid timeopen and dtnum input format:numeric required')
    end
    
    if dtnum < timeopen
        error('isclosetoday:dtnum shall be after timeopen')
    end
    
    dd1 = floor(timeopen);
    hh1 = hour(timeopen);
    dd2 = floor(dtnum);
    hh2 = hour(dtnum);
    
    if dd1 == dd2
        if hh1 < 15
            if hh2 < 15
                flag = 1;
            else
                %the same day but the close time is beyond the afternoon
                %close
                flag = 0;
            end
        else
            flag = 1;
        end
    elseif dd1 < dd2
        nextbd = businessdate(dd1,1);
        if nextbd == dd2 && (hh1 >= 21 || hh1 < 3) && hh2 < 15
            flag = 1;
        else
            flag = 0;
        end
    end
    
        
        
end