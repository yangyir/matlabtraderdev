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
        %���perfectbs�Ƿ����ڹ�ȥ��ʱ��㣬������Ҫ���perfectbs�Ƿ���Ȼ��Ч
        if np > ibs
            %1.�����perfectbs������ʱ��㵽����ʱ�����κ����̼۵�����stoploss
            %��perfectbs�����Ч
            stillvalid = isempty(find(p(ibs:end,5)<stoploss,1,'first'));
            %2.����������̼۵�����lvldn��perfectbsʱ����ֵ
            if stillvalid
                if p(end,5) < lvldn(ibs), stillvalid = false;end
            end
            %3.���������̼۵�����truelow
            if stillvalid
                if p(end,5) < truelow, stillvalid = false;end
            end
            %4.���Ҫ��bssetup��ֵ�����������
            if stillvalid && usesetups
                if bs(end) >= 4 && bs(end) < 9, stillvalid = false;end
            end
        else
            stillvalid = true;
        end

        %Ȼ����Ҫ���۸��Ƿ�������ͻ��lvlup,����ȡ���̼���Ϊ�ȽϾ����۸��Ƿ���ͻ��
        %�����ͻ�ƣ����ǽ��ż���ͻ�Ƶ������Ƿ�MACDת����
        haslvlupbreachedwithmacdbearishafterwards = false;
        if stillvalid
            ibreach = find(p(ibs:end,5) > lvlup(ibs),1,'first');
            if ~isempty(ibreach)
                %lvlup has been breached
                ibreach = ibreach + ibs-1;
                diffvec = macdvec(ibreach:end)-sigvec(ibreach:end);
                haslvlupbreachedwithmacdbearishafterwards = ~isempty(find(diffvec<0,1,'first'));
%                 %����߼��ж��Ƿ���ȫ����lvlup֮��
%                 haslvlupbreachedbutbouncedback = ~isempty(find(p(ibreach:end,3)<lvlup(ibs),1,'first'));
%                 %����۸�ص���lvlup֮�£�������ΪperfectbsҲ����Ч��
%                 if haslvlupbreachedbutbouncedback
%                     stillvalid = false;
%                 end
%                 %�����ʱ������̼���lvlup֮�£�������Ϊ��ʱ�����Ч
%                 if ~haslvlupbreachedbutbouncedback && p(end,5) < lvlup(ibs)
%                     stillvalid = false;
%                 end
            end
        end

        if ~stillvalid
            signal = {};
        else
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            %�����ͻ��lvlup��macd��ת����Ҫ���¼���risklvl
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
        %���perfectss�Ƿ����ڹ�ȥ��ʱ��㣬������Ҫ���perfectss�Ƿ���Ȼ��Ч
        if np > iss
            %1.�����perfectss������ʱ��㵽����ʱ�����κ����̼۸�����stoploss
            %��perfectss�����Ч
            stillvalid = isempty(find(p(iss:end,5)>stoploss,1,'first'));
            %2.����������̼۸�����lvldn��perfectssʱ����ֵ
            if stillvalid
                if p(end,5) > lvlup(iss), stillvalid = false;end
            end
            %3.���������̼۸�����truehigh
            if stillvalid
                if p(end,5) > truehigh, stillvalid = false;end
            end
            %4.���Ҫ��sssetup��ֵ�����������
            if stillvalid && usesetups
                if ss(end) >= 4 && ss(end) < 9, stillvalid = false;end
            end
            %
        else
            stillvalid = true;
        end
        
        %Ȼ����Ҫ���۸��Ƿ�������ͻ��lvldn,����ȡ���̼���Ϊ�ȽϾ����۸��Ƿ���ͻ��
        %�����ͻ�ƣ����ǽ��ż���ͻ�Ƶ������Ƿ�MACDת����
        haslvldnbreachedwithmacdbullishafterwards = false;
        if stillvalid
            ibreach = find(p(iss:end,5) < lvldn(iss),1,'first');
            if ~isempty(ibreach)
                %lvldn has been breached
                ibreach = ibreach + iss-1;
                diffvec = macdvec(ibreach:end)-sigvec(ibreach:end);
                haslvldnbreachedwithmacdbullishafterwards = ~isempty(find(diffvec>0,1,'first'));
%                 %����ͼ��ж��Ƿ���ȫ������lvldn֮��
%                 haslvldnbreachedbutbouncedback = ~isempty(find(p(ibreach:end,4)>lvldn(iss),1,'first'));
%                 %����۸�ص���lvldn֮�ϣ�������ΪperfectbsҲ����Ч��
%                 if haslvldnbreachedbutbouncedback
%                     stillvalid = false;
%                 end
%                 %�����ʱ������̼���lvldn֮�ϣ�������Ϊ��ʱ�����Ч
%                 if ~haslvldnbreachedbutbouncedback && p(end,5) > lvldn(iss)
%                     stillvalid = false;
%                 end
            end
        end
        
        if ~stillvalid
            signal = {};
        else
            %�����ͻ��lvldn��macd��ת����Ҫ���¼���risklvl
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