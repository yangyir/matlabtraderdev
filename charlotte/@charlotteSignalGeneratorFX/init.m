function obj = init(obj,varargin)
% a charlotteSignalGenerator (private) function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('codes',{},@iscell);
    p.addParameter('freqs',{},@iscell);
    p.addParameter('datafeed',{},@(x) validateattributes(x,{'charlotteDataFeedFX'},{},'','datafeed'));
    p.parse(varargin{:});
    obj.codes_ = p.Results.codes;
    obj.freqs_ = p.Results.freqs;
    
    ncodes = size(obj.codes_,1);
    if ncodes ~= size(obj.freqs_,1)
        error('charlotteSignalGeneratorFX:init:mismatch between input codes and freqs')
    end
    datafeed = p.Results.datafeed;
    % also need to check whether input codes are listed in the datafeed
    obj.extrainfo_ = cell(ncodes,1); 
    obj.ticksize_ = zeros(ncodes,1);
    for i = 1:ncodes
        ei_i = datafeed.getExtraInfo(obj.codes_{i},obj.freqs_{i});
        if isempty(ei_i)
            error('charlotteSignalGeneratorFX:init:%s not found in the datafeed',[obj.codes{i},'-',obj.freqs_{i}]);
        end
        obj.extrainfo_{i} = ei_i;
        %
        fx_i = code2instrument(obj.codes_{i});
        obj.ticksize_(i) = fx_i.tick_size;
    end
    
    obj.calcflag_ = ones(ncodes,1);
    obj.printSignal_ = true;
    obj.signals_ = cell(ncodes,1);    
    %
    for i = 1:4
        if i == 1
            strappendix = 'm15';
        elseif i == 2
            strappendix = 'm30';
        elseif i == 3
            strappendix = 'h1';
        elseif i == 4
            strappendix = 'h4';
        end
        try
            fn_i = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_',strappendix,'.mat'];
            data_i = load(fn_i);
            props = fieldnames(data_i);
            if i == 1
                obj.kellytables_m15_ = data_i.(props{1});
            elseif i == 2
                obj.kellytables_m30_ = data_i.(props{1});
            elseif i == 3
                obj.kellytables_h1_ = data_i.(props{1});
            elseif i == 4
                obj.kellytables_h4_ = data_i.(props{1});
            end
        catch
            %do nothing for now
        end
    end
    %
    newSignals = zeros(ncodes,1);
    for i= 1:ncodes
        obj.signals_{i} = obj.genSignal(obj.codes_{i},obj.freqs_{i},datafeed.mode_);
        if ~isempty(obj.signals_{i})
            newSignals(i) = 1;
        end
    end
    
    nsignal = sum(newSignals);
    if nsignal > 0
        data = struct('signals',{obj.signals_},...
            'extrainfo',{obj.extrainfo_},...
            'codes',{obj.codes_},...
            'freqs',{obj.freqs_},...
            'newsignals',{newSignals},...
            'mode',datafeed.mode_);
        notify(obj,'NewSignalGenerated',charlotteDataFeedEventData(data));
    end
end