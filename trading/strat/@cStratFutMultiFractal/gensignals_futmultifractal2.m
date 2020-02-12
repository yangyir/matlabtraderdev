function signals = gensignals_futmultifractal2(stratfractal)
%cStratFutMultiFractal
    n = stratfractal.count;
    signals = zeros(n,1);
    if ~stratfractal.displaysignalonly_, return;end
    
    if strcmpi(stratfractal.mode_,'replay')
        runningt = stratfractal.replay_time1_;
    else
        runningt = now;
    end
    runningmm = hour(runningt)*60+minute(runningt);
    
    is2minbeforemktopen = (runningmm >= 538 && runningmm < 540) || ...      %08:58 to 08:59
            (runningmm >= 778 && runningmm < 780) || ...                    %12:58 to 12:59
            (runningmm >= 1258 && runningmm < 1260);                        %20:58 to 21:00
    
    calcsignalbeforemktclose = false;
    if (runningmm == 899 || runningmm == 914) && second(runningt) >= 56
        cobd = floor(runningt);
        nextbd = businessdate(cobd);
        calcsignalbeforemktclose = nextbd - cobd <= 3;
    end
    
    instruments = stratfractal.getinstruments;
    
    mdefut = stratfractal.mde_fut_;
    
    if is2minbeforemktopen || calcsignalbeforemktclose
        for i = 1:n
            [bs,ss,lvlup,lvldn,bc,sc] = mdefut.calc_tdsq_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [~,hh,ll] = mdefut.calc_fractal_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
            stratfractal.hh_{i} = hh;
            stratfractal.ll_{i} = ll;
            stratfractal.jaw_{i} = jaw;
            stratfractal.teeth_{i} = teeth;
            stratfractal.lips_{i} = lips;
            stratfractal.bs_{i} = bs;
            stratfractal.ss_{i} = ss;
            stratfractal.bc_{i} = bc;
            stratfractal.sc_{i} = sc;
            stratfractal.lvlup_{i} = lvlup;
            stratfractal.lvldn_{i} = lvldn;
        end
        
        if is2minbeforemktopen, return;end
    end
    
    for i = 1:n
        try
            calcsignalflag = stratfractal.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag = 0;
            msg = ['ERROR:%s:getcalcsignalflag:',class(stratfractal),e.message,'\n'];
            fprintf(msg);
            if strcmpi(stratfractal.onerror_,'stop'), stratfractal.stop; end
        end
        
        if ~calcsignalflag && ~calcsignalbeforemktclose;continue;end
        
        if ~calcsignalbeforemktclose
            includelastcandle = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
            [bs,ss,lvlup,lvldn,bc,sc,p] = mdefut.calc_tdsq_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            [~,hh,ll] = mdefut.calc_fractal_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            stratfractal.hh_{i} = hh;
            stratfractal.ll_{i} = ll;
            stratfractal.jaw_{i} = jaw;
            stratfractal.teeth_{i} = teeth;
            stratfractal.lips_{i} = lips;
            stratfractal.bs_{i} = bs;
            stratfractal.ss_{i} = ss;
            stratfractal.bc_{i} = bc;
            stratfractal.sc_{i} = sc;
            stratfractal.lvlup_{i} = lvlup;
            stratfractal.lvldn_{i} = lvldn;
            
            validbreachhh = p(end,5)>hh(end-1)&p(end-1)<hh(end-1)&...
            hh(end-1)==hh(end)&...
            (teeth(end-1)>jaw(end-1) || hh(end-1)>jaw(end-1));
            %
            validbreachll = p(end,5)<ll(end-1)&p(end-1)>ll(end-1)&...
                ll(end-1)==ll(end)&...
                (teeth(end-1)<jaw(end-1) || ll(end-1)<jaw(end-1));
        
            tick = mdefut.getlasttick(instruments{i});
        
            if validbreachhh && sc(end) ~= 13 && tick(3)>hh(end-1)
                signals(i) = 1;                                             %breach hh buy
            elseif validbreachll && bc(end) ~= 13 && tick(2)<ll(end-1)                               
                signals(i) = -1;                                            %breach ll sell
            end
        
            fprintf('\n%s->fractal info:\n',stratfractal.name_);
            if i == 1
                fprintf('%10s%11s%10s%8s%8s%10s%10s%10s%10s%10s%10s%10s\n',...
                    'code','time','px','bs','ss','lvlup','lvldn','bc','sc','hh','ll','B/S');
            end
            timet = datestr(tick(1),'HH:MM:SS');
            dataformat = '%10s%11s%10s%8s%8s%10s%10s%10s%10s%10s%10s%10d\n';
            fprintf(dataformat,instruments{i}.code_ctp,...
                timet,...
                num2str(p(end,5)),...
                num2str(bs(end)),num2str(ss(end)),num2str(lvlup(end)),num2str(lvldn(end)),...
                num2str(bc(end)),num2str(sc(end)),...
                num2str(hh(end)),num2str(ll(end)),...
                signals(i));
        end
        
        if calcsignalbeforemktclose && mdefut.candle_freq_(i) == 1440
            %
        end
    end
end