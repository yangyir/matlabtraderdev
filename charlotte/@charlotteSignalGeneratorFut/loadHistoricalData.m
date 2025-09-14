function [] = loadHistoricalData(obj,varargin)
% charlotteSignalGeneratorFut function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('frequency','',@ischar);
    p.addParameter('datefrom','',@ischar);
    p.addParameter('dateto','',@ischar);
    p.parse(varargin{:});
    code = p.Results.code;
    freq = p.Results.frequency;
    if ~(strcmpi(freq,'m1') || strcmpi(freq,'1m') || ...
            strcmpi(freq,'m5') || strcmpi(freq,'5m') || ...
            strcmpi(freq,'m15') || strcmpi(freq,'15m') || ...
            strcmpi(freq,'m30') || strcmpi(freq,'30m') || ...
            strcmpi(freq,'d1') || strcmpi(freq,'daily'))
        error('%s:loadHistoricalData:invalid frequency input:%s....',class(obj),freq)
    end
    
    dt1 = p.Results.datefrom;
    dt2 = p.Results.dateto;

    ncodes = size(obj.codes_);
    idxfound = -1;
    for i = 1:ncodes
        if strcmpi(obj.codes_{i},code)
            idxfound = i;
            break;
        end
    end
    if idxfound == -1
        fprintf('%s:input code %s not registered....\n',class(obj),code);
        return;
    end

    instrument = code2instrument(code);

    if strcmpi(instrument.break_interval{end,end},'01:00:00') ||...
            strcmpi(instrument.break_interval{end,end},'02:30:00')
        date2str = [datestr(datenum(dt1,'yyyy-mm-dd')+1,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
    else
        date2str = [dt2,' ',instrument.break_interval{end,end}];
    end
    date1str = [datestr(dt1,'yyyy-mm-dd'),' 09:00:00'];

    ds = cLocal;
    
    nfractal = charlotte_freq2nfractal(freq);
    if strcmpi(freq,'m1') || strcmpi(freq,'1m')
        k_m1 = ds.intradaybar(instrument,date1str,date2str,1,'trade');
        obj.candles_m1_{idxfound} = k_m1;
    elseif strcmpi(freq,'m5') ||  strcmpi(freq,'5m')
        k_m5 = ds.intradaybar(instrument,date1str,date2str,5,'trade');
        obj.candles_m5_{idxfound} = k_m5;
        [~,ei_m5] = tools_technicalplot1(k_m5,nfractal,0,'volatilityperiod',0,'tolerance',0);
        obj.ei_m5_{idxfound} = ei_m5;
    elseif strcmpi(freq,'m15') || strcmpi(freq,'15m')
        k_m15 = ds.intradaybar(instrument,date1str,date2str,15','trade');
        obj.candles_m15_{idxfound} = k_m15;
        [~,ei_m15] = tools_technicalplot1(k_m15,nfractal,0,'volatilityperiod',0,'tolerance',0);
        obj.ei_m15_{idxfound} = ei_m15;
    elseif strcmpi(freq,'m30') || strcmpi(freq,'30m')
        k_m30 = ds.intradaybar(instrument,date1str,date2str,30,'trade');
        obj.candles_m30_{idxfound} = k_m30;
        [~,ei_m30] = tools_technicalplot1(k_m30,nfractal,0,'volatilityperiod',0,'tolerance',0);
        obj.ei_m30_{idxfound} = ei_m30;
    elseif strcmpi(freq,'d1') || strcmpi(freq,'daily')
        error('to be impelmented...')
    end
    
end

