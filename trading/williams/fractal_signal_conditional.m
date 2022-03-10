function [signal,op] = fractal_signal_conditional(extrainfo,ticksize,nfractal,varargin)
%return a signal in case there is neither valid breachup or valid breachdn
    signal = {};
    op = {};
    
    [validbreachhh,validbreachll] = fractal_validbreach(extrainfo,ticksize);
    if validbreachhh || validbreachll
        return
    end
    
    np = size(extrainfo.px,1);
    
    %LONG TREND:
    %1a.1.there are 2*nfractal candles close ABOVE alligator's teeth
    %continuously with HH being ABOVE alligator's teeth;
    %1a.2a:the lastest HH shall be above the previous HH, indicating an
    %upper trend;
    %1a.2b:in case the lastest HH is below the previous HH,i.e.the previous
    %was formed given higher price volatility, we shall still regard the
    %up-trend as valid if and only if there are 2*nfracal candles close
    %above alligator's lips
    last2hhidx = find(extrainfo.idxhh==1,2,'last');
    if isempty(last2hhidx)
        %long trend cannot be identified as there is not hh formed yet!!!
        longtrend = false;
    else
        last2hh = extrainfo.hh(last2hhidx);
        if np - (last2hhidx(end)-nfractal) + 1 >= 2*nfractal
            %there have been enough candles formed since the last hh
            % ************* determine flag1 *****************************
            %condition 1a.1 (2*ticksize as buffer zone)
            lflag1 = isempty(find(extrainfo.px(end-2*nfractal+1:end,5)-...
                extrainfo.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
            lflag1 = lflag1 & extrainfo.hh(end)-extrainfo.teeth(end)>=ticksize;
            lflag1 = lflag1 & extrainfo.px(end,5)<extrainfo.hh(end);
            %
            % ************* determine flag2 *****************************
            if size(last2hhidx,1) == 1
                lflag2 = true;
            elseif size(last2hhidx,1) == 2
                if last2hh(2) - last2hh(1) >= ticksize
                    %condition 1a.2a
                    lflag2 = true;
                else
                    %condition 1a.2b (2*ticksize as buffer zone)
                    lflag2 = isempty(find(extrainfo.px(end-2*nfractal+1:end,5)-...
                        extrainfo.lips(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
                    if ~lflag2
                        %weak condition:1)there are 2*nfracal candles low
                        %above alligator's teeth
                        %2)the last close WELL above lips
                        lflag2 = isempty(find(extrainfo.px(end-2*nfractal+1:end,4)-...
                            extrainfo.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
                        lflag2 = lflag2 & ...
                            extrainfo.px(end,5)-extrainfo.lips(end)-2*ticksize>0;
                        lflag2 = lflag2 && extrainfo.ss(end)>=1;
                    end
                end
            end
            %
            % ************* combine flag1 & flag2 ***********************
            longtrend = lflag1 & lflag2;
        else
            %there are not enough candles formed since the last hh
            %but long trend can be identified as long as there are
            %2*nfracal candles'low above alligator's teeth
            longtrend = isempty(find(extrainfo.px(end-2*nfractal+1:end,4)-...
                extrainfo.teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
            longtrend = longtrend & extrainfo.hh(end)-extrainfo.teeth(end)>=ticksize;
            longtrend = longtrend & extrainfo.px(end,5)<extrainfo.hh(end);
        end
    end
    %
    %further check whether alligator's teeth and jaw are crossed or not
    %DO NOT place any conditional order if they are crossed
    if longtrend
        [~,~,~,~,~,isteethjawcrossed,~] = fractal_countb(extrainfo.px,...
            extrainfo.idxhh,...
            nfractal,...
            extrainfo.lips,...
            extrainfo.teeth,...
            extrainfo.jaw,...
            ticksize);
        longtrend = longtrend & ~isteethjawcrossed;
    end
    %special case:
    %the upper-trend might be too strong and about to exhausted
    %1)the latest candle is within 12 candles(inclusive) from the last sc13
    %2)the latest sell sequential is greater than or equal 22(9+13)
    %3)the latest sc13 is included in the latest sell sequential
    %DO N0T place any order if the above 3 conditions hold
    if longtrend
        idx_sc13_last = find(extrainfo.sc==13,1,'last');
        idx_ss_last = find(extrainfo.ss >= 9, 1,'last');
        if ~isempty(idx_sc13_last) && ~isempty(idx_ss_last)
            ss_last = extrainfo.ss(idx_ss_last);
            idx_ss_start = idx_ss_last-ss_last+1;
            if size(extrainfo.sc,1) - idx_sc13_last <= 12 && ...
                    ss_last >= 22 && ...
                    idx_ss_start + 9 < idx_sc13_last
                longtrend = false;
            end
        end
    end
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
    last2llidx = find(extrainfo.idxll==-1,2,'last');
    if isempty(last2hhidx)
        %short trend cannot be identified as there is not ll formed yet!!!
        shorttrend = false;
    else
        last2ll = extrainfo.ll(last2llidx);
        if np - (last2llidx(end)-nfractal) + 1 >= 2*nfractal
            %there have been enough candles formed since the last ll
            % ************* determine flag1 *****************************
            %condition 2a.1 (2*ticksize as buffer zone)
            sflag1 = isempty(find(extrainfo.px(end-2*nfractal+1:end,5)-...
                extrainfo.teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
            sflag1 = sflag1 & extrainfo.ll(end)-extrainfo.teeth(end)<=-ticksize;
            sflag1 = sflag1 & extrainfo.px(end,5)>extrainfo.ll(end);
            %
            % ************* determine flag2 *****************************
            if size(last2llidx,1) == 1
                sflag2 = true;
            elseif size(last2llidx,1) == 2
                if last2ll(2) - last2ll(1) <= -ticksize
                    %condition 2a.2a
                    sflag2 = true;
                else
                    %condition 2a.2b (2*ticksize as buffer zone)
                    sflag2 = isempty(find(extrainfo.px(end-2*nfractal+1:end,5)-...
                        extrainfo.lips(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
                    if ~sflag2
                        %weak condition:1)there are 2*nfracal candles high
                        %below alligator's teeth
                        %2)the last close WELL below lips
                        sflag2 = isempty(find(extrainfo.px(end-2*nfractal+1:end,3)-...
                            extrainfo.teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
                        sflag2 = sflag2 & ...
                            extrainfo.px(end,5)-extrainfo.lips(end)+2*ticksize<0;
                        sflag2 = sflag2 && extrainfo.bs(end)>=1;
                    end
                end
            end
            %
            % ************* combine flag1 & flag2 ***********************
            shorttrend = sflag1 & sflag2;
        else
            %there are not enough candles formed since the last ll
            %but short trend can be identified as long as there are
            %2*nfracal candles high below alligator's teeth
            shorttrend = isempty(find(extrainfo.px(end-2*nfractal+1:end,3)-...
                extrainfo.teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
            shorttrend = shorttrend & extrainfo.ll(end)-extrainfo.teeth(end)<=-ticksize;
            shorttrend = shorttrend & extrainfo.px(end,5)>extrainfo.ll(end);
        end
    end
    %
    %further check whether alligator's teeth and jaw are crossed or not
    %DO NOT place any conditional order if they are crossed
    if shorttrend
        [~,~,~,~,~,isteethjawcrossed,~] = fractal_counts(extrainfo.px,...
            extrainfo.idxll,...
            nfractal,...
            extrainfo.lips,...
            extrainfo.teeth,...
            extrainfo.jaw,...
            ticksize);
        shorttrend = shorttrend & ~isteethjawcrossed;
    end
    %special case:
    %the down-trend might be too strong and about to exhausted
    %1)the latest candle stick is within 12 sticks(inclusive)
    %from the latest buy count 13
    %2)the latest buy sequential is greater than or equal 22(9+13)
    %3)the latest buy count 13 is included in the latest buy sequential
    %DO NOT place any order if the above 3 conditions hold
    if shorttrend
        idx_bc13_last = find(extrainfo.bc==13,1,'last');
        idx_bs_last = find(extrainfo.bs>=9,1,'last');
        if ~isempty(idx_bc13_last) && ~isempty(idx_bs_last)
            bs_last = extrainfo.bs(idx_bs_last);
            idx_bs_start = idx_bs_last-bs_last+1;
            if size(extrainfo.bc,1)-idx_bc13_last <= 12 && ...
                    bs_last >= 22 &&...
                    idx_bs_start + 9 < idx_bc13_last
                shorttrend = false;
            end
        end
    end
    
    if longtrend || shorttrend
        signal = cell(1,2);
        op = cell(1,2);
        if longtrend
            if extrainfo.teeth(end)>extrainfo.jaw(end)
                op{1,1} = 'conditional:strongbreach-trendconfirmed';
            else
                op{1,1} = 'conditional:mediumbreach-trendconfirmed';
            end
            this_signal = zeros(1,6);
            this_signal(1,1) = 1;
            this_signal(1,2) = extrainfo.hh(end);
            this_signal(1,3) = extrainfo.ll(end);
            this_signal(1,5) = extrainfo.px(end,3);
            this_signal(1,6) = extrainfo.px(end,4);
            this_signal(1,4) = 2;
            signal{1,1} = this_signal;
        end
        %
        if shorttrend
            if extrainfo.teeth(end)<extrainfo.jaw(end)
                op{1,2} = 'conditional:strongbreach-trendconfirmed';
            else
                op{1,2} = 'conditional:mediumbreach-trendconfirmed';
            end
            this_signal = zeros(1,6);
            this_signal(1,1) = -1;
            this_signal(1,2) = extrainfo.hh(end);
            this_signal(1,3) = extrainfo.ll(end);
            this_signal(1,5) = extrainfo.px(end,3);
            this_signal(1,6) = extrainfo.px(end,4);
            this_signal(1,4) = -2;
            signal{1,2} = this_signal;
        end
        
        return
        
    end
    %
    %************ NEITHER long NOR short trend ***********************
    
    
    
    
    
    
    
end