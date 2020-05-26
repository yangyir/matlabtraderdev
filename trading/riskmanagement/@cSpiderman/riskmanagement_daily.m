function [unwindtrade] =  riskmanagement_daily(obj,varargin)
%cSpiderman
    unwindtrade = {};
    signalmode = obj.trade_.opensignal_.mode_;
    
    if strcmpi(signalmode,'breachup-lvlup') || ...
            strcmpi(signalmode,'breachup-lvldn') || ...
            strcmpi(signalmode,'breachdn-lvldn') || ...
            strcmpi(signalmode,'breachdn-lvlup')
        [unwindtrade] = obj.riskmanagement_daily_breachtd(varargin{:});
    else
        %not implemented!!!
    end
end