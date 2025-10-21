function signals = gensignals_optmultifractal(stratoptfractal)
%cStratOptMultiFractal
%NEW CHANGE:signals are not generated with the price before the market
%close as we don't know whether the open price (once the market open again)
%would still be valid for a signal. however, we might miss big profit in
%case the market jumps in favor of the strategy. Of course, we might loose
%in case the market moves against the strategy

    signals = cell(1,2);
    %column1:direction
    %column2:fractal hh
    %column3:fractal ll
    %column4:use flag
    %column5:hh1:open candle high
    %column6:ll1:open candle low
    
    
    if strcmpi(stratoptfractal.mode_,'replay')
        runningt = stratoptfractal.replay_time1_;
    else
        runningt = now;
    end
    
    twominb4mktopen = is2minbeforemktopen(runningt);
    
    instruments = stratoptfractal.getinstruments;
        
    if twominb4mktopen
        try
            techvar = stratoptfractal.calctechnicalvariable('IncludeLastCandle',1,'RemoveLimitPrice',1);
            stratoptfractal.hh_ = techvar(:,8);
            stratoptfractal.ll_ = techvar(:,9);
            stratoptfractal.jaw_ = techvar(:,10);
            stratoptfractal.teeth_ = techvar(:,11);
            stratoptfractal.lips_ = techvar(:,12);
            stratoptfractal.bs_ = techvar(:,13);
            stratoptfractal.ss_ = techvar(:,14);
            stratoptfractal.lvlup_ = techvar(:,15);
            stratoptfractal.lvldn_ = techvar(:,16);
            stratoptfractal.bc_ = techvar(:,17);
            stratoptfractal.sc_ = techvar(:,18);
            stratoptfractal.wad_ = techvar(:,19);
        catch e
            msg = sprintf('ERROR:%s:calctechnicalvariable:%s\n',class(stratoptfractal),e.message);
            fprintf(msg);
        end
                
        return
    end
    
    underlier = stratoptfractal.mde_opt_.underlier_;
    underlier_code_ctp = underlier.code_ctp;
    try
        calcsignalflag = stratoptfractal.getcalcsignalflag(underlier);
    catch e
        calcsignalflag = 0;
        msg = sprintf('ERROR:%s:getcalcsignalflag:%s\n',class(stratoptfractal),e.message);
        fprintf(msg);
    end
    
    %
    if calcsignalflag == 0, return;end
    
    fprintf('\n%s->%s:signal calculated...\n',stratoptfractal.name_,datestr(runningt,'yyyy-mm-dd HH:MM'));
    
    try
        [techvar,extrainfo] = stratoptfractal.calctechnicalvariable('IncludeLastCandle',0,'RemoveLimitPrice',1);
        p = techvar(:,1:5);
        %
        stratoptfractal.hh_ = techvar(:,8);
        stratoptfractal.ll_ = techvar(:,9);
        stratoptfractal.jaw_ = techvar(:,10);
        stratoptfractal.teeth_ = techvar(:,11);
        stratoptfractal.lips_ = techvar(:,12);
        stratoptfractal.bs_ = techvar(:,13);
        stratoptfractal.ss_ = techvar(:,14);
        stratoptfractal.lvlup_ = techvar(:,15);
        stratoptfractal.lvldn_ = techvar(:,16);
        stratoptfractal.bc_ = techvar(:,17);
        stratoptfractal.sc_ = techvar(:,18);
        stratoptfractal.wad_ = techvar(:,19);
    catch e
        msg = sprintf('ERROR:%s:calctechnicalvariable:%s\n',class(stratoptfractal),e.message);
        fprintf(msg);
        return
    end
    %
    nfractal = stratoptfractal.riskcontrols_.getconfigvalue('code',instruments{1}.code_ctp,'propname','nfractals');
    freq = stratoptfractal.riskcontrols_.getconfigvalue('code',instruments{1}.code_ctp,'propname','samplefreq');
    
    if ~strcmpi(freq,'1440m')
        kellytables = stratoptfractal.tbl_all_intraday_;
        if strcmpi(freq,'5m')
            
            tickratio = 0;
        elseif strcmpi(freq,'15m')
            tickratio = 0.5;
        elseif strcmpi(freq,'30m')
            tickratio = 0.5;
        else
            tickratio = 0.5;
        end
    else
        kellytables = stratoptfractal.tbl_all_daily_;
        tickratio = 1;
    end
    
    try
        ticksize = stratoptfractal.mde_opt_.underlier_.tick_size;
    catch
        ticksize = 0;
    end
    
    try
        assetname = stratoptfractal.mde_opt_.underlier_.asset_name;
    catch
        assetname = 'unknown';
    end
    

    signaluncond = fractal_signal_unconditional2('extrainfo',extrainfo,...
        'ticksize',ticksize,...
        'nfractal',nfractal,...
        'assetname',assetname,...
        'kellytables',kellytables,...
        'ticksizeratio',tickratio);
    
    if ~isempty(signaluncond)
        if signaluncond.directionkellied == 1
            signal_i = signaluncond.signalkellied;
            if signaluncond.status.istrendconfirmed && ~stratoptfractal.helper_.book_.haslongposition(underlier)
                %long trend case with good kelly but lack of prop
                %position, we shall double check with its previous
                %conditional setup
                ei_ = fractal_truncate(extrainfo,size(extrainfo.px,1)-1);
                signalcond_ = fractal_signal_conditional2('extrainfo',ei_,...
                    'ticksize',ticksize,...
                    'nfractal',nfractal,...
                    'assetname',assetname,...
                    'kellytables',kellytables,...
                    'ticksizeratio',tickratio);
                if ~isempty(signalcond_)
                    if signalcond_.directionkellied == 1
                        %due to low kelly reported on volblowup2 as
                        %open price was high
                        lastss = find(extrainfo.ss >= 9,1,'last');
                        if size(extrainfo.ss,1) - lastss <= nfractal
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            signals{1,1} = signal_i;
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(1),[signaluncond.opkellied, ' not to place as tdsq sell setup'],100*signaluncond.kelly,100*signaluncond.wprob);
                            %
                            condentrusts2remove = EntrustArray;
                            ne = stratoptfractal.helper_.condentrustspending_.latest;
                            for jj = 1:ne
                                e = stratoptfractal.helper_.condentrustspending_.node(jj);
                                if e.offsetFlag ~= 1, continue; end
                                if ~strcmpi(e.instrumentCode,underlier_code_ctp), continue;end%the same instrument
                                condentrusts2remove.push(e);
                            end
                            if condentrusts2remove.latest > 0
                                stratoptfractal.removecondentrusts(condentrusts2remove);
                            end
                        else
                            if ~signaluncond.status.isvolblowup2
                                signals{1,1} = signal_i;
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                            else
                                signal_i(1) = 0;
                                signal_i(4) = 0;
                                signals{1,1} = signal_i;
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(1),[signaluncond.opkellied, ' not to place as volblowup2'],100*signaluncond.kelly,100*signaluncond.wprob);
                            end
                        end
                    elseif signalcond_.directionkellied == -1
                        fprintf('gensignal_futmultifractal1:further check with weired case...\n')
                    else
                        %there was a conditional signal with low kelly
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                        signals{1,1} = signal_i;
                        fprintf('\t%6s:%4s\tup:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
                    end
                else
                    %there wasn't any conditional
                    %signal,i.e.alligator lines crossed and etc
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                    signals{1,1} = signal_i;
                    fprintf('\t%6s:%4s\tup conditional %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                end
            else
                signals{1,1} = signal_i;
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            end
            %
            %
        elseif signaluncond.directionkellied == -1
            signal_i = signaluncond.signalkellied;
            if signaluncond.status.istrendconfirmed && ~stratoptfractal.helper_.book_.hasshortposition(underlier)
                %short trend case with good kelly but lack of prop
                %position, we shall double check with its previous
                %conditional setup
                ei_ = fractal_truncate(extrainfo,size(extrainfo.px,1)-1);
                signalcond_ = fractal_signal_conditional2('extrainfo',ei_,...
                    'ticksize',ticksize,...
                    'nfractal',nfractal,...
                    'assetname',assetname,...
                    'kellytables',kellytables,...
                    'ticksizeratio',tickratio);
                if ~isempty(signalcond_)
                    if signalcond_.directionkellied == -1
                        %due to low kelly reported on volblowup2 as
                        %open price was low
                        lastbs = find(extrainfo.bs >= 9,1,'last');
                        if size(extrainfo.bs,1) - lastbs <= nfractal && ~strcmpi(signaluncond.opkellied,'breachdn-bshighvalue')
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            signals{1,2} = signal_i;
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(-1),[signaluncond.opkellied,' not to place as tdsq buy setup'],100*signaluncond.kelly,100*signaluncond.wprob);
                            %
                            condentrusts2remove = EntrustArray;
                            ne = stratoptfractal.helper_.condentrustspending_.latest;
                            for jj = 1:ne
                                e = stratoptfractal.helper_.condentrustspending_.node(jj);
                                if e.offsetFlag ~= 1, continue; end
                                if ~strcmpi(e.instrumentCode,underlier_code_ctp), continue;end%the same instrument
                                condentrusts2remove.push(e);
                            end
                            if condentrusts2remove.latest > 0
                                stratoptfractal.removecondentrusts(condentrusts2remove);
                            end
                        else
                            if ~signaluncond.status.isvolblowup2
                                signals{1,2} = signal_i;
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                            else
                                signal_i(1) = 0;
                                signal_i(4) = 0;
                                signals{1,2} = signal_i;
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(-1),[signaluncond.opkellied,' not to place as volblowup2'],100*signaluncond.kelly,100*signaluncond.wprob);
                            end
                        end
                    elseif signalcond_.directionkellied == 1
                        fprintf('gensignal_futmultifractal1:further check with weired case...\n')
                    else
                        %there was a conditional signal with low kelly
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                        signals{1,2} = signal_i;
                        fprintf('\t%6s:%4s\tdn conditional:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
                    end
                else
                    if signaluncond.status.islvldnbreach
                        signals{1,2} = signal_i;
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                    else
                        %there wasn't any conditional
                        %signal,i.e.alligator lines crossed and etc
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                        signals{1,2} = signal_i;
                        fprintf('\t%6s:%4s\tdn %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                    end
                end
            else
                signals{1,2} = signal_i;
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            end
            %
            %
        else
            if stratoptfractal.helper_.book_.hasposition(underlier)
                %in case the signaluncond shares the same signal
                %mode with the current trade
                tradeexist = stratoptfractal.helper_.getlivetrade('code',underlier_code_ctp);
                mode1 = tradeexist.opensignal_.mode_;
                if strcmpi(mode1,signaluncond.opkellied)
                    stratoptfractal.unwindpositions(underlier,'closestr','kelly is too low');
                else
                    %                             exceptionflag =  tradeexist.opensignal_.kelly_ > 0.3 && ...
                    %                                 ~isempty(strfind(mode1,'volblowup'));
                    kelly = signaluncond.kelly;
                    if (kelly < 0 || isnan(kelly))
                        stratoptfractal.unwindpositions(underlier,'closestr','kelly is too low');
                    end
                end
            end
            %
            try
                stratoptfractal.processcondentrust('techvar',techvar);
            catch e
                fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                stratoptfractal.stop;
            end
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
            %
            condentrusts2remove = EntrustArray;
            ne = stratoptfractal.helper_.condentrustspending_.latest;
            for jj = 1:ne
                e = stratoptfractal.helper_.condentrustspending_.node(jj);
                if e.offsetFlag ~= 1, continue; end
                if ~strcmpi(e.instrumentCode,underlier_code_ctp), continue;end%the same instrument
                condentrusts2remove.push(e);
            end
            if condentrusts2remove.latest > 0
                stratoptfractal.removecondentrusts(condentrusts2remove);
            end
        end
        %
        %
    else
        %EMPTY RETURNS FROM UNCONDITIONAL SIGNAL CALCULATION
        try
            stratoptfractal.processcondentrust('techvar',techvar);
        catch e
            fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
            stratoptfractal.stop;
        end
        %
        %
        signalcond = fractal_signal_conditional2('extrainfo',extrainfo,...
            'nfractal',nfractal,...
            'ticksize',ticksize,...
            'assetname',assetname,...
            'kellytables',kellytables,...
            'ticksizeratio',tickratio);
        if ~isempty(signalcond)
            if signalcond.directionkellied == 1 && p(end,5) > extrainfo.teeth(end)
                %it is necessary to withdraw pending conditional
                %entrust with higher price to long
                ne = stratoptfractal.helper_.condentrustspending_.latest;
                if ne > 0
                    condentrusts2remove = EntrustArray;
                    for jj = 1:ne
                        e = stratoptfractal.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if ~strcmpi(e.instrumentCode,underlier_code_ctp), continue;end%the same instrument
                        if e.direction ~= 1, continue;end
                        %                                if tickratio == 0
                        %                                    if e.price <= signalcond.signalkellied(2),continue;end
                        %                                else
                        %                                    if e.price <= signalcond.signalkellied(2)+ticksize,continue;end
                        %                                end
                        %if the code reaches here, the existing entrust shall be canceled
                        condentrusts2remove.push(e);
                    end
                    if condentrusts2remove.latest > 0
                        stratoptfractal.removecondentrusts(condentrusts2remove);
                    end
                end
                %
                signals{1,1} = signalcond.signalkellied;
                fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                %
            elseif signalcond.directionkellied == -1 && p(end,5) < extrainfo.teeth(end)
                %it is necessary to withdraw pending conditional
                %entrust with higher price to long
                ne = stratoptfractal.helper_.condentrustspending_.latest;
                if ne > 0
                    condentrusts2remove = EntrustArray;
                    for jj = 1:ne
                        e = stratoptfractal.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if ~strcmpi(e.instrumentCode,underlier_code_ctp), continue;end%the same instrument
                        if e.direction ~= -1, continue;end %the same direction
                        %                                if tickratio == 0
                        %                                    if e.price >= signalcond.signalkellied(3),continue;end
                        %                                else
                        %                                    if e.price >= signalcond.signalkellied(3)-ticksize,continue;end
                        %                                end
                        %if the code reaches here, the existing entrust shall be canceled
                        condentrusts2remove.push(e);
                    end
                    if condentrusts2remove.latest > 0
                        stratoptfractal.removecondentrusts(condentrusts2remove);
                    end
                end
                %
                signals{1,2} = signalcond.signalkellied;
                fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,-1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                %
            else
                if stratoptfractal.helper_.book_.hasposition(underlier)
                    tradeexist = stratoptfractal.helper_.getlivetrade('code',underlier_code_ctp);
                    mode1 = tradeexist.opensignal_.mode_;
                    if strcmpi(mode1,'breachup-lvlup')
                        samesignal = signalcond.flags.islvlupbreach;
                    elseif strcmpi(mode1,'breachup-sshighvalue')
                        samesignal = signalcond.flags.issshighbreach;
                    elseif strcmpi(mode1,'breachup-highsc13')
                        samesignal = signalcond.flags.isschighbreach;
                    elseif strcmpi(mode1,'breachdn-lvldn')
                        samesignal = signalcond.flags.islvldnbreach;
                    elseif strcmpi(mode1,'breachdn-bshighvalue')
                        samesignal = signalcond.flags.isbslowbreach;
                    elseif strcmpi(mode1,'breachdn-lowbc13')
                        samesignal = signalcond.flags.isbclowbreach;
                    elseif ~isempty(strfind(mode1,'-trendconfirmed'))
                        samesignal = 1;
                    elseif ~isempty(strfind(mode1,'-conditional'))
                        %not yet implemented correctly
                        samesignal = 1;
                    else
                        %other non-trended signal
                        samesignal = 0;
                    end
                    if samesignal
                        stratoptfractal.unwindpositions(underlier,'closestr','conditional kelly is too low');
                    else
                        kelly = signalcond.kelly;
                        if kelly < 0 || isnan(kelly)
                            stratoptfractal.unwindpositions(underlier,'closestr','conditional kelly is too low');
                        end
                    end
                end
                fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underlier_code_ctp,0,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                %
                condentrusts2remove = EntrustArray;
                ne = stratoptfractal.helper_.condentrustspending_.latest;
                for jj = 1:ne
                    e = stratoptfractal.helper_.condentrustspending_.node(jj);
                    if e.offsetFlag ~= 1, continue; end
                    if ~strcmpi(e.instrumentCode,underlier_code_ctp), continue;end%the same instrument
                    condentrusts2remove.push(e);
                end
                if condentrusts2remove.latest > 0
                    stratoptfractal.removecondentrusts(condentrusts2remove);
                    fprintf('\t%6s:\t%2d\t%10s cancled as new mode with low kelly....\n',underlier_code_ctp,0,signalcond.opkellied);
                end
            end
        else
            %EMPTY RETURNS FROM CONDITIONAL SIGNAL CALCULATION
            try
                stratoptfractal.processcondentrust('techvar',techvar);
            catch e
                fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                stratoptfractal.stop;
            end
        end
        %
    end
    
   
    
    sum_signal = 0;
    
    signal_long = signals{1,1};
    signal_short = signals{1,2};
    if ~isempty(signal_long)
        sum_signal = sum_signal + abs(signal_long(1));
    end
    if ~isempty(signal_short)
        sum_signal = sum_signal + abs(signal_short(1));
    end
    
    
    if sum_signal == 0, return;end
    
    fprintf('\n');
end