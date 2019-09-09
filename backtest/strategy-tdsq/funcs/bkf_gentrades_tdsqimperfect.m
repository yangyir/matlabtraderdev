function [ tradesout ] = bkf_gentrades_tdsqimperfect(code,p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,varargin)
%inputs: ctp code
%candle prices, i.e. time,open,high,low,close
%buy setups
%sell setups
%lvlup
%lvldn
%buy countdown
%sell countdown
%scenario names
%macd vector
%sigpernine vector
%other optional inputs

    iparser = inputParser;
    iparser.CaseSensitive = false;iparser.KeepUnmatched = true;
    iparser.addParameter('RiskMode','macd-setup',@ischar);
    iparser.addParameter('OpenApproach','old',@ischar);
    iparser.parse(varargin{:});
    riskmode = iparser.Results.RiskMode;
    openapproach = iparser.Results.OpenApproach;
    
    if ~(strcmpi(riskmode,'macd-setup') || strcmpi(riskmode,'macd'))
        error('invalid risk mode input')
    end
    
    usesetups = strcmpi(riskmode,'macd-setup');
    usenewopenapproach = strcmpi(openapproach,'new');
    instrument = code2instrument(code);
    contractsize = instrument.contract_size;
    
    tradesout = cTradeOpenArray;
    n = size(p,1);
    i = 1;
    while i <= n
        sn_i = sns{i};
        tag_i = tdsq_snbd(sn_i);
        if isempty(tag_i)
            i = i+1;
        elseif strcmpi(tag_i,'perfectbs') || strcmpi(tag_i,'perfectss')
            i = i+1;
        elseif strcmpi(tag_i,'semiperfectbs') || strcmpi(tag_i,'imperfectbs')
            openidx = [];
            lastidxbs = find(bs(1:i) == 9,1,'last');
            newlvlup = lvlup(lastidxbs);
            oldlvldn = lvldn(lastidxbs);
            
            isdoublebearish = false;
            issinglebearish = false;
            if isnan(oldlvldn)
                issinglebearish = true;
            else
                isdoublebearish = newlvlup < oldlvldn;                
            end
            isdoublerange = ~(isdoublebearish || issinglebearish);
            
            %use close price to determine whether any of the sequential up
            %to 9 has breached oldlvldn in case of double range
            waspxbelowlvldn = ~isempty(find(p(lastidxbs-8:lastidxbs,5) < oldlvldn,1,'first')) && isdoublerange;
            
            for j = i:n
                sn_j = sns{j};
                tag_j = tdsq_snbd(sn_j);
                if isempty(openidx) && (strcmpi(tag_j,'perfectss') || strcmpi(tag_j,'semiperfectss') || strcmpi(tag_j,'imperfectss') || strcmpi(tag_j,'perfectbs'))
                    break;
                end
                %
                if isempty(openidx) && bs(j) == 9 && j > i
                    break
                end
                %
                if ~usenewopenapproach
                    if macdvec(j) > sigvec(j) && ~(usesetups && (bs(j) >= 4 && bs(j) <= 9))
                        openidx = j;
                        break
                    end
                else
                    f0 = macdvec(j) > sigvec(j) && ~(usesetups && (bs(j) >= 4 && bs(j) <= 9));
                    if isdoublerange
                        if waspxbelowlvldn
                            %the price has breached lvldn but the new lvlup
                            %is still above lvldn
                            f1 = p(j,5) > oldlvldn && ~isempty(find(p(j-8:j-1,5) < oldlvldn,1,'first'));
                            hasbc13inrange = ~isempty(find(bc(j-11:j) == 13,1,'last'));
                            if hasbc13inrange
                                %make sure the 13 is the correct one associated
                                %with the latest sequential
                                bctemp = bc(lastidxbs:j);
                                bcavailable = bctemp(~isnan(bctemp));
                                if length(bcavailable) < 13
                                    hasbc13inrange = false;
                                end
                            end
                            if f0 && (f1 || (~f1 && hasbc13inrange))
                                openidx = j;
                                break
                            end
                        else
                            %the price failed to breach lvldn
                            hasbc13inrange = ~isempty(find(bc(j-11:j) == 13,1,'last'));
                            if hasbc13inrange
                                bctemp = bc(lastidxbs:j);
                                bcavailable = bctemp(~isnan(bctemp));
                                if length(bcavailable) < 13
                                    hasbc13inrange = false;
                                end
                            end
                            if hasbc13inrange && f0
                                openidx = j;
                                break
                            end                   
                        end
                        %
                    elseif isdoublebearish || issinglebearish
                        %double-bearish
                        if f0 && bs(j) >= 9
                            %bs >= 9 but with bullish macd
                            openidx = j;
                            break
                        end
                        %check whether it is 9-13-9 within 12 bars
                        is9139bc = tdsq_is9139buycount(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
                        if f0 && is9139bc && j - lastidxbs <= 12
                            openidx = j;
                            break
                        end
                        breachlvlup = ~isempty(find(p(j-8:j-1,5) < newlvlup,1,'first')) && p(j,5) > newlvlup;
                        if f0 && breachlvlup
                            openidx = j;
                            break
                        end
                    end
                end
            end
            if ~isempty(openidx)
                count = tradesout.latest_;
                count = count + 1;
                trade_new = cTradeOpen('id',count,'code',code,...
                    'opendatetime',p(openidx,1),'opendirection',1,'openvolume',1,'openprice',p(openidx,5));
                info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                    'scenarioname',sns{openidx},'mode','reverse','type',tag_i,...
                    'lvlup',lvlup(openidx),'lvldn',lvldn(openidx));
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                tradesout.push(trade_new);
                for j = openidx+1:n
                    if macdvec(j) < sigvec(j) || (usesetups && bs(j) >= 4),break;end
                    sn_j = sns{j};
                    tag_j = tdsq_snbd(sn_j);
                    if strcmpi(tag_j,'perfectss'), break;end
                    %improvements in riskmanagement
                    if newlvlup > oldlvldn
                        hasbreachedlvlup = ~isempty(find(p(openidx:j,5) > newlvlup,1,'first'));
                        if hasbreachedlvlup && ~isdoublebearish && p(j,5) < newlvlup, break;end
                    else
                        hasbreachedlvldn = ~isempty(find(p(openidx:j,5) > oldlvldn,1,'first'));
                        if hasbreachedlvldn && isdoublebearish && p(j,5) < oldlvldn, break;end
                    end
                end
                if j < n
                    trade_new.closedatetime1_ = p(j,1);
                    trade_new.closeprice_ = p(j,5);
                    trade_new.closepnl_ = (trade_new.closeprice_-trade_new.openprice_)*contractsize;
                    trade_new.status_ = 'closed';
                elseif j == n
                    trade_new.runningpnl_ = (p(j,5)-trade_new.openprice_)*contractsize;
                    trade_new.status_ = 'set';
                    j = j + 1;
                end
                i = j;
            else
                i = i+1;
            end
            %
        elseif strcmpi(tag_i,'semiperfectss') || strcmpi(tag_i,'imperfectss')
            openidx = [];
            lastidxss = find(ss(1:i) == 9,1,'last');
            newlvldn = lvldn(lastidxss);
            oldlvlup = lvlup(lastidxss);
            
            isdoublebullish = false;
            issinglebullish = false;
            if isnan(oldlvlup)
                issinglebullish = true;
            else
                isdoublebullish = newlvldn > oldlvlup;
            end
            isdoublerange = ~(isdoublebullish || issinglebullish);
            
            %use close price to determine whether any of the sequential up
            %to 9 has breached oldlvlup
            waspxabovelvlup = ~isempty(find(p(lastidxss-8:lastidxss,5) > oldlvlup,1,'first')) && isdoublerange;
            
            for j = i:n
                sn_j = sns{j};
                tag_j = tdsq_snbd(sn_j);
                if isempty(openidx) && (strcmpi(tag_j,'perfectbs') || strcmpi(tag_j,'semiperfectbs') || strcmpi(tag_j,'imperfectbs') || strcmpi(tag_j,'perfectss'))
                    break;
                end
                if isempty(openidx) && ss(j) == 9 && j > i
                    break
                end
                if ~usenewopenapproach
                    if macdvec(j) < sigvec(j) && ~(usesetups && ss(j) >= 4 && ss(j) <= 9)
                        openidx = j;
                        break
                    end
                else
                    f0 = macdvec(j) < sigvec(j) && ~(usesetups && ss(j) >= 4 && ss(j) <= 9);
                    %for now just implement a case for double range
                    if isdoublerange
                        if waspxabovelvlup;
                            %the price has breached lvlup but the new lvldn is
                            %still below lvlup
                            f1 = p(j,5) < oldlvlup && ~isempty(find(p(j-8:j-1,5) > oldlvlup,1,'first'));
                            hassc13inrange = ~isempty(find(sc(j-11:j) == 13,1,'last'));
                            if hassc13inrange
                                %make sure the 13 is the correct one associated
                                %with the latest sequential
                                sctemp = sc(lastidxss:j);
                                scavailable = sctemp(~isnan(sctemp));
                                if length(scavailable) < 13
                                    hassc13inrange = false;
                                end
                            end
                        
                            if f0 && (f1 || (~f1 && hassc13inrange))
                                openidx = j;
                                break
                            end
                        else
                            %the price failed to breach lvlup
                            hassc13inrange = ~isempty(find(sc(j-11:j) == 13,1,'last'));
                            if hassc13inrange
                                sctemp = sc(lastidxss:j);
                                scavailable = sctemp(~isnan(sctemp));
                                if length(scavailable) < 13
                                    hassc13inrange = false;
                                end
                            end
                            if hassc13inrange && f0
                                openidx = j;
                                break
                            end
                        end
                    elseif isdoublebullish || issinglebullish
                        %double-bullish
                        if f0 && ss(j) >= 9
                            %ss >= 9 but with bearish macd
                            openidx = j;
                            break
                        end
                        %check whether it is 9-13-9 within 12 bars
                        is9139sc = tdsq_is9139sellcount(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
                        if f0 && is9139sc && j - lastidxss <= 12
                            openidx = j;
                            break
                        end
                        breachlvldn = ~isempty(find(p(j-8:j-1,5) > newlvldn,1,'first')) && p(j,5) < newlvldn;
                        if f0 && breachlvldn
                            openidx = j;
                            break
                        end     
                    end
                end
            end
            if ~isempty(openidx)
                count = tradesout.latest_;
                count = count + 1;
                trade_new = cTradeOpen('id',count,'code',code,...
                    'opendatetime',p(openidx,1),'opendirection',-1,'openvolume',1,'openprice',p(openidx,5));
                info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                    'scenarioname',sns{openidx},'mode','reverse','type',tag_i,...
                    'lvlup',lvlup(openidx),'lvldn',lvldn(openidx));
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                tradesout.push(trade_new);
                for j = openidx+1:n
                    if macdvec(j) > sigvec(j) || (usesetups && ss(j) >= 4),break;end
                    sn_j = sns{j};
                    tag_j = tdsq_snbd(sn_j);
                    if strcmpi(tag_j,'perfectbs'), break;end
                    %improvements in risk management
                    if newlvldn < oldlvlup
                        hasbreachedlvldn = ~isempty(find(p(openidx:j,5) < newlvldn,1,'first'));
                        if hasbreachedlvldn && ~isdoublebullish && p(j,5) > newlvldn, break;end
                    else
                        hasbreachedlvlup = ~isempty(find(p(openidx:j,5) < oldlvlup,1,'first'));
                        if hasbreachedlvlup && isdoublebullish && p(j,5) > oldlvlup, break;end
                    end
                end
                if j < n
                    trade_new.closedatetime1_ = p(j,1);
                    trade_new.closeprice_ = p(j,5);
                    trade_new.closepnl_ = (-trade_new.closeprice_+trade_new.openprice_)*contractsize;
                    trade_new.status_ = 'closed';
                elseif j == n
                    trade_new.runningpnl_ =(-p(j,5)+trade_new.openprice_)*contractsize;
                    trade_new.status_ = 'set';
                    j = j + 1;
                end
                i = j;
            else
                i = i+1;
            end 
        else
            error('unknown tag name')        
        end
    end



end

