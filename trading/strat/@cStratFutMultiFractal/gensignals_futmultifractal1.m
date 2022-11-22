function signals = gensignals_futmultifractal1(stratfractal)
%cStratFutMultiFractal
%NEW CHANGE:signals are not generated with the price before the market
%close as we don't know whether the open price (once the market open again)
%would still be valid for a signal. however, we might miss big profit in
%case the market jumps in favor of the strategy. Of course, we might loose
%in case the market moves against the strategy

    n = stratfractal.count;
%     signals = zeros(n,6);
    signals = cell(n,2);
    %column1:direction
    %column2:fractal hh
    %column3:fractal ll
    %column4:use flag
    %column5:hh1:open candle high
    %column6:ll1:open candle low
    
    
    if stratfractal.displaysignalonly_, return;end
    
    if strcmpi(stratfractal.mode_,'replay')
        runningt = stratfractal.replay_time1_;
    else
        runningt = now;
    end
    
    twominb4mktopen = is2minbeforemktopen(runningt);
    
    instruments = stratfractal.getinstruments;
        
    if twominb4mktopen
        for i = 1:n
            try
                techvar = stratfractal.calctechnicalvariable(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
                stratfractal.hh_{i} = techvar(:,8);
                stratfractal.ll_{i} = techvar(:,9);
                stratfractal.jaw_{i} = techvar(:,10);
                stratfractal.teeth_{i} = techvar(:,11);
                stratfractal.lips_{i} = techvar(:,12);
                stratfractal.bs_{i} = techvar(:,13);
                stratfractal.ss_{i} = techvar(:,14);
                stratfractal.lvlup_{i} = techvar(:,15);
                stratfractal.lvldn_{i} = techvar(:,16);
                stratfractal.bc_{i} = techvar(:,17);        
                stratfractal.sc_{i} = techvar(:,18);
                stratfractal.wad_{i} = techvar(:,19);
            catch e
                msg = sprintf('ERROR:%s:calctechnicalvariable:%s:%s\n',class(stratfractal),instruments{i}.code_ctp,e.message);
                fprintf(msg);
            end
        end        
        return
    end
    
    calcsignalflag = zeros(n,1);
    for i = 1:n
        try
            calcsignalflag(i) = stratfractal.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag(i) = 0;
            msg = sprintf('ERROR:%s:getcalcsignalflag:%s\n',class(stratfractal),e.message);
            fprintf(msg);
        end
    end
    %
    if sum(calcsignalflag) == 0, return;end
    
    fprintf('\n%s->%s:signal calculated...\n',stratfractal.name_,datestr(runningt,'yyyy-mm-dd HH:MM'));
    
    for i = 1:n
        if ~calcsignalflag(i);continue;end
        
        if calcsignalflag(i)
            try
                techvar = stratfractal.calctechnicalvariable(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
                p = techvar(:,1:5);
                idxHH = techvar(:,6);
                idxLL = techvar(:,7);
                hh = techvar(:,8);
                ll = techvar(:,9);
                jaw = techvar(:,10);
                teeth = techvar(:,11);
                lips = techvar(:,12);
                bs = techvar(:,13);
                ss = techvar(:,14);
                lvlup = techvar(:,15);
                lvldn = techvar(:,16);
                bc = techvar(:,17);
                sc = techvar(:,18);
                wad = techvar(:,19); 
            catch e
                msg = sprintf('ERROR:%s:calctechnicalvariable:%s:%s\n',class(stratfractal),instruments{i}.code_ctp,e.message);
                fprintf(msg);
                continue
            end
            %
            stratfractal.hh_{i} = hh;
            stratfractal.ll_{i} = ll;
            stratfractal.jaw_{i} = jaw;
            stratfractal.teeth_{i} = teeth;
            stratfractal.lips_{i} = lips;
            stratfractal.bs_{i} = bs;
            stratfractal.ss_{i} = ss;
            stratfractal.lvlup_{i} = lvlup;
            stratfractal.lvldn_{i} = lvldn;
            stratfractal.bc_{i} = bc;
            stratfractal.sc_{i} = sc;
            stratfractal.wad_{i} = wad;
            
            nfractal = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
            
            try
                ticksize = instruments{i}.tick_size;
            catch
                ticksize = 0;
            end
            
            extrainfo = struct('px',p,...
                'ss',ss,'sc',sc,...
                'bs',bs,'bc',bc,...
                'lvlup',lvlup,'lvldn',lvldn,...
                'idxhh',idxHH,'hh',hh,...
                'idxll',idxLL,'ll',ll,...
                'lips',lips,'teeth',teeth,'jaw',jaw,...
                'wad',wad);
            
            tick = stratfractal.mde_fut_.getlasttick(instruments{i});
            
            [signal_i,op] = fractal_signal_unconditional(extrainfo,ticksize,nfractal,'lasttick',tick);
            if ~isempty(signal_i)
                if signal_i(1) == 0
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                elseif signal_i(1) == 1
                    if signal_i(4) == 3
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:closetolvlup');
                    else
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),op.comment);
                    end
                elseif signal_i(1) == -1
                    if signal_i(4) == -3
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:closetolvldn');
                    else
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),op.comment);
                    end
                else
                    %do nothing
                end
                if signal_i(1) == 1
                    signals{i,1} = signal_i;
                else
                    signals{i,2} = signal_i;
                end
            else
                %neither a valid breachhh nor a valid breachll
