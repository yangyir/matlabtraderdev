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
    
    variablenotused(bc);
    variablenotused(sc);
    
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
            for j = i:n
                sn_j = sns{j};
                tag_j = tdsq_snbd(sn_j);
                if isempty(openidx) && (strcmpi(tag_j,'perfectss') || strcmpi(tag_j,'semiperfectss') || strcmpi(tag_j,'imperfectss') || strcmpi(tag_j,'perfectbs'))
                    break;
                end
                if ~usenewopenapproach
                    if macdvec(j) > sigvec(j) && ~(usesetups && (bs(j) >= 4 && bs(j) <= 9))
                        openidx = j;
                        break
                    end
                else
                    %not implemented
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
        elseif strcmpi(tag_i,'semiperfectss') || strcmpi(tag_i,'imperfectss')
            openidx = [];
            lastidxss = find(ss(1:j) == 9,1,'last');
            newlvldn = lvldn(lastidxss);
            oldlvldn = lvldn(lastidxss-1);
            oldlvlup = lvlup(lastidxss);
            %use close price to determine whether any of the sequential up
            %to 9 has breached oldlvlup
            waspxabovelvlup = ~isempty(find(p(lastidxss-8:lastidxss,5) > oldlvlup,1,'first'));
            isdoublebullish = false;
            if newlvldn > oldlvlup
                %double-bullish
                isdoublebullish = true;
            else
                %double range

            end
            
            
            for j = i:n
                sn_j = sns{j};
                tag_j = tdsq_snbd(sn_j);
                if isempty(openidx) && (strcmpi(tag_j,'perfectbs') || strcmpi(tag_j,'semiperfectbs') || strcmpi(tag_j,'imperfectbs') || strcmpi(tag_j,'perfectss'))
                    break;
                end
                if ~usenewopenapproach
                    if macdvec(j) < sigvec(j) && ~(usesetups && ss(j) >= 4 && ss(j) <= 9)
                        openidx = j;
                        break
                    end
                else
                    %for now just implement a case for double range
                    f0 = macdvec(j) < sigvec(j) && ~(usesetups && ss(j) >= 4 && ss(j) <= 9);
                    f1 = ~isdoublebullish;
                    if waspxabovelvlup;
                        %the price has breached lvlup but the new lvldn is
                        %still below lvlup
                        f2 = p(j,5) < oldlvlup;
                        %TODO: must find the correct 13 associated with the
                        %lastest sequential, SERIOUSLY
                        hassc13inrange = ~isempty(find(sc(j-11:j) == 13,1,'last'));
                        if f0 && f1 && (f2 || (~f2 && hassc13inrange))
                            openidx = j;
                            break
                        end
                    else
                        %the price failed to breach lvlup
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

