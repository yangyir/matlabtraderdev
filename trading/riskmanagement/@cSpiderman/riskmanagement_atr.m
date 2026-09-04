function [ unwindtrade ] = riskmanagement_atr( obj,varargin )
%cSpiderman
     unwindtrade = {};
    if strcmpi(obj.trade_.status_,'closed'), return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.addParameter('UpdatePnLForClosedTrade',false,@islogical);
    p.parse(varargin{:});
    ei = p.Results.ExtraInfo;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;

    try
        ei.px(end,1);
    catch
        ei.px = ei.p;
    end

    % hard-coded for now
    atrmultipliermax = obj.atrmax_;
    atrmultipliermin = obj.atrmin_;
    lambda = obj.atrlambda_;

    trade = obj.trade_;
    direction = trade.opendirection_;
    openpx = trade.openprice_;

    closeflag = 0;
    if direction == 1
        if ei.px(end,5) < obj.pxstoploss2_
            closeflag = 1;
            obj.closestr_ = 'atr';
        end
    elseif direction == -1
        if ei.px(end,5) > obj.pxstoploss2_
            closeflag = 1;
            obj.closestr_ = 'atr';
        end
    end
    
    if direction == 1
        pnlmax = (ei.px(end,3) - openpx) / obj.atropen_;
        if pnlmax > obj.atrpnlmax_
            obj.atrpnlmax_ = pnlmax;
            if obj.atrpnlmax_ > 1.5
                atrmultiplier = atrmultipliermin + (atrmultipliermax-atrmultipliermin)*exp(-lambda*obj.atrpnlmax_);
            else
                atrmultiplier = atrmultipliermax;
            end
            pxstoploss2 = ei.px(end,3) - atrmultiplier * ei.atr(end);
        else
            hh = obj.atrpnlmax_ * obj.atropen_ + openpx;
            if obj.atrpnlmax_ > 1.5
                atrmultiplier = atrmultipliermin + (atrmultipliermax-atrmultipliermin)*exp(-lambda*obj.atrpnlmax_);
            else
                atrmultiplier = atrmultipliermax;
            end
            pxstoploss2 = hh - atrmultiplier * ei.atr(end);
        end
        obj.pxstoploss2_ = max(obj.pxstoploss2_,pxstoploss2);
    elseif direction == -1
        pnlmax = (openpx - ei.px(end,4)) / obj.atropen_;
        if pnlmax > obj.atrpnlmax_
            obj.atrpnlmax_ = pnlmax;
            if obj.atrpnlmax_ > 1.5
                atrmultiplier = atrmultipliermin + (atrmultipliermax-atrmultipliermin)*exp(-lambda*obj.atrpnlmax_);
            else
                atrmultiplier = atrmultipliermax;
            end
            pxstoploss2 = ei.px(end,4) + atrmultiplier * ei.atr(end);
        else
            ll = openpx - obj.atrpnlmax_* obj.atropen_;
            if obj.atrpnlmax_ > 1.5
                atrmultiplier = atrmultipliermin + (atrmultipliermax-atrmultipliermin)*exp(-lambda*obj.atrpnlmax_);
            else
                atrmultiplier = atrmultipliermax;
            end
            pxstoploss2 = ll + atrmultiplier * ei.atr(end);
        end
        obj.pxstoploss2_ = min(obj.pxstoploss2_,pxstoploss2);
    end
   
    if closeflag
        obj.status_ = 'closed';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            if isempty(trade.instrument_)
                try
                    trade.closepnl_ = direction*trade.openvolume_*(ei.latestopen-trade.openprice_);
                catch
                    trade.closepnl_ = direction*trade.openvolume_*(ei.p(end,5)-trade.openprice_);
                end
            else
                try
                    trade.closepnl_ = direction*trade.openvolume_*(ei.latestopen-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                catch
                    trade.closepnl_ = direction*trade.openvolume_*(ei.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                end
            end
            try
                if ~isfx(trade.code_)
                    trade.closedatetime1_ = ei.latestdt;
                    trade.closeprice_ = ei.latestopen;
                else
                    trade.closedatetime1_ = ei.p(end,1);
                    trade.closeprice_ = ei.p(end,5);
                end
            catch
                trade.closedatetime1_ = ei.p(end,1);
                trade.closeprice_ = ei.p(end,5);
            end
            
        end
        return
    else
        if updatepnlforclosedtrade
            if isempty(trade.instrument_)
                trade.runningpnl_ = direction*trade.openvolume_*(ei.p(end,5)-trade.openprice_);
            else
                trade.runningpnl_ = direction*trade.openvolume_*(ei.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
            end
        end
    end
    
    
        


end