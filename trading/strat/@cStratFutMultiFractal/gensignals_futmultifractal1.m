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
            
            try
                assetname = instruments{i}.asset_name;
            catch
                assetname = 'unknown';
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
            
            [signal_i,op,status] = fractal_signal_unconditional(extrainfo,ticksize,nfractal,'lasttick',tick);
            if ~isempty(signal_i)
                if signal_i(1) == 0
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                elseif signal_i(1) == 1
                    %20230613:further check of signals
                    if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                            strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed') || ...
                            strcmpi(op.comment,'breachup-highsc13')
                        %do nothing as this is for sure trending trades
                    else
                        if strcmpi(op.comment,'breachup-lvlup') && ~status.istrendconfirmed
                            vlookuptbl = stratfractal.tbl_tb_intraday_{1}.table;
                        elseif strcmpi(op.comment,'breachup-sshighvalue') && ~status.istrendconfirmed
                            vlookuptbl = stratfractal.tbl_tb_intraday_{3}.table;
                        else
                            for isignal = 1:size(stratfractal.tbl_exotics_intraday_,1)
                                if strcmpi(op.comment,stratfractal.tbl_exotics_intraday_{isignal}.signalname) && ...
                                        strcmpi('b',stratfractal.tbl_exotics_intraday_{isignal}.direction)
                                    vlookuptbl = stratfractal.tbl_exotics_intraday_{isignal}.table;
                                    break
                                end
                            end
                        end
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            idx = strcmpi(op.comment,stratfractal.tbl_all_intraday_{1}.table.opensignal_l_unique);
                            kelly = stratfractal.tbl_all_intraday_{1}.table.kelly_unique_l(idx);
                            wprob = stratfractal.tbl_all_intraday_{1}.table.winprob_unique_l(idx);
                            if kelly >= 0.15 && wprob >= 0.43
                                signal_i(1) = 1;
                            else
                                signal_i(1) = 0;
                            end
                        else
                            if kelly < 0.08 || wprob < 0.43, signal_i(1) = 0;end
                        end
                    end
                    %
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                    %
                elseif signal_i(1) == -1
                    %20230613:further check of signals
                    if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                            strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed') || ...
                            strcmpi(op.comment,'breachdn-lowbc13')
                        %do nothing as this is for sure trending trades
                    else
                        if strcmpi(op.comment,'breachdn-lvldn') && ~status.istrendconfirmed
                            vlookuptbl = stratfractal.tbl_tb_intraday_{2}.table;
                        elseif strcmpi(op.comment,'breachdn-bshighvalue') && ~status.istrendconfirmed
                            vlookuptbl = stratfractal.tbl_tb_intraday_{4}.table;
                        else
                            for isignal = 1:size(stratfractal.tbl_exotics_intraday_,1)
                                if strcmpi(op.comment,stratfractal.tbl_exotics_intraday_{isignal}.signalname) && ...
                                        strcmpi('s',stratfractal.tbl_exotics_intraday_{isignal}.direction)
                                    vlookuptbl = stratfractal.tbl_exotics_intraday_{isignal}.table;
                                    break
                                end
                            end
                        end
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            idx = strcmpi(op.comment,stratfractal.tbl_all_intraday_{2}.table.opensignal_s_unique);
                            kelly = stratfractal.tbl_all_intraday_{2}.table.kelly_unique_s(idx);
                            wprob = stratfractal.tbl_all_intraday_{2}.table.winprob_unique_s(idx);
                            if kelly >= 0.15 && wprob >= 0.43
                                signal_i(1) = -1;
                            else
                                signal_i(1) = 0;
                            end
                        else
                            if kelly < 0.08 || wprob < 0.43, signal_i(1) = 0;end
                        end
                    end
                    %
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                else
                    %do nothing
                end
                if signal_i(1) == 1
                    signals{i,1} = signal_i;
                else
                    signals{i,2} = signal_i;
                end
            else
                try
                    stratfractal.processcondentrust(instruments{i},'techvar',techvar);
                catch e
                    fprintf('processcondentrust failed:%s\n', e.message);
                    stratfractal.stop;
                end
                
                %
                [signal_cond_i,op_cond_i] = fractal_signal_conditional(extrainfo,ticksize,nfractal);
                %20230613:further check of conditional signals
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 1
                    if strcmpi(op_cond_i{1,1},'conditional:mediumbreach-trendconfirmed')
                        vlookuptbl = stratfractal.tbl_tc_intraday_{1}.table;
                    elseif strcmpi(op_cond_i{1,1},'conditional:strongbreach-trendconfirmed')
                        vlookuptbl = stratfractal.tbl_tc_intraday_{2}.table;
                    else
                        %internal errror
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                    else
                        if kelly >= 0.15 && wprob >= 0.43
                            signal_cond_i{1,1}(1) = 1;
                        else
                            signal_cond_i{1,1}(1) = 0;
                        end
                    end
                end
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1
                    if strcmpi(op_cond_i{1,2},'conditional:mediumbreach-trendconfirmed')
                        vlookuptbl = stratfractal.tbl_tc_intraday_{3}.table;
                    elseif strcmpi(op_cond_i{1,2},'conditional:strongbreach-trendconfirmed')
                        vlookuptbl = stratfractal.tbl_tc_intraday_{4}.table;
                    else
                        %internal error
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                    else
                        if kelly >= 0.15 && wprob >= 0.43
                            signal_cond_i{1,2}(1) = -1;
                        else
                            signal_cond_i{1,2}(1) = 0;
                        end
                    end
                end               
                %
                [hhstatus,llstatus] = fractal_barrier_status(extrainfo,ticksize);
                hhupward = strcmpi(hhstatus,'upward');
                lldnward = strcmpi(llstatus,'dnward');
                
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
                    & p(end,5)<=lvlup(end) ...
                    & (lips(end)>teeth(end) || (lips(end)<=teeth(end) && hh(end)>jaw(end))) ...
                    & ~isempty(find(p(end-2*nfractal+1:end,4)-lvlup(end)+2*ticksize<0,1,'first')) ...
                    & ~isempty(find(p(end-2*nfractal+1:end,5)-lvlup(end)+2*ticksize<0,1,'first'));
                
                %the latest HH is above the previous, indicating an
                %upper-trend
                if hhabovelvlup    
                    if ~hhupward
                        %we regard the upper trend is valid if nfractal+1
                        %candle close above the alligator's lips
                        hhabovelvlup = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)+2*ticksize<0,1,'first'));
                        %also need at least nfractal+1 alligator's lips
                        %above teeth
                        hhabovelvlup = hhabovelvlup & isempty(find(lips(end-nfractal:end)-teeth(end-nfractal:end)+ticksize<0,1,'first'));
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
                    & p(end,5)<hh(end);

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
                    signals{i,1} = signal_cond_i{1,1};
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),op_cond_i{1,1},100*kelly,100*wprob);
                else
                    if hhabovelvlup
                        this_signal = zeros(1,7);
                        this_signal(1,1) = 1;
                        this_signal(1,2) = hh(end);                             %HH is already above TDST-lvlup
                        this_signal(1,3) = ll(end);
                        this_signal(1,5) = p(end,3);
                        this_signal(1,6) = p(end,4);
                        this_signal(1,7) = lips(end);
                        this_signal(1,4) = 4;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup');
                        signals{i,1} = this_signal;
                    elseif hhbelowlvlup && p(end,3)>lvldn(end)