%             end
            
%             [validbreachhh,validbreachll] = fractal_validbreach(extrainfo,ticksize);
%                         
%             if validbreachhh && ~validbreachll
% 
%             end
%             %    
%             if ~validbreachhh && validbreachll
% 
%             end
            %
%             if ~validbreachhh && ~validbreachll
                %neither a validbreachhh nor a validbreachll
                %special code for conditional entrust (sign indicates
                %direction)
                %code 2:trendconfirmed
                %code 3:closetolvlup(-3:closetolvldn)
                %code 4:breachup-lvlup(-4:breachdn-lvldn)
                try
                    stratfractal.processcondentrust(instruments{i},'techvar',techvar);
                catch e
                    fprintf('processcondentrust failed:%s\n', e.message);
                    stratfractal.stop;
                end
                
                %
                [signal_cond_i,op_cond_i] = fractal_signal_conditional(extrainfo,ticksize,nfractal);
                %
                %
                %
%                 %1a.there are 2*nfactal candles above alligator's teeth
%                 %continuously with HH being above alligator's teeth
%                 %the latest close price should be still below HH
%                 %the latest HH shall be above the previous HH, indicating
%                 %an upper trend
%                 %in case the latest HH is below the previous HH, i.e. the
%                 %previous was formed given higher price volatility, we
%                 %shall still regard the up-trend as valid if and only if
%                 %there are 2*nfractal candles above alligator's lips
                last2hhidx = find(idxHH(1:end)==1,2,'last');
                last2hh = hh(last2hhidx);
