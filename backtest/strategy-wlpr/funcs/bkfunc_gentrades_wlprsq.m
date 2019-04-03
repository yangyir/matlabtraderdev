function [trades,px_used,wrsellsetup,wrbuysetup] = bkfunc_gentrades_wlprsq(code,px_input,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('SampleFrequency','1m',@ischar);
    p.addParameter('NPeriod',144,@isnumeric);
    
    p.parse(varargin{:});
    freq = p.Results.SampleFrequency;
    nperiod = p.Results.NPeriod;
    wrmode = 'flash';
    
    trades = cTradeOpenArray;
   
    instrument = code2instrument(code);
    px_used = timeseries_compress(px_input,...
        'frequency',freq,...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
    
    datetimevec = px_used(:,1);
    pxopen = px_used(:,2);
    pxhigh = px_used(:,3);
    pxlow = px_used(:,4);
    pxclose = px_used(:,5);
    ndata = size(pxclose,1);
    
    wrsellsetup = 0*pxclose;
    wrbuysetup  = 0*pxclose;
   
    i = nperiod + 1;
    while i <= ndata
        premin = min(pxlow(i-nperiod:i-1));
        premax = max(pxhigh(i-nperiod:i-1));
        highp = pxhigh(i);
        lowp = pxlow(i);
        if highp >= premax
            wrsellsetup(i,1) = 1;
            preclose = pxclose(i);
            idxstart = i+1;
            idxend = i+1;
            for j = idxstart:ndata
                premax = max(pxhigh(j-nperiod:j-1));
                highp = pxhigh(j);
                closep = pxclose(j);
                if highp >= premax || closep > preclose
                    wrsellsetup(j,1) = wrsellsetup(j-1,1)+1;
                    preclose = closep;
                else
                    idxend = j;
                    break
                end
            end
            i = idxend;
        end
        %
        if lowp <= premin
            wrbuysetup(i,1) = 1;
            preclose = pxclose(i);
            idxstart = i+1;
            idxend = i+1;
            for j = idxstart:ndata
                premin = min(pxlow(j-nperiod:j-1));
                lowp = pxlow(j);
                closep = pxclose(j);
                if lowp <= premin || closep < preclose
                    wrbuysetup(j,1) = wrbuysetup(j-1,1)+1;
                    preclose = closep;
                else
                    idxend = j;
                    break
                end
            end
            i = idxend;
        end
        i = i+1;
    end
    
    for i = 2:ndata-1
        if wrsellsetup(i-1) ~= 0 && wrsellsetup(i) == 0
            extrainfo = struct('frequency',freq,...
                'lengthofperiod',nperiod,...
                'highesthigh',max(pxhigh(i-nperiod+1)),...
                'lowestlow',min(pxlow(i-nperiod+1:i)),...
                'wrmode',wrmode);
            id = trades.latest_ + 1;
            opendatetime = datetimevec(i+1)+1/86400;
            trade_i = cTradeOpen('id',id,'code',code,...
                'opendatetime',opendatetime,...
                'opendirection',-1,...
                'openvolume',1,...
                'openprice',pxopen(i+1));
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);
        elseif wrbuysetup(i-1) ~= 0 && wrbuysetup(i) == 0
            extrainfo = struct('frequency',freq,...
                'lengthofperiod',nperiod,...
                'highesthigh',max(pxhigh(i-nperiod+1)),...
                'lowestlow',min(pxlow(i-nperiod+1:i)),...
                'wrmode',wrmode);
            id = trades.latest_ + 1;
            opendatetime = datetimevec(i+1)+1/86400;
            trade_i = cTradeOpen('id',id,'code',code,...
                'opendatetime',opendatetime,...
                'opendirection',1,...
                'openvolume',1,...
                'openprice',pxopen(i+1));
            trade_i.setsignalinfo('name','williamsr','extrainfo',extrainfo);
            trades.push(trade_i);        
        end
    end

    
end