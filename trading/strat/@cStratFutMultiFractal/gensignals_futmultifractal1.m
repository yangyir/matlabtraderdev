function signals = gensignals_futmultifractal1(stratfractal)
%cStratFutMultiFractal
%NEW CHANGE:signals are not generated with the price before the market
%close as we don't know whether the open price (once the market open again)
%would still be valid for a signal. however, we might miss big profit in
%case the market jumps in favor of the strategy. Of course, we might loose
%in case the market moves against the strategy

    n = stratfractal.count;
    signals = zeros(n,6);
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
            
            validbreachhh = p(end,5)-hh(end-1)>ticksize & p(end-1,5)<=hh(end-1) &...
                abs(hh(end-1)/hh(end)-1)<0.002 &...
                p(end,3)>lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end))&... 
                hh(end)-teeth(end)>=ticksize;
            
            validbreachll = p(end,5)-ll(end-1)<-ticksize & p(end-1,5)>=ll(end-1)&...
                abs(ll(end-1)/ll(end)-1)<0.002 &...
                p(end,4)<lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end))&...
                ll(end)-teeth(end)<=-ticksize;
            
            if validbreachhh && ~validbreachll
                %市场按收盘价出现了有效的向上突破
                if teeth(end)>jaw(end)
                    b1type = 3;
                else
                    b1type = 2;
                end
                extrainfo = struct('px',p,'ss',ss,'sc',sc,'lvlup',lvlup,'lvldn',lvldn,...
                    'idxhh',idxHH,'hh',hh,...
                    'idxll',idxLL,'ll',ll,...
                    'lips',lips,'teeth',teeth,'jaw',jaw,...
                    'wad',wad);
                op = fractal_filterb1_singleentry(b1type,nfractal,extrainfo);
                useflag = op.use;
                if ~useflag
                    %special treatment when market jumps
                    tick = stratfractal.mde_fut_.getlasttick(instruments{i});
                    if ~isempty(tick)
                        ask = tick(3);
                        if ask>lvlup(end) && p(end,5)<lvlup(end)
                            useflag = 1;
                            op.comment = 'breachup-lvlup';
                        end
                    end
                end
                if ~useflag
                    %special treatment when market moves close to lvlup,
                    %i.e.the market breached up HH but still stayed below
                    %lvlup closely, we shall here place a conditional
                    %entrust just one tick above lvlup
                    status = fractal_b1_status(nfractal,extrainfo,ticksize);
                    if status.isclose2lvlup
                        signals(i,1) = 1;
                        signals(i,2) = lvlup(end);                          %here replace HH with lvlup
                        signals(i,3) = ll(end);
                        signals(i,5) = p(end,3);
                        signals(i,6) = p(end,4);
                        signals(i,4) = 3;                                   %special key for closetolvlup
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:closetolvlup');
                    else
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                    end
                else
                    validlongopen = p(end,5) > p(end,3)-0.382*(p(end,3)-ll(end)) & ...
                        p(end,5) < hh(end)+1.618*(hh(end)-ll(end)) & ...
                        p(end,5) > lips(end);
                    if validlongopen
                        signals(i,1) = 1;                                   %breach hh buy
                        signals(i,2) = hh(end);
                        signals(i,3) = ll(end);
                        signals(i,5) = p(end,3);
                        signals(i,6) = p(end,4);
                        switch op.comment
                            %TODO
                            case 'breachup-lvlup'
                                signals(i,4) = 1;
                            case 'volblowup'
                                signals(i,4) = 1;
                            otherwise
                                signals(i,4) = 1;
                        end
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),op.comment);
                        continue;
                    end
                end
                %
            elseif ~validbreachhh && validbreachll
                %%市场按收盘价出现了有效的向下突破
                if teeth(end)<jaw(end)
                    s1type = 3;
                else
                    s1type = 2;
                end
                extrainfo = struct('px',p,'bs',bs,'bc',bc,'lvlup',lvlup,'lvldn',lvldn,...
                    'idxhh',idxHH,'hh',hh,...
                    'idxll',idxLL,'ll',ll,...
                    'lips',lips,'teeth',teeth,'jaw',jaw,...
                    'wad',wad);
                op = fractal_filters1_singleentry(s1type,nfractal,extrainfo);
                useflag = op.use;
                if ~useflag
                    %special treatment when market jumps
                    tick = stratfractal.mde_fut_.getlasttick(instruments{i});
                    if ~isempty(tick)
                        bid = tick(2);
                        if bid < lvldn(end) && p(end,5)>lvldn(end)
                            useflag = 1;
                            op.comment = 'breachdn-lvldn';
                        end
                    end
                end
                if ~useflag
                    %special treatment when market moves close to
                    %lvldn,i.e.the market breached down LL but still stayed
                    %above lvldn closely, we shall here place an conditonal
                    %entrust just one tick below lvldn
                    status = fractal_s1_status(nfractal,extrainfo,ticksize);
                    if status.isclose2lvldn
                        signals(i,1) = -1;
                        signals(i,2) = hh(end);
                        signals(i,3) = lvldn(end);                          %here replace LL with lvldn
                        signals(i,5) = p(end,3);
                        signals(i,6) = p(end,4);
                        signals(i,4) = -3;                                  %special key for closetolvldn
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:closetolvldn');
                    else
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                    end
                else
                    validshortopen = p(end,5)<p(end,4)+0.382*(hh(end)-p(end,4)) & ...
                        p(end,5)>ll(end)-1.618*(hh(end)-ll(end)) & ...
                        p(end,5)<lips(end);
                    if validshortopen
                        signals(i,1) = -1;                                          %breach ll sell
                        signals(i,2) = hh(end);
                        signals(i,3) = ll(end);
                        signals(i,5) = p(end,3);
                        signals(i,6) = p(end,4);
                        switch op.comment
                            %TODO
                            case 'breachdn-lvldn'
                                signals(i,4) = 1;
                            case 'volblowup'
                                signals(i,4) = 1;
                            case 'breachdn-bshighvalue'
                                signals(i,4) = 1;
                            otherwise
                                signals(i,4) = 1;
                        end
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),op.comment);
                    end
                end
                %
            elseif ~validbreachhh && ~validbreachll
                %neither a validbreachhh nor a validbreachll
                %special code for conditional entrust (sign indicates
                %direction)
                %code 2:trendconfirmed
                %code 3:closetolvlup(-3:closetolvldn)
                %code 4:breachup-lvlup(-4:breachdn-lvldn)
                ncondpending = stratfractal.helper_.condentrustspending_.latest;
                if ncondpending > 0
                    condentrusts2remove = EntrustArray;
                    for jj = 1:ncondpending
                        condentrust = stratfractal.helper_.condentrustspending_.node(jj);
                        if ~strcmpi(instruments{i}.code_ctp,condentrust.instrumentCode), continue;end
                        if condentrust.offsetFlag ~= 1, continue; end
                        signalinfo = condentrust.signalinfo_;
                        if isempty(signalinfo),continue;end
                        if strcmpi(signalinfo.mode,'conditional-uptrendconfirmed')
                            %cancel the entrust 1)either the price fell below
                            %the alligator's teeth 2)or the lastest HH is
                            %below the previous HH
                            ispxbelowteeth = p(end,5)<teeth(end)-2*ticksize;
                            last2hh = hh(find(idxHH(1:end) == 1,2,'last'));
                            if size(last2hh,1) == 2
                                islatesthhlower = last2hh(2)<last2hh(1);
                            else
                                islatesthhlower = false;
                            end
                            if ispxbelowteeth || islatesthhlower
                                condentrusts2remove.push(condentrust);
                                if ispxbelowteeth
                                    fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as price fell below alligator teeth...');
                                elseif islatesthhlower
                                    fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as new hh is lower...');
                                end
                            end
                        elseif strcmpi(signalinfo.mode,'conditional-dntrendconfirmed')
                            %cancel the entrust 1)either the price rallied
                            %above the alligator's teeth )or the latest LL
                            %is above the previous LL
                            ispxaboveteeth = p(end,5)>teeth(end)+2*ticksize;
                            last2ll = hh(find(idxLL(1:end) == -1,2,'last'));
                            if size(last2ll,1) == 2
                                islatestllhigher = last2ll(2)>last2ll(1);
                            else
                                islatestllhigher = false;
                            end
                            if ispxaboveteeth || islatestllhigher
                                condentrusts2remove.push(condentrust);
                                if ispxaboveteeth
                                    fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as price rallied above alligator teeth...');
                                elseif islatestllhigher
                                    fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as new ll is higher...');
                                end
                            end
                        elseif strcmpi(signalinfo.mode,'conditional-close2lvlup')
                            %cancel the entrust once the close price as of
                            %the latest candle stick fell below HH
                            if p(end,5) < hh(end)
                                condentrusts2remove.push(condentrust);
                                fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as close price fell below hh...');
                            end
                        elseif strcmpi(signalinfo.mode,'conditional-close2lvldn')
                            %cancel the entrust once the close price as of
                            %the latest candle stick rallied above LL
                            if p(end,5) > ll(end)
                                condentrusts2remove.push(condentrust);
                                fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as close price rallied above ll...');
                            end
                        elseif strcmpi(signalinfo.mode,'conditional-breachuplvlup')
                            %cancel the entrust once the highest price as
                            %of the latest candle fell below lvlup
                            if p(end,3) < lvlup(end)
                                condentrusts2remove.push(condentrust);
                                fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as highest price fell below lvlup...');
                            end
                        elseif strcmpi(signalinfo.mode,'conditional-breachdnlvldn')
                            %cancel the entrust once the lowest price as of
                            %the latest candle rallies above lvldn
                            if p(end,4) > lvldn(end)
                                condentrusts2remove.push(condentrust);
                                fprintf('\t%6s:%s:%s\n',instruments{i}.code_ctp,signalinfo.mode, 'canceled as lowest price rallied above lvldn...');
                            end
                        else
                            continue;
                        end                        
                    end
                    stratfractal.removecondentrusts(condentrusts2remove);
                end
                %
                %
                %1a.已经连续2*nfractal的K线排列在alligator teeth的上方；且HH形成在alligator
                %teeth的上方，在HH的上方挂买单
                %且最新的收盘价还在HH的下方
                %且最新的HH比前一个HH高，证明趋势向上
                aboveteeth = isempty(find(p(end-2*nfractal+1:end,5)-teeth(end-2*nfractal+1:end)+2*ticksize<0,1,'first'));
                aboveteeth = aboveteeth & hh(end)-teeth(end)>=ticksize;
                aboveteeth = aboveteeth & p(end,5)<hh(end);
                last2hhidx = find(idxHH(1:end)==1,2,'last');
                last2hh = hh(last2hhidx);
                if size(last2hhidx,1) == 2
                    aboveteeth = aboveteeth & last2hh(2) > last2hh(1);     
                end
                %1b.TDST level up在HH的上方；且alligator lips大于alligator
                %teeth和alligator jaw,在HH的上方挂买单
                %且最新的收盘价还在HH的下方
                %且K线的最高价在TDST level up的下方
                %如果向上穿透HH则必然已经穿透TDST level up
                hhabovelvlup = hh(end)>=lvlup(end) & lips(end)>teeth(end) ...
                    & lips(end)>jaw(end);
                hhabovelvlup = hhabovelvlup & p(end,5)<hh(end)...
                    & p(end,3)<lvlup(end);
                
                if aboveteeth
                    %TREND has priority over TDST breakout
                    signals(i,1) = 1;
                    signals(i,2) = hh(end);
                    signals(i,3) = ll(end);
                    signals(i,5) = p(end,3);
                    signals(i,6) = p(end,4);
                    signals(i,4) = 2;
                    if teeth(end)>jaw(end)
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:strongbreach-trendconfirmed');
                    else
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:mediumbreach-trendconfirmed');
                    end
                else
                    if hhabovelvlup
                        signals(i,1) = 1;
                        signals(i,2) = hh(end);
                        signals(i,3) = ll(end);
                        signals(i,5) = p(end,3);
                        signals(i,6) = p(end,4);
                        signals(i,4) = 4;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup');
                    end
                end
                %
                %
                %2a.已经连续2*nfractal的K线排列在alligator teeth的下方；且LL形成在alligator
                %teeth的下方，在LL的下方一个tick挂卖单
                %且最新的收盘价还在LL的上方
                %且最新的LL比前一个LL低，证明趋势向下
                belowteeth = isempty(find(p(end-2*nfractal+1:end,5)-teeth(end-2*nfractal+1:end)-2*ticksize>0,1,'first'));
                belowteeth = belowteeth & ll(end)-teeth(end)<=-ticksize;
                belowteeth = belowteeth & p(end,5)>ll(end);
                last2llidx = find(idxLL(1:end)==1,2,'last');
                last2ll = ll(last2llidx);
                if size(last2ll) == 2
                    belowteeth = belowteeth & last2ll(2) < last2ll(1);          
                end
                %2b.TDST level dn在LL的上方；且alligator lips小于alligator
                %teeth和alligator jaw,在LL的下方一个tick挂卖单
                %且最新的收盘价还在LL的上方
                %且K线的最低价在level dn的上方
                %如果向下穿透LL则必然已经穿透TDST level dn
                llbelowlvldn = ll(end)<lvldn(end) & lips(end)<teeth(end) ...
                    & lips(end)<jaw(end);
                llbelowlvldn = llbelowlvldn & p(end,5)>ll(end)...
                    & p(end,4)>lvldn(end);

                if belowteeth
                    signals(i,1) = -1;
                    signals(i,2) = hh(end);
                    signals(i,3) = ll(end);
                    signals(i,5) = p(end,3);
                    signals(i,6) = p(end,4);
                    signals(i,4) = -2;
                    if teeth(end)<jaw(end)
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:strongbreach-trendconfirmed');
                    else
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:mediumbreach-trendconfirmed');
                    end
                else
                    if llbelowlvldn
                        signals(i,1) = -1;
                        signals(i,2) = hh(end);
                        signals(i,3) = ll(end);
                        signals(i,5) = p(end,3);
                        signals(i,6) = p(end,4);
                        signals(i,4) = -4;
                        fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn');
                    end
                    
                end
                %
                %
            end
        end
    end
   
    
    
    
    if sum(abs(signals(:,1))) == 0, return;end
    
    fprintf('\n');
end