%                 if size(p,1)-(last2hhidx(end)-nfractal)+1 >= 2*nfractal
%                     aboveteeth = isempty(find(p(end-2*nfractal+1:end,5)-teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
%                     aboveteeth = aboveteeth & hh(end)-teeth(end)>=ticksize;
%                     aboveteeth = aboveteeth & p(end,5)<hh(end);                    
%                     if size(last2hhidx,1) == 2 && aboveteeth
%                         if last2hh(2) - last2hh(1) >= ticksize
%                             aboveteeth = true;
%                         else
%                             %there are 2*nfractal candles above alligator's lips
%                             aboveteeth = isempty(find(p(end-2*nfractal+1:end,5)-lips(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
%                             if ~aboveteeth
%                                 %weak condition:1)there are 2*nfracal 
%                                 %candles's low above alligator's teeth;
%                                 %2)the last close above lips
%                                 flag1 = isempty(find(p(end-2*nfractal+1:end,4)-teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
%                                 flag2 = p(end,5)-lips(end)-2*ticksize>0;
%                                 flag3 = ss(end) >= 1;
%                                 aboveteeth = flag1 & flag2 & flag3;
%                             end
%                         end
%                     end
%                 else
%                     aboveteeth = false;
%                 end
%                 if aboveteeth
%                     [~,~,~,~,~,isteethjawcrossed,~] = fractal_countb(p,idxHH,nfractal,lips,teeth,jaw,ticksize);
%                     %DO NOT place any order if alligator's teeth and jaw
%                     %crossed
%                     aboveteeth = aboveteeth & ~isteethjawcrossed;
%                 end
%                 %20210603?special case:
%                 %the upper-trend might be too strong and about to exhausted
%                 %1)the latest candle stick is within 12 sticks(inclusive) from
%                 %the latest sell count 13
%                 %2)the latest sell sequential is greater than or equal 22(9+13)
%                 %3)the latest sell count 13 is included in the latest sell sequential
%                 %DO N0T place any order if the above 3 conditions hold
%                 if aboveteeth
%                     idx_sc13_last = find(sc==13,1,'last');
%                     idx_ss_last = find(ss >= 9, 1,'last');
%                     if ~isempty(idx_sc13_last) && ~isempty(idx_ss_last)
%                         ss_last = ss(idx_ss_last);
%                         idx_ss_start = idx_ss_last-ss_last+1;
%                         if size(sc,1) - idx_sc13_last <= 12 && ss_last >= 22 ...
%                                 && idx_ss_start +9 < idx_sc13_last
%                             aboveteeth = false;
%                         end
%                     end
%                 end
                %
                %1b.HH is above TDST level-up
                %HH is also above alligator's teeth
                %the latest close price is still below HH
                %the alligator's lips is above alligator's teeth OR
                %HH is well above jaw
                %some of the last 2*nfracal candles' low price was below TDST level-up
                %some of the last 2*nfractal candles' close was below TDST level-up
                %i.e.not all candles above TDST level-up
                %if HH is breached, it shall also breach TDST level up
                hhabovelvlup = hh(end)>=lvlup(end) ...
                    & hh(end)>teeth(end) ...
                    & p(end,5)<=hh(end) ...
                    & (lips(end)>teeth(end) || (lips(end)<=teeth(end) && hh(end)>jaw(end))) ...
                    & ~isempty(find(p(end-2*nfractal+1:end,4)-lvlup(end)+2*ticksize<0,1,'first')) ...
                    & ~isempty(find(p(end-2*nfractal+1:end,5)-lvlup(end)+2*ticksize<0,1,'first'));
                if hhabovelvlup
                    [~,~,~,~,~,isteethjawcrossed,~] = fractal_countb(p,idxHH,nfractal,lips,teeth,jaw,ticksize);
                    %in case alligator's teeth and jaw is crossed and also
                    %sell sequential is above 8, if wad distracts from the
                    %price movement
                    if isteethjawcrossed && ss(end) >= 8
                        maxpx = max(p(end-ss(end)+1:end-1,5));
                        maxpxidx = find(p(end-ss(end)+1:end-1,5)==maxpx,1,'last')+size(p,1)-ss(end);
                        if wad(maxpxidx) >= wad(end)
                            fprintf('hhabovelvlup failed because inconsistence of wad\n');
                            hhabovelvlup = false;
                        end
                    end
                end
                %the latest HH is above the previous, indicating an
                %upper-trend
                if size(last2hhidx,1) == 2 && hhabovelvlup
                    if last2hh(2) >= last2hh(1)
%                         hhabovelvlup = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)+2*ticksize<0,1,'first'));
                        hhabovelvlup = true;
                    else
                        %we regard the upper trend is valid if nfractal+1
                        %candle close above the alligator's lips
                        hhabovelvlup = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)+2*ticksize<0,1,'first'));
                        %also need at least nfractal+1 alligator's lips
                        %above teeth
                        hhabovelvlup = hhabovelvlup & isempty(find(lips(end-nfractal)-teeth(end-nfractal:end)+2*ticksize<0,1,'first'));
                    end
                end
                if hhabovelvlup
                    if lvlup(end) > lvldn(end)
                        hhabovelvlup = p(end,3) >= lvldn(end);
                    end
                end
                %
                %1c.HH is below TDST level up
                %HH is also above alligator's teeth
                %the alligator's lips is above alligator's teeth
                %the latest close price is still below HH
                hhbelowlvlup = hh(end)<lvlup(end) ...
                    & hh(end)>teeth(end) ...
                    & lips(end)>teeth(end) ...
                    & p(end,5)<=hh(end);
