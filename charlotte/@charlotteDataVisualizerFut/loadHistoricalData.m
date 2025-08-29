function [] = loadHistoricalData(obj,varargin)
% charlotteDataVisualizerFut function
   p = inputParser;
   p.CaseSensitive = false;p.KeepUnmatched = true;
   p.addParameter('code','',@ischar);
   p.addParameter('datefrom','',@ischar);
   p.addParameter('dateto','',@ischar);
   p.parse(varargin{:});
   code = p.Results.code;
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
    if idxfound == -1, return;end
    
    instrument = code2instrument(code);
    
    if strcmpi(instrument.break_interval{end,end},'01:00:00') ||...
        strcmpi(instrument.break_interval{end,end},'02:30:00')
        date2str = [datestr(datenum(dt1,'yyyy-mm-dd')+1,'yyyy-mm-dd'),' ',instrument.break_interval{end,end}];
    else
        date2str = [dt2,' ',instrument.break_interval{end,end}];
    end
    date1str = [datestr(dt1,'yyyy-mm-dd'),' 09:00:00'];
                
    ds = cLocal;
    k_m1 = ds.intradaybar(instrument,date1str,date2str,1,'trade');
    k_m5 = ds.intradaybar(instrument,date1str,date2str,5,'trade');
    k_m15 = ds.intradaybar(instrument,date1str,date2str,15','trade');
    k_m30 = ds.intradaybar(instrument,date1str,date2str,30,'trade');

    obj.candles_m1_{idxfound} = k_m1;
    obj.candles_m5_{idxfound} = k_m5;
    obj.candles_m15_{idxfound} = k_m15;
    obj.candles_m30_{idxfound} = k_m30;

end

