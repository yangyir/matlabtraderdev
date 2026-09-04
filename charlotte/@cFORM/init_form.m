function obj = init_form(obj,varargin)
% a cFORM method
% to initiate the FORM object
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('SignalFrequency','',@ischar);
    p.addParameter('IncludeBreachTDSQLevel',1,@isnumeric);
    p.addParameter('IncludeBreachTDSQHV',1,@isnumeric);
    p.addParameter('UseMT5',1,@isnumeric);
    
    p.parse(varargin{:});
    obj.signal_freq_ = p.Results.SignalFrequency;
    obj.include_tdsqlvl_ = p.Results.IncludeBreachTDSQLevel;
    obj.include_tdsqhv_ = p.Results.IncludeBreachTDSQHV;
    obj.use_mt5_ = p.Results.UseMT5;
    
    if ~(strcmpi(obj.signal_freq_,'H1') || strcmpi(obj.signal_freq_,'H4'))
        error('cFORM:init_form:invalid signal frequency input....')
    end
    
    % codes are HARD-coded here for FX
    obj.codes_ = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
    ncodes = length(obj.codes_);
    obj.ei_signal_ = cell(ncodes,1);
    obj.ei_special_ = cell(ncodes,1);
    
    
    nfractal_signal = charlotte_freq2nfractal(obj.signal_freq_);
    if strcmpi(obj.signal_freq_,'H1')
        freq_special = 'M15';
    elseif strcmpi(obj.signal_freq_,'H4')
        freq_special = 'M30';
    end
    
    nfractal_special = charlotte_freq2nfractal(freq_special);
    
    for i = 1:ncodes
        [~,obj.ei_signal_{i}] = charlotte_loaddata('futcode',obj.codes_{i},'frequency',obj.signal_freq_,'nfractal',nfractal_signal,'usemt5',obj.use_mt5_);
        [~,obj.ei_special_{i}] = charlotte_loaddata('futcode',obj.codes_{i},'frequency',freq_special,'nfractal',nfractal_special,'usemt5',obj.use_mt5_);    
    end
    
    
    obj.instruments_ = cell(ncodes,1);
    for i = 1:ncodes
        obj.instruments_{i} = code2instrument(obj.codes_{i});
    end

    obj.gen_trades_best;
        
    fprintf('a cFORM object is created...\n');    
    
        
   