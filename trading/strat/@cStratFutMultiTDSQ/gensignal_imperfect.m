function [signal] = gensignal_imperfect(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    signal = {};

    if strcmpi(tag,'imperfectbs')
        lastidxbs = find(bs == 9,1,'last');
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
        waspxbelowlvldn = ~isempty(find(p(lastidxbs-8:lastidxbs,5) < oldlvldn,1,'first')) && isdoublerange;
        f0 = macdvec(end) > sigvec(end);
        if isdoublerange
            if waspxbelowlvldn
                %the price has breached lvldn but the new lvlup
                %is still above lvldn
                f1 = p(end,5) > oldlvldn && ~isempty(find(p(end-8:end-1,5) < oldlvldn,1,'first'));
                hasbc13inrange = ~isempty(find(bc(end-11:end) == 13,1,'last'));
                if hasbc13inrange
                    lastidxbc13 = find(bc == 13,1,'last');
                    if lastidxbc13 < lastidxbs, hasbc13inrange = false;end
                end
                %when a bs that began before,on,or after
                %the developing buycountdown, but prior to
                %a bullish price flip, extends to 18 bars,
                %the buycountdown shall be recycled
                if hasbc13inrange
                    lastidxbs18 = find(bs == 18,1,'last');
                    if ~isempty(lastidxbs18)
                        if  lastidxbc13 <= lastidxbs18
                            hasbc13inrange = false;
                        elseif lastidxbc13 > lastidxbs18
                            %make sure there is no bullish price between
                            hasbc13inrange = ~isempty(find(ss(lastidxbs18+1:lastidxbc13)==1,1,'first'));
                        end
                    end
                end
                
                if f0 && (f1 || (~f1 && hasbc13inrange ))
                    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                    signal = struct('name','tdsq',...
                        'instrument',instrument,'frequency',samplefreqstr,...
                        'scenarioname','doublerange',...
                        'mode','reverse','type',tag,...
                        'lvlup',newlvlup,'lvldn',oldlvldn,'risklvl',-9.99);
                    return
                end
            else
                %the price failed to breach lvldn
                hasbc13inrange = ~isempty(find(bc(end-11:end) == 13,1,'last'));
                if hasbc13inrange
                    lastidxbc13 = find(bc == 13,1,'last');
                    if lastidxbc13 < lastidxbs, hasbc13inrange = false;end
                end
                %when a bs that began before,on,or after
                %the developing buycountdown, but prior to
                %a bullish price flip, extends to 18 bars,
                %the buycountdown shall be recycled
                if hasbc13inrange
                    lastidxbs18 = find(bs == 18,1,'last');
                    if ~isempty(lastidxbs18)
                        if  lastidxbc13 <= lastidxbs18
                            hasbc13inrange = false;
                        elseif lastidxbc13 > lastidxbs18
                            %make sure there is no bullish price between
                            hasbc13inrange = ~isempty(find(ss(lastidxbs18+1:lastidxbc13)==1,1,'first'));
                        end
                    end
                end
                
                if hasbc13inrange && f0
                    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                    signal = struct('name','tdsq',...
                        'instrument',instrument,'frequency',samplefreqstr,...
                        'scenarioname','doublerange',...
                        'mode','reverse','type',tag,...
                        'lvlup',newlvlup,'lvldn',oldlvldn,'risklvl',-9.99);
                    return
                end
            end
        elseif isdoublebearish || issinglebearish            
            if isdoublebearish
                sn = 'doublebearish';
            elseif issinglebearish
                sn = 'singlebearish';
            end
            %
            %bs >= 9 with bullish macd
            if f0 && bs(end) >= 9
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');                
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',newlvlup,'lvldn',oldlvldn,'risklvl',-9.99);
                return
            end
            %
            is9139bc = tdsq_is9139buycount(bs,ss,bc,sc);
            if f0 && is9139bc && length(bs) - lastidxbs <= 12
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',newlvlup,'lvldn',oldlvldn,'risklvl',-9.99);
                return
            end
            %
            breachlvlup = ~isempty(find(p(end-8:end-1,5) < newlvlup,1,'first')) && p(end,5) > newlvlup;
            if f0 && breachlvlup
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',newlvlup,'lvldn',oldlvldn,'risklvl',-9.99);
                return
            end
        end
        %
        return
    end
    %
    if strcmpi(tag,'imperfectss')
        lastidxss = find(ss == 9,1,'last');
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
        waspxabovelvlup = ~isempty(find(p(lastidxss-8:lastidxss,5) > oldlvlup,1,'first')) && isdoublerange;
        f0 = macdvec(end) < sigvec(end);
        if isdoublerange
            if waspxabovelvlup
                %the price has breached lvlup but the new lvldn is
                %still below lvlup
                f1 = p(end,5) < oldlvlup && ~isempty(find(p(end-8:end-1,5) > oldlvlup,1,'first'));
                hassc13inrange = ~isempty(find(sc(end-11:end) == 13,1,'last'));
                if hassc13inrange
                    lastidxsc13 = find(sc == 13,1,'last');
                    if lastidxsc13 < lastidxss, hassc13inrange = false;end
                end
                %when a ss that began before,on,or after
                %the developing sellcountdown, but prior to
                %a bearish price flip, extends to 18 bars,
                %the sellcountdown shall be recycled
                if hassc13inrange
                    lastidxss18 = find(ss == 18,1,'last');
                    if ~isempty(lastidxss18)
                        if  lastidxsc13 <= lastidxss18
                            hassc13inrange = false;
                        elseif lastidxsc13 > lastidxss18
                            %make sure there is no bearish price between
                            hassc13inrange = ~isempty(find(bs(lastidxss18+1:lastidxsc13)==1,1,'first'));
                        end
                    end
                end
                            
                if f0 && (f1 || (~f1 && hassc13inrange ))
                    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                    signal = struct('name','tdsq',...
                        'instrument',instrument,'frequency',samplefreqstr,...
                        'scenarioname','doublerange',...
                        'mode','reverse','type',tag,...
                        'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                    return
                end
            else
                %the price failed to breach lvlup
                hassc13inrange = ~isempty(find(sc(end-11:end) == 13,1,'last'));
                if hassc13inrange
                    lastidxsc13 = find(sc == 13,1,'last');
                    if lastidxsc13 < lastidxss, hassc13inrange = false;end
                end
                %when a ss that began before,on,or after
                %the developing sellcountdown, but prior to
                %a bearish price flip, extends to 18 bars,
                %the sellcountdown shall be recycled
                if hassc13inrange
                    lastidxss18 = find(ss == 18,1,'last');
                    if ~isempty(lastidxss18)
                        if  lastidxsc13 <= lastidxss18
                            hassc13inrange = false;
                        elseif lastidxsc13 > lastidxss18
                            %make sure there is no bearish price between
                            hassc13inrange = ~isempty(find(bs(lastidxss18+1:lastidxsc13)==1,1,'first'));
                        end
                    end
                end
                
                if hassc13inrange && f0
                    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                    signal = struct('name','tdsq',...
                        'instrument',instrument,'frequency',samplefreqstr,...
                        'scenarioname','doublerange',...
                        'mode','reverse','type',tag,...
                        'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                    return
                end
            end
            %
        elseif isdoublebullish || issinglebullish
            if isdoublebullish
                sn = 'doublebullish';
            elseif issinglebullish
                sn = 'singlebullish';
            end
            %
            %bs >= 9 with bearish macd
            if f0 && ss(end) >= 9
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                     'instrument',instrument,'frequency',samplefreqstr,...
                     'scenarioname',sn,...
                     'mode','reverse','type',tag,...
                     'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                 return
            end
            %check whether it is 9-13-9 within 12 bars
            is9139sc = tdsq_is9139sellcount(bs,ss,bc,sc);
            if f0 && is9139sc && length(ss) - lastidxss <= 12
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                return
            end
            %
            breachlvldn = ~isempty(find(p(end-8:end-1,5) > newlvldn,1,'first')) && p(end,5) < newlvldn;
            if f0 && breachlvldn
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                return
            end
        end
        %
        return
    end
end