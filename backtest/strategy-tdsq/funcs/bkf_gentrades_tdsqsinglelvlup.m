function [ tradesout ] = bkf_gentrades_tdsqsinglelvlup(code,p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,varargin)
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
    
    variablenotused(sns);
    
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
        if ~isnan(lvldn(i)) && isnan(lvlup(i)), i = i+1;end
        %
        %IN CASE ONLY LVLUP IS AVAILABLE
        %UPWARD TREND IF LVLUP IS BREACHED THROUGH FROM BELOW
        if isnan(lvldn(i)) && ~isnan(lvlup(i))
            %open condition1: if price > lvlup
            %open condition2: if macdvec > sigvec
            %open condition3: if ss > 0
            if p(i,5) > lvlup(i)
                wasbelowlvlup = false;
                for j = max(1,i-8):i-1
                    if p(j,5) < lvlup(i)
                        wasbelowlvlup = true;break
                    end
                end
                wasmacdbearish = false;
                for j = max(1,i-8):i-1
                    if macdvec(j)  < sigvec(j)
                        wasmacdbearish = true;break
                    end
                end
                if (wasbelowlvlup || wasmacdbearish) && macdvec(i) > sigvec(i) && ss(i) > 0 && sc(j) ~= 13
                    count = count + 1;
                    scenname = sns{i};
                    trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                        'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                    info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                        'scenarioname',scenname,'mode','follow','lvlup',lvlup(i),'lvldn',-9.99);
                    trade_new.setsignalinfo('name','tdsq','extrainfo',info);

                    for j = i+1:n
                        if macdvec(j) < sigvec(j) || (usesetups && bs(j) >= 4) || sc(j) == 13
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
                else
                    i = i + 1;
                end
            else
                i = i + 1;
            end
        end
        %
        %IN CASE BOTH LVLUP AND LVLDN ARE AVAILABLE
        if ~isnan(lvldn(i)) && ~isnan(lvlup(i)), i = i + 1;end
    
    end
    
    
end