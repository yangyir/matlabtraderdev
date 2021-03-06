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
    iparser.addParameter('UseBuffer',true,@islogical);
    iparser.addParameter('Frequency','15m',@ischar);
    iparser.parse(varargin{:});
    riskmode = iparser.Results.RiskMode;
    usebuffer = iparser.Results.UseBuffer;
    freq = iparser.Results.Frequency;
    
    if ~(strcmpi(riskmode,'macd-setup') || strcmpi(riskmode,'macd'))
        error('invalid risk mode input')
    end
    
    usesetups = strcmpi(riskmode,'macd-setup');
    instrument = code2instrument(code);
    contractsize = instrument.contract_size;
    if ~isempty(strfind(instrument.code_bbg,'TFT')) || ~isempty(strfind(instrument.code_bbg,'TFC'))
        contractsize = contractsize/100;
    end
    
    tradesout = cTradeOpenArray;
    n = size(p,1);
    i = 1;
    count = 0;
    diffvec = macdvec - sigvec;
    [macdbs,macdss] = tdsq_setup(diffvec);
   
    if usebuffer
        buffer = 2*instrument.tick_size;
    else
        buffer = 0;
    end
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
        if ~isnan(lvldn(i)) && ~isnan(lvlup(i)) && lvlup(i) < lvldn(i)
            idxlastbs = find(bs(1:i) == 9,1,'last');
            idxlastss = find(ss(1:i) == 9,1,'last');
            if idxlastbs > idxlastss, i = i+1;continue;end

            %bullish momentum
            if p(i,5) > lvldn(i) + buffer
                %we use the low prices of the previous 9 bars including
                %the most recent bar to determine whether the market
                %was traded below the lvldn
                wasbelowlvldn = ~isempty(find(p(i-8:i,4) < lvldn(i),1,'first'));
                wasmacdbearish = ~isempty(find(diffvec(i-8:i-1) < 0,1,'first'));
                if (wasbelowlvldn||wasmacdbearish ) && diffvec(i)>0 && ss(i)>0 && sc(i) ~= 13 && macdss(i)>0
                    idxlastss = find(ss(1:i) == 9,1,'last');
                    high6 = p(idxlastss-3,3);
                    high7 = p(idxlastss-2,3);
                    high8 = p(idxlastss-1,3);
                    high9 = p(idxlastss,3);
                    close8 = p(idxlastss-1,5);
                    close9 = p(idxlastss,5);
                    %check whether sell sequential itself is perfect???
                    %if it is perfect, we'd better not open up a trade
                    %with long position
                    f1 = (high8 > max(high6,high7) || high9 > max(high6,high7)) && (close9>close8);
                    if ~f1 || (f1 && i-idxlastss>24)
                        lastidxsc13 = find(sc(1:i) == 13,1,'last');
                        if isempty(lastidxsc13)
                            openflag = true;
                        else
                            if i - lastidxsc13 > 11
                                openflag = true;
                            else
                                %has macd been negative
                                openflag = ~isempty(find(diffvec(lastidxsc13:i) < 0,1,'last'));
                            end
                        end
                        if openflag
                            openflag = tdsq_validbuy1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
                        end
                    else
                        openflag = false;
                    end
                    
                    if openflag
                        count = count + 1;
                        trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                        'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                        info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                            'scenarioname','','mode','trend','type','double-bullish','lvlup',lvlup(i),'lvldn',lvldn(i));
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
                            %add:special treatment before holiday
                            %unwind before holiday as the market is not
                            %continous anymore
                            unwindbeforeholiday = islastbarbeforeholiday(instrument,freq,p(j,1));
                            if diffvec(j)<0 || (usesetups && bs(j) >= 4) || ss(j) >= 24 || isperfectss_j || sc(j) == 13 || ...
                                    unwindbeforeholiday || p(j,3) < lvldn(i)
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
                    else
                        %f1 condition not satisfied
                        i = i +1;
                    end
                end
                i = i + 1;
            elseif p(i,5) < lvldn(i) - buffer
                %we use the high prices of the previous 9 bars including
                %the most recent bar to determine whether the market
                %was traded above the lvldn
                wasabovelvldn = ~isempty(find(p(i-8:i,3) > lvldn(i),1,'first'));
                if wasabovelvldn && diffvec(i)<0 && bs(i)>0 && bc(i) ~= 13 && macdbs(i)>0
                    lastidxbc13 = find(bc(1:i) == 13,1,'last');
                    if isempty(lastidxbc13)
                        openflag = true;
                    else
                        if i - lastidxbc13 > 11
                            openflag = true;
                        else
                            %has macd been positive
                            openflag = ~isempty(find(diffvec(lastidxbc13:i) > 0,1,'last'));
                        end
                    end
                    if openflag
                        openflag = tdsq_validsell1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
                    end
                else
                    openflag = false;
                end
                if openflag
                    count = count + 1;
                    trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                        'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                    info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                        'scenarioname','','mode','trend','type','double-bullish','lvlup',lvlup(i),'lvldn',lvldn(i));
                    trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                    %riskmanagement below
                    hasperfectbs = false;
                    for j = i+1:n
                        if bs(j) == 9
                            low6 = p(j-3,4);
                            low7 = p(j-2,4);
                            low8 = p(j-1,4);
                            low9 = p(j,4);
                            close8 = p(j-1,5);
                            close9 = p(j,5);
                            %unwind the trade if the buysetup sequential
                            %itself is perfect
                            if (low8 < min(low6,low7) || low9 < min(low6,low7)) && close9 < close8
                                hasperfectbs = true;
                            end
                        end
                        %
                        %if the price has breached lvlup from the top and
                        %then bounce high with low price above lvlup
                        hasbreachlvlup = ~isempty(find(p(i:j,5) < lvlup(i),1,'first'));
                        %add:special treatment before holiday
                        %unwind before holiday as the market is not
                        %continous anymore
                        unwindbeforeholiday = islastbarbeforeholiday(instrument,freq,p(j,1));
                        if diffvec(j)>0 || (usesetups && ss(j) >= 4) || bs(j) >= 24|| bc(j) == 13 || ...
                                (hasbreachlvlup && p(j,4)>lvlup(i)) || ...
                                unwindbeforeholiday || ...
                                (hasperfectbs) || ...
                                (~hasbreachlvlup && p(j,4)>lvldn(i))
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
                %equal
                i = i + 1;
            end
        else
            i = i + 1;
        end
        
    end
    
    
end