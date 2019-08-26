function [ tradesout ] = bkf_gentrades_tdsqperfect(code,p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,varargin)
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
    iparser.parse(varargin{:});
    riskmode = iparser.Results.RiskMode;
    
    if ~(strcmpi(riskmode,'macd-setup') || strcmpi(riskmode,'macd'))
        error('invalid risk mode input')
    end
    
    usesetups = strcmpi(riskmode,'macd-setup');
        
    variablenotused(bc);
    variablenotused(sc);
    
    instrument = code2instrument(code);
    contractsize = instrument.contract_size;

    % mode1: tdsq-reverse-perfectbs/ss
    % using variables: bs,ss,macd,sig,p


    tradesout = cTradeOpenArray;
    n = size(p,1);
    i = 1;
    while i <= n
        sn_i = sns{i};
        tag_i = tdsq_snbd(sn_i);
    
        if isempty(tag_i)
            i = i+1;
        elseif strcmpi(tag_i,'semiperfectbs') || strcmpi(tag_i,'semiperfectss') ||...
                strcmpi(tag_i,'imperfectbs') || strcmpi(tag_i,'imperfectss')     
            i = i+1;
    
        elseif strcmpi(tag_i,'perfectbs')
            ibs = find(bs(1:i) == 9,1,'last');
            %note:the stoploss shall be calculated using the perfect 9 bars
            truelow = min(p(ibs-8:ibs,4));
            idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
            idxtruelow = idxtruelow + ibs - 9;
            truelowbarsize = p(idxtruelow,3) - truelow;
            stoploss = truelow - truelowbarsize;
        
            stillvalid = true;
            haslvlupbreachedwithmacdbearishafterwards = false;
            if i > ibs
                if stillvalid
                    stillvalid = isempty(find(p(ibs:i,5) < stoploss,1,'first'));   
                end
                %
                if stillvalid
                    if p(i,5) < lvldn(ibs), stillvalid = false;end
                end
                %
                if stillvalid
                    if p(i,5) < truelow, stillvalid = false;end
                end
                %
                if stillvalid && usesetups
                    if bs(i) >= 4 && bs(i) < 9, stillvalid = false;end
                end
                %
                if stillvalid
                    ibreach = find(p(ibs:i,5) < lvlup(ibs),1,'first');
                    if ~isempty(ibreach)
                        %lvlup has been breached
                        ibreach = ibreach + ibs-1;
                        diffvec = macdvec(ibreach:i-1)-sigvec(ibreach:i-1);
                        if ~isempty(find(diffvec < 0,1,'first'))
                            %macd has turned negative
                            haslvlupbreachedwithmacdbearishafterwards = true;
                        end
                    end
                    %
                end
            end
        
            if ~stillvalid
                i = i + 1;
            else
                count = tradesout.latest_;
                count = count + 1;
                volume = 1;
                if haslvlupbreachedwithmacdbearishafterwards
                    risklvl = p(i,5) - (p(ibs,5) - stoploss);
                else
                    risklvl = stoploss;
                end
                trade_new = cTradeOpen('id',count,'code',code,...
                    'opendatetime',p(i,1),'opendirection',1,'openvolume',volume,'openprice',p(i,5));
                info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                    'scenarioname',sn_i,'mode','reverse','risklvl',risklvl);
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                tradesout.push(trade_new);

                %risk management for perfect bs
                %1. (close) price breached down the true low minus the true range
                %of that bar
                %2. any ss sceanrio afterwards when macd turns bearish
                %3. any breach of lvlup afterwards when macd turns bearish
                %4. intraday upper-limit
                breachlvlup = p(i,5) > lvlup(i);
                if breachlvlup, breachidx = i;end
                for j = i+1:n
                    %case 1
                    if p(j,5) < risklvl;break;end
                    sn_j = sns{j};
                    tag_j = tdsq_snbd(sn_j);
                    %case 2
                    if ~isempty(strfind(tag_j,'ss')) && (macdvec(j) < sigvec(j) || (usesetups && bs(j) >= 4));break;end
                    %case 3
                    if ~breachlvlup && p(j,5) > lvlup(i), breachlvlup = true;breachidx = j;end
                    if breachlvlup
                        wasmacdbullish = false;
                        for k = breachidx:j
                            if macdvec(k) > sigvec(k)
                                wasmacdbullish = true;
                                break
                            end
                        end
                        if wasmacdbullish && (macdvec(j) < sigvec(j) || (usesetups && bs(j) >= 4));break;end
                    end
                    %case 4
                    if bs(j) == 0 && ss(j) == 0 && p(j,2) == p(j,3) && p(j,2) == p(j,4) && p(j,2) == p(j,5);break;end
                end
                %
                if j < n
                    trade_new.closedatetime1_ = p(j,1);
                    trade_new.closeprice_ = p(j,5);
                    trade_new.closepnl_ = (trade_new.closeprice_-trade_new.openprice_)*trade_new.openvolume_*contractsize;
                    trade_new.status_ = 'closed';
                elseif j >= n
                    trade_new.runningpnl_ = (p(j,5)-trade_new.openprice_)*trade_new.openvolume_*contractsize;
                end
                i = j+1;
            end
        elseif strcmpi(tag_i,'perfectss')
            iss = find(ss(1:i) == 9,1,'last');
            %note:the stoploss shall be calculated using the perfect 9 bars
            truehigh = max(p(iss-8:iss,3));
            idxtruehigh = find(p(iss-8:iss,3) == truehigh,1,'first');
            idxtruehigh = idxtruehigh + iss - 9;
            truehighbarsize = truehigh - p(idxtruehigh,4);
            stoploss = truehigh + truehighbarsize;
        
            %further check whether perfectss is still valid
            %1. whether lvldn is breached and was macd turned bullish after
            %breaching lvldn
            stillvalid = true;
            haslvldnbreachedwithmacdbullishhafterwards = false;
            if i > iss
                if stillvalid
                    stillvalid = isempty(find(p(iss:i,5) > stoploss,1,'first'));   
                end
                %
                if stillvalid
                    if p(i,5) > lvlup(iss), stillvalid = false;end
                end
                %
                if stillvalid
                    if p(i,5) > truehigh, stillvalid = false;end
                end
                %
                if stillvalid && usesetups
                    if ss(i) >= 4 && ss(i) < 9, stillvalid = false;end
                end
                %
                if stillvalid
                    ibreach = find(p(iss:i,5) < lvldn(iss),1,'first');
                    if ~isempty(ibreach)
                        %lvlup has been breached
                        ibreach = ibreach + iss-1;
                        diffvec = macdvec(ibreach:i-1)-sigvec(ibreach:i-1);
                        if ~isempty(find(diffvec > 0,1,'first'))
                            %macd has turned bullish
                            haslvldnbreachedwithmacdbullishhafterwards = true;
                        end
                    end
                    %
                end
            end
        
            if ~stillvalid
                i = i + 1;
            else
                count = tradesout.latest_;
                count = count + 1;
                volume = 1;
            
                if haslvldnbreachedwithmacdbullishhafterwards
                    risklvl = p(i,5) + (stoploss- p(iss,5));
                else
                    risklvl = stoploss;
                end
                trade_new = cTradeOpen('id',count,'code',code,...
                    'opendatetime',p(i,1),'opendirection',-1,'openvolume',volume,'openprice',p(i,5));
                info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                    'scenarioname',sn_i,'mode','reverse','risklvl',risklvl);
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                tradesout.push(trade_new);
            
                %risk management for perfect ss
                %1. (close) price breached up the true high plus the true range
                %of that bar
                %2. any bs scenario afterwards when macd turns bullish
                %3, any breach of lvldn afterwards when macd turns bullish
                %4. intraday lower-limit
                breachlvldn = p(i,5) < lvldn(i);
                if breachlvldn, breachidx = i;end
                
                for j = i+1:n
                    %case 1
                    if p(j,5) > risklvl,break;end
                    sn_j = sns{j};
                    tag_j = tdsq_snbd(sn_j);
                    %case 2
                    if ~isempty(strfind(tag_j,'bs')) && (macdvec(j) > sigvec(j) || (usesetups && ss(j) >= 4)),break;end
                    %case 3
                    if ~breachlvldn && p(j,5) < lvldn(j), breachlvldn = true;breachidx = j;end
                    if breachlvldn
                        wasmacdbearish = false;
                        for k = breachidx:j
                            if macdvec(k) < sigvec(k)
                                wasmacdbearish = true;
                                break
                            end
                        end
                        if wasmacdbearish && (macdvec(j) > sigvec(j) || (usesetups && ss(j) >= 4)),break;end
                    end
                    %case 4
                    if bs(j) == 0 && ss(j) == 0 && p(j,2) == p(j,3) && p(j,2) == p(j,4) && p(j,2) == p(j,5);break;end
                end
                if j < n
                    trade_new.closedatetime1_ = p(j,1);
                    trade_new.closeprice_ = p(j,5);
                    trade_new.closepnl_ = (-trade_new.closeprice_+trade_new.openprice_)*trade_new.openvolume_*contractsize;
                    trade_new.status_ = 'closed';
                elseif j >= n
                    trade_new.runningpnl_ = (-p(j,5)+trade_new.openprice_)*trade_new.openvolume_*contractsize;
                end
                i = j+1;
            end
        else
            error('unknown tag name')        
        end
    end


end

