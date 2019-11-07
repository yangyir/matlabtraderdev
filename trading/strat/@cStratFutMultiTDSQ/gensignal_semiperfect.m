function [signal] = gensignal_semiperfect(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    signal = {};

    if strcmpi(tag,'semiperfectbs')
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
        hasbc13inrange = tdsq_hasbc13inrange(bs,ss,bc,sc);
        
        %在doublerange的情景下，我们仅在MACD为正的情况(f0 = true)下考虑开仓
        if isdoublerange && f0
            if waspxbelowlvldn
                %the price has breached lvldn but the new lvlup
                %is still above lvldn
                %f1:市场的收盘价又回到了之前lvldn的上方且过去的9个收盘价中有收盘价低于之前的lvldn
                f1 = p(end,5) > oldlvldn && ~isempty(find(p(end-8:end-1,5) < oldlvldn,1,'first'));
                %todo:
                %需要加入距离上次full buysetup的时间距离，如果已经时间过去很久，
                %我们通常认为这次的反转是虚假的信号
                if (f1 || (~f1 && hasbc13inrange ))
                    if f1
                        sn = 'range-reverse';
                        if hasbc13inrange, sn = [sn,'-countdown'];end
                    elseif ~f1 && hasbc13inrange
                        sn = 'range-breachdn-countdown';
                    end
                    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                    signal = struct('name','tdsq',...
                        'instrument',instrument,'frequency',samplefreqstr,...
                        'scenarioname',sn,...
                        'mode','reverse','type',tag,...
                        'lvlup',newlvlup,'lvldn',oldlvldn,'risklvl',-9.99);
                    return
                end
            else
                %the price failed to breach lvldn
                if hasbc13inrange
                    sn = 'range-countdown';
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
            breachlvlup = ~isempty(find(p(end-8:end-1,5) < newlvlup,1,'first')) && p(end,5) > newlvlup;
            %todo:
            %需要加入距离上次full buysetup的时间距离，如果已经时间过去很久，
            %我们通常认为这次的穿越是虚假的信号
            if breachlvlup
                sn = 'range-breachup';
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
            if is9139bc && length(bs) - lastidxbs <= 12
                sn = 'range-9139';
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',newlvlup,'lvldn',oldlvldn,'risklvl',-9.99);
                return
            end
            %
        elseif (isdoublebearish || issinglebearish) && f0
            %bs >= 9 with bullish macd
            if bs(end) >= 9
                sn = 'trend-setup';
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
            if is9139bc && length(bs) - lastidxbs <= 12
                sn = 'trend-9139';
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
            %todo:
            %我们需要考虑trend breach是否在semiperfect/imperfect scenario中
            if f0 && breachlvlup
                sn = 'trend-breach';
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
    if strcmpi(tag,'semiperfectss')
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
        hassc13inrange = tdsq_hassc13inrange(bs,ss,bc,sc);
        
        if isdoublerange && f0
            if waspxabovelvlup
                %the price has breached lvlup but the new lvldn is
                %still below lvlup
                %f1:市场的收盘价又回到了之前lvlup的下方且过去的9个收盘价中有收盘价高于之前的lvlup
                f1 = p(end,5) < oldlvlup && ~isempty(find(p(end-8:end-1,5) > oldlvlup,1,'first'));
                %todo:
                %需要加入距离上次full sellsetup的时间距离，如果已经时间过去很久，
                %我们通常认为这次的反转是虚假的信号
                
                if (f1 || (~f1 && hassc13inrange ))
                    if f1
                        sn = 'range-reverse';
                        if hassc13inrange, sn = [sn,'-countdown'];end
                    elseif ~f1 && hassc13inrange
                        sn = 'range-breachup-countdown';
                    end
                    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                    signal = struct('name','tdsq',...
                        'instrument',instrument,'frequency',samplefreqstr,...
                        'scenarioname',sn,...
                        'mode','reverse','type',tag,...
                        'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                    return
                end
            else
                %the price failed to breach lvlup 
                if hassc13inrange
                    sn = 'range-countdown';
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
            breachlvldn = ~isempty(find(p(end-8:end-1,5) > newlvldn,1,'first')) && p(end,5) < newlvldn;
            %todo:
            %需要加入距离上次full sellsetup的时间距离，如果已经时间过去很久，
            %我们通常认为这次的穿越是虚假的信号
            if breachlvldn
                sn = 'range-breachdn';
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                return
            end
            %
            is9139sc = tdsq_is9139sellcount(bs,ss,bc,sc);
            if is9139sc && length(ss) - lastidxss <= 12
                sn = 'range-9139';
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname',sn,...
                    'mode','reverse','type',tag,...
                    'lvlup',oldlvlup,'lvldn',newlvldn,'risklvl',-9.99);
                return
            end
            %
        elseif (isdoublebullish || issinglebullish) && f0
            %ss >= 9 with bearish macd
            if ss(end) >= 9
                sn = 'trend-setup';
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
            if is9139sc && length(ss) - lastidxss <= 12
                sn = 'trend-setup';
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
            %todo:
            %我们需要考虑trend breach是否在semiperfect/imperfect scenario中
            if f0 && breachlvldn
                sn = 'trend-breach';
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