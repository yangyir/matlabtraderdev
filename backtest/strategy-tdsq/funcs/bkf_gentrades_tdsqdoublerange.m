function [ tradesout ] = bkf_gentrades_tdsqdoublerange(code,p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,varargin)
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
    
    instrument = code2instrument(code);
    contractsize = instrument.contract_size;
    
    tradesout = cTradeOpenArray;
    n = size(p,1);
    i = 1;
    count = 0;
    while i <= n
        %DO NOTHING IF BOTH LVLUP AND LVLDN ARE NOT AVAILABLE
        if isnan(lvldn(i)) && isnan(lvlup(i)), i = i + 1;end
        %
        %IN CASE ONLY LVLDN IS AVAILABLE
        %DOWNWARD TREND IF LVLDN IS BREACHED FROM ABOVE
        if ~isnan(lvldn(i)) && isnan(lvlup(i)), i = i + 1;end
        %
        %IN CASE ONLY LVLUP IS AVAILABLE
        %UPWARD TREND IF LVLUP IS BREACHED THROUGH FROM BELOW
        if isnan(lvldn(i)) && ~isnan(lvlup(i)), i = i + 1;end
        %
        %IN CASE BOTH LVLUP AND LVLDN ARE AVAILABLE
        if ~isnan(lvldn(i)) && ~isnan(lvlup(i))
            sn_i = sns{i};
            tag_i = tdsq_snbd(sn_i);
            %IDENTIFY WHETHER PEFECT IS STILL VALID,I.E.STOPLOSS IS BREACHED OR
            isperfectbs = strcmpi(tag_i,'perfectbs');
            isperfectss = strcmpi(tag_i,'perfectss');
            
            if isperfectbs
                ibs = find(bs(1:i) == 9,1,'last');
                truelow = min(p(ibs-8:ibs,4));
                idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
                idxtruelow = idxtruelow + ibs - 9;
                truelowbarsize = p(idxtruelow,3) - truelow;
                stoploss = truelow - truelowbarsize;
                if ~isempty(find(p(ibs+1:i,5) < stoploss,1,'first'))
                    isperfectbs = false;
                end
            end
            
            if isperfectss
                iss = find(ss(1:i) == 9,1,'last');
                truehigh = max(p(iss-8:iss,3));
                idxtruehigh = find(p(iss-8:iss,3) == truehigh,1,'first');
                idxtruehigh = idxtruehigh + iss - 9;
                truehighbarsize = truehigh - p(idxtruehigh,4);
                stoploss = truehigh + truehighbarsize;
                if ~isempty(find(p(iss+1:i,5) > stoploss,1,'first'))
                    isperfectss = false;
                end
            end
        
            %In case the most recent lvlup is greater than lvldn, i.e. the
            %highest price of the most recent bs is higher than the lowest
            %price of the most recent ss
            if lvlup(i) > lvldn(i)
                %note:yangyiran:20190904
                %we use the close price of the bar to determine the
                %momentum
                isabove = p(i,5) > lvlup(i);
                isbelow = p(i,5) < lvldn(i);
                isbetween = p(i,5) <= lvlup(i) && p(i,5) >= lvldn(i);
                
                hassc13inrange = ~isempty(find(sc(i-11:i) == 13,1,'first'));
                hasbc13inrange = ~isempty(find(bc(i-11:i) == 13,1,'first'));
            
                if isbetween
                    %check whether it was above the lvlup
                    %note:yangyiran 20190904
                    %we use the high prices of the previous 9 bars including
                    %the most recent bar to determine whether the market
                    %was traded above the lvlup
                    wasabovelvlup = ~isempty(find(p(i-8:i,3) > lvlup(i),1,'first')); 
                    
                    %or check whether it was below the lvldn
                    %note:yangyiran 20190904
                    %we use the low prices of the previous 9 bars including
                    %the most recent bar to determine whether the market
                    %was traded below the lvldn
                    wasbelowlvldn = ~isempty(find(p(i-8:i,4) < lvldn(i),1,'first'));
                                        
                    if wasabovelvlup && wasbelowlvldn
                        fprintf('interesting case here and further check pls')
                    end
                    %
                    if wasabovelvlup && macdvec(i)<sigvec(i) && bs(i)>0 && ~isperfectbs && ~hasbc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        %risk management below
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            
                            isperfectbs_j = strcmpi(tag_j,'perfectbs');
                            if isperfectbs_j
                                %check whether perfectbs is still valid
                                ibs_j = find(bs(1:j) == 9,1,'last');
                                truelow_j = min(p(ibs_j-8:ibs_j,4));
                                idxtruelow_j = find(p(ibs_j-8:ibs_j,4) == truelow_j,1,'first');
                                idxtruelow_j = idxtruelow_j + ibs_j - 9;
                                truelowbarsize_j = p(idxtruelow_j,3) - truelow_j;
                                stoploss_j = truelow_j - truelowbarsize_j;
                                if ~isempty(find(p(ibs_j+1:j,5) < stoploss_j,1,'first'))
                                    isperfectbs_j = false;
                                end
                            end
                            %use the close price to determine the momentum
                            hasbreachlvldn = ~isempty(find(p(i+1:j,5) < lvldn(i),1,'first'));
                            %if the price has breached lvldn from the top
                            %and then bounce high back with low above lvldn
                            if macdvec(j)>sigvec(j) || (usesetups && ss(j)>=4) || bc(j)==13 || isperfectbs_j || (hasbreachlvldn && p(j,4)>lvldn(i))
                                trade_new.closedatetime1_ = p(j,1);
                                trade_new.closeprice_ = p(j,5);
                                trade_new.closepnl_ = trade_new.opendirection_*(trade_new.closeprice_-trade_new.openprice_)*contractsize;
                                trade_new.status_ = 'closed';
                                i = j-1;
                                break
                            end
                            if j == n
                                trade_new.runningpnl_ = trade_new.opendirection_*(p(j,5)-trade_new.openprice_)*contractsize;
                                trade_new.status_ = 'set';
                                i = n;
                            end
                        end
                        tradesout.push(trade_new);
                    end
                    %
                    %
                    if wasbelowlvldn && macdvec(i)>sigvec(i) && ss(i)>0 && ~isperfectss && ~hassc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        %risk management below
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            
                            isperfectss_j = strcmpi(tag_j,'perfectss');
                            if isperfectss_j
                                %check whether perfectss is still valid
                                iss_j = find(ss(1:j) == 9,1,'last');
                                truehigh_j = max(p(iss_j-8:iss_j,3));
                                idxtruehigh_j = find(p(iss_j-8:iss_j,3) == truehigh_j,1,'first');
                                idxtruehigh_j = idxtruehigh_j + iss_j - 9;
                                truehighbarsize_j = truehigh_j - p(idxtruehigh_j,4);
                                stoploss_j = truehigh_j + truehighbarsize_j;
                                if ~isempty(find(p(iss_j+1:j,5) > stoploss_j,1,'first'))
                                    isperfectss_j = false;
                                end
                            end
                            %use the close price to determine the momentum
                            hasbreachlvlup = ~isempty(find(p(i+1:j,5) > lvlup(i),1,'first'));
                            %if the price has breached lvlup from the top
                            %and then bounce low back with high below lvlup
                            if macdvec(j)<sigvec(j) || (usesetups && bs(j)>=4) || sc(j)==13 || isperfectss_j || (hasbreachlvlup && p(j,3)<lvlup(i))
                                trade_new.closedatetime1_ = p(j,1);
                                trade_new.closeprice_ = p(j,5);
                                trade_new.closepnl_ = trade_new.opendirection_*(trade_new.closeprice_-trade_new.openprice_)*contractsize;
                                trade_new.status_ = 'closed';
                                i = j-1;
                                break
                            end
                            if j == n
                                trade_new.runningpnl_ = trade_new.opendirection_*(p(j,5)-trade_new.openprice_)*contractsize;
                                trade_new.status_ = 'set';
                                i = n;
                            end
                        end
                        tradesout.push(trade_new);
                    end
                    %  
                elseif isabove
                    %note:yangyiran 20190904
                    %we use the low prices of the previous 9 bars including
                    %the most recent bar to determine whether the market
                    %was traded below the lvlup
                    wasbelowlvlup = ~isempty(find(p(i-8:i,4) < lvlup(i),1,'first'));
                    diffvec = macdvec - sigvec;
                    wasmacdbearish = ~isempty(find(diffvec(i-8:i-1) < 0,1,'first'));
                    if (wasbelowlvlup || wasmacdbearish ) && diffvec(i)>0 && (ss(i)>0 && ss(i)<9) && ~isperfectss && ~hassc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        %riskmanagement below
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            
                            isperfectss_j = strcmpi(tag_j,'perfectss');
                            if isperfectss_j
                                %check whether perfectss is still valid
                                iss_j = find(ss(1:j) == 9,1,'last');
                                truehigh_j = max(p(iss_j-8:iss_j,3));
                                idxtruehigh_j = find(p(iss_j-8:iss_j,3) == truehigh_j,1,'first');
                                idxtruehigh_j = idxtruehigh_j + iss_j - 9;
                                truehighbarsize_j = truehigh_j - p(idxtruehigh_j,4);
                                stoploss_j = truehigh_j + truehighbarsize_j;
                                if ~isempty(find(p(iss_j+1:j,5) > stoploss_j,1,'first'))
                                    isperfectss_j = false;
                                end
                            end
                            
                            if diffvec(j)<0 || (usesetups && bs(j) >= 4) || sc(j) == 13 || isperfectss_j
                                trade_new.closedatetime1_ = p(j,1);
                                trade_new.closeprice_ = p(j,5);
                                trade_new.closepnl_ = trade_new.opendirection_*(trade_new.closeprice_-trade_new.openprice_)*contractsize;
                                trade_new.status_ = 'closed';
                                i = j-1;
                                break
                            end
                            if j == n
                                trade_new.runningpnl_ = trade_new.opendirection_*(p(j,5)-trade_new.openprice_)*contractsize;
                                trade_new.status_ = 'set';
                                i = n;
                            end
                        end
                        tradesout.push(trade_new);
                    end
                %
                elseif isbelow
                    %note:yangyiran 20190904
                    %we use the high prices of the previous 9 bars including
                    %the most recent bar to determine whether the market
                    %was traded above the lvldn
                    wasabovelvldn = ~isempty(find(p(i-8:i,3) > lvldn(i),1,'first'));
                    diffvec = macdvec - sigvec;
                    wasmacdbullish = ~isempty(find(diffvec(i-8:i-1) > 0,1,'first'));
                    
                    if (wasabovelvldn || wasmacdbullish) && diffvec(i)<0 && (bs(i) > 0 && bs(i) < 9)&& ~isperfectbs && ~hasbc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        %riskmanagement below
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            
                            isperfectbs_j = strcmpi(tag_j,'perfectbs');
                            if isperfectbs_j
                                ibs_j = find(bs(1:j) == 9,1,'last');
                                truelow_j = min(p(ibs_j-8:ibs_j,4));
                                idxtruelow_j = find(p(ibs_j-8:ibs_j,4) == truelow_j,1,'first');
                                idxtruelow_j = idxtruelow_j + ibs_j - 9;
                                truelowbarsize_j = p(idxtruelow_j,3) - truelow_j;
                                stoploss_j = truelow_j - truelowbarsize_j;
                                if ~isempty(find(p(ibs_j+1:j,5) < stoploss_j,1,'first'))
                                    isperfectbs_j = false;
                                end
                            end
                            
                            if diffvec(j)>0 || (usesetups && ss(j) >= 4) || bc(j) == 13 || isperfectbs_j
                                trade_new.closedatetime1_ = p(j,1);
                                trade_new.closeprice_ = p(j,5);
                                trade_new.closepnl_ = trade_new.opendirection_*(trade_new.closeprice_-trade_new.openprice_)*contractsize;
                                i = j-1;
                                break
                            end
                            if j == n
                                trade_new.runningpnl_ = trade_new.opendirection_*(p(j,5)-trade_new.openprice_)*contractsizer;
                                trade_new.status_ = 'set';
                                i = n;
                            end
                        end
                        tradesout.push(trade_new);
                    end        
                end
                %
                %
            elseif lvlup(i) < lvldn(i)
                i = i + 1;
            end
            i = i + 1;
        end 
    end
    
end