function obj = init(obj,varargin)
% a charlotteDataFeedFX function
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('symbol',{},@iscell);
p.addParameter('frequency',{},@iscell);
p.addParameter('mode','realtime',@ischar);
p.addParameter('replaydatefrom','',@ischar);
p.addParameter('replaydateto','',@ischar);
p.parse(varargin{:});
symbol = p.Results.symbol;
frequency = p.Results.frequency;
mode = p.Results.mode;
rplfrom = p.Results.replaydatefrom;
rplto = p.Results.replaydateto;

nSymbol = length(symbol);
nFreq = length(frequency);
if nSymbol ~= nFreq
    error('charlotteDataFeedFX::init::mismatch between input symbol and frequency');
end

if ~(strcmpi(mode,'realtime') || strcmpi(mode,'replay') || strcmpi(mode,'demo'))
    error('charlotteDataFeedFX::init::invalid mode input');
end

codes = cell(nSymbol,1);
instruments = cInstrumentArray;
for i = 1:nSymbol
    codes{i} = [symbol{i},'-',frequency{i}];
    instrument = code2instrument(symbol{i});
    instruments.addinstrument(instrument);
end

obj.codes_ = codes;
obj.freq_ = frequency;
obj.instruments_ = instruments;
obj.mode_ = mode;
obj.fn_ = cell(nSymbol,1);
obj.lastbartime_ = zeros(nSymbol,1);

if strcmpi(obj.mode_,'realtime') || strcmpi(obj.mode_,'demo')
    obj.updateinterval_ = 1;
    for i = 1:nSymbol
        if strcmpi(obj.freq_{i},'5m')
            obj.fn_{i} = [obj.dir_,symbol{i},'.lmx_M5_running.csv'];
        elseif strcmpi(obj.freq_{i},'15m')
            obj.fn_{i} = [obj.dir_,symbol{i},'.lmx_M15_running.csv'];
        elseif strcmpi(obj.freq_{i},'30m')
            obj.fn_{i} = [obj.dir_,symbol{i},'.lmx_M30_running.csv'];
        elseif strcmpi(obj.freq_{i},'1h')
            obj.fn_{i} = [obj.dir_,symbol{i},'.lmx_H1_running.csv'];
        elseif strcmpi(obj.freq_{i},'4h')
            obj.fn_{i} = [obj.dir_,symbol{i},'.lmx_H4_running.csv'];
        elseif strcmpi(obj.freq_{i},'daily')
            obj.fn_{i} = [obj.dir_,symbol{i},'.lmx_D1_running.csv'];
        else
            error('charlotteDataFeedFX::init::invalid frequency input');
        end
        
        try
            lastrow = readlastrowfromcsvfile(obj.fn_{i});
            lastbardate = lastrow{1};
            lastbardatestr = [lastbardate(1:4),lastbardate(6:7),lastbardate(9:10)];
            lastbartimestr = lastrow{2};
            lastbartime = datenum([lastbardatestr,' ',lastbartimestr],'yyyymmdd HH:MM');
            obj.lastbartime_(i) = lastbartime;
        catch ME
            error(['charlotteDataFeedFX::init::',ME.message]);
        end  
    end
elseif strcmpi(obj.mode_,'replay')
    obj.updateinterval_ = 0.02;
    if isempty(obj.replaycounts_)
        obj.replaycounts_ = zeros(nSymbol,1);
    end
    
    if isempty(obj.replaydata_)
        obj.replaydata_ = cell(nSymbol,1);
    end
    
    if isempty(obj.replaydatefrom_)
        if isempty(rplfrom)
            obj.replaydatefrom_ = today - 1;
        else
            obj.replaydatefrom_ = datenum(rplfrom);
        end
    end
    
    if isempty(obj.replaydateto_)
        if isempty(rplto)
            obj.replaydateto_ = today;
        else
            obj.replaydateto_ = datenum(rplto);
        end
    end
    
    pathdir = [getenv('onedrive'),'\Documents\fx_mt4\'];   
    for i = 1:nSymbol
        if strcmpi(obj.freq_{i},'5m')
            obj.fn_{i} = [pathdir,symbol{i},'_MT4_M5.mat'];
        elseif strcmpi(obj.freq_{i},'15m')
            obj.fn_{i} = [pathdir,symbol{i},'_MT4_M15.mat'];
        elseif strcmpi(obj.freq_{i},'30m')
            obj.fn_{i} = [pathdir,symbol{i},'_MT4_M30.mat'];
        elseif strcmpi(obj.freq_{i},'1h')
            obj.fn_{i} = [pathdir,symbol{i},'_MT4_H1.mat'];
        elseif strcmpi(obj.freq_{i},'4h')
            obj.fn_{i} = [pathdir,symbol{i},'_MT4_H4.mat'];
        elseif strcmpi(obj.freq_{i},'daily')
            obj.fn_{i} = [pathdir,symbol{i},'_MT4_D1.mat'];
        else
            error('charlotteDataFeedFX::init::invalid frequency input');
        end
        
        try
            d = load(obj.fn_{i});
            data = d.data;
            idxstart = find(data(:,1) < obj.replaydatefrom_,1,'last');
            if ~isempty(idxstart)
                obj.replaycounts_(i) = idxstart;
                obj.lastbartime_(i) = data(idxstart,1);
                obj.replaydata_{i} = data;
            else
                error('charlotteDataFeedFX::init::invalid replay period');
            end
        catch ME
            error(['charlotteDataFeedFX::init::replay',ME.message]);
        end
    end
    
    
end







end