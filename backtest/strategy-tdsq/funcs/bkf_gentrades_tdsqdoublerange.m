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
        
            %NOTE: TODO:
            %IDENTIFY WHETHER PEFECT IS STILL VALID,I.E.STOPLOSS IS BREACHED OR
            %NOT
            isperfectbs = strcmpi(tag_i,'perfectbs');
            isperfectss = strcmpi(tag_i,'perfectss');
        
            %In case the most recent lvlup is greater than lvldn, i.e. the
            %highest price of the most recent bs is higher than the lowest
            %price of the most recent ss
            if lvlup(i) > lvldn(i)
                
                isabove = p(i,5) > lvlup(i);
                isbelow = p(i,5) < lvldn(i);
                isbetween = p(i,5) <= lvlup(i) && p(i,5) >= lvldn(i);
                
                hassc13inrange = ~isempty(find(sc(i-11:i) == 13,1,'first'));
                hasbc13inrange = ~isempty(find(bc(i-11:i) == 13,1,'first'));
            
                if isbetween
                    %check whether it was above the lvlup
                    wasabovelvlup = ~isempty(find(p(i-8:i-1,5) > lvlup(i),1,'first')); 
                    
                    %or check whether it was below the lvldn
                    wasbelowlvldn = ~isempty(find(p(i-8:i-1,5) < lvldn(i),1,'first'));
                                        
                    if wasabovelvlup && wasbelowlvldn
                        fprintf('interesting case here and further check pls')
                    end
                    %
                    
                    if wasabovelvlup && macdvec(i) < sigvec(i) && bs(i) > 0 && ~isperfectbs && ~hasbc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            if macdvec(j) > sigvec(j) || (usesetups && ss(j) >= 4) || bc(j) == 13 || strcmpi(tag_j,'perfectbs')
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
                    if wasbelowlvldn && macdvec(i) > sigvec(i) && ss(i) > 0 && ~isperfectss && ~hassc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            if macdvec(j) < sigvec(j) || (usesetups && bs(j) >= 4) || sc(j) == 13 || strcmpi(tag_j,'perfectss')
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
                    wasbelowlvlup = ~isempty(find(p(i-8:i-1,5) < lvlup(i),1,'first'));
                    diffvec = macdvec - sigvec;
                    wasmacdbearish = ~isempty(find(diffvec(i-8:i-1) < 0,1,'first'));
                    if (wasbelowlvlup || wasmacdbearish ) && macdvec(i) > sigvec(i) && ss(i) > 0 && ~isperfectss && ~hassc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            if macdvec(j) < sigvec(j) || (usesetups && bs(j) >= 4) || sc(j) == 13 || strcmpi(tag_j,'perfectss')
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
                    wasabovelvldn = ~isempty(find(p(i-8:i-1,5) > lvldn(i),1,'first'));
                    diffvec = macdvec - sigvec;
                    wasmacdbullish = ~isempty(find(diffvec(i-8:i-1) > 0,1,'first'));
                    
                    if (wasabovelvldn || wasmacdbullish) && macdvec(i) < sigvec(i) && bs(i) > 0 && ~isperfectbs && ~hasbc13inrange
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname',sn_i,'mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
                        trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                        for j = i+1:n
                            sn_j = sns{j};
                            tag_j = tdsq_snbd(sn_j);
                            if macdvec(j) > sigvec(j) || (usesetups && ss(j) >= 4) || bc(j) == 13 || strcmpi(tag_j,'perfectbs')
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