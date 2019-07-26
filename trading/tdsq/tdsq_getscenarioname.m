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
    
    
    if strcmpi(scenarioname,'bslast') || strcmpi(scenarioname,'bsonly')
        if ~isempty(idxss)
            lastssidx = idxss(end);
            subidxbs = idxbs > lastssidx;%the most recent buy setups after the most recent sell setup
            subidxbs = idxbs(subidxbs);
        else
            subidxbs = idxbs;
        end
        lastidxbs = subidxbs(end);
        
        [tag,recentrangelow,recentrangehigh,lastidxbs_start] = tdsq_lastbs(bs,ss,lvlup,lvldn,bc,sc,p);

        if length(subidxbs) == 1
            %the most recent is a TD Buy Setup, with a prior TD Sell Setup
            scenarioname = [scenarioname,'-1-',tag];
        elseif length(subidxbs) >= 2
            %the most recent 2 (or more than 2) are TD Buy Setup
            [priorrangelow,priorrangehigh,lastidxbs2_start] = tdsq_priorbs(bs,ss,lvlup,lvldn,bc,sc,p);
                       
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
                condition1 = lastidxbs_start > lastidxbc(end) && lastidxbc(end) > lastidxbs2_start+8;
                condition2 = ~isempty(find(ss(lastidxbc(end)+1:lastidxbs - 9) == 1, 1));
                if condition1 && condition2
                    scenarioname = [scenarioname,'-',num2str(length(subidxbs)),'-',tag,'-9139'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(subidxbs)),'-',tag,'-13included'];
                end
            end
        end    
        
        return
    end
    
    if strcmpi(scenarioname,'sslast') || strcmpi(scenarioname,'ssonly')
        if ~isempty(idxbs)
            lastbsidx = idxbs(end);
            subidxss = idxss > lastbsidx;%the most recent sell setups after the most recent buy setup
            subidxss = idxss(subidxss);
        else
            subidxss = idxss;
        end
        lastidxss = subidxss(end);
        
        [tag,recentrangelow,recentrangehigh,lastidxss_start] = tdsq_lastss(bs,ss,lvlup,lvldn,bc,sc,p);
        
        if length(subidxss) == 1
            %the most recent is a TD Sell Setup, with a prior TD Buy Setup
            scenarioname = [scenarioname,'-1-',tag];
        elseif length(subidxss) >= 2
            %the most recent 2 (or more than 2) are TD Sell Setup
            [priorrangelow,priorrangehigh,lastidxbs2_start] = tdsq_priorss(bs,ss,lvlup,lvldn,bc,sc,p);

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
                condition1 = lastidxss_start > lastidxsc(end) && lastidxsc(end) > lastidxbs2_start+8;
                condition2 = ~isempty(find(bs(lastidxsc(end)+1:lastidxss - 9) == 1, 1));
                if condition1 && condition2
                    scenarioname = [scenarioname,'-',num2str(length(subidxss)),'-',tag,'-9139'];
                else
                    scenarioname = [scenarioname,'-',num2str(length(subidxss)),'-',tag,'-13included'];
                end
            end
                
            
        end
        
        return
    end
    
    
    
    
    
        

end