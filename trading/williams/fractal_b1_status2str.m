function [outputstr] = fractal_b1_status2str(status)
    
    if status.b1type == 2
        outputstr = 'mediumbreach';
    elseif status.b1type == 3
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
    
    if status.islvlupbreach
        outputstr = [outputstr,'-breachup-lvlup'];
    end
    
    if status.issshighbreach
        outputstr = [outputstr,'-sshighvalue'];
    end
    
    if status.isschighbreach
        outputstr = [outputstr,'-highsc13'];
    end
    
    if status.istrendconfirmed
        outputstr = [outputstr,'-trendconfirmed'];
    else
        outputstr = [outputstr,'-trendbreak'];
    end
    
    if status.isclose2lvlup
        outputstr = 'closetolvlup';
        return
    end
    
end