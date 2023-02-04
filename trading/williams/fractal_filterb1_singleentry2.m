function [output] = fractal_filterb1_singleentry2(b1type,nfractal,extrainfo,ticksize)
%fractal utility function to check special case for mediumbreach-trendbreak
%and strongbreach-trendbreak
%with long direction
    if nargin < 4
        ticksize = 0;
    end
    
    status = fractal_b1_status(nfractal,extrainfo,ticksize);
    
    if b1type == 1
        error('fractal_filterb1_singleentry2:internal error')
    end
    %
    if b1type == 2
        %special treatment for up-mediumbreach-trendbreak
        %check whether hh moves upward or NOT (downward)
        last2hhidx = find(extrainfo.idxhh==1,2,'last');
        if isempty(last2hhidx)
            hhupward = true;
        else
            if size(last2hhidx,1) == 1
                hhupward = true;
            elseif size(last2hhidx,1) == 2
                last2hh = extrainfo.hh(last2hhidx);
                if last2hh(2) == last2hh(1)
                    last3hhidx = find(extrainfo.idxhh==1,3,'last');
                    try
                        hhupward = last2hh(1) - extrainfo.hh(last3hhidx(1)) > -5*ticksize;
                    catch
                        hhupward = true;
                    end
                else
                    hhupward = last2hh(2) - last2hh(1) > -5*ticksize;
                end
            end
        end
        %
        %check whether ll moves upward or NOT (downward)
        last2llidx = find(extrainfo.idxll==-1,2,'last');
        if isempty(last2llidx)
            llupward = true;
        else
            if size(last2llidx,1) == 1
                llupward = true;
            elseif size(last2llidx,1) == 2
                last2ll = extrainfo.ll(last2llidx);
                if last2ll(2) == last2ll(1)
                    last3llidx = find(extrainfo.idxll==-1,3,'last');
                    try
                        llupward = last2ll(1) - extrainfo.ll(last3llidx(1)) > -5*ticksize;
                    catch
                        llupward = true;
                    end
                else
                    llupward = last2ll(2) - last2ll(1) > -5*ticksize;
                end
            end
        end 
        %
        %1.further check whether there are any breach-up of hh since
        %the last fractal point
        nonbreachhhflag = isempty(find(extrainfo.px(last2hhidx(end)-2*nfractal:end-1,5)-extrainfo.hh(end-1)-2*ticksize>0,1,'last'));
        %2.further check whether last price is above teeth
        aboveteeth = extrainfo.px(end,5)-extrainfo.teeth(end)-2*ticksize>0;
        %3.further check whether there is any breach-dn of ll between
        nonbreachllflag = true;
        for k = last2hhidx(end)-2*nfractal:size(extrainfo.px,1)
            ei_k = fractal_truncate(extrainfo,k);
            [~,validbreachll,~,~] = fractal_validbreach(ei_k,ticksize,false);
            if validbreachll
                nonbreachllflag = false;
                break
            end
        end
        %
        if hhupward
            %4.extra check
            extraflag = extrainfo.px(end,5)-extrainfo.jaw(end)-2*ticksize>0;
            if ~extraflag
                sslast = extrainfo.ss(end);
                abovelipsflag = isempty(find(extrainfo.lips(end-sslast+1:end)-extrainfo.px(end-sslast+1:end,5)-2*ticksize>0,1,'last'));
                extraflag = sslast >= 5 & abovelipsflag;
            end
            %
            if nonbreachhhflag && aboveteeth && nonbreachllflag && extraflag 
                output = struct('use',1,'comment','mediumbreach-trendbreak-s');%here we go
            elseif ~nonbreachhhflag && aboveteeth && ~nonbreachllflag && extraflag
                %market moves volatile with price breached-up and down
                if status.isteethlipscrossed && extrainfo.lips(end) - extrainfo.teeth(end) + 2*ticksize > 0
                    output = struct('use',1,'comment','mediumbreach-trendbreak-s');%here we go
                else
                    output = struct('use',0,'comment','mediumbreach-trendbreak');
                end
            else
                output = struct('use',0,'comment','mediumbreach-trendbreak');
            end
        else
            %NOT hhupward
            %if the price were below lvldn and it breached-up lvldn
            belowlvldnflag = isempty(find(extrainfo.px(last2hhidx(end)-2*nfractal:end-1,5)-extrainfo.lvldn(last2hhidx(end)-2*nfractal:end-1)-2*ticksize>0 ,1,'last'));
            breachlvldnflag = extrainfo.px(end,5)-extrainfo.lvldn(end)-2*ticksize>0;
            if belowlvldnflag && breachlvldnflag && aboveteeth
                output = struct('use',1,'comment','mediumbreach-trendbreak-s');%here we go
                return
            end
            sslast = extrainfo.ss(end);
            abovelipsflag = isempty(find(extrainfo.lips(end-sslast+1:end)-extrainfo.px(end-sslast+1:end,5)-2*ticksize>0,1,'last'));
            %sslast breached 4 indicates the trend might continue
            if sslast >= 5 && abovelipsflag && aboveteeth
                output = struct('use',1,'comment','mediumbreach-trendbreak-s');%here we go
                return
            end
            if llupward && nonbreachhhflag && nonbreachllflag && sslast > 0
                %not sure here
%                 output = struct('use',1,'comment','mediumbreach-trendbreak-s1');
%                 return
            end
            output = struct('use',0,'comment','mediumbreach-trendbreak');
        end
        
    end
    %
    
    if b1type == 3
        
    end
    
end