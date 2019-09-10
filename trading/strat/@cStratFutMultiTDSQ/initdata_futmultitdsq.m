function [] = initdata_futmultitdsq(obj)
%cStratFutMultiTDSQ
    instruments = obj.getinstruments;
    for i = 1:obj.count
        try
            samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
        catch
            samplefreqstr = '15m';
        end

        samplefreqnum = str2double(samplefreqstr(1:end-1));

        if samplefreqnum == 1
            nbdays = 1;
        elseif samplefreqnum == 3
            nbdays = 3;
        elseif samplefreqnum == 5
            nbdays = 5;
        elseif samplefreqnum == 15
            nbdays = 10;
        elseif samplefreqnum == 30
            nbdays = 20;
        else
            error('ERROR:%s:initdata_futmultitdsq:unsupported sample freq %s of %s',class(obj),samplefreqstr,instruments{i}.code_ctp)
        end
        
        fprintf('init historical data of %s...\n',instruments{i}.code_ctp);
        obj.mde_fut_.initcandles(instruments{i},'NumberofPeriods',nbdays);
        %
%         wrnperiod = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrnperiod');
%         wrinfo = obj.mde_fut_.calc_wr_(instruments{i},'NumOfPeriods',wrnperiod,'IncludeLastCandle',1);
        %
        macdlead = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlead');
        macdlag = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlag');
        macdnavg = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdnavg');
        [macdvec,sigvec,p] = obj.mde_fut_.calc_macd_(instruments{i},'Lead',macdlead,'Lag',macdlag,'Average',macdnavg,'IncludeLastCandle',1,'RemoveLimitPrice',1);
        %
        tdsqlag = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
        tdsqconsecutive = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
        [bs,ss,levelup,leveldn,bc,sc] = obj.mde_fut_.calc_tdsq_(instruments{i},'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',1,'RemoveLimitPrice',1);       
        
        obj.tdbuysetup_{i} = bs;
        obj.tdsellsetup_{i} = ss;
        obj.tdbuycountdown_{i} = bc;
        obj.tdsellcountdown_{i} = sc;
        obj.tdstlevelup_{i} = levelup;
        obj.tdstleveldn_{i} = leveldn;
%         obj.wr_{i} = wrinfo;
        obj.macdvec_{i} = macdvec;
        obj.nineperma_{i} = sigvec;
        
        if obj.usesimpletrend_(i)
            diffvec = macdvec - sigvec;
            [macdbs,macdss] = tdsq_setup(diffvec);
            obj.macdbs_{i} = macdbs;
            obj.macdss_{i} = macdss;
        end
        
%         candlesticks = obj.mde_fut_.getallcandles(instruments{i});
%         p = candlesticks{1};
%         %remove intraday limits
%         idxkeep = ~(p(:,2)==p(:,3)&p(:,2)==p(:,4)&p(:,2)==p(:,5));
%         p = p(idxkeep,:);       
        
        lastidxbs = find(bs==9,1,'last');
        lastidxss = find(ss==9,1,'last');
        if isempty(lastidxbs) && isempty(lastidxss)
            obj.tags_{i} = 'blank';
        elseif (~isempty(lastidxbs) && isempty(lastidxss)) || ...
            ((~isempty(lastidxbs) && ~isempty(lastidxss)) && lastidxbs > lastidxss)
            low6 = p(lastidxbs-3,4);
            low7 = p(lastidxbs-2,4);
            low8 = p(lastidxbs-1,4);
            low9 = p(lastidxbs,4);
            close8 = p(lastidxbs-1,5);
            close9 = p(lastidxbs,5);
            closedbelow = false;
            for j = lastidxbs-8:lastidxbs
                if isnan(leveldn(j)), continue;end
                if p(j,5) < leveldn(j)
                    closedbelow = true;
                    break
                end
            end
            if (low8 < min(low6,low7) || low9 < min(low6,low7)) && ~closedbelow
                if close9 < close8
                    tag = 'perfectbs';
                else
                    tag = 'semiperfectbs';
                end
            else
                tag = 'imperfectbs';
            end
            obj.tags_{i} = tag;
        elseif (isempty(lastidxbs) && ~isempty(lastidxss)) || ...
                ((~isempty(lastidxbs) && ~isempty(lastidxss)) && lastidxbs < lastidxss)
            high6 = p(lastidxss-3,3);
            high7 = p(lastidxss-2,3);
            high8 = p(lastidxss-1,3);
            high9 = p(lastidxss,3);
            close8 = p(lastidxss-1,5);
            close9 = p(lastidxss,5);
            closedabove = false;
            for j = lastidxss-8:lastidxss
                if isnan(levelup(j)), continue;end
                if p(j,5) > levelup(j)
                    closedabove = true;
                    break
                end
            end
            
            if (high8 > max(high6,high7) || high9 > max(high6,high7)) && ~closedabove
                if close9 > close8
                    tag = 'perfectss';
                else
                    tag = 'semiperfectss';
                end
            else
                tag = 'imperfectss';
            end
            obj.tags_{i} = tag;            
        end        
    end
    
    ntypes = cTDSQInfo.numoftype;
    obj.targetportfolio_ = zeros(obj.count,ntypes);
    
    
end