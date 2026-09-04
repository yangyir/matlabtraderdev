function obj = init(obj,varargin)
% a charlotteTraderFX method
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('codes',{},@iscell);
    p.addParameter('freqs',{},@iscell);
    p.parse(varargin{:});
    
    codes = p.Results.codes;
    freqs = p.Results.freqs;
    ncodes = size(codes,1);
    if ncodes ~= size(freqs,1)
        error('charlotteTraderFX:size mismatch between input codes and freqs')
    end
    
    obj.codes_ = codes;
    obj.freqs_ = freqs;
    
    obj.signals_ = cell(ncodes,1);
    obj.ei_signal_ = cell(ncodes,1);
    
    obj.book_ = cTradeOpenArray;
    obj.pendingbook_ = cTradeOpenArray;
    obj.specialbook_ = cTradeOpenArray;
    try
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_m15.mat']);
        obj.kellytables_m15_ = data.strat_fx_m15;
    catch
        obj.kellytables_m15_ = [];
    end
    %
    try
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_m30.mat']);
        obj.kellytables_m30_ = data.strat_fx_m30;
    catch
        obj.kellytables_m30_ = [];
    end
    %
    try
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_h1.mat']);
        obj.kellytables_h1_ = data.strat_fx_h1;
    catch
        obj.kellytables_h1_ = [];
    end
    %
    try
        data = load([getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\strat_fx_h4.mat']);
        obj.kellytables_h4_ = data.strat_fx_h4;
    catch
        obj.kellytables_h4_ = [];
    end
    %
    
    
end