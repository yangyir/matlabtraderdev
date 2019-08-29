function [ret] = withdrawentrusts(strategy,instrument,varargin)
    if nargin < 2
        %note:withdraw all pending entrusts, i.e.entrusts not associated
        %with any particular instrument
        code_ctp = 'all';
    else
        if ischar(instrument)
            code_ctp = instrument;
        elseif isa(instrument,'cInstrument')
            code_ctp = instrument.code_ctp;
        else
            error('cStrat:withdrawentrusts:invalid instrument input')
        end

    end
    
    ret = strategy.trader_.cancelorders(code_ctp,strategy.helper_,varargin{:});
    
end
%end of withdrawentrusts
