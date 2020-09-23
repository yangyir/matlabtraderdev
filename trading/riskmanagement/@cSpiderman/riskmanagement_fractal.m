function [ unwindtrade ] = riskmanagement_fractal( obj,varargin )
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
    
    if ~isempty(trade.instrument_)
        ticksize = trade.instrument_.tick_size;
    else
        ticksize = 0;
    end

    hh = extrainfo.hh(end);
    ll = extrainfo.ll(end);
       
    if direction == 1
        if extrainfo.p(end,5) < extrainfo.lips(end)-ticksize
            closeflag = 1;
            obj.closestr_ = 'fractal:lips';
        else
            if hh > obj.hh1_
                obj.hh0_ = obj.hh1_;
                obj.hh1_ = hh;
            end
            if ll > obj.ll1_
                obj.ll0_ = obj.ll1_;
                obj.ll1_ = ll;
            end
            if extrainfo.p(end,5) < 1.382*obj.hh0_-0.382*obj.hh1_ && obj.hh1_ - obj.hh0_ > 2*ticksize
                closeflag = 1;
                obj.closestr_ = 'fractal:update';
            else
%                 obj.pxtarget_ = obj.hh1_ + 1.618*(obj.hh1_-obj.ll1_);
%                 if ~isempty(trade.instrument_)
%                     ticksize = trade.instrument_.tick_size;
%                     obj.pxtarget_ = ceil(obj.pxtarget_/ticksize)*ticksize;
%                 end
                if extrainfo.teeth(end) > obj.pxstoploss_
                    if ~isempty(trade.instrument_)
                        ticksize = trade.instrument_.tick_size;
                        obj.pxstoploss_ = floor(extrainfo.teeth(end)/ticksize)*ticksize;
                    end
                    obj.closestr_ = 'fractal:teeth';
                end 
            end
        end
        %
    else
        if extrainfo.p(end,5) > extrainfo.lips(end)+ticksize
            closeflag = 1;
            obj.closestr_ = 'fractal:lips';
        else
            if ll < obj.ll1_
                obj.ll0_ = obj.ll1_;
                obj.ll1_ = ll;
            end
            if hh < obj.hh1_
                obj.hh0_ = obj.hh1_;
                obj.hh1_ = hh;
            end
            if extrainfo.p(end,5) > 0.382*obj.ll0_+1.382*obj.ll1_ && obj.ll1_ - obj.ll0_ <-2*ticksize
                closeflag = 1;
                obj.closestr_ = 'fractal:update';
            else
%                 obj.pxtarget_ = obj.ll1_ - 1.618*(obj.hh1_-obj.ll1_);
%                 if ~isempty(trade.instrument_)
%                     ticksize = trade.instrument_.tick_size;
%                     obj.pxtarget_ = floor(obj.pxtarget_/ticksize)*ticksize;
%                 end
                if extrainfo.teeth(end) < obj.pxstoploss_
                    obj.pxstoploss_ = extrainfo.teeth(end);
                    if ~isempty(trade.instrument_)
                        ticksize = trade.instrument_.tick_size;
                        obj.pxstoploss_ = ceil(extrainfo.teeth(end)/ticksize)*ticksize;
                    end
                    obj.closestr_ = 'fractal:teeth';
                end
            end
        end
        %
    end
    
    if closeflag
        obj.status_ = 'closed';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            if isempty(trade.instrument_)
                trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_);
            else
                trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
            end
            trade.closedatetime1_ = extrainfo.p(end,1);
            trade.closeprice_ = extrainfo.p(end,5);
        end
    end
    
end

