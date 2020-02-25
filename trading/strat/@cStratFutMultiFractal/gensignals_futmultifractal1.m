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
            [idxfractal,hh,ll] = mdefut.calc_fractal_(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
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
                hh(end-1)==hh(end);
            %exclude sell countdown 13
            validbreachhh = validbreachhh && sc(end) ~= 13;
            %exclude perfect sell sequential if it is not a 'strong' breach
            if validbreachhh && ~(teeth(end) > jaw(end))
                if ss(end) >= 9 && p(end,5) >= max(p(end-ss(end)+1:end,5)) && p(end,3) >= max(p(end-ss(end)+1:end,3))
                    validbreachhh = false;
                end
            end
%             %exclude if there is sell fractal below teeth happend between
%             if validbreachhh
%                 idxHH = find(idxfractal==1,1,'last');
%                 idxLL = find(idxfractal(idxHH:end)==-1,1,'first')+idxHH-1;
%                 if ~isempty(idxLL)
%                     if ll(idxLL)<teeth(idxLL-mdefut.nfractals_(i)) && idxLL<size(p,1)
%                         validbreachhh = false;
%                     end
%                  end
%             end
            %    
            %
            validbreachll = p(end,5)<ll(end-1)&p(end-1,5)>ll(end-1)&...
                ll(end-1)<teeth(end-1)&...
                ll(end-1)==ll(end);
            %exclude buy countdown 13
            validbreachll = validbreachll && bc(end) ~= 13;
            %exclude perfect buy sequential if it is not a 'strong' breach
            if validbreachll && ~(teeth(end) < jaw(end))
                if bs(end) >= 9 && p(end,5) <= min(p(end-bs(end)+1:end,5)) && p(end,4) <= min(p(end-bs(end)+1:end,4))
                    validbreachll = false;
                end
            end
%             %exclude if there is buy fractal above teech happend between
%             if validbreachll
%                 idxLL = find(idxfractal==-1,1,'last');
%                 idxHH = find(idxfractal(idxLL:idxopen,6)==1,1,'first')+idxLL-1;
%                 if ~isempty(idxHH)
%                     if hh(idxHH)>teeth(idxHH-mdefut.nfractals_(i)) && idxHH<size(p,1)
%                         validbreachll = false;
%                     end
%                 end    
%             end
            %
            tick = mdefut.getlasttick(instruments{i});
        
            if validbreachhh && tick(3)>hh(end) && ...
                    tick(3) > p(end,3)-0.382*(p(end,3)-ll(end)) && ...
                    tick(3) > lips(end)
                signals(i,1) = 1;                                           %breach hh buy
                signals(i,2) = p(end,3);
                signals(i,3) = ll(end);
            elseif validbreachll && tick(2)<ll(end) && ...
                    tick(2) < p(end,4)+0.382*(hh(end)-p(end,4)) && ...
                    tick(2) < lips(end)
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
                hh(end-1)==hh(end);
            validbreachhh = validbreachhh && sc(end) ~= 13;
            if validbreachhh && ~(teeth(end) > jaw(end))
                if ss(end) >= 9 && p(end,5) >= max(p(end-ss(end)+1:end,5)) && p(end,3) >= max(p(end-ss(end)+1:end,3))
                    validbreachhh = false;
                end
            end
            if validbreachhh
                idxHH = find(idxfractal==1,1,'last');
                idxLL = find(idxfractal(idxHH:end)==-1,1,'first')+idxHH-1;
                if ~isempty(idxLL)
                    if ll(idxLL)<teeth(idxLL-mdefut.nfractals_(i)) && idxLL<size(p,1)
                        validbreachhh = false;
                    end
                 end
            end
            %
            %
            validbreachll = p(end,5)<ll(end-1)&p(end-1,5)>ll(end-1)&...
                ll(end-1)<teeth(end-1)&...
                ll(end-1)==ll(end);
            validbreachll = validbreachll && bc(end) ~= 13;
            if validbreachll && ~(teeth(end) < jaw(end))
                if bs(end) >= 9 && p(end,5) <= min(p(end-bs(end)+1:end,5)) && p(end,4) <= min(p(end-bs(end)+1:end,4))
                    validbreachll = false;
                end
            end
            if validbreachll
                idxLL = find(idxfractal==-1,1,'last');
                idxHH = find(idxfractal(idxLL:idxopen,6)==1,1,'first')+idxLL-1;
                if ~isempty(idxHH)
                    if hh(idxHH)>teeth(idxHH-mdefut.nfractals_(i)) && idxHH<size(p,1)
                        validbreachll = false;
                    end
                end    
            end
            
            if validbreachhh && ...
                    p(end,5) > p(end,3)-0.382*(p(end,3)-ll(end)) && ...
                    p(end,5) > lips(end)
                signals(i,1) = 1;                                           %breach hh buy
                signals(i,2) = hh(end);
                signals(i,3) = ll(end);
            elseif validbreachll && ...
                    p(end,5) < p(end,4)+0.382*(hh(end)-p(end,4)) && ...
                    p(end,5) < lips(end)
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