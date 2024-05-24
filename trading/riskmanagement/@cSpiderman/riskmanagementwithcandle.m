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
    p.addParameter('KellyTables',{},@isstruct);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    extrainfo = p.Results.ExtraInfo;
    runhighlowonly = p.Results.RunHighLowOnly;
    runriskmanagementbeforemktclose = p.Results.RunRiskManagementBeforeMktClose;
    kellytables = p.Results.KellyTables;
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
                %speical treatment for tin and nickel as they are very
                %volotile
                if strcmpi(trade.instrument_.asset_name,'tin')
                    if ~(extrainfo.p(end,2) < extrainfo.p(end,5) && extrainfo.ss(end) >= 3)
                        obj.trade_.closedatetime1_ = extrainfo.latestdt;
                        obj.trade_.closeprice_ = extrainfo.latestopen;
                        volume = trade.openvolume_;
                        obj.status_ = 'closed';
                        obj.closestr_ = 'conditional uptrendconfirmed failed to breach';
                        obj.trade_.status_ = 'closed';
                        obj.trade_.runningpnl_ = 0;
                        instrument = trade.instrument_;
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                        unwindtrade = obj.trade_;
                    return
                    end
                end
                if runriskmanagementbeforemktclose || ...
                        extrainfo.p(end,5) < max(extrainfo.teeth(end),extrainfo.lips(end))
                    %special case that the close is above lvlup and the
                    %close is above teeth and lips is above teeth
                    if extrainfo.p(end,5) > extrainfo.lvlup(end) && ...
                            extrainfo.p(end,5) > extrainfo.teeth(end) && ...
                            extrainfo.lips(end) > extrainfo.teeth(end)
                        %donothing
                        thisbd = floor(candleTime);
                        nextbd = dateadd(thisbd,'1b');
                        if nextbd - thisbd <= 3
                            return
                        end
                    else
                        obj.trade_.closedatetime1_ = extrainfo.latestdt;
                        obj.trade_.closeprice_ = extrainfo.latestopen;
                        volume = trade.openvolume_;
                        obj.status_ = 'closed';
                        obj.trade_.status_ = 'closed';
                        if runriskmanagementbeforemktclose
                            obj.closestr_ = 'conditional-uptrendconfirmed failed before market closes';
                        else
                            obj.closestr_ = 'conditional-uptrendconfirmed failed';
                        end
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
                end
            elseif runriskmanagementbeforemktclose && strcmpi(val,'conditional-uptrendconfirmed') && extrainfo.p(end,5) > extrainfo.hh(end-1) && extrainfo.p(end-1,5) < extrainfo.hh(end-1) 
                if extrainfo.p(end,1) - extrainfo.p(end-1,1) >= 1
                    nfractal = 2;
                elseif extrainfo.p(end,1) - extrainfo.p(end-1,1) <= 5/1440
                    nfractal = 6;
                else
                    nfractal = 4;
                end
                status = fractal_b1_status(nfractal,extrainfo,trade.instrument_.tick_size);
                if status.islvlupbreach
                    tbl = kellytables.breachdnlvlup_tc;
                    idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
                    kelly = tbl.K(idx);
                elseif status.isvolblowup
                    kelly = kelly_k('volblowup',trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l);
                elseif status.issshighbreach
                    tbl = kellytables.breachupsshighvalue_tc;
                    idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
                    kelly = tbl.K(idx);
                elseif status.isschighbreach
                    tbl = kellytables.breachuphighsc13;
                    idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
                    kelly = tbl.K(idx);
                else
                    if status.b1type == 2
                        kelly = kelly_k('mediumbreach-trendconfirmed',trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l);
                    elseif status.b1type == 3
                        kelly = kelly_k('strongbreach-trendconfirmed',trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l);
                    end 
                end
                if kelly < 0.145
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.trade_.status_ = 'closed';
                    obj.closestr_ = 'conditional uptrendconfirmed failed as kelly is low';
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
                %speical treatment for tin and nickel as they are very
                %volotile
                if strcmpi(trade.instrument_.asset_name,'tin')
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.closestr_ = 'conditional dntrendconfirmed failed to breach';
                    obj.trade_.status_ = 'closed';
                    obj.trade_.runningpnl_ = 0;
                    instrument = trade.instrument_;
                    obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                    unwindtrade = obj.trade_;
                    return
                end
                %
                isbreachdnlvldn = extrainfo.ll(end) <= extrainfo.lvldn(end) && extrainfo.p(end,5) > extrainfo.lvldn(end);
                if isbreachdnlvldn
                    tbl2lookup = kellytables.breachdnlvldn_tc;
                    idx = strcmpi(tbl2lookup.asset,trade.instrument_.asset_name);
                    kelly = tbl2lookup.K(idx);
                    if kelly < 0.15
                        obj.trade_.closedatetime1_ = extrainfo.latestdt;
                        obj.trade_.closeprice_ = extrainfo.latestopen;
                        volume = trade.openvolume_;
                        obj.status_ = 'closed';
                        obj.trade_.status_ = 'closed';
                        obj.closestr_ = 'conditional breachdn-lvldn failed';
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
                    return
                end
                %
                if runriskmanagementbeforemktclose || ...
                        extrainfo.p(end,5) > min(extrainfo.teeth(end),extrainfo.lips(end))         
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.trade_.status_ = 'closed';
                    if runriskmanagementbeforemktclose
                        obj.closestr_ = 'conditional-dntrendconfirmed failed before market closes';
                    else
                        obj.closestr_ = 'conditional-dntrendconfirmed failed';
                    end
                    obj.trade_.runningpnl_ = 0;
                    instrument = trade.instrument_;
                    if isempty(instrument)
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_);
                    else
                        obj.trade_.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_)/instrument.tick_size * instrument.tick_value;
                    end
                    unwindtrade = obj.trade_;
                    return
                else
                    %special treatment for conditional-breachdn-bshighvalue
                    lastbsidx = find(extrainfo.bs >= 9,1,'last');
                    ndiff = size(extrainfo.bs,1)-lastbsidx;
                    if ndiff <= 13
                        lastbsval = extrainfo.bs(lastbsidx);
                        bslow = min(extrainfo.p(lastbsidx-lastbsval+1:lastbsidx,4));
                        if bslow == extrainfo.ll(end)
                            %here we confirm it is a conditional-breachdnbshighvalue
                            tbl2lookup = kellytables.breachdnbshighvalue_tc;
                            idx = strcmpi(tbl2lookup.asset,trade.instrument_.asset_name);
                            kelly = tbl2lookup.K(idx);
                            if kelly < 0.145                          
                                obj.trade_.closedatetime1_ = extrainfo.latestdt;
                                obj.trade_.closeprice_ = extrainfo.latestopen;
                                volume = trade.openvolume_;
                                obj.status_ = 'closed';
                                obj.trade_.status_ = 'closed';
                                obj.closestr_ = 'conditional breachdn-bshighvalue failed';
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
                        end
                    end
                end
            elseif runriskmanagementbeforemktclose && strcmpi(val,'conditional-dntrendconfirmed') && extrainfo.p(end,5) < extrainfo.ll(end-1) && extrainfo.p(end-1,5) > extrainfo.ll(end-1)
                if extrainfo.p(end,1) - extrainfo.p(end-1,1) >= 1
                    nfractal = 2;
                elseif extrainfo.p(end,1) - extrainfo.p(end-1,1) <= 5/1440
                    nfractal = 6;
                else
                    nfractal = 4;
                end  
                status = fractal_s1_status(nfractal,extrainfo,trade.instrument_.tick_size);
                if status.islvldnbreach
                    tbl = kellytables.breachdnlvldn_tc;
                    idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
                    kelly = tbl.K(idx);
                elseif status.isvolblowup
                    kelly = kelly_k('volblowup',trade.instrument_.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
                elseif status.isbslowbreach
                    tbl = kellytables.breachdnbshighvalue_tc;
                    idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
                    kelly = tbl.K(idx);
                elseif status.isbclowbreach
                    tbl = kellytables.breachdnlowbc13;
                    idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
                    kelly = tbl.K(idx);
                else
                    if status.s1type == 2
                        kelly = kelly_k('mediumbreach-trendconfirmed',trade.instrument_.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
                    elseif status.s1type == 3
                        kelly = kelly_k('strongbreach-trendconfirmed',trade.instrument_.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
                    end 
                end
                if kelly < 0.145
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.trade_.status_ = 'closed';
                    obj.closestr_ = 'conditional dntrendconfirmed failed as kelly is low';
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
                %
            elseif strcmpi(val,'conditional-breachuplvlup')
                if extrainfo.p(end,5) < extrainfo.hh(end-1) && extrainfo.p(end,3) > extrainfo.hh(end-1)
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                    volume = trade.openvolume_;
                    obj.status_ = 'closed';
                    obj.trade_.status_ = 'closed';
                    obj.closestr_ = 'conditional-breachuplvlup failed as highest price fails to breach hh';
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
    
    %special case when a long dated public holiday is ahead
    if runriskmanagementbeforemktclose
        thisbd = floor(candleTime);
        nextbd = dateadd(thisbd,'1b');
        if nextbd - thisbd > 3 && hour(candleTime) >= 9
            unwindtrade = trade;
            obj.closestr_ = 'long holiday';
            obj.status_ = 'closed';
            trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            trade.closeprice_ = extrainfo.p(end,5);
            trade.closedatetime1_ = extrainfo.p(end,1);
            if isempty(trade.instrument_)
                trade.closepnl_ = direction*trade.openvolume_*(trade.closeprice_-trade.openprice_);
            else
                trade.closepnl_ = direction*trade.openvolume_*(trade.closeprice_-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
            end
            return
        end
    end
    %
    %special case when tdsq ss>=9 with sc=13 or bs>=9 with bc=13 and a
    %weekend ahead
    if runriskmanagementbeforemktclose
        thisbd = floor(candleTime);
        nextbd = dateadd(thisbd,'1b');
        if nextbd - thisbd == 3
            if (direction == 1 && extrainfo.ss(end) >= 9 && extrainfo.sc(end) == 13) || ...
                    (direction == -1 && extrainfo.bs(end) >= 9 && extrainfo.bc(end) == 13)
                unwindtrade = trade;
                if direction == 1
                    obj.closestr_ = 'tdsq:sc13limit';
                else
                    obj.closestr_ = 'tdsq:bc13limit';
                end
                obj.status_ = 'closed';
                trade.status_ = 'closed';
                trade.runningpnl_ = 0;
                trade.closeprice_ = extrainfo.p(end,5);
                trade.closedatetime1_ = extrainfo.p(end,1);
                if isempty(trade.instrument_)
                    trade.closepnl_ = direction*trade.openvolume_*(trade.closeprice_-trade.openprice_);
                else
                    trade.closepnl_ = direction*trade.openvolume_*(trade.closeprice_-trade.openprice_)/trade.instrument_.tick_size * trade.instrument_.tick_value;
                end
            end 
        end
    end
    %
    %in case it is a up-breach of fractal barrier, we shall calculate kelly
    if runriskmanagementbeforemktclose && extrainfo.p(end,5) > extrainfo.hh(end-1) && extrainfo.p(end-1,5) < extrainfo.hh(end-1)
        if extrainfo.p(end,1) - extrainfo.p(end-1,1) >= 1
            nfractal = 2;
        elseif extrainfo.p(end,1) - extrainfo.p(end-1,1) <= 5/1440
            nfractal = 6;
        else
            nfractal = 4;
        end
        ei = extrainfo;
        ei.px = ei.p;
        [~,op] = fractal_signal_unconditional(ei,trade.instrument_.tick_size,nfractal);
        try
            kelly = kelly_k(op.comment,trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l);
            wprob = kelly_w(op.comment,trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l);
        catch
            kelly = -9.99;
            wprob = 0;
        end
        if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
            obj.trade_.closedatetime1_ = extrainfo.latestdt;
            obj.trade_.closeprice_ = extrainfo.latestopen;
            volume = trade.openvolume_;
            obj.status_ = 'closed';
            obj.trade_.status_ = 'closed';
            obj.closestr_ = ['up:',op.comment,':kelly is low'];
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
    end
    %
    %in case it is a dn-breach of fractal barrier, we shall calculate kelly
    if runriskmanagementbeforemktclose && extrainfo.p(end,5) < extrainfo.ll(end-1) && extrainfo.p(end-1,5) > extrainfo.ll(end-1)
        if extrainfo.p(end,1) - extrainfo.p(end-1,1) >= 1
            nfractal = 2;
        elseif extrainfo.p(end,1) - extrainfo.p(end-1,1) <= 5/1440
            nfractal = 6;
        else
            nfractal = 4;
        end
        ei = extrainfo;
        ei.px = ei.p;
        [~,op] = fractal_signal_unconditional(ei,trade.instrument_.tick_size,nfractal);
        try
            kelly = kelly_k(op.comment,trade.instrument_.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
            wprob = kelly_w(op.comment,trade.instrument_.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
        catch
            kelly = -9.99;
            wprob = 0;
        end
        if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
            obj.trade_.closedatetime1_ = extrainfo.latestdt;
            obj.trade_.closeprice_ = extrainfo.latestopen;
            volume = trade.openvolume_;
            obj.status_ = 'closed';
            obj.trade_.status_ = 'closed';
            obj.closestr_ = ['dn:',op.comment,':kelly is low'];
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
    end
    %
    if isempty(instrument)
        obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_);
    else
        obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_)/instrument.tick_size * instrument.tick_value;
    end
    
end