%                         this_signal = zeros(1,7);
%                         this_signal(1,1) = 1;
%                         this_signal(1,2) = lvlup(end);                          %HH is still below TDST-lvlup
%                         this_signal(1,3) = ll(end);
%                         this_signal(1,5) = p(end,3);
%                         this_signal(1,6) = p(end,4);
%                         this_signal(1,7) = lips(end);
%                         this_signal(1,4) = 4;
%                         fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup');
%                         signals{i,1} = this_signal;
                    end
                end
                %
                %
                %2b.LL is below TDST level-dn
                %LL is also below alligator's teeth
                %the latest close price is still above LL
                %the alligator's lips is below alligator's teeth
                %some of the latest 2*nfractal candle's high price was
                %above TDST level-dn
                llbelowlvldn = ll(end)<=lvldn(end) ...
                    & ll(end)<teeth(end) ...
                    & p(end,5)>ll(end) ...
                    & p(end,5)>=lvldn(end) ...
                    & lips(end)<teeth(end) ...
                    & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,3)+2*ticksize<0,1,'first'))...
                    & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,5)+2*ticksize<0,1,'first'));
                
                %the latest LL is below the previous, indicating a
                %down-trend
                if llbelowlvldn
                    if ~lldnward
                        %we regard the down trend is valid if nfractal+1
                        %candle close below the alligator's lips
                        llbelowlvldn = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)-2*ticksize>0,1,'first'));
                        %also need at least nfractal+1 alligator's lips
                        %below teeth
                        llbelowlvldn = llbelowlvldn & isempty(find(lips(end-nfractal:end)-teeth(end-nfractal:end)-ticksize>0,1,'first'));
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
                    signals{i,2} = signal_cond_i{1,2};
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),op_cond_i{1,2},100*kelly,100*wprob);
                else
                    %NOT BELOW TEETH
                    if llbelowlvldn
                        this_signal = zeros(1,7);
                        this_signal(1,1) = -1;
                        this_signal(1,2) = hh(end);
                        this_signal(1,3) = ll(end);                         %LL is already below TDST-lvldn
                        this_signal(1,5) = p(end,3);
                        this_signal(1,6) = p(end,4);
                        this_signal(1,7) = lips(end);
                        this_signal(1,4) = -4;
                        signals{i,2} = this_signal;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn');
%                     elseif llabovelvldn && p(end,4)<lvlup(end)
                      elseif llabovelvldn
%                         this_signal = zeros(1,6);
%                         this_signal(1,1) = -1;
%                         this_signal(1,2) = hh(end);
%                         this_signal(1,3) = lvldn(end);                      %LL is still above TDST-lvldn
%                         this_signal(1,5) = p(end,3);
%                         this_signal(1,6) = p(end,4);
%                         this_signal(1,7) = lips(end);
%                         this_signal(1,4) = -4;
%                         signals{i,2} = this_signal;
%                         fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn');
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