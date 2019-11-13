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
    iparser.addParameter('Frequency','15m',@ischar);
    iparser.addParameter('DoReverse',false,@ischar);
    iparser.parse(varargin{:});
    riskmode = iparser.Results.RiskMode;
    freq = iparser.Results.Frequency;
    doreverse = iparser.Results.DoReverse;
    
    if ~(strcmpi(riskmode,'macd-setup') || strcmpi(riskmode,'macd'))
        error('invalid risk mode input')
    end
    
    usesetups = strcmpi(riskmode,'macd-setup');
    
    variablenotused(sns);
    variablenotused(bc);
    
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
    buffer = 2*instrument.tick_size;
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
            risklvl = [];
            if p(i,5) > lvlup(i)+buffer
                %we use the low prices of the previous 9 bars including
                %the most recent bar to determine whether the market
                %was traded below the lvlup
                wasbelowlvlup = ~isempty(find(p(i-8:i,4) < lvlup(i),1,'first'));
                if wasbelowlvlup && diffvec(i)>0 && ss(i) > 0 && sc(i) ~= 13 && macdss(i)>0
                    lastidxsc13 = find(sc(1:i) == 13,1,'last');
                    if isempty(lastidxsc13)
                        openlongflag = true;
                    else
                        if i - lastidxsc13 > 11
                            openlongflag = true;
                        else
                            %has macd been nagative
                            openlongflag = ~isempty(find(diffvec(lastidxsc13:i) < 0,1,'last'));
                        end
                    end
                    if openlongflag
                        openlongflag = tdsq_validbuy1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
                    end
                else
                    openlongflag = false;
                end
                
                openshortflag = false;
                if ~openlongflag && diffvec(i)<0 && doreverse
                    refs = macdenhanced(i,p(1:i,:),diffvec(1:i));
                    threshold = refs.range2max - refs.range2maxbarsize;
                    if p(i,5) < threshold
                        openshortflag = tdsq_validsell1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
                        risklvl = refs.range2max;
                    end
                end   
                
                if openlongflag
                    count = count + 1;
                    scenname = sns{i};
                    trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                        'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                    info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                        'scenarioname',scenname,'mode','trend','type','single-lvlup','lvlup',lvlup(i),'lvldn',-9.99,'risklvl',risklvl);
                    trade_new.setsignalinfo('name','tdsq','extrainfo',info);

                    %riskmanagement below
                    hasperfectss = false;
                    for j = i+1:n
                        if ss(j) == 9
                            high6 = p(j-3,3);
                            high7 = p(j-2,3);
                            high8 = p(j-1,3);
                            high9 = p(j,3);
                            close8 = p(j-1,5);
                            close9 = p(j,5);
                            %unwind the trade if the sellsetup sequential
                            %itself is perfect
                            if (high8 > max(high6,high7) || high9 > max(high6,high7)) && (close9>close8)
                                hasperfectss = true;
                            end
                        end
                        %
%                         %if the price has breached lvldn from the below and
%                         %then bounce back low with high price below the
%                         %lvldn
%                         hasbreachlvldn = ~isempty(find(p(i:j,5) > lvldn(i),1,'first'));
                        %add:special treatment before holiday
                        %unwind before holiday as the market is not
                        %continous anymore
                        unwindbeforeholiday = islastbarbeforeholiday(instrument,freq,p(j,1));
