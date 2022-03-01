function [ret,direction,breachdate,breachidx] = fractal_hasdailybreach(t,extrainfo,ticksize)
%fractal utility function to check whether there was any daily breach for
%the last 5 business (trading) days;
    lastbd = getlastbusinessdate(t);
    dtend = extrainfo.px(end,1);
    
    ret = false;
    direction = [];
    breachdate = [];
    breachidx = [];
    
    if dtend < lastbd
        error('fractal_hasdailybreach:price info not updated till the last business date')
    end
    
    np = size(extrainfo.px,1);
    
    for i = np:-1:np-4
        extrainfo_i = fractal_truncate(extrainfo,i);
        
        [validbreachhh,validbreachll,~,~] = fractal_validbreach(extrainfo_i,ticksize);
        
        if validbreachhh
            ret = true;
            direction = 1;
            breachdate = extrainfo.px(i,1);
            breachidx = i;
            break
        end
        
        if validbreachll
            ret = true;
            direction = -1;
            breachdate = extrainfo.px(i,1);
            breachidx = i;
            break
        end
        
    end
    
    
end