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
    ticksize = obj.trade_.instrument_.tick_size;
    
    if direction == 1
        if ret.inconsistence && strcmpi(ret.reason,'new high wad w/o price being higher')
            if extrainfo.latestopen < obj.cphigh_
                if strcmpi(trade.opensignal_.frequency_,'daily')
                    closeflag = ret.inconsistence;
                end
%                 obj.pxstoploss_ = max(extrainfo.p(end,4),extrainfo.lips(end));
                obj.pxstoploss_ = max(2*extrainfo.p(end,4)-extrainfo.p(end,3),extrainfo.lips(end));
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
            else
                pmove = 0;
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
            %note:20200716
            %there is one exception that 1)the new price is a valid breach
            %of fractal hh
            nfractal = trade.opensignal_.nfractal_;
            flag1 = extrainfo.p(end,5)>=extrainfo.hh(end-1)&&...
                extrainfo.p(end-1,5)<extrainfo.hh(end-1)&&...
                extrainfo.hh(end-1)==extrainfo.hh(end);
            if isempty(find(extrainfo.p(:,5)<extrainfo.teeth,1,'last'))
                flag2 = size(extrainfo.p,1)>=2*nfractal+1;
            else
                flag2 = size(extrainfo.p,1)-find(extrainfo.p(:,5)<extrainfo.teeth,1,'last')>=2*nfractal+1;
            end
            flag3 = extrainfo.teeth(end) > extrainfo.jaw(end);
            if flag1 && flag2 && flag3
                return
            end
            %note:20220915
            %there is one exception that 2)the new price is a valid breach
            %of tdsq lvlup with tdsq lvlup being above fractal hh
            flag1 = extrainfo.p(end,5)>=extrainfo.lvlup(end-1)&&...
                extrainfo.p(end-1,5)<extrainfo.lvlup(end-1)&&...
                extrainfo.lvlup(end-1)==extrainfo.lvlup(end)&&...
                extrainfo.lvlup(end-1)>extrainfo.hh(end-1)&&...
                extrainfo.hh(end-1)==extrainfo.hh(end);
            if flag1
                return
            end
            %
            %use the lastest open to recalculate wad
            if extrainfo.latestopen > extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - min(extrainfo.p(end,4),extrainfo.p(end-1,5));
            elseif extrainfo.latestopen == extrainfo.p(end-1,5)
                pmove = 0;
            elseif extrainfo.latestopen < extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - max(extrainfo.p(end,3),extrainfo.p(end-1,5));
            else
                pmove = 0;
            end
            wadadj = extrainfo.wad(end-1)+pmove;
            if wadadj - obj.wadhigh_ <= -2*ticksize
                closeflag = ret.inconsistence;
                obj.closestr_ = ['wad:',ret.reason];
            else
                %if the re-calculated wad is higher than the highest wad so
                %far, the trade can be saved
            end
        else
            closeflag = ret.inconsistence;
%             obj.closestr_ = ret.reason;
        end
    else
%         ret = obj.riskmanagement_wadupdate('extrainfo',extrainfo);
        if ret.inconsistence && strcmpi(ret.reason,'new low wad w/o price being lower')
            if extrainfo.latestopen > obj.cplow_
                if strcmpi(trade.opensignal_.frequency_,'daily')
                    closeflag = ret.inconsistence;
                end
%                 obj.pxstoploss_ =  min(extrainfo.p(end,3),extrainfo.lips(end));
                obj.pxstoploss_ =  min(2*extrainfo.p(end,3)-extrainfo.p(end,4),extrainfo.lips(end));
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
            else
                pmove = 0;
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
            %note:20200716
            %there is one exception that 1)the new price is a valid breach
            %of fractal ll
            nfractal = trade.opensignal_.nfractal_;
            flag1 = extrainfo.p(end,5)<extrainfo.ll(end-1)&&...
                extrainfo.p(end-1,5)>extrainfo.ll(end-1)&&...
                extrainfo.ll(end-1)==extrainfo.ll(end);
            flag2 = size(extrainfo.p,1)-find(extrainfo.p(:,5)>extrainfo.teeth,1,'last')>=2*nfractal+1;
            if isempty(flag2)
                flag2 = false;
            end
            flag3 = extrainfo.teeth(end) < extrainfo.jaw(end);
            if flag1 && flag2 && flag3
                return
            end
            %note:20220929
            %there is another exception that 2)the new price is a valid
            %breach of lvldn
            flag1_ = extrainfo.p(end,5)<extrainfo.lvldn(end-1)&&...
                extrainfo.p(end-1,5)>extrainfo.lvldn(end-1)&&...
                extrainfo.lvldn(end-1)==extrainfo.lvldn(end);
            if flag1_ && flag2
                return
            end
            %use the lastest open to recalculate wad
            if extrainfo.latestopen > extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - min(extrainfo.p(end,4),extrainfo.p(end-1,5));
            elseif extrainfo.latestopen == extrainfo.p(end-1,5)
                pmove = 0;
            elseif extrainfo.latestopen < extrainfo.p(end-1,5)
                pmove = extrainfo.latestopen - max(extrainfo.p(end,3),extrainfo.p(end-1,5));
            else
                pmove = 0;
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
%             obj.closestr_ = ret.reason;
        end
    end
    
    if closeflag
        obj.status_ = 'closed';
        unwindtrade = obj.trade_;
        if updatepnlforclosedtrade
            trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            if isempty(trade.instrument_)
%                 trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_);
                trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_);
            else
%                 trade.closepnl_ = direction*trade.openvolume_*(extrainfo.p(end,5)-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                trade.closepnl_ = direction*trade.openvolume_*(extrainfo.latestopen-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
            end
%             trade.closedatetime1_ = extrainfo.p(end,1);
%             trade.closeprice_ = extrainfo.p(end,5);
            trade.closedatetime1_ = extrainfo.latestdt;
            trade.closeprice_ = extrainfo.latestopen;
        end
    end

end

