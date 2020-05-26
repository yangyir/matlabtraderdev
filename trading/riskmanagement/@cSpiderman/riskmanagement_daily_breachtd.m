function [unwindtrade] = riskmanagement_daily_breachtd(obj,varargin)
%cSpiderman
    unwindtrade = {};
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('ExtraInfo',{},@isstruct);
    p.parse(varargin{:});
    
    
    
    
end