%                 if aboveteeth
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 1
                    %TREND has priority over TDST breakout
                    %note:20211118
                    %it is necessary to withdraw pending conditional
                    %entrust with higher price to long
                    ne = stratfractal.helper_.condentrustspending_.latest;
                    if ne > 0
                        condentrusts2remove = EntrustArray;
                        for jj = 1:ne
                            e = stratfractal.helper_.condentrustspending_.node(jj);
                            if e.offsetFlag ~= 1, continue; end
                            if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                            if e.direction ~= 1, continue;end %the same direction
                            if e.price <= hh(end)+ticksize,continue;end
                            %if the code reaches here, the existing entrust shall be canceled
                            condentrusts2remove.push(e);
                        end
                        if condentrusts2remove.latest > 0
                            stratfractal.removecondentrusts(condentrusts2remove);
                        end
                    end
%                     this_signal = zeros(1,6);
%                     this_signal(1,1) = 1;
%                     this_signal(1,2) = hh(end);
%                     this_signal(1,3) = ll(end);
%                     this_signal(1,5) = p(end,3);
%                     this_signal(1,6) = p(end,4);
%                     this_signal(1,4) = 2;
%                     if teeth(end)>jaw(end)
%                         fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:strongbreach-trendconfirmed');
%                     else
%                         fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:mediumbreach-trendconfirmed');
%                     end
%                     signals{i,1} = this_signal;
                    signals{i,1} = signal_cond_i{1,1};
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),op_cond_i{1,1});
                else
                    %NOT ABOVE TEETH
%                     if hhabovelvlup && p(end,3)>lvldn(end)
                    if hhabovelvlup
                        this_signal = zeros(1,6);
                        this_signal(1,1) = 1;
                        this_signal(1,2) = hh(end);                             %HH is already above TDST-lvlup
                        this_signal(1,3) = ll(end);
                        this_signal(1,5) = p(end,3);
                        this_signal(1,6) = p(end,4);
                        this_signal(1,4) = 4;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup');
                        signals{i,1} = this_signal;
                    elseif hhbelowlvlup && p(end,3)>lvldn(end)
                        this_signal = zeros(1,6);
                        this_signal(1,1) = 1;
                        this_signal(1,2) = lvlup(end);                          %HH is still below TDST-lvlup
                        this_signal(1,3) = ll(end);
                        this_signal(1,5) = p(end,3);
                        this_signal(1,6) = p(end,4);
                        this_signal(1,4) = 4;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup');
                        signals{i,1} = this_signal;
                    end
                end
                %
                %
%                 %2a.there are 2*nfactal candles below alligator's teeth
%                 %continuously with LL being below alligator's teeth
%                 %the latest close price should be still above LL
%                 %the latest LL shall be below the previous LL, indicating
%                 %a down trend
%                 %in case the latest LL is above the previous LL, i.e. the
%                 %previous was formed given higher price volatility, we
%                 %shall still regard the down-trend as valid if and only if
%                 %there are 2*nfractal candles below alligator's lips
                last2llidx = find(idxLL(1:end)==-1,2,'last');
