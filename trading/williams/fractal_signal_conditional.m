function [signal,op] = fractal_signal_conditional(ei,ticksize,nfractal,varargin)
%return a signal in case there is neither valid breachup or valid breachdn
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseLastCandle',true,@islogical);
    p.parse(varargin{:});
    uselastcandle = p.Results.UseLastCandle;
    if ~uselastcandle
        ei = fractal_truncate(ei,size(ei.px,1)-1);
    end

    signal = {};
    op = {};
    
    [validbreachhh,validbreachll] = fractal_validbreach(ei,ticksize);
    if validbreachhh || validbreachll
        return
    end
    
    np = size(ei.px,1);
    
    %LONG TREND:
    %1a.1.there are 2*nfractal candles close ABOVE alligator's teeth
    %continuously with HH being ABOVE alligator's teeth;
    %1a.2a:the lastest HH shall be above the previous HH, indicating an
    %upper trend;
    %1a.2b:in case the lastest HH is below the previous HH,i.e.the previous
    %was formed given higher price volatility, we shall still regard the
    %up-trend as valid if and only if there are 2*nfracal candles close
    %above alligator's lips
    [~,~,~,nkaboveteeth,nkfromhh,isteethjawcrossed,isteethlipscrossed] = fractal_countb(ei.px,...
        ei.idxhh,...
        nfractal,...
        ei.lips,...
        ei.teeth,...
        ei.jaw,...
        ticksize);
   
    [hhstatus,llstatus] = fractal_barrier_status(ei,ticksize);
    hhupward = strcmpi(hhstatus,'upward');
    %
    %as long as there are 1) at least 2*nfractal candles close above teeth
    %2)the lips,teeth and jaws are not crossed
    %3)the fractal hh moves upward or (breachup-lvlup case)
    %then the long trend shall be confirmed
    lflag1 = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
        ei.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
    lflag2 = ~isteethjawcrossed & ~isteethlipscrossed;
    lflag3 = hhupward;
    lflag4 = (~hhupward&&ei.hh(end)>=ei.lvlup(end)&&ei.px(end,5)<=ei.lvlup(end));
    longtrend = lflag1 & (lflag2 | lflag4) & (lflag3 | lflag4);
    %
    %if not all of the above 3 conditions hold
    if ~longtrend 
        if nkaboveteeth >= 2*nfractal
            %there are enough candles formed since the last hh
            if hhupward
                %longtrend is valid if fractal hh moves upward
                %TODO:
                %NO MATTER WHETHER ANY LIPS,TEETH OR JAWS CROSSED
                longtrend = true;
            else
                %special cases if fractal hh moves downward
                if ~isteethlipscrossed
                    %strong condition that all close are above lips IF THEY
                    %ARE NOT CROSSED
                    longtrend = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                        ei.lips(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
                    if ~longtrend
                        %weak condition:1)there are 2*nfracal candles low
                        %above alligator's teeth
                        %2)the last close WELL above lips
                        longtrend = isempty(find(ei.px(end-2*nfractal+1:end,4)-...
                            ei.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
                        longtrend = longtrend & ...
                            ei.px(end,5)-ei.lips(end)-2*ticksize>0;
                        longtrend = longtrend && ei.ss(end)>=1;
                    end
                else
                    %strong condition that all close are above max of lips and
                    %teeth IF THERY ARE CROSSED
                    if ~lflag1
                        longtrend = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                            max(ei.lips(end-2*nfractal+1:end),ei.teeth(end-2*nfractal+1:end))+2*ticksize<0,1,'first'));
                    else
                        longtrend = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                            max(ei.lips(end-2*nfractal+1:end),ei.teeth(end-2*nfractal+1:end))+4*ticksize<0,1,'first'));
                    end
                end
            end
        else
            %in case all candles are above teeth since hh formed but there are
            %less than 2*nfractal candles since then, we include candles before
            %the hh and check
            if nkaboveteeth == nkfromhh
                %long trend can be identified as long as there are
                %2*nfracal candles'low above alligator's teeth
                longtrend = isempty(find(ei.px(end-2*nfractal+1:end,4)-...
                    ei.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first')) || ...
                    isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                    max(ei.lips(end-2*nfractal+1:end),ei.teeth(end-2*nfractal+1:end))+2*ticksize<0,1,'first'));
            else
                longtrend = false;
            end
        end
    end
    %
    %further check whether alligator's teeth and jaw are crossed or not
    %DO NOT place any conditional order if they are crossed
    if longtrend && isteethjawcrossed && ...
            ~(ei.hh(end)>=ei.lvlup(end)&&ei.px(end,5)<=ei.lvlup(end))
        exceptionflag = false;
        %breachup-sshighvalue
        lastssidx = find(ei.ss >= 9,1,'last');
        if ~isempty(lastssidx) && size(ei.ss,1)-lastssidx+1 <= nkfromhh
            lastssval = ei.ss(lastssidx);
            pxhigh = max(ei.px(lastssidx-lastssval+1:lastssidx,3));
            exceptionflag = ei.hh(end) >= pxhigh;
        end
        %breachup-schighvalue
        lastscidx = find(ei.sc == 13,1,'last');
        if ~isempty(lastscidx) && ~exceptionflag
            nkfromsc13 = size(ei.sc,1)-lastscidx;
            exceptionflag = nkfromsc13 < 12 & ...
                ei.hh(end)>=max(ei.px(lastscidx:end,3));
        end
        %exception in case lips are well above teeth without
        %intersection and also candles are well above teeth even if
        %teeth and jaw are crossed
        if ~exceptionflag
            exceptionflag = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                        ei.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first')) && ...
                        isempty(find(ei.lips(end-nfractal:end)-...
                        ei.teeth(end-nfractal:end)-2*ticksize<0, 1,'first'));
        end
        %exception in case fractal hhs are upwards and lastest hh is
        %above lvlup with candles are above teeth
        %breachup-lvlup
        if ~exceptionflag
            exceptionflag = hhupward && ...
                isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                ei.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first')) && ...
                ei.hh(end)-ei.lvlup(end)>=0;
        end
        %exception in case fractal hhs are upwards and candles close
        %above maximum of teeth and lips
        if ~exceptionflag
            exceptionflag = hhupward && ...
                isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                max(ei.teeth(end-2*nfractal+1:end),ei.lips(end-2*nfractal+1:end))+2*ticksize<0,1,'first'));
        end
        %
        if exceptionflag
            longtrend = true;
        else
            longtrend = false;
        end
    end
    %
    %special case:
    %the upper-trend might be too strong and about to exhausted
    %1)the latest candle is within 12 candles(inclusive) from the last sc13
    %2)the latest sell sequential is greater than or equal 22(9+13)
    %3)the latest sc13 is included in the latest sell sequential
    %DO N0T place any order if the above 3 conditions hold
    if longtrend
        idx_sc13_last = find(ei.sc==13,1,'last');
        idx_ss_last = find(ei.ss >= 9, 1,'last');
        if ~isempty(idx_sc13_last) && ~isempty(idx_ss_last)
            ss_last = ei.ss(idx_ss_last);
            idx_ss_start = idx_ss_last-ss_last+1;
            if size(ei.sc,1) - idx_sc13_last <= 12 && ...
                    ss_last >= 22 && ...
                    idx_ss_start + 9 < idx_sc13_last
                longtrend = false;
            end
        end
    end
    if longtrend
        longtrend = ~(ei.px(end,5)-ei.ll(end-1)<=-ticksize);
    end
    longtrend = longtrend & ei.px(end,5)<ei.hh(end);
    %
    %
    %SHORT TREND:
    %2a.1.there are 2*nfractal candles close BELOW alligator's teeth
    %continuously with LL being BELOW alligator's teeth;
    %2a.2a:the lastest LL shall be below the previous LL, indicating a
    %down trend;
    %2a.2b:in case the lastest LL is above the previous LL,i.e.the previous
    %was formed given higher price volatility, we shall still regard the
    %down-trend as valid if and only if there are 2*nfracal candles close
    %below alligator's lips
    [~,~,~,nkbelowteeth,nkfromll,isteethjawcrossed,isteethlipscrossed] = fractal_counts(ei.px,...
            ei.idxll,...
            nfractal,...
            ei.lips,...
            ei.teeth,...
            ei.jaw,...
            ticksize);
    lldnward = strcmpi(llstatus,'dnward');
    %
    %as long as there are 1) at least 2*nfractal candles close below teeth
    %2)the lips,teeth and jaws are not crossed
    %3)the fractal ll moves dnward or (breachdn-lvldn case)
    %then the short trend shall be confirmed
    sflag1 = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
        ei.teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
    sflag2 = ~isteethjawcrossed & ~isteethlipscrossed;
    sflag3 = lldnward;
    sflag4 = (~lldnward && ei.ll(end)<=ei.lvldn(end)&&ei.px(end,5)>=ei.lvldn(end));
    shorttrend = sflag1 & (sflag2 | sflag4) & (sflag3 | sflag4);
    %
    %if not all the above 3 conditions hold
    if ~shorttrend
        if nkbelowteeth >= 2*nfractal
            %there are enough candles formed since last hh
            if lldnward
                %shorttrend is valid if fractal ll moves dnward
                %TODO:
                %NO MATTER WHETHER ANY LIPS,TEETH OR JAWS CROSSED
                shorttrend = true;
            else
                %special cases if ll moves upward
                if ~isteethlipscrossed
                    %strong condition that all close are below lips IF THEY
                    %ARE NOT CROSSED
                    shorttrend = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                        ei.lips(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
                    if ~shorttrend
                        %weak condition:1)there are 2*nfracal candles high
                        %below alligator's teeth
                        %2)the last close WELL below lips
                        shorttrend = isempty(find(ei.px(end-2*nfractal+1:end,3)-...
                            ei.teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
                        shorttrend = shorttrend & ...
                            ei.px(end,5)-ei.lips(end)+2*ticksize<0;
                        shorttrend = shorttrend && ei.bs(end)>=1;
                    end
                else
                    %strong condition that all close are below min of lips
                    %and teeth IF THEY ARE 
                    if ~sflag1
                        shorttrend = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                            min(ei.lips(end-2*nfractal+1:end),ei.teeth(end-2*nfractal+1:end))-2*ticksize>0,1,'first'));
                    else
                        shorttrend = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                            min(ei.lips(end-2*nfractal+1:end),ei.teeth(end-2*nfractal+1:end))-4*ticksize>0,1,'first'));
                    end
                end
            end
        else
            %in case all candles are below teeth since ll formed but there are
            %less than 2*nfractal candles since then, we include candles before
            %the ll and check
            if nkbelowteeth == nkfromll
                %short trend can be identified as long as there are
                %2*nfracal candles' high below alligator's teeth
                shorttrend = isempty(find(ei.px(end-2*nfractal+1:end,3)-...
                    ei.teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first')) || ...
                    isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                    min(ei.lips(end-2*nfractal+1:end),ei.teeth(end-2*nfractal+1:end))-2*ticksize>0,1,'first'));
            else
                shorttrend = false;
            end
        end
    end
    %
    %further check whether alligator's teeth and jaw are crossed or not
    %DO NOT place any conditional order if they are crossed
    if shorttrend && isteethjawcrossed && ...
            ~(ei.ll(end)<=ei.lvldn(end)&&ei.px(end,5)>=ei.lvldn(end))
        exceptionflag = false;
        lastbsidx = find(ei.bs >= 9,1,'last');
        if ~isempty(lastbsidx) && size(ei.bs,1)-lastbsidx+1 <= nkfromll
            lastbsval = ei.bs(lastbsidx);
            pxlow = min(ei.px(lastbsidx-lastbsval+1:lastbsidx,4));
            exceptionflag = ei.ll(end) <= pxlow;
        end
        lastbcidx = find(ei.bc == 13,1,'last');
        if ~isempty(lastbcidx) && ~exceptionflag
            nkfrombc13 = size(ei.bc,1)-lastbcidx;
            exceptionflag = nkfrombc13 < 12 & ...
                ei.ll(end)<=min(ei.px(lastbcidx:end,4));
        end
        %exception in case lips are well below teeth without
        %intersection and also candles are well below lips even if
        %teeth and jaw are crossed
        if ~exceptionflag
            exceptionflag = isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                    ei.lips(end-2*nfractal+1:end)-2*ticksize>0,1,'first')) && ...
                    isempty(find(ei.lips(end-nfractal:end)-...
                    ei.teeth(end-nfractal:end)+2*ticksize>0, 1,'first'));
        end
        %exception in case fractal lls are downwards and lastest ll is
        %below lvldn with candles are below teeth
        if ~exceptionflag
            exceptionflag = lldnward && ...
                isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                ei.teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first')) && ...
                ei.ll(end)-ei.lvldn(end)<=0;
        end
        %exception in case fractal lls are dnwards and candles close
        %below minimum of teeth and lips
        if ~exceptionflag
            exceptionflag = lldnward && ...
                isempty(find(ei.px(end-2*nfractal+1:end,5)-...
                min(ei.teeth(end-2*nfractal+1:end),ei.lips(end-2*nfractal+1:end))-2*ticksize>0,1,'first'));
        end

        if exceptionflag
            shorttrend = true;
        else
            shorttrend = false;
        end
    end
    %special case:
    %the down-trend might be too strong and about to exhausted
    %1)the latest candle stick is within 12 sticks(inclusive)
    %from the latest buy count 13
    %2)the latest buy sequential is greater than or equal 22(9+13)
    %3)the latest buy count 13 is included in the latest buy sequential
    %DO NOT place any order if the above 3 conditions hold
    if shorttrend
        idx_bc13_last = find(ei.bc==13,1,'last');
        idx_bs_last = find(ei.bs>=9,1,'last');
        if ~isempty(idx_bc13_last) && ~isempty(idx_bs_last)
            bs_last = ei.bs(idx_bs_last);
            idx_bs_start = idx_bs_last-bs_last+1;
            if size(ei.bc,1)-idx_bc13_last <= 12 && ...
                    bs_last >= 22 &&...
                    idx_bs_start + 9 < idx_bc13_last
                shorttrend = false;
            end
        end
    end
    if shorttrend
        shorttrend = ~(ei.px(end,5)-ei.hh(end-1)>=ticksize);
    end
    shorttrend = shorttrend & ei.px(end,5)>ei.ll(end);
        
    if longtrend || shorttrend
        signal = cell(1,2);
        op = cell(1,2);
        if longtrend
            if ei.teeth(end)>ei.jaw(end)
                op{1,1} = 'conditional:strongbreach-trendconfirmed';
            else
                op{1,1} = 'conditional:mediumbreach-trendconfirmed';
            end
            this_signal = zeros(1,7);
            this_signal(1,1) = 1;
            %speical treatment here in case of close fractal hh and tdst
            %lvlup
            if ei.lvlup(end)-ei.hh(end) <= 4*ticksize && ...
                    ei.lvlup(end)>ei.hh(end) && ...
                    ei.lvlup(end)>ei.lvldn(end)
                this_signal(1,2) = ei.lvlup(end);
            else
                this_signal(1,2) = ei.hh(end);
            end
            this_signal(1,3) = ei.ll(end);
            this_signal(1,5) = ei.px(end,3);
            this_signal(1,6) = ei.px(end,4);
            this_signal(1,7) = ei.lips(end);
            this_signal(1,4) = 2;
            signal{1,1} = this_signal;
        end
        %
        if shorttrend
            if ei.teeth(end)<ei.jaw(end)
                op{1,2} = 'conditional:strongbreach-trendconfirmed';
            else
                op{1,2} = 'conditional:mediumbreach-trendconfirmed';
            end
            this_signal = zeros(1,7);
            this_signal(1,1) = -1;
            this_signal(1,2) = ei.hh(end);
            if ei.ll(end)-ei.lvldn(end) <= 4*ticksize && ...
                    ei.lvldn(end)<ei.ll(end) && ...
                    ei.lvldn(end)<ei.lvlup(end)
                this_signal(1,3) = ei.lvldn(end);
            else
                this_signal(1,3) = ei.ll(end);
            end
            this_signal(1,5) = ei.px(end,3);
            this_signal(1,6) = ei.px(end,4);
            this_signal(1,7) = ei.lips(end);
            this_signal(1,4) = -2;
            signal{1,2} = this_signal;
        end
        
        return
        
    end
    %
    %************ NEITHER long NOR short trend ***********************
    
    
    
    
    
    
    
end