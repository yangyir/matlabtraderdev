function [output] = fractal_filterb1_singleentry2(b1type,nfractal,extrainfo,ticksize)
%fractal utility function to check special case for mediumbreach-trendbreak
%and strongbreach-trendbreak
%with long direction
    if b1type == 1, error('fractal_filterb1_singleentry2:internal error');end
    
    if nargin < 4
        ticksize = 0;
    end
    
    
    [hhstatus,llstatus] = fractal_barrier_status(extrainfo,ticksize);
    
    hhupward = strcmpi(hhstatus,'upward');
    llupward = strcmpi(llstatus,'upward');
    variablenotused(llupward);
    %
    nonbreachhhflag = true;
    nonbreachllflag = true;
    last2hhidx = find(extrainfo.idxhh==1,2,'last');
    %1.check whether there are any breach-up of hh since
    %the last fractal point also check whether there is any breach-dn 
    %of ll between 
    for k = last2hhidx(end)-nfractal:size(extrainfo.px,1)-1
        ei_k = fractal_truncate(extrainfo,k);
        [validbreachhh,~,~,~] = fractal_validbreach(ei_k,ticksize,false);
        if validbreachhh
            nonbreachhhflag = false;
            break
        end
    end
    %
    for k = last2hhidx(end)-nfractal:size(extrainfo.px,1)
        ei_k = fractal_truncate(extrainfo,k);
        [~,validbreachll,~,~] = fractal_validbreach(ei_k,ticksize,false);
        if validbreachll
            nonbreachllflag = false;
            break
        end
    end
    %2.further check whether last price is above teeth
    aboveteeth = extrainfo.px(end,5)-extrainfo.teeth(end)-2*ticksize>0;
    %3.
    sslast = extrainfo.ss(end);
    %sslast breached 4 indicates the trend might continue
    abovelipsflag = isempty(find(extrainfo.lips(end-sslast+1:end)-extrainfo.px(end-sslast+1:end,5)-2*ticksize>0,1,'last'));
    potentialuptrend = sslast >= 4 & abovelipsflag;
    %
    if hhupward
        %extra check
        extraflag = extrainfo.px(end,5)-extrainfo.jaw(end)-2*ticksize>0;
        if ~extraflag
            extraflag = potentialuptrend;
        end
        %
        if nonbreachhhflag && aboveteeth && nonbreachllflag && extraflag
            if b1type == 2
                output = struct('use',1,'comment','mediumbreach-trendbreak-s1');
            else
                output = struct('use',1,'comment','strongbreach-trendbreak-s1');
            end        
        else
            if b1type == 2
                output = struct('use',0,'comment','mediumbreach-trendbreak');
            else
                output = struct('use',0,'comment','strongbreach-trendbreak');
            end
        end
    else
        %if the price were below lvldn and it breached-up lvldn
        belowlvldnflag = isempty(find(extrainfo.px(last2hhidx(end)-nfractal:end-1,5)-extrainfo.lvldn(last2hhidx(end)-nfractal:end-1)-2*ticksize>0 ,1,'last'));
        breachlvldnflag = extrainfo.px(end,5)-extrainfo.lvldn(end)-2*ticksize>0;
        if belowlvldnflag && breachlvldnflag && aboveteeth
            if b1type == 2
                output = struct('use',1,'comment','mediumbreach-trendbreak-s2');
            else
                output = struct('use',1,'comment','strongbreach-trendbreak-s2');
            end
            return
        end
        if potentialuptrend && aboveteeth && nonbreachllflag
            if b1type == 2
                output = struct('use',1,'comment','mediumbreach-trendbreak-s3');
            else
                output = struct('use',1,'comment','strongbreach-trendbreak-s3');
            end
            return
        end
        if b1type == 2
            output = struct('use',0,'comment','mediumbreach-trendbreak');
        else
            output = struct('use',0,'comment','strongbreach-trendbreak');
        end
    end
        
    %
      
end