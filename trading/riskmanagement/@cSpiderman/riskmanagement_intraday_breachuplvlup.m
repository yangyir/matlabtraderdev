function [unwindtrade] = riskmanagement_intraday_breachuplvlup(obj,varargin)
%cSpiderman
    unwindtrade = {};
    
    trade = obj.trade_;
    direction = trade.opendirection_;
    
    if direction ~= 1, return; end
    if ~strcmpi(trade.opensignal_.frequency_,'daily'),return;end
    if ~strcmpi(trade.opensignal_.mode_,'breachup-lvlup'), return;end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.parse(varargin{:});
    extrainfo = p.Results.ExtraInfo;
    
    
    idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last')-1;
    if isempty(idxstart2check), return; end
    
    instrument = trade.instrument_;
    if ~isempty(instrument)
        ticksize = instrument.tick_size;
    else
        ticksize = 0;
    end
    
    closeflag = 0;
    candleClose = extrainfo.p(end,5);
    if closeflag == 0 && candleClose < extrainfo.teeth(end)-2*ticksize
        closeflag = 1;
        obj.closestr_ = 'candle close under alligator teeth';
    end
    
    if closeflag
        obj.status_ = 'closed';
        unwindtrade = obj.trade_;
        return
    end
    
end