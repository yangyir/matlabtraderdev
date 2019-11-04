function signals = gensignals_futmultitdsq3(strategy)
%cStratFutMultiTDSQ
    %note:column 1 is for reverse-type signal
    %column 2 is for trend-type signal
    if ~strategy.displaysignalonly_, return;end
    
    signals = cell(size(strategy.count,1),3);
    instruments = strategy.getinstruments;
    
    if strcmpi(strategy.mode_,'replay')
        runningt = strategy.replay_time1_;
    else
        runningt = now;
    end
    
    runningmm = hour(runningt)*60+minute(runningt);
    
    is2minbeforemktopen = (runningmm >= 538 && runningmm < 540) || ...
            (runningmm >= 778 && runningmm < 780) || ...
            (runningmm >= 1258 && runningmm < 1260);
    
    %NOTE:special treatment before market close on 15:00 or 15:15
    %for govtbond futures
    calcsignalbeforemktclose = false;
    if (runningmm == 899 || runningmm == 914) && second(runningt) >= 56
        cobd = floor(runningt);
        nextbd = businessdate(cobd);
        calcsignalbeforemktclose = nextbd - cobd <= 3;
    end
    
    if is2minbeforemktopen || calcsignalbeforemktclose
            %one minute before market open in the morning, afternoon and
            %evening respectively
       for i = 1:strategy.count
           [macdvec,sigvec,p] = strategy.mde_fut_.calc_macd_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
           %
           [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
           %
           strategy.tdbuysetup_{i} = bs;
           strategy.tdsellsetup_{i} = ss;
           strategy.tdbuycountdown_{i} = bc;
           strategy.tdsellcountdown_{i} = sc;
           strategy.tdstlevelup_{i} = levelup;
           strategy.tdstleveldn_{i} = leveldn;
           strategy.macdvec_{i} = macdvec;
           strategy.nineperma_{i} = sigvec;
           %
           strategy.updatetag(instruments{i},p,bs,ss,levelup,leveldn);
           %
           diffvec = macdvec - sigvec;
           [macdbs,macdss] = tdsq_setup(diffvec);
           strategy.macdbs_{i} = macdbs;
           strategy.macdss_{i} = macdss;
       end
       
       if is2minbeforemktopen, return; end
    end
    
    for i = 1:strategy.count
        try
            calcsignalflag = strategy.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag = 0;
            msg = ['ERROR:%s:getcalcsignalflag:',class(strategy),e.message,'\n'];
            fprintf(msg);
            if strcmpi(strategy.onerror_,'stop'), strategy.stop; end
        end
        
        if ~calcsignalflag && ~calcsignalbeforemktclose
            %NOTE:class variable _signals not updated if signals are not
            %calculated...^_^
            signals{i,1} = 0;
            signals{i,2} = {};
            signals{i,3} = {};
            continue;
        end
        
%         samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
        
        if ~calcsignalbeforemktclose
            includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
            [macdvec,sigvec,p] = strategy.mde_fut_.calc_macd_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
        
            bs = strategy.tdbuysetup_{i};
            ss = strategy.tdsellsetup_{i};
            bc = strategy.tdbuycountdown_{i};
            sc = strategy.tdsellcountdown_{i};
            levelup = strategy.tdstlevelup_{i};
            leveldn = strategy.tdstleveldn_{i};
        
            if size(p,1) - size(bs,1) == 1
                if strategy.printflag_, fprintf('%s:update tdsq variables of %s...\n',strategy.name_,instruments{i}.code_ctp);end
                [bs,ss,levelup,leveldn,bc,sc] = tdsq_piecewise(p,bs,ss,levelup,leveldn,bc,sc);
            elseif size(p,1) < size(bs,1)
                [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            elseif size(p,1) - size(bs,1) > 1
                error('unknown error and check is required')
            end
        
            %update strategy-related variables
            strategy.tdbuysetup_{i} = bs;
            strategy.tdsellsetup_{i} = ss;
            strategy.tdbuycountdown_{i} = bc;
            strategy.tdsellcountdown_{i} = sc;
            strategy.tdstlevelup_{i} = levelup;
            strategy.tdstleveldn_{i} = leveldn;
        
            diffvec = macdvec - sigvec;
            [macdbs,macdss] = tdsq_setup(diffvec);
            strategy.macdbs_{i} = macdbs;
            strategy.macdss_{i} = macdss;

            strategy.macdvec_{i} = macdvec;
            strategy.nineperma_{i} = sigvec;
            
            [~,tag] = strategy.updatetag(instruments{i},p,bs,ss,levelup,leveldn);
        else
            tag = strategy.tags_{i};
        end
        
        variablenotused(tag);
        
        temp = diffvec(2:end).*diffvec(1:end-1);
        idxchg = find(temp<0)+1;
        
        np = size(p,1);
        lastidxchg = find(idxchg<=np,1,'last');
        if isempty(lastidxchg), continue;end
        lvlup = levelup(idxchg(lastidxchg));
        lvldn = leveldn(idxchg(lastidxchg));
        
        refs = macdenhanced(np,p);
        upperbound1 = refs.y1 + refs.k1*refs.x(end);
        lowerbound1 = refs.y2 + refs.k2*refs.x(end);
        upperbound2 = refs.y3 + refs.k3*refs.x(end);
        lowerbound2 = refs.y4 + refs.k4*refs.x(end);
        signals{i,1} = 0;
        
        tick = strategy.mde_fut_.getlasttick(instruments{i});
        %need to make sure MACD sign not change
        [tempa,tempb] = macd([p(1:end,5);tick(4)]);
        if tempa(end) < tempb(end) && diffvec(end) > 0
            checkdirection = -1;
            pxuse = tick(4);
        elseif tempa(end) < tempb(end) && diffvec(end) < 0
            checkdirection = -1;
            pxuse = p(end,5);
        elseif tempa(end) > tempb(end) && diffvec(end) < 0
            checkdirection = 1;
            pxuse = tick(4);
        elseif tempa(end) > tempb(end) && diffvec(end) > 0
            checkdirection = 1;
            pxuse = p(end,5);
        end
        
        if checkdirection == 1           
            if isempty(upperbound1) && isempty(upperbound2)
                %no signal
            elseif ~isempty(upperbound1) && isempty(upperbound2)
                %at the turning point
                %if the upperbound1 and lowerbound1 crossed before the MACD
                %turning point, we will not use upperbound1 here as we
                %believe it is not valid anymore
                if upperbound1 < lowerbound1, continue;end
                
                if pxuse > upperbound1
                    %breach lvldn?
                    if ~isnan(lvldn) && refs.range2min < lvldn && pxuse > lvldn && pxuse > lowerbound1
%                         fprintf('B with ss %2d:breach up lvldn\n',ss(end));
                        signals{i,1} = 1;
                    end
                    %breach lvlup?
                    if ~isnan(lvlup) && refs.range2min < lvlup && pxuse > lvlup && pxuse > lowerbound1
%                         fprintf('B with ss %2d:breach up lvlup\n',ss(end));
                        signals{i,1} = 1;
                    end
                    %after a full buy-setup and there is no buy-setup
                    %between
                    lastbs = find(bs >=9,1,'last');
                    lastss = find(ss >=9,1,'last');
                    if isempty(lastbs), lastbs = -1;end
                    if isempty(lastss), lastss = -1;end
                    if lastbs > lastss && np-lastbs <= 2
%                         fprintf('B with ss %2d:td buysetup\n',ss(end));
                        signals{i,1} = 1;
                    end
                    %otherwise we need to make sure ss is greater than 1
                    if ss(end) > 1
%                         fprintf('B with ss %2d\n',ss(end));
                        signals{i,1} = 1;
                    end
                else
                    %if the price is below upperbound1 but it either
                    %breached lvldn or lvlup
                    %breach lvldn?
                    if ~isnan(lvldn) && refs.range2min < lvldn && pxuse > lvldn && pxuse > lowerbound1
%                         fprintf('B with ss %2d:breach up lvldn\n',ss(end));
                        signals{i,1} = 1;
                    end
                    %breach lvlup?
                    if ~isnan(lvlup) && refs.range2min < lvlup && pxuse > lvlup && pxuse > lowerbound1
%                         fprintf('B with ss %2d:breach up lvlup\n',ss(end));
                        signals{i,1} = 1;
                    end
                end
                
            elseif isempty(upperbound1) && ~isempty(upperbound2)
                %very rare case due to data coverage is not sufficient
                if p(end,5) > upperbound2 && upperbound2 > lowerbound2
%                     fprintf('B with ss %2d:rare case\n',ss(k));
                    signals{i,1} = 1;
                end
            else
                %open conditions are not satisfied at the turning point
                if upperbound1 < lowerbound1
                    %in case upperbound1 and lowerbound1 crossed before
                    %this time point, we will use upperbound2 instead but
                    %we would also make sure that upperbound2 is not
                    %crossed with lowerbound2
                    if pxuse > upperbound2 && upperbound2 > lowerbound2 && ss(end)>1
%                         fprintf('B with ss %2d\n',ss(end));
                        signals{i,1} = 1;
                    end
                else
                    %if upperbound1 and lowerbound1 is not crossed, we need
                    %to make sure that price is above upperbound1 and 
                    if pxuse > upperbound1 && pxuse > min(lowerbound2,upperbound2) && ss(end)>1
%                         fprintf('B with ss %2d\n',ss(end));
                        signals{i,1} = 1;
                    end
                end
            end
        elseif checkdirection == -1
            if isempty(lowerbound1) && isempty(lowerbound2)
                %no signal
                return
            elseif ~isempty(lowerbound1) && isempty(lowerbound2)
                %at the turning point
                %if the upperbound1 and lowerbound1 crossed before the MACD
                %turning point, we will not use upperbound1 here as we
                %believe it is not valid anymore
                if upperbound1 < lowerbound1, continue;end
                
                if puse < lowerbound1
                    %breach lvldn?
                    if ~isnan(lvldn) && refs.range2max > lvldn && pxuse < lvldn && pxuse < upperbound1
%                         fprintf('S with bs %2d:breach down lvldn\n',bs(end));
                        signals{i,1} = -1;
                    end
                    %breach lvlup?
                    if ~isnan(lvlup) && refs.range2max > lvlup && pxuse < lvlup && pxuse < upperbound1
%                         fprintf('S with bs %2d:breach down lvlup\n',bs(end));
                        signals{i,1} = -1;
                    end
                    %after a full sell-setup and there is no buy-setup
                    %between
                    lastss = find(ss >= 9,1,'last');
                    lastbs = find(bs >= 9,1,'last');
                    if isempty(lastss), lastss = -1;end
                    if isempty(lastbs), lastbs = -1;end
                    if lastss > lastbs && k - lastss <= 2
%                         fprintf('S with bs %2d:td sellsetup\n',bs(end));
                        signals{i,1} = -1;
                    end
                    %otherwise we meed to make sure bs is greater than 1
                    if bs(end) > 1
%                         fprintf('S with bs %2d\n',bs(end));
                        signals{i,1} = -1;
                    end
                else
                    %breach lvldn?
                    if ~isnan(lvldn) && refs.range2max > lvldn && pxuse < lvldn && pxuse < upperbound1
%                         fprintf('S with bs %2d:breach down lvldn\n',bs(end));
                        signals{i,1} = -1;
                    end
                    %breach lvlup?
                    if ~isnan(lvlup) && refs.range2max > lvlup && pxuse < lvlup && pxuse < upperbound1
%                         fprintf('S with bs %2d:breach down lvlup\n',bs(end));
                        signals{i,1} = -1;
                    end
                end
            elseif isempty(lowerbound1) && ~isempty(lowerbound2)
                %very rare case due to data coverage is not sufficient
                if p(end,5) < lowerbound2 && lowerbound2 < upperbound2
%                     fprintf('S with bs %2d:rare case\n',bs(end));
                    signals{i,1} = -1;
                end
            else
                if upperbound1 < lowerbound1
                    %in case upperbound1 and lowerbound1 crossed before
                    %this time point, we will use lowerbound2 instead but
                    %we would also make sure that upperbound2 is not
                    %crossed with lowerbound2
                    if pxuse < lowerbound2 && lowerbound2 < upperbound2 && bs(end)>1
%                         fprintf('S with bs %2d\n',bs(end));
                        signals{i,1} = -1;
                    end
                else
                    %if upperbound1 and lowerbound1 is not crossed, we meed
                    %to make sure that price is below lowerbound1 and
                    if pxuse < lowerbound1 && p(end,5) < max(lowerbound2,upperbound2) && bs(end)>1
%                         fprintf('S with bs %2d\n',bs(end));
                        signals{i,1} = -1;
                    end
                end
            end
        end
        
       %
        fprintf('\n%s->tdsq info:\n',strategy.name_);
        if i == 1
            fprintf('%10s%11s%10s%8s%8s%10s%10s%10s%10s\n',...
                'contract','time','px','bs','ss','levelup','leveldn','diff','buy/sell');
        end
        timet = datestr(tick(1),'HH:MM:SS');

        dataformat = '%10s%11s%10s%8s%8s%10s%10s%10.3f%10d\n';
        fprintf(dataformat,instruments{i}.code_ctp,...
            timet,...
            num2str(p(end,5)),...
            num2str(bs(end)),num2str(ss(end)),num2str(levelup(end)),num2str(leveldn(end)),...
            macdvec(end)-sigvec(end),...
            signals{i,1});
        
        %%
        strategy.signals_{i,1} = signals{i,1};
        strategy.signals_{i,2} = signals{i,2};
    end
    
    

end