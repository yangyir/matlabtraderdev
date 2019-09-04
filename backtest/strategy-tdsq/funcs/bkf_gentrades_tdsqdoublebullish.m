function [ tradesout ] = bkf_gentrades_tdsqdoublebullish(code,p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,varargin)
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
    diffvec = macdvec - sigvec;
    
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
        
        %IN CASE BOTH LVLUP AND LVLDN ARE AVAILABLE
        if ~isnan(lvldn(i)) && ~isnan(lvlup(i))
            if lvlup(i) < lvldn(i)
                idxlastbs = find(bs(1:i) == 9,1,'last');
                idxlastss = find(ss(1:i) == 9,1,'last');
                if idxlastbs < idxlastss
                    %bullish momentum
                    isabovelvldn = p(i,5) > lvldn(i);
                    wasbelowlvldn = ~isempty(find(p(i-8:i,4) < lvldn(i),1,'first'));
                    wasmacdbearish = ~isempty(find(diffvec(i-8:i-1) < 0,1,'first'));
%                     hassc13inrange = ~isempty(find(sc(i-11:i) == 13,1,'first'));
                    if isabovelvldn && (wasbelowlvldn||wasmacdbearish ) && diffvec(i)>0 && ss(i)>0 && sc(i) ~= 13
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                            'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                            'scenarioname','','mode','follow','lvlup',lvlup(i),'lvldn',lvldn(i));
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
                            
                            if diffvec(j)<0 || (usesetups && bs(j) >= 4) || ss(j) >= 24 || isperfectss_j
                                trade_new.closedatetime1_ = p(j,1);
                                trade_new.closeprice_ = p(j,5);
                                trade_new.closepnl_ = trade_new.opendirection_*(trade_new.closeprice_-trade_new.openprice_)*contractsize;
                                trade_new.status_ = 'closed';
                                i = j;
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
                    i = i + 1;
                else
                    %bearish momentum do nothing
                    i = i + 1;
                end
            else
                i = i + 1;
            end
        end
        
    end
    
    
end