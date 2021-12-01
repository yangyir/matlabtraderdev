function [validbreachhh,validbreachll,b1type,s1type] = fractal_validbreach(extrainfo,ticksize)
    %fractal strategy related utility function
    %check whether the price expericences a valid breach of the fractal
    %hh/ll
    if nargin < 2
        ticksize = 0;
    end
    
    validbreachhh = extrainfo.px(end,5)-extrainfo.hh(end-1)>=ticksize & ...
        extrainfo.px(end-1,5)<=extrainfo.hh(end-1) &...
        abs(extrainfo.hh(end-1)/extrainfo.hh(end)-1)<0.002 &...
        extrainfo.px(end,3)>extrainfo.lips(end) &...                         %the high price of candle is above alligator's lips
        ~isnan(extrainfo.lips(end))&~isnan(extrainfo.teeth(end))&~isnan(extrainfo.jaw(end)) &... 
        extrainfo.hh(end)-extrainfo.teeth(end)>=ticksize;
    
    validbreachll = extrainfo.px(end,5)-extrainfo.ll(end-1)<=-ticksize & ...
        extrainfo.px(end-1,5)>=extrainfo.ll(end-1) &...
        abs(extrainfo.ll(end-1)/extrainfo.ll(end)-1)<0.002 &...
        extrainfo.px(end,4)<extrainfo.lips(end) &...                         %the low price of candle is below alligator's lips
        ~isnan(extrainfo.lips(end))&~isnan(extrainfo.teeth(end))&~isnan(extrainfo.jaw(end)) &...
        extrainfo.ll(end)-extrainfo.teeth(end)<=-ticksize;
    
    b1type = [];
    s1type = [];
    if validbreachhh && ~validbreachll
        if extrainfo.teeth(end)>extrainfo.jaw(end)
            b1type = 3;
        else
            b1type = 2;
        end
    elseif ~validbreachhh && validbreachll
        if extrainfo.teeth(end)<extrainfo.jaw(end)
            s1type = 3;
        else
            s1type = 2;
        end
    end
end