function signals = gensignals_futmultifractal1(stratfractal)
%cStratFutMultiFractal
    n = stratfractal.count;
    signals = zeros(n,3);
    if stratfractal.displaysignalonly_, return;end
    
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
    
    calcsignalflag = zeros(n,1);
    for i = 1:n
        try
            calcsignalflag(i) = stratfractal.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag(i) = 0;
            msg = ['ERROR:%s:getcalcsignalflag:',class(stratfractal),e.message,'\n'];
            fprintf(msg);
            if strcmpi(stratfractal.onerror_,'stop'), stratfractal.stop; end
        end
        
        if ~calcsignalflag(i) && ~calcsignalbeforemktclose;continue;end
        
        if ~calcsignalbeforemktclose
%             includelastcandle = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
            [bs,ss,lvlup,lvldn,bc,sc,p] = mdefut.calc_tdsq_(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
            [~,hh,ll] = mdefut.calc_fractal_(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
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
            
            validbreachhh = p(end,5)>hh(end-1)&p(end-1,5)<hh(end-1)&...
                hh(end-1)>teeth(end-1)&...
                hh(end-1)==hh(end)&...
                (teeth(end-1)>jaw(end-1) || hh(end-1)>jaw(end-1));
            %
            validbreachll = p(end,5)<ll(end-1)&p(end-1,5)>ll(end-1)&...
                ll(end-1)<teeth(end-1)&...
                ll(end-1)==ll(end)&...
                (teeth(end-1)<jaw(end-1) || ll(end-1)<jaw(end-1));
        
            tick = mdefut.getlasttick(instruments{i});
        
            if validbreachhh && sc(end) ~= 13 && tick(3)>hh(end-1)
                signals(i,1) = 1;                                           %breach hh buy
                signals(i,2) = p(end,3);
                signals(i,3) = ll(end);
            elseif validbreachll && bc(end) ~= 13 && tick(2)<ll(end-1)                               
                signals(i,1) = -1;                                          %breach ll sell
                signals(i,2) = hh(end);
                signals(i,3) = p(end,4);
            end
        end
        
        if calcsignalbeforemktclose && mdefut.candle_freq_(i) == 1440
            candlesticks = mdefut.getallcandles(instruments{i});
            p = candlesticks{1};
            validbreachhh = p(end,5)>hh(end-1)&p(end-1,5)<hh(end-1)&...
                hh(end-1)>teeth(end-1)&...
                hh(end-1)==hh(end)&...
                teeth(end-1)>jaw(end-1);
            %
            validbreachll = p(end,5)<ll(end-1)&p(end-1,5)>ll(end-1)&...
                ll(end-1)<teeth(end-1)&...
                ll(end-1)==ll(end)&...
                teeth(end-1)<jaw(end-1);
            
        
            if validbreachhh && sc(end) ~= 13
                signals(i,1) = 1;                                           %breach hh buy
                signals(i,2) = hh(end);
                signals(i,3) = ll(end);
            elseif validbreachll && bc(end) ~= 13
                signals(i,1) = -1;                                          %breach ll sell
                signals(i,2) = hh(end);
                signals(i,3) = ll(end);
            end
        end
    end
    %
    if sum(calcsignalflag) == 0, return;end
    
    fprintf('\n%s->%s:signal calculated...\n',stratfractal.name_,datestr(runningt,'yyyy-mm-dd HH:MM'));
    
    if sum(abs(signals(:,1))) == 0, return;end
    
    %some signal generated
    for i = 1:n
        if signals(i) == 0, continue;end
        fprintf('\t%6s:%4s\n',instruments{i}.code_ctp,num2str(signals(i,1)));
    end
    fprintf('\n');
end