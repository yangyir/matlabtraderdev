function [validbreachhh,validbreachll,b1type,s1type] = fractal_validbreach(extrainfo,ticksize,checkteeth)
    %fractal strategy related utility function
    %check whether the price expericences a valid breach of the fractal
    %hh/ll
    if nargin < 2
        ticksize = 0;
        checkteeth = 1;
    end
    
    if nargin < 3
        checkteeth = 1;
    end
    
%     abs(extrainfo.hh(end-1)/extrainfo.hh(end)-1)<0.002 &...
    if abs(ticksize) <= 1e-6
        validbreachhh = extrainfo.px(end,5)-extrainfo.hh(end-1) >= -1e-6 & ...
            extrainfo.px(end-1,5) < extrainfo.hh(end-1) &...
            extrainfo.px(end,3)>extrainfo.lips(end) &...                         %the high price of candle is above alligator's lips
            ~isnan(extrainfo.lips(end))&~isnan(extrainfo.teeth(end))&~isnan(extrainfo.jaw(end));
    else
        validbreachhh = extrainfo.px(end,5)-extrainfo.hh(end-1)-ticksize >= -1e-6 & ...
            extrainfo.px(end-1,5) <= extrainfo.hh(end-1) &...
            extrainfo.px(end,3)>extrainfo.lips(end) &...                         %the high price of candle is above alligator's lips
            ~isnan(extrainfo.lips(end))&~isnan(extrainfo.teeth(end))&~isnan(extrainfo.jaw(end));
    end
    if validbreachhh && extrainfo.px(end-1,5)==extrainfo.hh(end-1)
        validbreachhh = extrainfo.ss(end-1) < 16;
    end
    
    if checkteeth
        validbreachhh = validbreachhh & extrainfo.hh(end)-extrainfo.teeth(end)>=ticksize;
    end
    
%     abs(extrainfo.ll(end-1)/extrainfo.ll(end)-1)<0.002 &...
    if abs(ticksize) <= 1e-6
        validbreachll = extrainfo.px(end,5)-extrainfo.ll(end-1)+ticksize<= 1e-6 & ...
            extrainfo.px(end-1,5) > extrainfo.ll(end-1) &...
            extrainfo.px(end,4)<extrainfo.lips(end) &...                         %the low price of candle is below alligator's lips
            ~isnan(extrainfo.lips(end))&~isnan(extrainfo.teeth(end))&~isnan(extrainfo.jaw(end));
    else
        validbreachll = extrainfo.px(end,5)-extrainfo.ll(end-1)+ticksize<= 1e-6 & ...
            extrainfo.px(end-1,5) >= extrainfo.ll(end-1) &...
            extrainfo.px(end,4)<extrainfo.lips(end) &...                         %the low price of candle is below alligator's lips
            ~isnan(extrainfo.lips(end))&~isnan(extrainfo.teeth(end))&~isnan(extrainfo.jaw(end));
    end
    if validbreachll && extrainfo.px(end-1,5)==extrainfo.ll(end-1)
        validbreachll = extrainfo.bs(end-1) < 16;
    end
    if checkteeth
        validbreachll = validbreachll & extrainfo.ll(end)-extrainfo.teeth(end)<=-ticksize;
    end
    
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