%                         sn_j = sns{j};
%                         tag_j = tdsq_snbd(sn_j);
                        if diffvec(j)<0 || (usesetups && bs(j) >= 4) || ss(j) >= 24|| sc(j) == 13 || ...
                                p(j,3)<lvlup(i) || ...
                                unwindbeforeholiday || ...
                                (hasperfectss && p(j,4) < lvlup(i))
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
                %
                elseif openshortflag
                    count = count + 1;
                    scenname = sns{i};
                    trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                        'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                    info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                        'scenarioname',scenname,'mode','trend','type','single-lvlup','lvlup',lvlup(i),'lvldn',-9.99,'risklvl',risklvl);
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
                        unwindbeforeholiday = islastbarbeforeholiday(instrument,freq,p(j,1));
                        if diffvec(j)>0 || (usesetups && ss(j) >= 4) || bs(j) >= 24|| bc(j) == 13 || ...
                                p(j,3)>risklvl || ...
                                unwindbeforeholiday || ...
                                (hasperfectbs && p(j,3) > lvlup(i))
                                trade_new.closedatetime1_ = p(j,1);
                            if p(j,3)>risklvl
                                if p(j,2)>risklvl
                                    trade_new.closeprice_ = p(j,2);
                                else
                                    trade_new.closeprice_ = risklvl;
                                end
                            else
                                trade_new.closeprice_ = p(j,5);
                            end
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
                %
            %
            elseif p(i,5) < lvlup(i)-buffer
                %we use the high prices of the previous 9 bars including
                %the most recent bar to determine whether the market
                %was traded above the lvlup
                wasabovelvlup = ~isempty(find(p(i-8:i,3) > lvlup(i),1,'first'));
                wasmacdbullish = ~isempty(find(diffvec(i-8:i-1) > 0,1,'first'));
                if (wasabovelvlup||wasmacdbullish ) && diffvec(i)<0 && bs(i)>0 && bc(i) ~= 13 && macdbs(i)>0
                    lastbsidx = find(bs(1:i) == 9,1,'last');
                    low6 = p(lastbsidx-3,4);
                    low7 = p(lastbsidx-2,4);
                    low8 = p(lastbsidx-1,4);
                    low9 = p(lastbsidx,4);
                    close8 = p(lastbsidx-1,5);
                    close9 = p(lastbsidx,5);
                    %check whether buy sequential itself is perfect???
                    %if it is perfect, we'd better not open up a trade
                    %with short position
                    f1 = (low8 < min(low6,low7) || low9 < min(low6,low7)) && close9 < close8;
                    if ~f1 || (f1&&i-lastbsidx>24)
                        lastidxbc13 = find(bc(1:i) == 13,1,'last');
                        if isempty(lastidxbc13)
                            openshortflag = true;
                        else
                            if i - lastidxbc13 > 11
                                openshortflag = true;
                            else
                                %has macd been positive
                                openshortflag = ~isempty(find(diffvec(lastidxbc13:i) > 0,1,'last'));
                            end
                        end
                        if openshortflag
                            openshortflag = tdsq_validsell1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
                        end
                    else
                        openshortflag = false;
                    end
                else
                    openshortflag = false;
                end
                openlongflag = false;
                if ~openshortflag && doreverse
                    if diffvec(i) > 0
                        refs = macdenhanced(i,p(1:i,:),diffvec(1:i));
                        threshold = refs.range2min+refs.range2minbarsize;
                        if p(i,5)>threshold
                            openlongflag = tdsq_validbuy1(p(1:i,:),bs(1:i),ss(1:i),lvlup(1:i),lvldn(1:i),macdvec(1:i),sigvec(1:i));
                            risklvl = refs.range2min;
                        end
                    else
                        if bs(i) >= 24
                            refs = macdenhanced(i,p(1:i,:),diffvec(1:i));
                            risklvl = refs.range3min-refs.range3minbarsize;
                            openlongflag = true;
                        end
                    end
                end
                    
                if openshortflag
                    count = count + 1;
                    trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                        'opendatetime',p(i,1),'opendirection',-1,'openvolume',1,'openprice',p(i,5));
                    info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                        'scenarioname','','mode','trend','type','single-lvlup','lvlup',lvlup(i),'lvldn',lvldn(i),'risklvl',risklvl);
                    trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                    %riskmanagement below
                    for j = i+1:n
                        sn_j = sns{j};
                        tag_j = tdsq_snbd(sn_j);
                        
                        isperfectbs_j = strcmpi(tag_j,'perfectbs');
                        if isperfectbs_j
                            %check whether perfectss is still valid
                            ibs_j = find(bs(1:j) == 9,1,'last');
                            truelow_j = min(p(ibs_j-8:ibs_j,4));
                            idxtruelow_j = find(p(ibs_j-8:ibs_j,4) == truelow_j,1,'first');
                            idxtruelow_j = idxtruelow_j + ibs_j - 9;
                            truelowbarsize_j = p(idxtruelow_j,4) - truelow_j;
                            stoploss_j = truelow_j - truelowbarsize_j;
                            if ~isempty(find(p(ibs_j+1:j,5) < stoploss_j,1,'first'))
                                isperfectbs_j = false;
                            end
                        end
                        %add:special treatment before holiday
                        %unwind before holiday as the market is not
                        %continous anymore
                        unwindbeforeholiday = islastbarbeforeholiday(instrument,freq,p(j,1));
                        if diffvec(j)>0 || (usesetups && ss(j) >= 4) || bs(j) >= 24 || isperfectbs_j || bc(j) == 13 || ...
                                unwindbeforeholiday || p(j,4) > lvlup(i)
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
                elseif openlongflag
                    count = count + 1;
                    trade_new = cTradeOpen('id',count,'bookname','tdsq','code',code,...
                        'opendatetime',p(i,1),'opendirection',1,'openvolume',1,'openprice',p(i,5));
                    info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                        'scenarioname','','mode','trend','type','single-lvlup','lvlup',lvlup(i),'lvldn',lvldn(i),'risklvl',risklvl);
                    trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                    %riskmanagement below
                    macdbullishonopen = diffvec(i)>0;
                    for j = i+1:n
                        unwindbeforeholiday = islastbarbeforeholiday(instrument,freq,p(j,1));
                        if macdbullishonopen
                            f1 = diffvec(j)<0 || (usesetups && bs(j) >= 4);
                        else
                            if ~isempty(find(diffvec(i:j)>0,1,'first'))
                                f1 = diffvec(j)<0 || (usesetups && bs(j) >= 4);
                            else
                                f1 = false;
                            end
                        end
                        if f1 || ss(j) >= 24|| sc(j) == 13 || ...
                                p(j,4)<risklvl || ...
                                unwindbeforeholiday
                            trade_new.closedatetime1_ = p(j,1);
                            if p(j,4)<risklvl
                                if p(j,2)<risklvl
                                    trade_new.closeprice_ = p(j,2);
                                else
                                    trade_new.closeprice_ = risklvl;
                                end
                            else
                                trade_new.closeprice_ = p(j,5);
                            end
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