function [ unwindtrade ] = riskmanagement_fibonacci( obj,varargin )
%cSpiderman
    unwindtrade = {};
    if strcmpi(obj.trade_.status_,'closed'), return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    extrainfo = p.Results.ExtraInfo;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    
    trade = obj.trade_;
    direction = trade.opendirection_;
    closeflag = 0;    

    %backtesting indicates there shall be exclusion for breachup-lvlup
    %trades without alligator's lips being breached but fibonacci:0.618 is
    %triggered.
    exceptionflagb = direction == 1 & ...
        strcmpi(trade.opensignal_.mode_,'breachup-lvlup') & ...
        extrainfo.p(end,5) > extrainfo.lips(end);
    exceptionflagb2 = direction == 1 & ...
        extrainfo.p(end,5) > extrainfo.teeth(end) & ...
        ~isnan(extrainfo.lvlup(end)) & ...
        extrainfo.p(end,5) > extrainfo.lvlup(end);
    
    %not sure about breachdn-lvldn case but we shall leave it as exception
    exceptionflags = direction == -1 & ...
        strcmpi(trade.opensignal_.mode_,'breachdn-lvldn') & ...
        extrainfo.p(end,5) < extrainfo.lips(end);
    
    if direction == 1
        if extrainfo.p(end,5) < obj.fibonacci1_-0.618*(obj.fibonacci1_-obj.fibonacci0_) && ...
                ~exceptionflagb && ~exceptionflagb2 && obj.usefibonacci_
            closeflag = 1;
            obj.closestr_ = 'fibonacci:0.618';
        end
    else
        if extrainfo.p(end,5) > obj.fibonacci0_+0.618*(obj.fibonacci1_-obj.fibonacci0_) && ...
                ~exceptionflags && obj.usefibonacci_
            closeflag = 1;
            obj.closestr_ = 'fibonacci:0.618';
        end
    end
    
    if closeflag
        obj.status_ = 'closed';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            if isempty(trade.instrument_)
                try
                    trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_);
                catch
                    trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_);
                end
            else
                try
                    trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                catch
                    trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                end
            end
            try
                trade.closedatetime1_ = extrainfo.latestdt;
                trade.closeprice_ = extrainfo.latestopen;
            catch
                trade.closedatetime1_ = extrainfo.p(end,1);
                trade.closeprice_ = extrainfo.p(end,5);
            end
            
        end
        return
    else
        if strcmpi(obj.type_,'breachup-B')
            phigh = extrainfo.p(end,3);
            hh = extrainfo.hh(end);
            if phigh > hh
                hh = hh + 0.382*(phigh-hh);
            end
            ll = extrainfo.ll(end);
            if ll > obj.fibonacci0_ && ll == extrainfo.ll(end-1)
                obj.fibonacci0_ = ll;
            end
            if hh > obj.fibonacci1_
                obj.fibonacci1_ = hh;
%                 pstop = phigh - 0.618*(phigh-obj.fibonacci0_);
                ptarget = obj.fibonacci1_ + 1.618*(obj.fibonacci1_-obj.fibonacci0_);
                if ~isempty(trade.instrument_)
                    ticksize = trade.instrument_.tick_size;
%                     pstop = floor(pstop/ticksize)*ticksize;
                    ptarget = ceil(ptarget/ticksize)*ticksize;
                end
%                 if pstop > obj.pxstoploss_
%                     obj.pxstoploss_ = pstop;
%                     obj.closestr_ = 'fibonacci:0.618';
%                 end
                if ptarget > obj.pxtarget_
                    obj.pxtarget_ = ptarget;
                end
            end
            if extrainfo.p(end,5) < obj.fibonacci1_-0.618*(obj.fibonacci1_-obj.fibonacci0_) && ...
                    ~exceptionflagb && ~exceptionflagb2 && obj.usefibonacci_
                obj.status_ = 'closed';
                obj.closestr_ = 'fibonacci:0.618';
                unwindtrade = obj.trade_;
                if updatepnlforclosedtrade
                    trade.status_ = 'closed';
                    trade.runningpnl_ = 0;
                    if isempty(trade.instrument_)
                        try
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_);
                        catch
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_);
                        end
                    else
                        try
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                        catch
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                        end
                    end
                    try
                        trade.closedatetime1_ = extrainfo.latestdt;
                        trade.closeprice_ = extrainfo.latestopen;
                    catch
                        trade.closedatetime1_ = extrainfo.p(end,1);
                        trade.closeprice_ = extrainfo.p(end,5);
                    end
                end
                return
            end
            %
        elseif strcmpi(obj.type_,'breachdn-S')
            plow = extrainfo.p(end,4);
            ll = extrainfo.ll(end);
            if plow < ll
                ll = ll - 0.382*(ll-plow);
            end
            hh = extrainfo.hh(end);
            if hh < obj.fibonacci1_, obj.fibonacci1_ = hh;end
            if ll < obj.fibonacci0_
                obj.fibonacci0_ = ll;
%                 pstop = ll + 0.618*(ll-obj.fibonacci0_);
                ptarget = obj.fibonacci0_ - 1.618*(obj.fibonacci1_-obj.fibonacci0_);
                if ~isempty(trade.instrument_)
                    ticksize = trade.instrument_.tick_size;
%                     pstop = ceil(pstop/ticksize)*ticksize;
                    ptarget = floor(ptarget/ticksize)*ticksize;
                end
%                 if pstop < obj.pxstoploss_
%                     obj.pxstoploss_ = pstop;
%                     obj.closestr_ = 'fibonacci:0.618';
%                 end
                if ptarget < obj.pxtarget_
                    obj.pxtarget_ = ptarget;
                end
            end
            if extrainfo.p(end,5) > obj.fibonacci0_+0.618*(obj.fibonacci1_-obj.fibonacci0_) && ...
                    ~exceptionflags && obj.usefibonacci_
                obj.status_ = 'closed';
                obj.closestr_ = 'fibonacci:0.618';
                unwindtrade = obj.trade_;
                if updatepnlforclosedtrade
                    trade.status_ = 'closed';
                    trade.runningpnl_ = 0;
                    if isempty(trade.instrument_)
                        try
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_);
                        catch
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_);
                        end
                    else
                        try
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                        catch
                            trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                        end
                    end
                    try
                        trade.closedatetime1_ = extrainfo.latestdt;
                        trade.closeprice_ = extrainfo.latestopen;
                    catch
                        trade.closedatetime1_ = extrainfo.p(end,1);
                        trade.closeprice_ = extrainfo.p(end,5);
                    end
                end
                return
            end
        else 
            error('cSpiderman:riskmanagement_fibonacci:%s not implemented',obj.type_)
        end
    end
    
    
    

end

