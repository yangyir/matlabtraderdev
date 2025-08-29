function obj = init(obj,varargin)
% a charlotteDataFeedFut function
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('codes',{},@iscell);
p.addParameter('mode','realtime',@ischar);
p.addParameter('replayfrom','',@ischar);
p.addParameter('replayto','',@ischar);
p.parse(varargin{:});
codes = p.Results.codes;
mode = p.Results.mode;

obj.codes_ = codes;
obj.mode_ = mode;

if strcmpi(mode,'replay')
    rpl1 = p.Results.replayfrom;
    rpl2 = p.Results.replayto;
    if ~strcmpi(rpl1,rpl2)
        obj.stop;
        error('charlotteDataFeedFut::init::same replayfrom and replayto are required...');
    end
end

ncodes = size(codes,1);
if ncodes > 0
    obj.lastticktime_ = zeros(ncodes,1);
    obj.lasttrade_ = zeros(ncodes,1);
    
    if strcmpi(mode,'realtime')
        obj.qms_ = cQMS;
        obj.qms_.setdatasource('ctp');
        for i = 1:ncodes
            instrument_i = code2instrument(codes{i});
            obj.qms_.registerinstrument(instrument_i);
        end
    elseif strcmpi(mode,'replay')
        if ncodes > 1
            obj.stop;
            error('charlotteDataFeedFut::init::only one code is supported in replay mode...')
        end
        fns = cell(ncodes,1);
        obj.replaycounts_ = zeros(ncodes,1);
        obj.replaydata_ = cell(ncodes,1);
        for i = 1:ncodes
            fns{i} = [getenv('datapath'),'ticks\',codes{i},'\',codes{i},'_',datestr(rpl1,'yyyymmdd'),'_tick.txt'];
            obj.replaydata_{i} = cDataFileIO.loadDataFromTxtFile(fns{i});
            obj.replaycounts_(i) = 1;
            obj.lastticktime_(i) = obj.replaydata_{i}(1,1);
            obj.lasttrade_(i) = obj.replaydata_{i}(1,2);
        end
    end
end
    
if strcmpi(mode,'realtime')
    t = now;
elseif strcmpi(mode,'replay')
    t = obj.replaydata_{1}(1,1);
end

if ~obj.istime2sleep(t)
    data.time = t;
    notify(obj, 'MarketOpen', charlotteDataFeedEventData(data));
    if strcmpi(mode,'realtime')
        if obj.qmsconnected_
            try
                obj.qms_.refesh;
                for i = 1:ncodes
                    quote = obj.qms_.getquote(obj.codes_{i});
                    if quote.update_time1 == 0
                        obj.qms_.refresh;
                    end
                    quote = obj.qms_.getquote(obj.codes_{i});
                    obj.lastticktime_(i) = quote.update_time1;
                    obj.lasttrade_(i) = quote.last_trade;
                end
            catch
                notify(obj, 'ErrorOccurred', ...
                    charlotteErrorEventData('Failed to get tick data from CTP server'));
            end
        end
    end
end

end