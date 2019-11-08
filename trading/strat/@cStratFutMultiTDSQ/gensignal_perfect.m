function [signal] = gensignal_perfect(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    variablenotused(bc);
    variablenotused(sc);
    signal = {};
    riskmode = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmode');
    usesetups = strcmpi(riskmode,'macd-setup');
    
    if strcmpi(tag,'perfectbs')
        ibs = find(bs == 9,1,'last');
        %note:the stoploss shall be calculated using the perfect 9 bars
        truelow = min(p(ibs-8:ibs,4));
        idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
        idxtruelow = idxtruelow + ibs - 9;
        truelowbarsize = p(idxtruelow,3) - truelow;
        stoploss = truelow - truelowbarsize;
        
        np = size(p,1);
        %如果perfectbs是发生在过去的时间点，我们需要检查perfectbs是否依然有效
        if np > ibs
            %1.如果从perfectbs发生的时间点到现在时间点的任何收盘价低于了stoploss
            %则perfectbs变得无效
            stillvalid = isempty(find(p(ibs:end,5)<stoploss,1,'first'));
            %2.如果最新收盘价低于了lvldn在perfectbs时间点的值
            if stillvalid
                if p(end,5) < lvldn(ibs), stillvalid = false;end
            end
            %3.如果最近收盘价低于了truelow
            if stillvalid
                if p(end,5) < truelow, stillvalid = false;end
            end
            %4.如果要用bssetup的值的情况。。。
            if stillvalid && usesetups
                if bs(end) >= 4 && bs(end) < 9, stillvalid = false;end
            end
        else
            stillvalid = true;
        end

        %然后需要检查价格是否有向上突破lvlup,这里取收盘价做为比较决定价格是否有突破
        %如果有突破，我们接着检查从突破到现在是否MACD转负过
        haslvlupbreachedwithmacdbearishafterwards = false;
        if stillvalid
            ibreach = find(p(ibs:end,5) > lvlup(ibs),1,'first');
            if ~isempty(ibreach)
                %lvlup has been breached
                ibreach = ibreach + ibs-1;
                diffvec = macdvec(ibreach:end)-sigvec(ibreach:end);
                haslvlupbreachedwithmacdbearishafterwards = ~isempty(find(diffvec<0,1,'first'));
%                 %用最高价判断是否完全跌回lvlup之下
%                 haslvlupbreachedbutbouncedback = ~isempty(find(p(ibreach:end,3)<lvlup(ibs),1,'first'));
%                 %如果价格回到了lvlup之下，我们认为perfectbs也就无效了
%                 if haslvlupbreachedbutbouncedback
%                     stillvalid = false;
%                 end
%                 %如果此时间点收盘价在lvlup之下，我们认为该时间点无效
%                 if ~haslvlupbreachedbutbouncedback && p(end,5) < lvlup(ibs)
%                     stillvalid = false;
%                 end
            end
        end

        if ~stillvalid
            signal = {};
        else
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            %如果有突破lvlup且macd有转负需要重新计算risklvl
            if haslvlupbreachedwithmacdbearishafterwards
                risklvl = p(end,5) - (p(ibs,5) - stoploss);
            else
                risklvl = stoploss;
            end
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname',tag,...
                'mode','reverse','type','perfectbs',...
                'lvlup',lvlup(ibs),'lvldn',lvldn(ibs),'risklvl',risklvl);
        end
        return
    end
    %
    if strcmpi(tag,'perfectss')
        iss = find(ss == 9,1,'last');
        %note:the stoploss shall be calculated using the perfect 9 bars
        truehigh = max(p(iss-8:iss,3));
        idxtruehigh = find(p(iss-8:iss,3) == truehigh,1,'first');
        idxtruehigh = idxtruehigh + iss - 9;
        truehighbarsize = truehigh - p(idxtruehigh,4);
        stoploss = truehigh + truehighbarsize;
        
        np = size(p,1);
        %如果perfectss是发生在过去的时间点，我们需要检查perfectss是否依然有效
        if np > iss
            %1.如果从perfectss发生的时间点到现在时间点的任何收盘价高于了stoploss
            %则perfectss变得无效
            stillvalid = isempty(find(p(iss:end,5)>stoploss,1,'first'));
            %2.如果最新收盘价高于了lvldn在perfectss时间点的值
            if stillvalid
                if p(end,5) > lvlup(iss), stillvalid = false;end
            end
            %3.如果最近收盘价高于了truehigh
            if stillvalid
                if p(end,5) > truehigh, stillvalid = false;end
            end
            %4.如果要用sssetup的值的情况。。。
            if stillvalid && usesetups
                if ss(end) >= 4 && ss(end) < 9, stillvalid = false;end
            end
            %
        else
            stillvalid = true;
        end
        
        %然后需要检查价格是否有向下突破lvldn,这里取收盘价做为比较决定价格是否有突破
        %如果有突破，我们接着检查从突破到现在是否MACD转正过
        haslvldnbreachedwithmacdbullishafterwards = false;
        if stillvalid
            ibreach = find(p(iss:end,5) < lvldn(iss),1,'first');
            if ~isempty(ibreach)
                %lvldn has been breached
                ibreach = ibreach + iss-1;
                diffvec = macdvec(ibreach:end)-sigvec(ibreach:end);
                haslvldnbreachedwithmacdbullishafterwards = ~isempty(find(diffvec>0,1,'first'));
%                 %用最低价判断是否完全反弹回lvldn之上
%                 haslvldnbreachedbutbouncedback = ~isempty(find(p(ibreach:end,4)>lvldn(iss),1,'first'));
%                 %如果价格回到了lvldn之上，我们认为perfectbs也就无效了
%                 if haslvldnbreachedbutbouncedback
%                     stillvalid = false;
%                 end
%                 %如果此时间点收盘价在lvldn之上，我们认为该时间点无效
%                 if ~haslvldnbreachedbutbouncedback && p(end,5) > lvldn(iss)
%                     stillvalid = false;
%                 end
            end
        end
        
        if ~stillvalid
            signal = {};
        else
            %如果有突破lvldn且macd有转正需要重新计算risklvl
            if haslvldnbreachedwithmacdbullishafterwards
                risklvl = p(end,5) + (stoploss-p(iss,5));
            else
                risklvl = stoploss;
            end
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname',tag,...
                'mode','reverse','type','perfectss',...
                'lvlup',lvlup(iss),'lvldn',lvldn(iss),'risklvl',risklvl);
        end
        return
    end
    

end