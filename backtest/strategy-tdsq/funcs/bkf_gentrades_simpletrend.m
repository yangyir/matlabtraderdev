function [ tradesout ] = bkf_gentrades_simpletrend(code,p,bs,ss,lvlup,lvldn,bc,sc,sns,macdvec,sigvec,varargin)
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
    variablenotused(lvlup);
    variablenotused(lvldn);
    
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
    variablenotused(bc);
    
    instrument = code2instrument(code);
    contractsize = instrument.contract_size;
    
    tradesout = cTradeOpenArray;
    n = size(p,1);
    i = 1;
    count = 0;
    
    diffvec = macdvec - sigvec;
    [macdbs,macdss] = tdsq_setup(diffvec);
        
    while i <= n   
        %Conditions for LONG
        %1.in the start period of developing a TD Sell Setup, i.e. ss between 0
        %and 4
        %2.MACD just turn bullish
        %3.open candle bar is positive, i.e. close price is greater than or
        %equal to the open price
%         if isnan(lvlup(i)) && isnan(lvldn(i)), i=i+1;continue;end
        
        if ss(i) > 0 && diffvec(i) > 0 && diffvec(i-1) < 0 && p(i,5) >= p(i,2) && macdss(i) > 0
            validbuy = tdsq_validbuy1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
            if validbuy
                count = count + 1;
    %             scenname = sns{i};
                trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                    'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                    'scenarioname','','mode','trend');
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                for j = i+1:n
                    if diffvec(j) < 0 || (usesetups && bs(j) >= 3) || ss(j) >= 24 || sc(j) >= 12
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
                if i == n, i = i+1;end
            else
                i=i+1;
            end
            %
        %Conditions for SHORT
        %1.in the start period of developing a TD Buy Setup, i.e. bs between 0
        %and 4
        %2.MACD just turn bearish
        %3.open candle bar is negative, i.e. close price is less than or
        %equal to the open price
        elseif bs(i) > 0 && diffvec(i) < 0 && diffvec(i-1) > 0 && p(i,5) <= p(i,2) && macdbs(i) > 0
            validsell = tdsq_validsell1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
            if validsell 
                count = count + 1;
    %             scenname = sns{i};
                trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                    'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                info = struct('name','tdsq','instrument',instrument,'frequency','15m',...
                    'scenarioname','','mode','trend');
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                for j = i+1:n
                    if diffvec(j) > 0 || (usesetups && ss(j) >= 3) || bs(j) >= 24 || bc(j) >= 12
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
                if i == n, i = i+1;end
            else
                i=i+1;
            end
        else
            i = i + 1;
        end
    end
    
    
end