function [] = setspiderman(obj,varargin)
%cSpiderman
    if ~(strcmpi(obj.trade_.status_,'unset') ||...
            strcmpi(obj.status_,'unset')) 
        return; 
    end
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
        %candle time is 09:00:00, which is the candle from 09:00:00 to
        %09:29:59
        idxopen = find(extrainfo.p(:,1) <= trade.opendatetime1_,1,'last')-1;
    end
    
    if isempty(idxopen)
        error('cSpiderman:setspiderman:invalid extrainfo input or trade')
    end
    
    obj.wadopen_ = extrainfo.wad(idxopen);
    obj.cpopen_ = extrainfo.p(idxopen,5);
    if trade.opendirection_ == 1
        obj.wadhigh_ = obj.wadopen_;
        obj.cphigh_ = obj.cpopen_;
    else
        obj.wadlow_ = obj.wadopen_;
        obj.cplow_ = obj.cpopen_;
    end
    
    trade.status_ = 'set';
    obj.status_ = 'set';
    
end