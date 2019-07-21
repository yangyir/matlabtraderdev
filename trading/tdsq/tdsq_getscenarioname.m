function scenarioname = tdsq_getscenarioname(bs,ss,lvlup,lvldn,bc,sc,p)
%inputs:
%bs:TD Buy Setup
%ss:TD Sell Setup
%lvlup: TDST Level Up
%lvldn: TDST Level Down
%bc:TD Buy Countdown
%sc:TD Sell Countdown
%p:candle prices,i.e. [time,open,high,low,close]
    
    %first to check whether the latest finished TD Setup is a Buy or Sell
    %Setup
    idxbs = find(bs == 9);
    idxss = find(ss == 9);
    
    if isempty(idxbs) && isempty(idxss)
        scenarioname = 'blank';
        return
    elseif isempty(idxbs) && ~isempty(idxss)
        scenarioname = 'ssonly';
    elseif ~isempty(idxbs) && isempty(idxss)
        scenarioname = 'bsonly';
    elseif ~isempty(idxbs) && ~isempty(idxss)
        if idxbs(end) > idxss(end)
            scenarioname = 'bslast';
        else
            scenarioname = 'sslast';
        end 
    end
    
    if strcmpi(scenarioname,'ssonly')
        lastidxss = idxss(end);
        high6 = p(lastidxss-3,3);
        high7 = p(lastidxss-2,3);
        high8 = p(lastidxss-1,3);
        high9 = p(lastidxss,3);
        close8 = p(lastidxss-1,5);
        close9 = p(lastidxss,5);
        if high8 > max(high6,high7) || high9 > max(high6,high7)
            if close9 > close8
                tag = 'perfectss';
            else
                tag = 'semiperfectss';
            end
        else
            tag = 'imperfectss';
        end
        if length(idxss) == 1
            scenarioname = [scenarioname,'-1-',tag];
        elseif length(idxss) >= 2
            %check whether there is a TD Sell Countdown 13 finished in
            %between 2 TD Sell Setup
            lastss1 = idxss(end);
            lastss2 = idxss(end-1);
            lastsc = find(sc==13,1,'last');
            if isempty(lastsc)
                %there is no TD Sell Countdown finished at all
                
            else
            end
            
            
        end
        
        return
    end
    
    if strcmpi(scenarioname,'bsonly')
        lastidxbs = idxbs(end);
        low6 = p(lastidxbs-3,4);
        low7 = p(lastidxbs-2,4);
        low8 = p(lastidxbs-1,4);
        low9 = p(lastidxbs,4);
        close8 = p(lastidxbs-1,5);
        close9 = p(lastidxbs,5);
        if low8 < min(low6,low7) || low9 < min(low6,low7)
            if close9 < close8
                tag = 'perfectbs';
            else
                tag = 'semiperfectbs';
            end
        else
            tag = 'imperfectbs';
        end

        if length(idxbs) == 1
            %Note:there is only ONE TD Buy Setup in advance
            scenarioname = [scenarioname,'-1-',tag];
        elseif length(idxbs) >= 2
            %Note:there are more than ONE TD Buy Setup in advance
            lastidxbs2 = idxbs(end-1);
            %check the prior TD Buy Setup's true range
            lastidxbs2_start = lastidxbs2 - 8;
            %be aware that the prior TD Buy Setup does not necessarily stop
            %at 9
            lastidxbs2_end = lastidxbs2;
            for i = lastidxbs2_end+1:lastidxbs-9
                if bs(i) == 0
                    break
                end
                lastidxbs2_end = i;
            end
            priorrangehigh = max(p(lastidxbs2_start:lastidxbs2_end,3));
            priorrangelow = min(p(lastidxbs2_start:lastidxbs2_end,4));
            %check the current TD Buy Setup's true range
            lastidxbs_start = lastidxbs - 8;
            lastidxbs_end = lastidxbs;
            for i = 1:lastidxbs_end+1:size(bs,1)
                if bs(i) == 0
                    break
                end
                lastidxbs_end = i;
            end
            recentrangehigh = max(p(lastidxbs_start:lastidxbs_end,3));
            recentrangelow = min(p(lastidxbs_start:lastidxbs_end,4));
            
            if priorrangehigh > recentrangehigh && priorrangelow < recentrangelow
                withinprior = true;
            else
                withinprior = false;
            end
                
            lastidxbc = find(bc==13,1,'last');
            if isempty(lastidxbc)
                %Note:there is no completion of a TD Buy Countdown between
                if withinprior
                    scenarioname = [scenarioname,'-',num2str(length(idxbs)),'-',tag,'-withinprior'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(idxbs)),'-',tag];
                end
            else
                %Note:there is at least one completion of a TD Buy Countdown between
                %check most recent TD Buy Setup begin after the completed
                %TD Buy Countdown
                condition1 = lastidxbs_start > lastidxbc(end) && lastidxbc(end) > lastidxbs2_end;
                condition2 = ~isempty(find(ss(lastidxbc(end)+1:lastidxbs - 9) == 1, 1));
                if condition1 && condition2 && withinprior
                    scenarioname = [scenarioname,'-',num2str(length(idxbs)),'-',tag,'-9139'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(idxbs)),'-',tag];
                end
            end
        end
        return
    end
    
    if strcmpi(scenarioname,'bslast')
        lastssidx = idxss(end);
        subidxbs = idxbs > lastssidx;%the most recent buy setups after the most recent sell setup
        subidxbs = idxbs(subidxbs);
        lastidxbs = subidxbs(end);
        low6 = p(lastidxbs-3,4);
        low7 = p(lastidxbs-2,4);
        low8 = p(lastidxbs-1,4);
        low9 = p(lastidxbs,4);
        close8 = p(lastidxbs-1,5);
        close9 = p(lastidxbs,5);
        %here also need to check whether any bar within the TD Sell Setup
        %has closed below TDST Leveldn
        closedbelow = false;
        for i = lastidxbs-8:lastidxbs
            if p(i,5) < lvldn(i)
                closedbelow = true;
                break
            end
        end             
        if low8 < min(low6,low7) || low9 < min(low6,low7) && ~closedbelow
            if close9 < close8
                tag = 'perfectbs';
            else
                tag = 'semiperfectbs';
            end
        else
            tag = 'imperfectbs';
        end
        if length(subidxbs) == 1
            %the most recent is a TD Buy Setup, with a prior TD Sell Setup
            scenarioname = [scenarioname,'-1-',tag];
        elseif length(subidxbs) >= 2
            %the most recent 2 (or more than 2) are TD Buy Setup
            lastidxbs2 = subidxbs(end-1);
            %check the prior TD Buy Setup's true range
            lastidxbs2_start = lastidxbs2 - 8;
            %be aware that the prior TD Sell Setup does not necessarily stop
            %at 9
            lastidxbs2_end = lastidxbs2;
            for i = lastidxbs2_end+1:lastidxbs-9
                if ss(i) == 0
                    break
                end
                lastidxbs2_end = i;
            end
            priorrangehigh = max(p(lastidxbs2_start:lastidxbs2_end,3));
            priorrangelow = min(p(lastidxbs2_start:lastidxbs2_end,4));
            %check the current TD Buy Setup's true range
            lastidxbs_start = lastidxbs - 8;
            lastidxbs_end = lastidxbs;
            for i = 1:lastidxbs_end+1:size(bs,1)
                if bs(i) == 0
                    break
                end
                lastidxbs_end = i;
            end
            recentrangehigh = max(p(lastidxbs_start:lastidxbs_end,3));
            recentrangelow = min(p(lastidxbs_start:lastidxbs_end,4));
            
            if priorrangehigh > recentrangehigh && priorrangelow < recentrangelow
                withinprior = true;
            else
                withinprior = false;
            end
            
            lastidxbc = find(bc==13,1,'last');
            if isempty(lastidxbc)
                %Note:there is no completion of a TD Buy Countdown between
                if withinprior
                    scenarioname = [scenarioname,'-',num2str(length(subidxbs)),'-',tag,'-withinprior'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(subidxbs)),'-',tag];
                end
            else
                %Note:there is at least one completion of a TD Sell Countdown between
                %check most recent TD Sell Setup begin after the completed
                %TD Sell Countdown
                condition1 = lastidxbs_start > lastidxbc(end) && lastidxbc(end) > lastidxbs2_end;
                condition2 = ~isempty(find(ss(lastidxbc(end)+1:lastidxbs - 9) == 1, 1));
                if condition1 && condition2 && withinprior
                    scenarioname = [scenarioname,'-',num2str(length(subidxbs)),'-',tag,'-9139'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(subidxbs)),'-',tag];
                end
            end
        end
        
        
        return
    end
    
    if strcmpi(scenarioname,'sslast')
        lastbsidx = idxbs(end);
        subidxss = idxss > lastbsidx;%the most recent sell setups after the most recent buy setup
        subidxss = idxss(subidxss);
        lastidxss = subidxss(end);
        high6 = p(lastidxss-3,3);
        high7 = p(lastidxss-2,3);
        high8 = p(lastidxss-1,3);
        high9 = p(lastidxss,3);
        close8 = p(lastidxss-1,5);
        close9 = p(lastidxss,5);
        %here also need to check whether any bar within the TD Sell Setup
        %has closed above TDST Levelup
        closedabove = false;
        for i = lastidxss-8:lastidxss
            if p(i,5) > lvlup(i)
                closedabove = true;
                break
            end
        end        
        if (high8 > max(high6,high7) || high9 > max(high6,high7)) && ~closedabove
            if close9 > close8
                tag = 'perfectss';
            else
                tag = 'semiperfectss';
            end
        else
            tag = 'imperfectss';
        end
        if length(subidxss) == 1
            %the most recent is a TD Sell Setup, with a prior TD Buy Setup
            scenarioname = [scenarioname,'-1-',tag];
        elseif length(subidxss) >= 2
            %the most recent 2 (or more than 2) are TD Sell Setup
            lastidxss2 = subidxss(end-1);
            %check the prior TD Sell Setup's true range
            lastidxss2_start = lastidxss2 - 8;
            %be aware that the prior TD Sell Setup does not necessarily stop
            %at 9
            lastidxss2_end = lastidxss2;
            for i = lastidxss2_end+1:lastidxss-9
                if ss(i) == 0
                    break
                end
                lastidxss2_end = i;
            end
            priorrangehigh = max(p(lastidxss2_start:lastidxss2_end,3));
            priorrangelow = min(p(lastidxss2_start:lastidxss2_end,4));
            %check the current TD Sell Setup's true range
            lastidxss_start = lastidxss - 8;
            lastidxss_end = lastidxss;
            for i = 1:lastidxss_end+1:size(bs,1)
                if ss(i) == 0
                    break
                end
                lastidxss_end = i;
            end
            recentrangehigh = max(p(lastidxss_start:lastidxss_end,3));
            recentrangelow = min(p(lastidxss_start:lastidxss_end,4));
            
            if priorrangehigh > recentrangehigh && priorrangelow < recentrangelow
                withinprior = true;
            else
                withinprior = false;
            end
            
            lastidxsc = find(sc==13,1,'last');
            if isempty(lastidxsc)
                %Note:there is no completion of a TD Sell Countdown between
                if withinprior
                    scenarioname = [scenarioname,'-',num2str(length(subidxss)),'-',tag,'-withinprior'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(subidxss)),'-',tag];
                end
            else
                %Note:there is at least one completion of a TD Sell Countdown between
                %check most recent TD Sell Setup begin after the completed
                %TD Sell Countdown
                condition1 = lastidxss_start > lastidxsc(end) && lastidxsc(end) > lastidxss2_end;
                condition2 = ~isempty(find(ss(lastidxsc(end)+1:lastidxss - 9) == 1, 1));
                if condition1 && condition2 && withinprior
                    scenarioname = [scenarioname,'-',num2str(length(subidxss)),'-',tag,'-9139'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(subidxss)),'-',tag];
                end
            end
                
            
        end
        
        return
    end
    
    
    
    
    
        

end