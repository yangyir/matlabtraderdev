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
            [~,~,hh,ll] = mdefut.calc_fractal_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
            wad = mdefut.calc_wad_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
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
            stratfractal.wad_{i} = wad;
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
%             if strcmpi(stratfractal.onerror_,'stop'), stratfractal.stop; end
        end
    end
    %
    if sum(calcsignalflag) == 0, return;end
    
    fprintf('\n%s->%s:signal calculated...\n',stratfractal.name_,datestr(runningt,'yyyy-mm-dd HH:MM'));
    
    for i = 1:n
        if ~calcsignalflag(i) && ~calcsignalbeforemktclose;continue;end
        
        if calcsignalflag(i) && ~calcsignalbeforemktclose
%             includelastcandle = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
            [bs,ss,lvlup,lvldn,bc,sc,p] = mdefut.calc_tdsq_(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
            [idxHH,idxLL,hh,ll] = mdefut.calc_fractal_(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = mdefut.calc_alligator_(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
            wad = mdefut.calc_wad_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
            
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
            stratfractal.wad_{i} = wad;
            
            nfractal = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
            
            validbreachhh = p(end,5)>hh(end-1) & p(end-1,5)<=hh(end-1) &...
                abs(hh(end-1)/hh(end)-1)<0.002 &...
                p(end,3)>lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end))&... 
                hh(end)>teeth(end);
            
            if validbreachhh
                if teeth(end)>jaw(end)
                    b1type = 3;
                else
                    b1type = 2;
                end
                extrainfo = struct('px',p,'ss',ss,'sc',sc,'lvlup',lvlup,'lvldn',lvldn,...
                    'idxhh',idxHH,'hh',hh,...
                    'lips',lips,'teeth',teeth,'jaw',jaw,...
                    'wad',wad);
                op = fractal_filterb1_singleentry(b1type,nfractal,extrainfo);
                validbreachhh = op.use;
                if ~validbreachhh
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                    continue;
                end
                if validbreachhh && ...
                        p(end,5) > p(end,3)-0.382*(p(end,3)-ll(end)) && ...
                        p(end,5) < hh(end)+1.618*(hh(end)-ll(end)) && ...
                        p(end,5) > lips(end)
                    signals(i,1) = 1;                                           %breach hh buy
                    signals(i,2) = hh(end);
                    signals(i,3) = ll(end);
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),op.comment);
                    continue;
                end
            end
                  
            validbreachll = p(end,5)<ll(end-1) & p(end-1,5)>=ll(end-1)&...
                abs(ll(end-1)/ll(end)-1)<0.002 &...
                p(end,4)<lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end))&...
                ll(end)<teeth(end);
            
            if validbreachll
                if teeth(end)<jaw(end)
                    s1type = 3;
                else
                    s1type = 2;
                end
                extrainfo = struct('px',p,'bs',bs,'bc',bc,'lvlup',lvlup,'lvldn',lvldn,...
                    'idxll',idxLL,'ll',ll,...
                    'lips',lips,'teeth',teeth,'jaw',jaw,...
                    'wad',wad);
                op = fractal_filters1_singleentry(s1type,nfractal,extrainfo);
                validbreachll = op.use;
                if ~validbreachll
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                    continue;
                end
                if validbreachll && ...
                        p(end,5) < p(end,4)+0.382*(hh(end)-p(end,4)) && ...
                        p(end,5) > ll(end)-1.618*(hh(end)-ll(end)) && ...
                        p(end,5) < lips(end)
                    signals(i,1) = -1;                                          %breach ll sell
                    signals(i,2) = hh(end);
                    signals(i,3) = ll(end);
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),op.comment);
                    continue;
                end
            end
            
        end
    end
   
    
    
    
    if sum(abs(signals(:,1))) == 0, return;end
    
    fprintf('\n');
end