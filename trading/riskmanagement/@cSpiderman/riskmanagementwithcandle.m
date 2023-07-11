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
    p.addParameter('RunRiskManagementBeforeMktClose',false,@islogical);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    extrainfo = p.Results.ExtraInfo;
    runhighlowonly = p.Results.RunHighLowOnly;
    runriskmanagementbeforemktclose = p.Results.RunRiskManagementBeforeMktClose;
    try
        candleTime = extrainfo.p(end,1);
    catch
        extrainfo.p = extrainfo.px;
        candleTime = extrainfo.p(end,1);
    end
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
    
    %note:20200926:further check whether the trade is open with conditional
    %entrust executed but in fact the close price did not breach the
    %relevant barrier and etc
    signalinfo = trade.opensignal_;
    if strcmpi(signalinfo.frequency_,'1440m')
        %todo:avoid for long public holidays
        runriskmanagementbeforemktclose = false;
    end
    if isa(signalinfo,'cFractalInfo')
        if extrainfo.p(end,1) <= trade.opendatetime1_
            val = signalinfo.mode_;
            if strcmpi(val,'conditional-uptrendconfirmed') && extrainfo.p(end,5) < extrainfo.hh(end-1) && extrainfo.p(end,3) > extrainfo.hh(end-1) 
                if runriskmanagementbeforemktclose || ...
                        extrainfo.p(end,5) < max(extrainfo.teeth(end),extrainfo.lips(end))         
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.trade_.status_ = 'closed';
                    obj.trade_.runningpnl_ = 0;
                    instrument = trade.instrument_;
                    if isempty(instrument)
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_);
                    else
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                    end
                    unwindtrade = obj.trade_;
                    return
                end
            elseif strcmpi(val,'conditional-dntrendconfirmed') && extrainfo.p(end,5) > extrainfo.ll(end-1) && extrainfo.p(end,4) < extrainfo.ll(end-1)
                if runriskmanagementbeforemktclose || ...
                        extrainfo.p(end,5) > min(extrainfo.teeth(end),extrainfo.lips(end))         
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.trade_.status_ = 'closed';
                    obj.trade_.runningpnl_ = 0;
                    instrument = trade.instrument_;
                    if isempty(instrument)
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_);
                    else
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                    end
                    unwindtrade = obj.trade_;
                    return
                end
            elseif strcmpi(val,'conditional-breachuplvlup')
                if extrainfo.p(end,5) < extrainfo.hh(end-1) && extrainfo.p(end,3) > extrainfo.hh(end-1)
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.trade_.status_ = 'closed';
                    obj.trade_.runningpnl_ = 0;
                    instrument = trade.instrument_;
                    if isempty(instrument)
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_);
                    else
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                    end
                    unwindtrade = obj.trade_;
                    return
                end
            elseif strcmpi(val,'conditional-breachdnlvldn')
            else
                %do nothing for now
            end
        end
            
    end
    
    [ unwindtrade ] = obj.riskmanagement_tdsq('extrainfo',extrainfo,...
        'updatepnlforclosedtrade',updatepnlforclosedtrade);
    if ~isempty(unwindtrade)
        return
    end
    
    [ unwindtrade ] = obj.riskmanagement_fractal('extrainfo',extrainfo,...
        'updatepnlforclosedtrade',updatepnlforclosedtrade);
    if ~isempty(unwindtrade)
        return
    end
        
    [ unwindtrade ] = obj.riskmanagement_fibonacci('extrainfo',extrainfo,...
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
