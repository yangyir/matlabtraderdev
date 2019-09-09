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
        if isdoublerange
            if waspxbelowlvldn
                %the price has breached lvldn but the new lvlup
                %is still above lvldn
                f1 = p(end,5) > oldlvldn && ~isempty(find(p(end-8:end-1,5) < oldlvldn,1,'first'));
                hasbc13inrange = ~isempty(find(bc(end-11:end) == 13,1,'last'));
                if hasbc13inrange
                    %make sure the 13 is the correct one associated with
                    %the latest sequential
                    bctemp = bc(lastidxbs:end);
                    bcavailable = bctemp(~isnan(bctemp));
                    if length(bcavailable) < 13, hasbc13inrange = false;end
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
                    bctemp = bc(lastidxbs:end);
                    bcavailable = bctemp(~isnan(bctemp));
                    if length(bcavailable) < 13, hasbc13inrange = false;end
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
%         if macdvec(end) > sigvec(end) || bs(end) >= 24
%             samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
%             signal = struct('name','tdsq',...
%                 'instrument',instrument,'frequency',samplefreqstr,...
%                 'scenarioname',tag,...
%                 'mode','reverse','type',tag,...
%                 'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99);
%         end
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
        if isdoublerange
            if waspxabovelvlup
                %the price has breached lvlup but the new lvldn is
                %still below lvlup
                f1 = p(end,5) < oldlvlup && ~isempty(find(p(end-8:end-1,5) > oldlvlup,1,'first'));
                hassc13inrange = ~isempty(find(sc(end-11:end) == 13,1,'last'));
                if hassc13inrange
                    %make sure the 13 is the correct one associated with
                    %the latest sequential
                    sctemp = sc(lastidxss:end);
                    scavailable = sctemp(~isnan(sctemp));
                    if length(scavailable) < 13, hassc13inrange = false;end
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
                    %make sure the 13 is the correct one associated with
                    %the latest sequential
                    sctemp = sc(lastidxss:end);
                    scavailable = sctemp(~isnan(sctemp));
                    if length(scavailable) < 13, hassc13inrange = false;end
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
%         if macdvec(end) < sigvec(end) || ss(end) >= 24
%             samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
%             signal = struct('name','tdsq',...
%                 'instrument',instrument,'frequency',samplefreqstr,...
%                 'scenarioname',tag,...
%                 'mode','reverse','type',tag,...
%                 'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99);
%         end
        return
    end
end