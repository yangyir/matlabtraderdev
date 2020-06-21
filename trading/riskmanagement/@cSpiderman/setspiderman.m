function [] = setspiderman(obj,varargin)
%cSpiderman
    if ~strcmpi(obj.trade_.status_,'unset'), return; end
    %
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.parse(varargin{:});
    extrainfo = p.Results.ExtraInfo;
    
    trade = obj.trade_;
    
    if strcmpi(obj.trade_.opensignal_.frequency_,'daily')
        %the open time shall be the same of the candle time in daily
        %frequency trade
        idxopen = find(extrainfo.p(:,1) <= trade.opendatetime1_,1,'last');
    else
        %the open time shall be 1 sec ahead of the next candle time
        %e.g.the trade's open time is 09:30:01,however,the close price
        %recorded time is 09:00:00, which is the candle from 09:00:00 to
        %09:29:59
        
    end
end