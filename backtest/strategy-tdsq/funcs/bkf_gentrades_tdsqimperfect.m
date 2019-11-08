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
    iparser.addParameter('CloseOnPerfect',true,@islogical);
    iparser.addParameter('RangeBreachLimit',-1,@isnumeric);
    iparser.addParameter('RangeReverseLimit',-1,@isnumeric);
    iparser.addParameter('UseTrendBreach',true,@islogical);
    iparser.addParameter('UseSetupScenario',true,@islogical);
    iparser.addParameter('Frequency','15m',@ischar);
    iparser.parse(varargin{:});
    riskmode = iparser.Results.RiskMode;
    closeonperfect = iparser.Results.CloseOnPerfect;
    rangebreachlimit = iparser.Results.RangeBreachLimit;
    rangereverselimit = iparser.Results.RangeReverseLimit;
    usetrendbreach = iparser.Results.UseTrendBreach;
    usesetupscenario = iparser.Results.UseSetupScenario;
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
    
    diffvec = macdvec - sigvec;
    [macdbs,macdss] = tdsq_setup(diffvec);
    
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
            opensn = '';
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
            bsbreachdnlvldn = ~isempty(find(p(lastidxbs-8:lastidxbs,5) < oldlvldn,1,'first')) && isdoublerange;
            
            for j = i:n
                %note:beforehand we only use 9 bars to check whether the
                %price has fallen below oldlvldn or not. however, the
                %buysetup sequential doesn't necessary stop at 9, so we
                %shall use the buysetup sequential developed so far to
                %determine whether it has fallen below the oldlvldn or not
                sn_j = sns{j};
                [tag_j,count_j] = tdsq_snbd(sn_j);
                if ~bsbreachdnlvldn && count_j > 9
                    bsbreachdnlvldn = ~isempty(find(p(lastidxbs-8:lastidxbs+count_j-9,5) < oldlvldn,1,'first')) && isdoublerange;
                end
                
                if isempty(openidx) && (strcmpi(tag_j,'perfectss') || strcmpi(tag_j,'semiperfectss') || strcmpi(tag_j,'imperfectss') || strcmpi(tag_j,'perfectbs'))
                    break;
                end
                %
                if isempty(openidx) && bs(j) == 9 && j > i
                    break
                end
                %
                hasbc13inrange = tdsq_hasbc13inrange(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
                %
                f0 = macdvec(j) > sigvec(j) && ~(usesetups && (bs(j) >= 4 && bs(j) <= 9));
                if isdoublerange
                    if bsbreachdnlvldn
                        %the price has breached lvldn but the new lvlup
                        %is still above lvldn
                        f1 = p(j,5) > oldlvldn && ~isempty(find(p(j-8:j-1,5) < oldlvldn,1,'first'));
                        if f1 && rangereverselimit >= 0
                            idx2check = find(bs(lastidxbs+1:j) == 0,1,'first');
                            if ~isempty(idx2check)
                                idx2check = idx2check +lastidxbs-1;
                            else
                                idx2check = j;
                            end
                            if j - idx2check > rangereverselimit
                                f1 = false;
                            end
                        end
                        
%                         if f0 && (f1 || hasbc13inrange) && macdss(j) > 0
                        if f0 && (f1 || hasbc13inrange)
                            validbuy = tdsq_validbuy1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                            if validbuy
                                openidx = j;
                                if f1 && ~hasbc13inrange
                                    opensn = 'range-reverse';
                                elseif ~f1 && hasbc13inrange
                                    opensn = 'range-breachdn-countdown';
                                elseif f1 && hasbc13inrange
                                    opensn = 'range-reverse-countdown';
                                end
                                break
                            end
                        end
                    else
                        %the price failed to breach lvldn
%                         if hasbc13inrange && f0 && macdss(j) > 0
                        if hasbc13inrange && f0    
                            validbuy = tdsq_validbuy1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                            if validbuy
                                openidx = j;
                                opensn = 'range-countdown';
                                break
                            end
                        end
                    end
                    %
                    breachlvlup = ~isempty(find(p(j-8:j-1,5) < newlvlup,1,'first')) && p(j,5) > newlvlup;
                    if breachlvlup && rangebreachlimit >= 0
                        idx2check = find(bs(lastidxbs:j) == 0,1,'first');
                        if ~isempty(idx2check)
                            idx2check = idx2check+lastidxbs-1;
                        else
                            idx2check = j;
                        end
                        if j - idx2check > rangebreachlimit
                            breachlvlup = false;
                        end
                    end
%                     if f0 && breachlvlup && macdss(j) > 0
                    if f0 && breachlvlup
                        validbuy = tdsq_validbuy1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validbuy
                            openidx = j;
                            opensn = 'range-breachup';
                            break
                        end
                    end
                    %
                    is9139bc = tdsq_is9139buycount(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
%                     if f0 && is9139bc && j - lastidxbs <= 12 && macdss(j) > 0
                    if f0 && is9139bc && j - lastidxbs <= 12
                        validbuy = tdsq_validbuy1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validbuy
                            openidx = j;
                            opensn = 'range-9139';
                            break
                        end
                    end
                    %
                elseif isdoublebearish || issinglebearish
                    %double-bearish
                    if f0 && bs(j) >= 9 && usesetupscenario
                        %bs >= 9 but with bullish macd
                        validbuy = tdsq_validbuy1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validbuy
                            openidx = j;
                            opensn = 'trend-setup';
                            break
                        end
                    end
                    %
                    %check whether it is 9-13-9 within 12 bars
                    is9139bc = tdsq_is9139buycount(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
%                     if f0 && is9139bc && j - lastidxbs <= 12 && macdss(j) > 0
                    if f0 && is9139bc && j - lastidxbs <= 12
                        validbuy = tdsq_validbuy1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validbuy
                            openidx = j;
                            opensn = 'trend-9139';
                            break
                        end
                    end
                    breachlvlup = ~isempty(find(p(j-8:j-1,5) < newlvlup,1,'first')) && p(j,5) > newlvlup;
                    if breachlvlup && rangebreachlimit >= 0
                        idx2check = find(bs(lastidxbs:j) == 0,1,'first');
                        if ~isempty(idx2check)
                            idx2check = idx2check+lastidxbs-1;
                        else
                            idx2check = j;
                        end
                        if j - idx2check > rangebreachlimit
                            breachlvlup = false;
                        end
                    end
                    breachlvlup = breachlvlup && usetrendbreach;
%                     if f0 && breachlvlup && macdss(j) > 0
                    if f0 && breachlvlup && macdss(j) > 0
                        validbuy = tdsq_validbuy1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validbuy
                            openidx = j;
                            if isdoublebearish
                                opensn = 'trend-breach';
                            else
                                opensn = 'trend-breach';
                            end
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
                info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                    'scenarioname',opensn,'mode','reverse','type',tag_i,...
                    'lvlup',lvlup(openidx),'lvldn',lvldn(openidx));
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                tradesout.push(trade_new);
                for j = openidx+1:n
                    if macdvec(j) - sigvec(j) < -5e-4 || (usesetups && bs(j) >= 4),break;end
                    sn_j = sns{j};
                    tag_j = tdsq_snbd(sn_j);
                    if strcmpi(tag_j,'perfectss') && closeonperfect, break;end
                    %improvements in riskmanagement
                    if isdoublerange && bsbreachdnlvldn && f1 && p(j,3) < oldlvldn                        
                        break;
                    end
                    if isdoublerange && ~bsbreachdnlvldn && breachlvlup && p(j,3) < newlvlup
                        break;
                    end
                    if (issinglebearish || isdoublebearish) && breachlvlup && p(j,3) < newlvlup
                        break;
                    end
                    if ~isempty(strfind(opensn,'range-reverse')) && ...
                            ~isempty(find(macdss(openidx:j) == 20,1,'last')) && macdss(j) == 0
                        break
                    end
                    if ~isempty(strfind(opensn,'range-breach')) && ss(j) == 9
                        break
                    end
                    if isdoublerange || issinglebearish
                        hasbreachedlvlup = ~isempty(find(p(openidx:j,5) > newlvlup,1,'first'));
                        if hasbreachedlvlup && p(j,5) - newlvlup <= -4*instrument.tick_size 
                            break;
                        end
                    elseif isdoublebearish
                        hasbreachedlvldn = ~isempty(find(p(openidx:j,5) > oldlvldn,1,'first'));
                        if hasbreachedlvldn && p(j,5) - oldlvldn <= -4*instrument.tick_size 
                            break;
                        end
                    end
                    %special treatment before holiday
                    %unwind before holiday as the market is not continous
                    %anymore
                    lastbar = islastbarbeforeholiday(instrument,freq,p(j,1));
                    if lastbar
                        break
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
            opensn = '';
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
            breachlvldn = false;
            waspxabovelvlup = ~isempty(find(p(lastidxss-8:lastidxss,5) > oldlvlup,1,'first')) && isdoublerange;
            
            for j = i:n
                sn_j = sns{j};
                [tag_j,count_j] = tdsq_snbd(sn_j);
                if ~waspxabovelvlup && count_j > 9
                    waspxabovelvlup = ~isempty(find(p(lastidxss-8:lastidxss+count_j-9,5) > oldlvlup,1,'first')) && isdoublerange;
                end
                if isempty(openidx) && (strcmpi(tag_j,'perfectbs') || strcmpi(tag_j,'semiperfectbs') || strcmpi(tag_j,'imperfectbs') || strcmpi(tag_j,'perfectss'))
                    break;
                end
                if isempty(openidx) && ss(j) == 9 && j > i
                    break
                end
                hassc13inrange = tdsq_hassc13inrange(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
                %
                f0 = macdvec(j) < sigvec(j) && ~(usesetups && ss(j) >= 4 && ss(j) <= 9);
                %for now just implement a case for double range
                if isdoublerange
                    if waspxabovelvlup
                        %the price has breached lvlup but the new lvldn is
                        %still below lvlup
                        f1 = p(j,5) < oldlvlup && ~isempty(find(p(j-8:j-1,5) > oldlvlup,1,'first'));
                        if f1 && rangereverselimit >= 0
                            idx2check = find(ss(lastidxss+1:j) == 0,1,'first');
                            if ~isempty(idx2check)
                                idx2check = idx2check+lastidxss-1;
                            else
                                idx2check = j;
                            end
                            if j - idx2check  > rangereverselimit
                                f1 = false;
                            end
                        end
%                         if f0 && (f1 || hassc13inrange) && macdbs(j) > 0
                        if f0 && (f1 || hassc13inrange)
                            validsell = tdsq_validsell1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                            if validsell
                                openidx = j;
                                if f1 && ~hassc13inrange
                                    opensn = 'range-reverse';
                                elseif ~f1 && hassc13inrange
                                    opensn = 'range-breachup-countdown';
                                elseif f1 && hassc13inrange
                                    opensn = 'range-reverse-countdown';
                                end
                                break
                            end
                        end
                    else
                        %the price failed to breach lvlup
%                         if hassc13inrange && f0 && macdbs(j) > 0
                        if hassc13inrange && f0
                            validsell = tdsq_validsell1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                            if validsell
                                openidx = j;
                                opensn = 'range-countdown';
                                break
                            end
                        end
                    end
                    %
                    breachlvldn = ~isempty(find(p(j-8:j-1,5) > newlvldn,1,'first')) && p(j,5) < newlvldn;
                    if breachlvldn && rangebreachlimit >= 0
                        idx2check = find(ss(lastidxss:j) == 0,1,'first');
                        if ~isempty(idx2check)
                            idx2check = idx2check + lastidxss-1;
                        else
                            idx2check = j;
                        end
                        if j - idx2check  > rangebreachlimit
                            breachlvldn = false;
                        end
                    end
%                     if f0 && breachlvldn && macdbs(j) > 0
                    if f0 && breachlvldn
                        validsell = tdsq_validsell1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validsell
                            openidx = j;
                            opensn = 'range-breach';
                            break
                        end
                    end
                    %check whether it is 9-13-9 within 12 bars
                    is9139sc = tdsq_is9139sellcount(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
%                     if f0 && is9139sc && j - lastidxss <= 12 && macdbs(j) > 0
                    if f0 && is9139sc && j - lastidxss <= 12
                        validsell = tdsq_validsell1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validsell
                            openidx = j;
                            opensn = 'range-9139';
                            break
                        end
                    end
                elseif isdoublebullish || issinglebullish
                    %double-bullish
                    if f0 && ss(j) >= 9 && usesetupscenario
                        %ss >= 9 but with bearish macd
                        validsell = tdsq_validsell1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validsell
                            openidx = j;
                            if isdoublebullish
                                opensn = 'trend-setup';
                            else
                                opensn = 'trend-setup';
                            end
                            break
                        end
                    end
                    %
                    %check whether it is 9-13-9 within 12 bars
                    is9139sc = tdsq_is9139sellcount(bs(1:j),ss(1:j),bc(1:j),sc(1:j));
%                     if f0 && is9139sc && j - lastidxss <= 12 && macdbs(j) > 0
                    if f0 && is9139sc && j - lastidxss <= 12
                        validsell = tdsq_validsell1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validsell
                            openidx = j;
                            if isdoublebullish
                                opensn = 'trend-9139';
                            else
                                opensn = 'trend-9139';
                            end
                            break
                        end
                    end
                    %
                    breachlvldn = ~isempty(find(p(j-8:j-1,5) > newlvldn,1,'first')) && p(j,5) < newlvldn;
                    if breachlvldn && rangebreachlimit >= 0
                        idx2check = find(ss(lastidxss:j) == 0,1,'first');
                        if ~isempty(idx2check)
                            idx2check = idx2check + lastidxss-1;
                        else
                            idx2check = j;
                        end
                        if j - idx2check  > rangebreachlimit
                            breachlvldn = false;
                        end
                    end
                    breachlvldn = usetrendbreach && breachlvldn;
%                     if f0 && breachlvldn && macdbs(j) > 0
                    if f0 && breachlvldn
                        validsell = tdsq_validsell1(p(1:j,:),bs(1:j),ss(1:j),lvlup(1:j),lvldn(1:j),macdvec(1:j),sigvec(1:j));
                        if validsell
                            openidx = j;
                            if isdoublebullish
                                opensn = 'trend-breach';
                            else
                                opensn = 'trend-breach';
                            end
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
                info = struct('name','tdsq','instrument',instrument,'frequency',freq,...
                    'scenarioname',opensn,'mode','reverse','type',tag_i,...
                    'lvlup',lvlup(openidx),'lvldn',lvldn(openidx));
                trade_new.setsignalinfo('name','tdsq','extrainfo',info);
                tradesout.push(trade_new);
                for j = openidx+1:n
                    if macdvec(j) - sigvec(j) > 5e-4 || (usesetups && ss(j) >= 4),break;end
                    sn_j = sns{j};
                    tag_j = tdsq_snbd(sn_j);
                    if strcmpi(tag_j,'perfectbs') && closeonperfect, break;end
                    %improvements in risk management
                    if isdoublerange && waspxabovelvlup && f1 && p(j,4) > oldlvlup
                        break;
                    end
                    if isdoublerange && ~waspxabovelvlup && breachlvldn && p(j,4) > newlvldn
                        break;
                    end
                    if (issinglebullish || isdoublebullish) && breachlvldn && p(j,4) > newlvldn
                        break;
                    end
                    if ~isempty(strfind(opensn,'range-reverse')) && ...
                            ~isempty(find(macdbs(openidx:j) == 20,1,'last')) && macdbs(j) == 0
                        break
                    end
                    if ~isempty(strfind(opensn,'range-breach')) && bs(j) == 9
                        break
                    end
                    if isdoublerange || issinglebullish
                        hasbreachedlvldn = ~isempty(find(p(openidx:j,5) < newlvldn,1,'first'));
                        if hasbreachedlvldn && p(j,5) - newlvldn >= 4*instrument.tick_size, break;end
                    elseif isdoublebullish
                        hasbreachedlvlup = ~isempty(find(p(openidx:j,5) < oldlvlup,1,'first'));
                        if hasbreachedlvlup && p(j,5) - oldlvlup >= 4*instrument.tick_size, break;end
                    end
                    %special treatment before holiday
                    %unwind before holiday as the market is not continous
                    %anymore
                    lastbar = islastbarbeforeholiday(instrument,freq,p(j,1));
                    if lastbar
                        break
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

