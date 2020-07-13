function [ unwindtrade ] = riskmanagement_wad( obj,varargin )
%cSpiderman method
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
    
    ret = obj.riskmanagement_wadupdate('extrainfo',extrainfo);
    closeflag = 0;
    
    if direction == 1
        if ret.inconsistence && strcmpi(ret.reason,'new high wad w/o price being higher')
            if extrainfo.latestopen < obj.cphigh_
                closeflag = ret.inconsistence;
                obj.closestr_ = ['wad:',ret.reason];
            else
                %if latest open jumps and moves higher than the highest
                %close so far, the trade can be saved
            end
        elseif ret.inconsistence && ...
                (strcmpi(ret.reason,'higher price to open w/o wad being higher') || ...
                strcmpi(ret.reason,'same price to open with lower wad'))
            %use the lastest open to recalculate wad
            if extrainfo.latestopen > extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - min(extrainfo.p(end,4),extrainfo.p(end-1,5));
            elseif extrainfo.latestopen == extrainfo.p(end-1,5)
                pmove = 0;
            elseif extrainfo.latestopen < extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - max(extrainfo.p(end,3),extrainfo.p(end-1,5));
            end
            wadadj = extrainfo.wad(end-1)+pmove;
            if wadadj < obj.wadopen_
                closeflag = ret.inconsistence;
                obj.closestr_ = ['wad:',ret.reason];
            else
                %if the re-calculated wad is higher than the open wad, the
                %trade can be saved
            end
        elseif ret.inconsistence && strcmpi(ret.reason,'new high price w/o wad being higher')
            %use the lastest open to recalculate wad
            if extrainfo.latestopen > extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - min(extrainfo.p(end,4),extrainfo.p(end-1,5));
            elseif extrainfo.latestopen == extrainfo.p(end-1,5)
                pmove = 0;
            elseif extrainfo.latestopen < extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - max(extrainfo.p(end,3),extrainfo.p(end-1,5));
            end
            wadadj = extrainfo.wad(end-1)+pmove;
            if wadadj < obj.wadhigh_
                closeflag = ret.inconsistence;
                obj.closestr_ = ['wad:',ret.reason];
            else
                %if the re-calculated wad is higher than the highest wad so
                %far, the trade can be saved
            end
        else
            closeflag = ret.inconsistence;
            obj.closestr_ = ret.reason;
        end
    else
        ret = obj.riskmanagement_wadupdate('extrainfo',extrainfo);
        if ret.inconsistence && strcmpi(ret.reason,'new low wad w/o price being lower')
            if extrainfo.latestopen > obj.cplow_
                closeflag = ret.inconsistence;
                obj.closestr_ = ['wad:',ret.reason];
            else
                %if latest open jumps and moves lower than the lowest close
                %so far, the trade can be saved
            end
        elseif ret.inconsistence && ...
                (strcmpi(ret.reason,'lower price to open w/o wad being lower') ||...
                strcmpi(ret.reason,'same price to open with higher wad'))
            %use the lastest open to recalculate wad
            if extrainfo.latestopen > extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - min(extrainfo.p(end,4),extrainfo.p(end-1,5));
            elseif extrainfo.latestopen == extrainfo.p(end-1,5)
                pmove = 0;
            elseif extrainfo.latestopen < extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - max(extrainfo.p(end,3),extrainfo.p(end-1,5));
            end
            wadadj = extrainfo.wad(end-1)+pmove;
            if wadadj > obj.wadopen_
                closeflag = ret.inconsistence;
                obj.closestr_ = ['wad:',ret.reason];
            else
                %if the re-calculated wad is lower than the open wad, the
                %trade can be saved
            end
        elseif ret.inconsistence && strcmpi(ret.reason,'new low price w/o wad being lower')
            %use the lastest open to recalculate wad
            if extrainfo.latestopen > extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - min(extrainfo.p(end,4),extrainfo.p(end-1,5));
            elseif extrainfo.latestopen == extrainfo.p(end-1,5)
                pmove = 0;
            elseif extrainfo.latestopen < extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - max(extrainfo.p(end,3),extrainfo.p(end-1,5));
            end
            wadadj = extrainfo.wad(end-1)+pmove;
            if wadadj > obj.wadlow_
                closeflag = ret.inconsistence;
                obj.closestr_ = ['wad:',ret.reason];
            else
                %if the re-calculated wad is lower than the lowest wad
                %so far, the trade can be saved
            end
        else
            closeflag = ret.inconsistence;
            obj.closestr_ = ret.reason;
        end
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

