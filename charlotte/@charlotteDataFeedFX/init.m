function obj = init(obj,varargin)
% a charlotteDataFeedFX function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('symbol',{},@iscell);
    p.addParameter('mode','realtime',@ischar);
    p.addParameter('replaydatefrom','',@ischar);
    p.addParameter('replaydateto','',@ischar);
    p.parse(varargin{:});
    symbol = p.Results.symbol;
    mode = p.Results.mode;
    rplfrom = p.Results.replaydatefrom;
    rplto = p.Results.replaydateto;

    nSymbol = length(symbol);

    if ~(strcmpi(mode,'realtime') || strcmpi(mode,'replay') || strcmpi(mode,'demo'))
        error('charlotteDataFeedFX::init::invalid mode input');
    end

    codes = cell(nSymbol,1);
    instruments = cInstrumentArray;
    for i = 1:nSymbol
        codes{i} = symbol{i};
        instrument = code2instrument(symbol{i});
        instruments.addinstrument(instrument);
    end

    obj.codes_ = codes;
    obj.instruments_ = instruments;
    obj.mode_ = mode;
    obj.fn_m15_ = cell(nSymbol,1);
    obj.fn_m30_ = cell(nSymbol,1);
    obj.fn_h1_ = cell(nSymbol,1);
    obj.fn_h4_ = cell(nSymbol,1);
    %
    obj.lastbartime_m15_ = zeros(nSymbol,1);
    obj.lastbartime_m30_ = zeros(nSymbol,1);
    obj.lastbartime_h1_ = zeros(nSymbol,1);
    obj.lastbartime_h4_ = zeros(nSymbol,1);
    %
    obj.extrainfo_m15_ = cell(nSymbol,1);
    obj.extrainfo_m30_ = cell(nSymbol,1);
    obj.extrainfo_h1_ = cell(nSymbol,1);
    obj.extrainfo_h4_ = cell(nSymbol,1);

    if strcmpi(obj.mode_,'realtime') || strcmpi(obj.mode_,'demo')
        obj.updateinterval_ = 1;
        for i = 1:nSymbol
            obj.fn_m15_{i} = [obj.dir_,symbol{i},'.lmx_M15_running.csv'];
            obj.fn_m30_{i} = [obj.dir_,symbol{i},'.lmx_M30_running.csv'];
            obj.fn_h1_{i} = [obj.dir_,symbol{i},'.lmx_H1_running.csv'];
            obj.fn_h4_{i} = [obj.dir_,symbol{i},'.lmx_H1_running.csv'];

            for j = 1:4
                try
                    if j == 1
                        data = readtable(obj.fn_m15_{i},'readvariablenames',1);
                    elseif j == 2
                        data = readtable(obj.fn_m30_{i},'readvariablenames',1);
                    elseif j == 3
                        data = readtable(obj.fn_h1_{i},'readvariablenames',1);
                    elseif j == 4
                        data = readtable(obj.fn_h4_{i},'readvariablenames',1);
                    end
                    idxlast = find(~isnan(data.Close),1,'last');
                    % for save memory, we cut candles differently for
                    % different frequency
                    idxfirst = 1;
                    if j == 1
                        % last 3 trading days
                        if idxlast >= 288
                            idxfirst = idxlast - 287;
                        end
                    elseif j == 2
                        % last 5 trading days
                        if idxlast >= 240
                            idxfirst = idxlast - 239;
                        end
                    elseif j == 3
                        % last 2 weeks
                        if idxlast >= 240
                            idxfirst = idxlast - 239;
                        end
                    elseif j == 4
                        % last 2 months
                        if idxlast >= 240
                            idxfirst = idxlast - 239;
                        end
                    end
                    candleopen = data.Open(idxfirst:idxlast);
                    candlehigh = data.High(idxfirst:idxlast);
                    candlelow = data.Low(idxfirst:idxlast);
                    candleclose = data.Close(idxfirst:idxlast);
                    candledate = data.Date(idxfirst:idxlast);
                    candletime = data.Time(idxfirst:idxlast);
                    nbars = size(candledate,1);
                    candledatetime = zeros(nbars,1);
                    for k = 1:nbars
                        thisbardate = candledate{k};
                        thisbartime = candletime{k};
                        thisbardatestr = [thisbardate(1:4),thisbardate(6:7),thisbardate(9:10)];
                        candledatetime(k) = datenum([thisbardatestr,' ',thisbartime],'yyyymmdd HH:MM');
                    end
                    p = [candledatetime,candleopen,candlehigh,candlelow,candleclose];

                    if j == 1
                        obj.lastbartime_m15_(i) = candledatetime(end);
                        [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('m15'),0,'volatilityperiod',0,'tolerance',0);
                        obj.extrainfo_m15_{i} = ei;
                    elseif j == 2
                        obj.lastbartime_m30_(i) = candledatetime(end);
                        [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('m30'),0,'volatilityperiod',0,'tolerance',0);
                        obj.extrainfo_m30_{i} = ei;
                    elseif j == 3
                        obj.lastbartime_h1_(i) = candledatetime(end);
                        [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('h1'),0,'volatilityperiod',0,'tolerance',0);
                        obj.extrainfo_h1_{i} = ei;
                    elseif j == 4
                        obj.lastbartime_h4_(i) = candledatetime(end);
                        [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('h4'),0,'volatilityperiod',0,'tolerance',0);
                        obj.extrainfo_h4_{i} = ei;
                    end
                catch ME
                    error(['charlotteDataFeedFX::init::',ME.message]);
                end
            end
        end
    elseif strcmpi(obj.mode_,'replay')
        obj.updateinterval_ = 0.01;

        obj.replaydata_m15_ = cell(nSymbol,1);
        obj.replaydata_m30_ = cell(nSymbol,1);
        obj.replaydata_h1_ = cell(nSymbol,1);
        obj.replaydata_h4_ = cell(nSymbol,1);

        if isempty(rplfrom)
            obj.replaydatefrom_ = today - 1;
        else
            obj.replaydatefrom_ = datenum(rplfrom);
        end

        if isempty(rplto)
            obj.replaydateto_ = today;
        else
            obj.replaydateto_ = datenum(rplto);
        end

        ndays = obj.replaydateto_ - obj.replaydatefrom_;
        n5mins = ndays * 1440/5;
        obj.replaytimevec_ = zeros(n5mins+1,1);
        obj.replaytimevec_(1) = obj.replaydatefrom_;
        for i = 2:n5mins+1
            obj.replaytimevec_(i) = obj.replaytimevec_(i-1) + 5/1440;
        end

        obj.lastreplayidx_ = 0;

        pathdir = [getenv('onedrive'),'\Documents\fx_mt4\'];   
        for i = 1:nSymbol

            obj.fn_m15_{i} = [pathdir,symbol{i},'_MT4_M15.mat'];
            obj.fn_m30_{i} = [pathdir,symbol{i},'_MT4_M30.mat'];
            obj.fn_h1_{i} = [pathdir,symbol{i},'_MT4_H1.mat'];
            obj.fn_h4_{i} = [pathdir,symbol{i},'_MT4_H4.mat'];

            % M15
            try
                d = load(obj.fn_m15_{i});
                props = fieldnames(d);
                data = d.(props{1});
                idxstart = find(data(:,1) < obj.replaydatefrom_,1,'last');
                if ~isempty(idxstart)
                    obj.lastbartime_m15_(i) = data(idxstart,1);
                    % last 3 trading days
                    idxfirst = 1;
                    if idxstart >= 288
                        idxfirst = idxstart - 287;
                    end
                    obj.replaydata_m15_{i} = data(idxfirst:end,:);
                    p = data(idxfirst:idxstart,1:5);
                    [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('m15'),0,'volatilityperiod',0,'tolerance',0);
                    obj.extrainfo_m15_{i} = ei;
                else
                    error('charlotteDataFeedFX::init::invalid replay period');
                end
            catch ME
                error(['charlotteDataFeedFX::init::replay',ME.message]);
            end
            %
            % M30
            try
                d = load(obj.fn_m30_{i});
                props = fieldnames(d);
                data = d.(props{1});
                idxstart = find(data(:,1) < obj.replaydatefrom_,1,'last');
                if ~isempty(idxstart)
                    obj.lastbartime_m30_(i) = data(idxstart,1);
                    % last 5 trading days
                    idxfirst = 1;
                    if idxstart >= 240
                        idxfirst = idxstart - 239;
                    end
                    obj.replaydata_m30_{i} = data(idxfirst:end,:);
                    p = data(idxfirst:idxstart,1:5);
                    [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('m30'),0,'volatilityperiod',0,'tolerance',0);
                    obj.extrainfo_m30_{i} = ei;
                else
                    error('charlotteDataFeedFX::init::invalid replay period');
                end
            catch ME
                error(['charlotteDataFeedFX::init::replay',ME.message]);
            end
            %
            % H1
            try
                d = load(obj.fn_h1_{i});
                props = fieldnames(d);
                data = d.(props{1});
                idxstart = find(data(:,1) < obj.replaydatefrom_,1,'last');
                if ~isempty(idxstart)
                    obj.lastbartime_h1_(i) = data(idxstart,1);
                    % last 2 week
                    idxfirst = 1;
                    if idxstart >= 240
                        idxfirst = idxstart - 239;
                    end
                    obj.replaydata_h1_{i} = data(idxfirst:end,:);
                    p = data(idxfirst:idxstart,1:5);
                    [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('h1'),0,'volatilityperiod',0,'tolerance',0);
                    obj.extrainfo_h1_{i} = ei;
                else
                    error('charlotteDataFeedFX::init::invalid replay period');
                end
            catch ME
                error(['charlotteDataFeedFX::init::replay',ME.message]);
            end
            %
            % H4
            try
                d = load(obj.fn_h4_{i});
                props = fieldnames(d);
                data = d.(props{1});
                idxstart = find(data(:,1) < obj.replaydatefrom_,1,'last');
                if ~isempty(idxstart)
                    obj.lastbartime_h4_(i) = data(idxstart,1);
                    % last 2 month
                    idxfirst = 1;
                    if idxstart >= 240
                        idxfirst = idxstart - 239;
                    end
                    obj.replaydata_h4_{i} = data(idxfirst:end,:);
                    p = data(idxfirst:idxstart,1:5);
                    [~,ei] = tools_technicalplot1(p,charlotte_freq2nfractal('h4'),0,'volatilityperiod',0,'tolerance',0);
                    obj.extrainfo_h4_{i} = ei;
                else
                    error('charlotteDataFeedFX::init::invalid replay period');
                end
            catch ME
                error(['charlotteDataFeedFX::init::replay',ME.message]);
            end

        end


    end

end