%                 if size(p,1)-(last2llidx(end)-nfractal)+1 >= 2*nfractal
%                     belowteeth = isempty(find(p(end-2*nfractal+1:end,5)-teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
%                     belowteeth = belowteeth & ll(end)-teeth(end)<=-ticksize;
%                     belowteeth = belowteeth & p(end,5)>ll(end);
%                     last2ll = ll(last2llidx);
%                     if size(last2ll,1) == 2 && belowteeth
%                         if last2ll(2) - last2ll(1) <= -ticksize
%                             belowteeth = true;
%                         else
%                             %there are 2*nfractal candles below alligator's lips
%                             belowteeth = isempty(find(p(end-2*nfractal+1:end,5)-lips(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
%                         end
%                     end
%                 else
%                     belowteeth = false;
%                 end
%                 if belowteeth
%                     [~,~,~,~,~,isteethjawcrossed,~] = fractal_counts(p,idxLL,nfractal,lips,teeth,jaw,ticksize);
%                     %DO NOT place any order if alligator's tteh and jaw
%                     %crossed
%                     belowteeth = belowteeth & ~isteethjawcrossed;
%                 end
%                 %20210603?special case:
%                 %the down-trend might be too strong and about to exhausted
%                 %1)the latest candle stick is within 12 sticks(inclusive)
%                 %from the latest buy count 13
%                 %2)the latest buy sequential is greater than or equal 22(9+13)
%                 %3)the latest buy count 13 is included in the latest buy sequential
%                 %DO NOT place any order if the above 3 conditions hold
%                 if belowteeth
%                     idx_bc13_last = find(bc==13,1,'last');
%                     idx_bs_last = find(bs>=9,1,'last');
%                     if ~isempty(idx_bc13_last) && ~isempty(idx_bs_last)
%                         bs_last = bs(idx_bs_last);
%                         idx_bs_start = idx_bs_last-bs_last+1;
%                         if size(bc,1)-idx_bc13_last <= 12 && bs_last >= 12 ...
%                                 &&idx_bs_start + 9 < idx_bc13_last
%                             belowteeth = false;
%                         end
%                     end
%                 end
                %
                %2b.LL is below TDST level-dn
                %LL is also below alligator's teeth
                %the latest close price is still above LL
                %the alligator's lips is below alligator's teeth
                %some of the latest 2*nfractal candle's high price was
                %above TDST level-up
                llbelowlvldn = ll(end)<=lvldn(end) ...
                    & ll(end)<teeth(end) ...
                    & p(end,5)>ll(end) ...
                    & lips(end)<teeth(end) ...
                    & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,3)+2*ticksize<0,1,'first'))...
                    & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,5)+2*ticksize<0,1,'first'));
                if llbelowlvldn
                    %not to place conditional order in
                    %mediumbreach-bshighvalue
                    isbshighvalue = bs(end)>=9 & teeth(end)-jaw(end)>=-2*ticksize;
                    if isbshighvalue
                        llbelowlvldn = false;
                    end                    
                    [~,~,~,~,~,isteethjawcrossed,~] = fractal_counts(p,idxLL,nfractal,lips,teeth,jaw,ticksize);
                    %in case alligator's teeth and jaw is crossed and also
                    %buy sequential is above 8, if wad distracts from the
                    %price movement
                    if isteethjawcrossed && bs(end) >= 8 && llbelowlvldn
                        minpx = min(p(end-bs(end)+1:end-1,5));
                        minpxid = find(p(end-bs(end)+1:end-1,5) == minpx,1,'last')+size(p,1)-bs(end);
                        allabovell = isempty(find(p(end-bs(end)+1:end,5)-ll(end)-2*ticksize<0,1,'first'));
                        if wad(minpxid) <= wad(end) && allabovell
                            fprintf('%s:llbelowlvldn failed because inconsistence of wad\n',instruments{i}.code_ctp);
                            llbelowlvldn = false;
                        end
                    end
                end
                %the latest LL is below the previous, indicating a
                %down-trend
                if size(last2llidx,1) == 2 && llbelowlvldn
                    last2ll = ll(last2llidx);
                    if last2ll(2) < last2ll(1)
                        llbelowlvldn = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)-2*ticksize>0,1,'first'));
                    else
                        %we regard the down trend is valid if nfractal+1
                        %candle close below the alligator's lips
                        llbelowlvldn = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)-2*ticksize>0,1,'first'));
                    end
                end
                if llbelowlvldn
                    if lvlup(end) > lvldn(end)
                        llbelowlvldn = p(end,4) <= lvlup(end);
                    end
                end
                %
                %2c.LL is above TDST level dn
                %LL is also below alligator's teeth
                %the alligator's lips is below alligator's teeth
                %the latest close price is still above LL
                llabovelvldn = ll(end)>lvldn(end) ...
                    & ll(end)<teeth(end) ...
                    & lips(end)<teeth(end) -2*ticksize...
                    & p(end,5)>ll(end);
                if llabovelvldn && ~isnan(lvlup(end))
                    llabovelvldn = llabovelvldn & p(end,4)<lvlup(end);
                end
                
