function [output] = fractal_filters1_singleentry2(s1type,nfractal,extrainfo,ticksize)
%fractal utility function to check special case for mediumbreach-trendbreak
%and strongbreach-trendbreak
%with short direction
    if s1type == 1, error('fractal_filters1_singleentry2:internal error');end
    
    if nargin < 4
        ticksize = 0;
    end
    
    [hhstatus,llstatus] = fractal_barrier_status(extrainfo,ticksize);
    
    hhdnward = ~strcmpi(hhstatus,'upward');
    lldnward = ~strcmpi(llstatus,'upward');
    variablenotused(hhdnward);
    %
    nonbreachhhflag = true;
    nonbreachllflag = true;
    last2llidx = find(extrainfo.idxll==-1,2,'last');
    %1.check whether there are any breach-dn of ll since
    %the last fractal point also check whether there is any breach-up 
    %of hh between 
    for k = last2llidx(end)-nfractal:size(extrainfo.px,1)
        ei_k = fractal_truncate(extrainfo,k);
        [validbreachhh,~,~,~] = fractal_validbreach(ei_k,ticksize,false);
        if validbreachhh
            nonbreachhhflag = false;
            break
        end
    end
    %
    for k = last2llidx(end)-nfractal:size(extrainfo.px,1)-1
        ei_k = fractal_truncate(extrainfo,k);
        [~,validbreachll,~,~] = fractal_validbreach(ei_k,ticksize,false);
        if validbreachll
            nonbreachllflag = false;
            break
        end
    end
    %2.further check whether last price is above teeth
    belowteeth = extrainfo.px(end,5)-extrainfo.teeth(end)+2*ticksize<0;
    belowjaw = extrainfo.px(end,5)-extrainfo.jaw(end)+2*ticksize<0;
    %3.
    bslast = extrainfo.bs(end);
    %bslast breached 4 indicates the trend might continue
    belowlipsflag = isempty(find(extrainfo.lips(end-bslast+1:end)-extrainfo.px(end-bslast+1:end,5)+2*ticksize<0,1,'last'));
    potentialdntrend = bslast >= 4 & belowlipsflag;
    %
    if lldnward
        %extra check
        extraflag = belowjaw | potentialdntrend;
        %
        if nonbreachhhflag && belowteeth && nonbreachllflag && extraflag
            if s1type == 2
                output = struct('use',1,'comment','mediumbreach-trendbreak-s1');
            else
                output = struct('use',1,'comment','strongbreach-trendbreak-s1');
            end        
        else
            if s1type == 2
                output = struct('use',0,'comment','mediumbreach-trendbreak');
            else
                output = struct('use',0,'comment','strongbreach-trendbreak');
            end
        end
    else
        %if the price were above lvlup and it breached-dn lvlup
        abovelvlupflag = isempty(find(extrainfo.px(last2llidx(end)-nfractal:end-1,5)-extrainfo.lvlup(last2llidx(end)-nfractal:end-1)+2*ticksize<0 ,1,'last'));
        breachlvlupflag = extrainfo.px(end,5)-extrainfo.lvlup(end)+2*ticksize<0;
        if abovelvlupflag && breachlvlupflag && belowteeth && (belowjaw || potentialdntrend)
            if s1type == 2
                output = struct('use',1,'comment','mediumbreach-trendbreak-s2');
            else
                output = struct('use',1,'comment','strongbreach-trendbreak-s2');
            end
            return
        end
        if potentialdntrend && belowteeth && nonbreachllflag
            if s1type == 2
                output = struct('use',1,'comment','mediumbreach-trendbreak-s3');
            else
                output = struct('use',1,'comment','strongbreach-trendbreak-s3');
            end
            return
        end
        if s1type == 2
            output = struct('use',0,'comment','mediumbreach-trendbreak');
        else
            output = struct('use',0,'comment','strongbreach-trendbreak');
        end
    end
        
    %
      
end