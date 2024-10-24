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
            catch e
                msg = sprintf('ERROR:%s:calctechnicalvariable:%s:%s\n',class(stratfractal),instruments{i}.code_ctp,e.message);
                fprintf(msg);
                continue
            end
            %
            nfractal = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
            freq = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
            
            if ~strcmpi(freq,'1440m')
                kellytables = stratfractal.tbl_all_intraday_;
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
                kellytables = stratfractal.tbl_all_daily_;
                tickratio = 1;
            end
            
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
            
%             tick = stratfractal.mde_fut_.getlasttick(instruments{i});
            
            signaluncond = fractal_signal_unconditional2('extrainfo',extrainfo,...
                'ticksize',ticksize,...
                'nfractal',nfractal,...
                'assetname',assetname,...
                'kellytables',kellytables,...
                'ticksizeratio',tickratio);
            
            if ~isempty(signaluncond)
                if signaluncond.directionkellied == 1
                    signal_i = signaluncond.signalkellied;
                    if signaluncond.status.istrendconfirmed && ~stratfractal.helper_.book_.haslongposition(instruments{i})
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
                            if signalcond_.directionkellied ~= 0
                                fprintf('gensignal_futmultifractal1:further check with weired case...\n')
                            end
                            %there was a conditional signal with low kelly
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            signals{i,1} = signal_i;
                            fprintf('\t%6s:%4s\tup conditional:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
                        else
                            %there wasn't any conditional
                            %signal,i.e.alligator lines crossed and etc
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            signals{i,1} = signal_i;
                            fprintf('\t%6s:%4s\tup conditional %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                        end
                    else
                        signals{i,1} = signal_i;
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                    end
                    %
                    %
                elseif signaluncond.directionkellied == -1
                    signal_i = signaluncond.signalkellied;
                    if signaluncond.status.istrendconfirmed && ~stratfractal.helper_.book_.hasshortposition(instruments{i})
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
                            if signalcond_.directionkellied ~= 0
                                fprintf('gensignal_futmultifractal1:further check with weired case...\n')
                            end
                            %there was a conditional signal with low kelly
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            signals{i,1} = signal_i;
                            fprintf('\t%6s:%4s\tdn conditional:%10s with low kelly\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(0),signalcond_.opkellied,100*signalcond_.kelly,100*signalcond_.wprob);
                        else
                            %there wasn't any conditional
                            %signal,i.e.alligator lines crossed and etc
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            signals{i,1} = signal_i;
                            fprintf('\t%6s:%4s\tdn conditional %10s was invalid\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                        end
                    else
                        signals{i,2} = signal_i;
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                    end
                    %
                    %
                else                
                    stratfractal.unwindpositions(instruments{i},'closestr','kelly is too low');
                    try
                        stratfractal.processcondentrust(instruments{i},'techvar',techvar);
                    catch e
                        fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                        stratfractal.stop;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(0),signaluncond.opkellied,100*signaluncond.kelly,100*signaluncond.wprob);
                end           
                %
                %
            else
                %EMPTY RETURNS FROM UNCONDITIONAL SIGNAL CALCULATION
                try
                    stratfractal.processcondentrust(instruments{i},'techvar',techvar);
                catch e
                    fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                    stratfractal.stop;
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
                       ne = stratfractal.helper_.condentrustspending_.latest;
                       if ne > 0
                           condentrusts2remove = EntrustArray;
                           for jj = 1:ne
                               e = stratfractal.helper_.condentrustspending_.node(jj);
                               if e.offsetFlag ~= 1, continue; end
                               if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                               if tickratio == 0
                                   if e.price <= signalcond.signalkellied(2),continue;end
                               else
                                   if e.price <= signalcond.signalkellied(2)+ticksize,continue;end
                               end
                               %if the code reaches here, the existing entrust shall be canceled
                               condentrusts2remove.push(e);
                           end
                           if condentrusts2remove.latest > 0
                               stratfractal.removecondentrusts(condentrusts2remove);
                           end
                       end
                       %
                       signals{i,1} = signalcond.signalkellied; 
                       fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                       %
                   elseif signalcond.directionkellied == -1 && p(end,5) < teeth(end)
                       %it is necessary to withdraw pending conditional
                       %entrust with higher price to long
                       ne = stratfractal.helper_.condentrustspending_.latest;
                       if ne > 0
                           condentrusts2remove = EntrustArray;
                           for jj = 1:ne
                               e = stratfractal.helper_.condentrustspending_.node(jj);
                               if e.offsetFlag ~= 1, continue; end
                               if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                               if e.direction ~= -1, continue;end %the same direction
                               if tickratio == 0
                                   if e.price >= signalcond.signalkellied(3),continue;end
                               else
                                   if e.price >= signalcond.signalkellied(3)-ticksize,continue;end
                               end
                               %if the code reaches here, the existing entrust shall be canceled
                               condentrusts2remove.push(e);
                           end
                           if condentrusts2remove.latest > 0
                               stratfractal.removecondentrusts(condentrusts2remove);
                           end
                       end
                       %
                       signals{i,2} = signalcond.signalkellied;
                       fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,-1,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                       %
                   else
                       stratfractal.unwindpositions(instruments{i},'closestr','conditional kelly is too low');
                       fprintf('\t%6s:\t%2d\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,0,signalcond.opkellied,100*signalcond.kelly,100*signalcond.wprob);
                       %
                       condentrusts2remove = EntrustArray;
                       ne = stratfractal.helper_.condentrustspending_.latest;
                       for jj = 1:ne
                           e = stratfractal.helper_.condentrustspending_.node(jj);
                           if e.offsetFlag ~= 1, continue; end
                           if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                           if e.direction ~= -1,continue;end
                           condentrusts2remove.push(e);
                       end
                       if condentrusts2remove.latest > 0
                           stratfractal.removecondentrusts(condentrusts2remove);
                           fprintf('\t%6s:%4s\t%10s cancled as new mode with low kelly....\n',instruments{i}.code_ctp,num2str(0),signalcond.opkellied);
                       end
                   end
                else
                    %EMPTY RETURNS FROM CONDITIONAL SIGNAL CALCULATION
                    try
                        stratfractal.processcondentrust(instruments{i},'techvar',techvar);
                    catch e
                        fprintf('processcondentrust called in gensignals but failed:%s\n', e.message);
                        stratfractal.stop;
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