function signals = gensignals_optmultifractal(stratfractalopt)
    %a cStratOptMultiFractal function
    nu = stratfractalopt.countunderliers;
    signals = cell(nu,2);
    
    if strcmpi(stratfractalopt.mode_,'replay')
        runningt = stratfractalopt.replay_time1_;
    else
        runningt = now;
    end
    
    twominb4mktopen = is2minbeforemktopen(runningt);
    
    underliers = stratfractalopt.getunderliers;
    
    if twominb4mktopen
        for i = 1:nu
            try
                techvar = stratfractalopt.calctechnicalvariable(underliers{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
                stratfractalopt.hh_{i} = techvar(:,8);
                stratfractalopt.ll_{i} = techvar(:,9);
                stratfractalopt.jaw_{i} = techvar(:,10);
                stratfractalopt.teeth_{i} = techvar(:,11);
                stratfractalopt.lips_{i} = techvar(:,12);
                stratfractalopt.bs_{i} = techvar(:,13);
                stratfractalopt.ss_{i} = techvar(:,14);
                stratfractalopt.lvlup_{i} = techvar(:,15);
                stratfractalopt.lvldn_{i} = techvar(:,16);
                stratfractalopt.bc_{i} = techvar(:,17);        
                stratfractalopt.sc_{i} = techvar(:,18);
                stratfractalopt.wad_{i} = techvar(:,19);
            catch e
                msg = sprintf('ERROR:%s:calctechnicalvariable:%s:%s\n',class(stratfractalopt),underliers{i}.code_ctp,e.message);
                fprintf(msg);
            end
        end        
        return
    end
    
    calcsignalflag = zeros(nu,1);
    for i = 1:nu
        try
            calcsignalflag(i) = stratfractalopt.getcalcsignalflag(underliers{i});
        catch e
            calcsignalflag(i) = 0;
            msg = sprintf('ERROR:%s:getcalcsignalflag:%s\n',class(stratfractalopt),e.message);
            fprintf(msg);
        end
    end
    
    if sum(calcsignalflag) == 0, return;end
    
    fprintf('\n%s->%s:signal calculated...\n',stratfractalopt.name_,datestr(runningt,'yyyy-mm-dd HH:MM'));
    
    for i = 1:nu
        if ~calcsignalflag(i);continue;end
        
        if calcsignalflag(i)
            try
                [techvar,extrainfo] = stratfractalopt.calctechnicalvariable(underliers{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
                p = techvar(:,1:5);
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
                %
                stratfractalopt.hh_{i} = hh;
                stratfractalopt.ll_{i} = ll;
                stratfractalopt.jaw_{i} = jaw;
                stratfractalopt.teeth_{i} = teeth;
                stratfractalopt.lips_{i} = lips;
                stratfractalopt.bs_{i} = bs;
                stratfractalopt.ss_{i} = ss;
                stratfractalopt.lvlup_{i} = lvlup;
                stratfractalopt.lvldn_{i} = lvldn;
                stratfractalopt.bc_{i} = bc;
                stratfractalopt.sc_{i} = sc;
                stratfractalopt.wad_{i} = wad;
            catch e
                msg = sprintf('ERROR:%s:calctechnicalvariable:%s:%s\n',class(stratfractalopt),underliers{i}.code_ctp,e.message);
                fprintf(msg);
                continue
            end
            %
            options = stratfractalopt.getinstruments;
            for j = 1:stratfractalopt.count
                if strcmpi(options{j}.code_ctp_underlier,underliers{i}.code_ctp)
                    nfractal = stratfractalopt.riskcontrols_.getconfigvalue('code',options{j}.code_ctp,'propname','nfractals');
                    freq = stratfractalopt.riskcontrols_.getconfigvalue('code',options{j}.code_ctp,'propname','samplefreq');
                    break
                end
            end
            %                   
            kellytables = stratfractalopt.kellytable_;
            if ~strcmpi(freq,'1440m')
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
                tickratio = 1;
            end
            
            try
                ticksize = underliers{i}.tick_size;
            catch
                ticksize = 0;
            end
            
            try
                assetname = underliers{i}.asset_name;
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
                    if signaluncond.status.istrendconfirmed && ~stratfractalopt.helper_.book_.haslongposition(underliers{i})
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
                                    signals{i,1} = signal_i;
                                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(1),[signaluncond.opkellied, ' not to place as tdsq sell setup'],100*signaluncond.kelly,100*signaluncond.wprob);
                                    %
                                    condentrusts2remove = EntrustArray;
                                    ne = stratfractalopt.helper_.condentrustspending_.latest;
                                    for jj = 1:ne
                                        e = stratfractalopt.helper_.condentrustspending_.node(jj);
                                        if e.offsetFlag ~= 1, continue; end
                                        if ~strcmpi(e.instrumentCode,underliers{i}.code_ctp), continue;end%the same instrument
                                        condentrusts2remove.push(e);
                                    end
                                    if condentrusts2remove.latest > 0
                                        stratfractalopt.removecondentrusts(condentrusts2remove);
                                    end
                                else
                                    if ~signaluncond.status.isvolblowup2
                                        signals{i,1} = signal_i;
                                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                                    else
                                        signal_i(1) = 0;
                                        signal_i(4) = 0;
                                        signals{i,1} = signal_i;
                                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(1),[signaluncond.opkellied, ' not to place as volblowup2'],100*signaluncond.kelly,100*signaluncond.wprob);
                                    end
                                end
                            elseif signalcond_.directionkellied == -1
                                fprintf('gensignal_futmultifractal1:further check with weired case...\n')
                            else
                                %there was a conditional signal with low kelly
                                signal_i(1) = 0;
                                signal_i(4) = 0;
                                signals{i,1} = signal_i;
                                fprintf('\t%6s:%4s\tup:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
                            end
                        else
                            %there wasn't any conditional
                            %signal,i.e.alligator lines crossed and etc
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            signals{i,1} = signal_i;
                            fprintf('\t%6s:%4s\tup conditional %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                        end
                    else
                        signals{i,1} = signal_i;
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                    end
                    %
                    %
                elseif signaluncond.directionkellied == -1
                    signal_i = signaluncond.signalkellied;
                    if signaluncond.status.istrendconfirmed && ~stratfractalopt.helper_.book_.hasshortposition(underliers{i})
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
                                    signals{i,2} = signal_i;
                                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(-1),[signaluncond.opkellied,' not to place as tdsq buy setup'],100*signaluncond.kelly,100*signaluncond.wprob);
                                    %
                                    condentrusts2remove = EntrustArray;
                                    ne = stratfractalopt.helper_.condentrustspending_.latest;
                                    for jj = 1:ne
                                        e = stratfractalopt.helper_.condentrustspending_.node(jj);
                                        if e.offsetFlag ~= 1, continue; end
                                        if ~strcmpi(e.instrumentCode,underliers{i}.code_ctp), continue;end%the same instrument
                                        condentrusts2remove.push(e);
                                    end
                                    if condentrusts2remove.latest > 0
                                        stratfractalopt.removecondentrusts(condentrusts2remove);
                                    end
                                else
                                    if ~signaluncond.status.isvolblowup2
                                        signals{i,2} = signal_i;
                                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                                    else
                                        signal_i(1) = 0;
                                        signal_i(4) = 0;
                                        signals{i,2} = signal_i;
                                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(-1),[signaluncond.opkellied,' not to place as volblowup2'],100*signaluncond.kelly,100*signaluncond.wprob);
                                    end
                                end
                            elseif signalcond_.directionkellied == 1
                                fprintf('gensignal_futmultifractal1:further check with weired case...\n')
                            else
                                %there was a conditional signal with low kelly
                                signal_i(1) = 0;
                                signal_i(4) = 0;
                                signals{i,2} = signal_i;
                                fprintf('\t%6s:%4s\tdn conditional:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
                            end
                        else
                            if signaluncond.status.islvldnbreach
                                signals{i,2} = signal_i;
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                            else
                                %there wasn't any conditional
                                %signal,i.e.alligator lines crossed and etc
                                signal_i(1) = 0;
                                signal_i(4) = 0;
                                signals{i,2} = signal_i;
                                fprintf('\t%6s:%4s\tdn %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                            end
                        end
                    else
                        signals{i,2} = signal_i;
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                    end
                    %
                    %
                else
                    if stratfractalopt.helper_.book_.hasposition(underliers{i})
                        %in case the signaluncond shares the same signal
                        %mode with the current trade
                        tradeexist = stratfractalopt.helper_.getlivetrade('code',underliers{i});
                        mode1 = tradeexist.opensignal_.mode_;
                        if strcmpi(mode1,signaluncond.opkellied)
                            stratfractalopt.unwindpositions(underliers{i},'closestr','kelly is too low');
                        else
%                             exceptionflag =  tradeexist.opensignal_.kelly_ > 0.3 && ...
%                                 ~isempty(strfind(mode1,'volblowup'));
                            kelly = signaluncond.kelly;
                            if (kelly < 0 || isnan(kelly))
                                stratfractalopt.unwindpositions(underliers{i},'closestr','kelly is too low');
                            end
                        end
                    end
                    %
                    try
                        stratfractalopt.processcondentrust(underliers{i},'techvar',techvar);
                    catch e
                        fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                        stratfractalopt.stop;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                    %
                    condentrusts2remove = EntrustArray;
                    ne = stratfractalopt.helper_.condentrustspending_.latest;
                    for jj = 1:ne
                        e = stratfractalopt.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if ~strcmpi(e.instrumentCode,underliers{i}.code_ctp), continue;end%the same instrument
                        condentrusts2remove.push(e);
                    end
                    if condentrusts2remove.latest > 0
                        stratfractalopt.removecondentrusts(condentrusts2remove);
                    end
                end           
                %
                %
            else
                %EMPTY RETURNS FROM UNCONDITIONAL SIGNAL CALCULATION
                try
                    stratfractalopt.processcondentrust(underliers{i},'techvar',techvar);
                catch e
                    fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                    stratfractalopt.stop;
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
                   if signalcond.directionkellied == 1 && p(end,5) > teeth(end)
                       %it is necessary to withdraw pending conditional
                       %entrust with higher price to long
                       ne = stratfractalopt.helper_.condentrustspending_.latest;
                       if ne > 0
                           condentrusts2remove = EntrustArray;
                           for jj = 1:ne
                               e = stratfractalopt.helper_.condentrustspending_.node(jj);
                               if e.offsetFlag ~= 1, continue; end
                               if ~strcmpi(e.instrumentCode,underliers{i}.code_ctp), continue;end%the same instrument
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
                               stratfractalopt.removecondentrusts(condentrusts2remove);
                           end
                       end
                       %
                       signals{i,1} = signalcond.signalkellied; 
                       fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                       %
                   elseif signalcond.directionkellied == -1 && p(end,5) < teeth(end)
                       %it is necessary to withdraw pending conditional
                       %entrust with higher price to long
                       ne = stratfractalopt.helper_.condentrustspending_.latest;
                       if ne > 0
                           condentrusts2remove = EntrustArray;
                           for jj = 1:ne
                               e = stratfractalopt.helper_.condentrustspending_.node(jj);
                               if e.offsetFlag ~= 1, continue; end
                               if ~strcmpi(e.instrumentCode,underliers{i}.code_ctp), continue;end%the same instrument
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
                               stratfractalopt.removecondentrusts(condentrusts2remove);
                           end
                       end
                       %
                       signals{i,2} = signalcond.signalkellied;
                       fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,-1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                       %
                   else
                       if stratfractalopt.helper_.book_.hasposition(underliers{i})
                           tradeexist = stratfractalopt.helper_.getlivetrade('code',underliers{i});
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
                               stratfractalopt.unwindpositions(underliers{i},'closestr','conditional kelly is too low');
                           else
                               kelly = signalcond.kelly;
                               if kelly < 0 || isnan(kelly)
                                   stratfractalopt.unwindpositions(underliers{i},'closestr','conditional kelly is too low');
                               end
                           end
                       end
                       fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',underliers{i}.code_ctp,0,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                       %
                       condentrusts2remove = EntrustArray;
                       ne = stratfractalopt.helper_.condentrustspending_.latest;
                       for jj = 1:ne
                           e = stratfractalopt.helper_.condentrustspending_.node(jj);
                           if e.offsetFlag ~= 1, continue; end
                           if ~strcmpi(e.instrumentCode,underliers{i}.code_ctp), continue;end%the same instrument
                           condentrusts2remove.push(e);
                       end
                       if condentrusts2remove.latest > 0
                           stratfractalopt.removecondentrusts(condentrusts2remove);
                           fprintf('\t%6s:\t%2d\t%10s cancled as new mode with low kelly....\n',underliers{i}.code_ctp,0,signalcond.opkellied);
                       end
                   end
                else
                    %EMPTY RETURNS FROM CONDITIONAL SIGNAL CALCULATION
                    try
                        stratfractalopt.processcondentrust(underliers{i},'techvar',techvar);
                    catch e
                        fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                        stratfractalopt.stop;
                    end
                end
                %
            end
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