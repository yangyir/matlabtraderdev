function [stoptime1,stoptime2] = gettradestoptime(code,opentime,freq,nperiod)
%compute the mandate stoptime for an open trade
%for example, we trade with 5m candle stick and we want the trade to be
%unwinded within the next 50 candle sticks no matter how the market goes
    if isempty(nperiod)
        stoptime1 = [];
        stoptime2 = datestr(stoptime1,'yyyy-mm-dd HH:MM:SS');
        return
    end

    if ~ischar(code), error('gettradestoptime:invalid code input');end
    instrument = code2instrument(code);
    if ischar(opentime)
        opentime = datenum(opentime,'yyyy-mm-dd HH:MM:SS');
    end
    
    freq = [num2str(freq),'m'];
    
    if hour(opentime) >= 0 && hour(opentime) < 9
        openbusdate = businessdate(floor(opentime),-1);
    else
        openbusdate = floor(opentime);
    end
    
    buckets = getintradaybuckets2('date',openbusdate,'frequency',freq,...
        'tradinghours',instrument.trading_hours,...
        'tradingbreak',instrument.trading_break);
    nbuckets = size(buckets,1);
    idx = buckets(1:end-1) < opentime & buckets(2:end) >= opentime;
    thisbucket = buckets(idx);
    
    if isempty(thisbucket)
        if opentime == buckets(1);
            thiscount = 0;
        else
            error('internal error')
        end
    else
        thiscount = find(buckets == thisbucket);
    end
    
    stopcount = mod(thiscount+nperiod,nbuckets);
    stopdateadd = floor((thiscount+nperiod)/nbuckets);
    
    %note: if thiscount+nperiod is a multiple of nbuckets
    %we stop on the last bucket of the business date
    if stopcount == 0
        stopdateadd = stopdateadd - 1;
        stopcount = nbuckets;
    end
    
    stopdate = openbusdate;
    ndateadded = 1;
    while ndateadded <= stopdateadd
        stopdate = businessdate(stopdate,1);
        ndateadded = ndateadded + 1;
    end
    
    stoptime1 = stopdate + buckets(stopcount) - openbusdate;
    stoptime2 = datestr(stoptime1,'yyyy-mm-dd HH:MM:SS');
    
    %sanity check
    if stoptime1 < opentime
        error('internal error')
    end
    
end