%                 if belowteeth
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1
                    %TREND has priority over TDST breakout
                    %note:20211118
                    %it is necessary to withdraw pending conditional
                    %entrust with lower price to short
                    ne = stratfractal.helper_.condentrustspending_.latest;
                    if ne > 0
                        condentrusts2remove = EntrustArray;
                        for jj = 1:ne
                            e = stratfractal.helper_.condentrustspending_.node(jj);
                            if e.offsetFlag ~= 1, continue; end
                            if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                            if e.direction ~= -1, continue;end %the same direction
                            if e.price >= ll(end)-ticksize,continue;end
                            %if the code reaches here, the existing entrust shall be canceled
                            condentrusts2remove.push(e);
                        end
                        if condentrusts2remove.latest > 0
                            stratfractal.removecondentrusts(condentrusts2remove);
                        end
                    end
%                     this_signal = zeros(1,6);
%                     this_signal(1,1) = -1;
%                     this_signal(1,2) = hh(end);
%                     this_signal(1,3) = ll(end);
%                     this_signal(1,5) = p(end,3);
%                     this_signal(1,6) = p(end,4);
%                     this_signal(1,4) = -2;
%                     if teeth(end)<jaw(end)
%                         fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:strongbreach-trendconfirmed');
%                     else
%                         fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:mediumbreach-trendconfirmed');
%                     end
%                     signals{i,2} = this_signal;
                    signals{i,2} = signal_cond_i{1,2};
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),op_cond_i{1,2});
                else
                    %NOT BELOW TEETH
                    if llbelowlvldn
                        this_signal = zeros(1,6);
                        this_signal(1,1) = -1;
                        this_signal(1,2) = hh(end);
                        this_signal(1,3) = ll(end);                         %LL is already below TDST-lvldn
                        this_signal(1,5) = p(end,3);
                        this_signal(1,6) = p(end,4);
                        this_signal(1,4) = -4;
                        signals{i,2} = this_signal;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn');
%                     elseif llabovelvldn && p(end,4)<lvlup(end)
                      elseif llabovelvldn
                        this_signal = zeros(1,6);
                        this_signal(1,1) = -1;
                        this_signal(1,2) = hh(end);
                        this_signal(1,3) = lvldn(end);                      %LL is still above TDST-lvldn
                        this_signal(1,5) = p(end,3);
                        this_signal(1,6) = p(end,4);
                        this_signal(1,4) = -4;
                        signals{i,2} = this_signal;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn');
                    end   
                end
            end
            %
        end
    end
   
    
    sum_signal = 0;
    for i = 1:n
        signal_long = signals{i,1};
        signal_short = signals{i,2};
        if ~isempty(signal_long)
            sum_signal = sum_signal + abs(signal_long(1));
        end
        if ~isempty(signal_short)
            sum_signal = sum_signal + abs(signal_short(1));
        end
    end
    
    if sum_signal == 0, return;end
    
    fprintf('\n');
end