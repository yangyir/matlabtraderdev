function [unwindtrade] = riskmanagementwithcandle(obj,candlek,varargin)
%cSpiderman
    variablenotused(candlek);
    unwindtrade = {};
%     if strcmpi(obj.status_,'closed'), return; end
    if strcmpi(obj.trade_.status_,'closed'), return; end
    if obj.pxstoploss_ == -9.99, return;end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('UseCandleLastOnly',false,@islogical);
    p.addParameter('Debug',false,@islogical)
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.addParameter('ExtraInfo',{},@isstruct);
    p.addParameter('RunHighLowOnly',false,@islogical);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    extrainfo = p.Results.ExtraInfo;
    runhighlowonly = p.Results.RunHighLowOnly;
    
    candleTime = extrainfo.p(end,1);
    candleOpen = extrainfo.p(end,2);
    candleHigh = extrainfo.p(end,3);
    candleLow = extrainfo.p(end,4);
    candleClose = extrainfo.p(end,5);
    
    trade = obj.trade_;
    direction = trade.opendirection_;
    volume = trade.openvolume_;
    instrument = trade.instrument_;
            
    if strcmpi(trade.status_,'unset') || strcmpi(obj.status_,'unset')
        obj.setspiderman('extrainfo',extrainfo);
    end
    
    if ~usecandlelastonly
        unwindtrade = obj.candlehighlow(candleTime,candleOpen,candleHigh,candleLow,updatepnlforclosedtrade);
        if ~isempty(unwindtrade)
            return
        end  
    end
    % for cETFWatcher useage only
    if runhighlowonly, return;end
    
    if strcmpi(trade.opensignal_.frequency_,'daily')
        idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first')+1;
    else
        idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last')-1;
    end
    if isempty(idxstart2check), return; end
        
    [ unwindtrade ] = obj.riskmanagement_fibonacci('extrainfo',extrainfo,...
        'updatepnlforclosedtrade',updatepnlforclosedtrade);
    if ~isempty(unwindtrade)
        return
    end
    
    [ unwindtrade ] = obj.riskmanagement_fractal('extrainfo',extrainfo,...
        'updatepnlforclosedtrade',updatepnlforclosedtrade);
    if ~isempty(unwindtrade)
        return
    end
    
    [ unwindtrade ] = obj.riskmanagement_tdsq('extrainfo',extrainfo,...
        'updatepnlforclosedtrade',updatepnlforclosedtrade);
    if ~isempty(unwindtrade)
        return
    end
    
    [ unwindtrade ] = obj.riskmanagement_wad('extrainfo',extrainfo, ...
        'updatepnlforclosedtrade',updatepnlforclosedtrade);
    if ~isempty(unwindtrade)
        return
    end
    
    obj.updatestoploss('extrainfo',extrainfo);
    %
    if isempty(instrument)
        obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_);
    else
        obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_)/instrument.tick_size * instrument.tick_value;
    end
    
end
