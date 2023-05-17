function [outputstr] = fractal_s1_status2str(status)
    if status.s1type == 2
        outputstr = 'mediumbreach';
    elseif status.s1type == 3
        outputstr = 'strongbreach';
    else
        outputstr = 'weakbreach';
        return
    end
    
    if status.isvolblowup
        outputstr = [outputstr,'-volblowup1'];
    end
    if ~status.isvolblowup && status.isvolblowup2
        outputstr = [outputstr,'-volblowup2'];
    end
    
    if status.islvldnbreach
        outputstr = [outputstr,'-breachdn-lvldn'];
    end
    
    if status.isbslowbreach
        outputstr = [outputstr,'-bslowbreach'];
    end
    
    if status.isbclowbreach
        outputstr = [outputstr,'-lowbc13breach'];
    end
    
    if status.istrendconfirmed
        outputstr = [outputstr,'-trendconfirmed'];
    else
        outputstr = [outputstr,'-trendbreak'];
    end
    
    if status.isclose2lvldn
        outputstr = 'closetolvldn';
        return
    end
end