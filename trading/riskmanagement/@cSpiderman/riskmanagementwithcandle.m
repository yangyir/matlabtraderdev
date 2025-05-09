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
    p.addParameter('CompulsoryCheckForConditional',true,@islogical);
    p.parse(varargin{:});
    usecandlelastonly = p.Results.UseCandleLastOnly;
    doprint = p.Results.Debug;
    updatepnlforclosedtrade = p.Results.UpdatePnLForClosedTrade;
    extrainfo = p.Results.ExtraInfo;
    runhighlowonly = p.Results.RunHighLowOnly;
    runriskmanagementbeforemktclose = p.Results.RunRiskManagementBeforeMktClose;
    kellytables = p.Results.KellyTables;
    compulsorycheck = p.Results.CompulsoryCheckForConditional;
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
    
    if ~isfx(trade.code_)
        if strcmpi(trade.opensignal_.frequency_,'daily')
            idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first')+1;
        else
            idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last')-1;
        end
    else
        if strcmpi(trade.opensignal_.frequency_,'daily')
            idxstart2check = find(extrainfo.p(:,1)>=trade.opendatetime1_,1,'first')+1;
        else
            if isempty(strfind(trade.opensignal_.mode_,'conditional'))
                idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last');
            else
                idxstart2check = find(extrainfo.p(:,1)<=trade.opendatetime1_,1,'last');
            end
        end
    end
    if isempty(idxstart2check), return; end
    if idxstart2check > size(extrainfo.p,1), return;end
    
    if ~usecandlelastonly
        if size(extrainfo.p,1) > idxstart2check
            unwindtrade = obj.candlehighlow(candleTime,candleOpen,candleHigh,candleLow,updatepnlforclosedtrade);
            if ~isempty(unwindtrade)
                return
            end
        elseif size(extrainfo.p,1) == idxstart2check
            if isempty(strfind(trade.opensignal_.mode_,'conditional'))
                unwindtrade = obj.candlehighlow(candleTime,candleOpen,candleHigh,candleLow,updatepnlforclosedtrade);
            else
                %do nothing
            end
        end
    end
    % for cETFWatcher useage only
    if runhighlowonly, return;end
    
    
    %note:20200926:further check whether the trade is open with conditional
    %entrust executed but in fact the close price did not breach the
    %relevant barrier and etc
    signalinfo = trade.opensignal_;
    if strcmpi(signalinfo.frequency_,'1440m')
        %todo:avoid for long public holidays
        runriskmanagementbeforemktclose = false;
    end

    val = trade.opensignal_.mode_;
    if (strcmpi(val,'conditional-uptrendconfirmed') || ...
            strcmpi(val,'conditional-uptrendconfirmed-1') || ...
            strcmpi(val,'conditional-uptrendconfirmed-2') || ...
            strcmpi(val,'conditional-uptrendconfirmed-3') || ...
            strcmpi(val,'conditional-breachuplvlup') || ...
            strcmpi(val,'conditional-dntrendconfirmed') || ...
            strcmpi(val,'conditional-dntrendconfirmed-1') || ...
            strcmpi(val,'conditional-dntrendconfirmed-2') || ...
            strcmpi(val,'conditional-dntrendconfirmed-3') || ...
            strcmpi(val,'conditional-breachdnlvldn')) && ...
            compulsorycheck
        if isempty(kellytables)
            [ unwindflag, msg ] = obj.riskmanagementwithcandleonopen('trade',trade,...
                'extrainfo',extrainfo,...
                'runriskmanagementbeforemktclose',runriskmanagementbeforemktclose);
        else
            [ unwindflag, msg ] = obj.riskmanagementwithcandleonopen('trade',trade,...
                'extrainfo',extrainfo,...
                'runriskmanagementbeforemktclose',runriskmanagementbeforemktclose,...
                'kellytables',kellytables);
        end
        if unwindflag
            if ~runriskmanagementbeforemktclose
                if ~isfx(trade.code_)
                    trade.closedatetime1_ = extrainfo.latestdt;
                    trade.closeprice_ = extrainfo.latestopen;
                else
                    trade.closedatetime1_ = extrainfo.p(end,1);
                    trade.closeprice_ = extrainfo.p(end,5);
                end
            else
                trade.closedatetime1_ = extrainfo.p(end,1);
                trade.closeprice_ = extrainfo.p(end,5);
            end
            volume = trade.openvolume_;
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            %         trade.status_ = 'closed';
            trade.runningpnl_ = 0;
            instrument = trade.instrument_;
            if isempty(instrument)
                trade.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_);
            else
                trade.closepnl_ = direction*volume*(trade.closeprice_-trade.openprice_)/instrument.tick_size * instrument.tick_value;
            end
            unwindtrade = trade;
            return
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
    if runriskmanagementbeforemktclose && hour(candleTime) < 21 && hour(candleTime) > 9
        %big uncertainty between pm market close and evening/next day
        %market open
        isgovtbond = (strcmpi(trade.instrument_.asset_name,'govtbond_10y') || ...
            strcmpi(trade.instrument_.asset_name,'govtbond_30y'));
        
        if (trade.opendirection_ == 1 && strcmpi(obj.closestr_,'wad:new high price w/o wad being higher') && ~isgovtbond ) || ...
                (trade.opendirection_ == 1 && strcmpi(obj.closestr_,'wad:new high wad w/o price being higher') && ~isgovtbond) || ...
                (trade.opendirection_ == -1 && strcmpi(obj.closestr_,'wad:new low wad w/o price being lower') && ~isgovtbond) || ...
                (trade.opendirection_ == -1 && strcmpi(obj.closestr_,'wad:new low price w/o wad being lower') && ~isgovtbond)
            unwindtrade = trade;
            obj.status_ = 'closed';
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
%             trade.status_ = 'closed';
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
    freq_ = trade.opensignal_.frequency_;
    nfractal = trade.opensignal_.nfractal_;
    if strcmpi(freq_,'30m')
        ticksizeratio = 0.5;
    elseif strcmpi(freq_,'15m')
        ticksizeratio = 0.5;
    elseif strcmpi(freq_,'5m')
        ticksizeratio = 0;
    elseif strcmpi(freq_,'1440m') || strcmpi(freq_,'daily')
        ticksizeratio = 1;
    end
    
    try
        ticksize = trade.instrument_.tick_size;
    catch
        ticksize = 0;
    end
    
    try
        assetname = trade.instrument_.asset_name;
    catch
        assetname = '';
    end
    
    %in case it is a up-breach of fractal barrier, we shall calculate kelly
    %OR
    %in case it is a dn-breach of fractal barrier, we shall calculate kelly
    if runriskmanagementbeforemktclose && ~isempty(kellytables)
        if abs(ticksizeratio*ticksize) < 1e-6
            breachupsuccess = extrainfo.p(end,5) - extrainfo.hh(end-1) >= -1e-6 &....
                extrainfo.p(end-1,5) < extrainfo.hh(end-1);
        else
            breachupsuccess = extrainfo.p(end,5) - extrainfo.hh(end-1) - ticksizeratio*ticksize >= -1e-6 &....
                extrainfo.p(end-1,5) <= extrainfo.hh(end-1);
        end
        %
        if abs(ticksizeratio*ticksize) < 1e-6
            breachdnsuccess = extrainfo.p(end,5) - extrainfo.ll(end-1) <= 1e-6 &...
                extrainfo.p(end-1,5) > extrainfo.ll(end-1);
        else
            breachdnsuccess = extrainfo.p(end,5) - extrainfo.ll(end-1) + ticksizeratio*ticksize < 1e-6 &...
                extrainfo.p(end-1,5) >= extrainfo.ll(end-1);
        end
        %
        if (breachupsuccess || breachdnsuccess)
            signaluncond = fractal_signal_unconditional2('extrainfo',extrainfo,...
                'ticksize',ticksize,...
                'nfractal',nfractal,...
                'assetname',assetname,...
                'kellytables',kellytables,...
                'ticksizeratio',ticksizeratio);
            if isempty(signaluncond)
                closeflag = true;
                closestr = 'invalid breachup';
            else
                %need to double-check whether the trade opened with the same
                %signal
                if strcmpi(obj.trade_.opensignal_.mode_,signaluncond.opkellied)
                    kellythreshold = 0.088;
                else
                    kellythreshold = 0;
                end
                
                kelly = signaluncond.kelly;
                if kelly < kellythreshold || isnan(kelly)
                    closeflag = true;
                    if breachupsuccess
                        closestr = ['up: ',signaluncond.opkellied,':kelly is low'];
                    else
                        closestr = ['dn: ',signaluncond.opkellied,':kelly is low'];
                    end
                else
                    closeflag = false;
                end
            end
            %
            if closeflag
                if ~isfx(trade.code_)
                    obj.trade_.closedatetime1_ = extrainfo.latestdt;
                    obj.trade_.closeprice_ = extrainfo.latestopen;
                else
                    obj.trade_.closedatetime1_ = extrainfo.p(end,1);
                    obj.trade_.closeprice_ = extrainfo.p(end,5);
                end
                volume = trade.openvolume_;
                obj.status_ = 'closed';
                obj.closestr_ = closestr;
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
        end
    end
    %
    if direction == 1 && extrainfo.hh(end) > extrainfo.hh(end-1) && abs(extrainfo.hh(end)/extrainfo.hh(end-1)-1)>0.0003
        if ~isnan(obj.tdlow_)
            sshighidx = find(extrainfo.ss >=9,1,'last');
            sshigh = extrainfo.ss(sshighidx);
            if sshigh >= 16
                exceptionflag = false;
            else
                lasthhidx = find(extrainfo.idxhh(1:end-1) == 1,1,'last');
                if lasthhidx < sshighidx
                    exceptionflag = true;
                else
                    exceptionflag = false;
                end
            end
        else
            exceptionflag = false;
        end
        if ~exceptionflag
            if extrainfo.p(end,5) >= extrainfo.hh(end-1)
                %todo:
                %trick part when extrainfo.p(end,5) == extrainfo.p(end,2)
                if extrainfo.p(end,5) < extrainfo.p(end,2)
                    closeflag = true;
                    shadowlineratio = (extrainfo.p(end,3) - extrainfo.p(end,5))/(extrainfo.p(end,3) - extrainfo.p(end,4));
                    if shadowlineratio > 0.5
                        obj.pxstoploss_ = extrainfo.p(end,5);
                    else
                        obj.pxstoploss_ = extrainfo.p(end,4);
                    end
                else
                    lasthhidx = find(extrainfo.idxhh(1:end-1) == 1,1,'last');
                    if isempty(lasthhidx)
                        lasthhidx = 1;
                    end 
                    sshighidx = find(extrainfo.ss >=9,1,'last');
                    if lasthhidx < sshighidx
                        sshigh = extrainfo.ss(sshighidx);
                        if sshigh >= 16
                            closeflag = true;
                            obj.pxstoploss_ = extrainfo.p(end,5) + ticksize;
                        else
                            closeflag = false;
                        end
                    else
                        closeflag = false;
                    end
                end
            else
                closeflag = true;
                if ~isempty(strfind(val,'conditional-'))
                    if ~strcmpi(obj.trade_.opensignal_.frequency_,'daily')
                        obj.pxstoploss_ = extrainfo.p(end,5) + ticksize;
                    else
                        if extrainfo.p(end,5) > extrainfo.p(end,2)
                            obj.pxstoploss_ = extrainfo.p(end,4) + ticksize;
                        else
                            obj.pxstoploss_ = extrainfo.p(end,5) + ticksize;
                        end
                    end
                else
                    if extrainfo.sc(end) == 13 || extrainfo.ss(end) >= 9
                        obj.pxstoploss_ = extrainfo.p(end,5) + ticksize;
                    else
                        obj.pxstoploss_ = extrainfo.p(end,4) + ticksize;
                    end
                end
            end
            if closeflag          
                obj.closestr_ = 'fractal:upupdate';
                if runriskmanagementbeforemktclose && extrainfo.p(end,5) < extrainfo.lips(end)
                    obj.status_ = 'closed';
                    obj.trade_.closedatetime1_ = extrainfo.p(end,1);
                    obj.trade_.closeprice_ = extrainfo.p(end,5);
                    volume = trade.openvolume_;
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
    %
    %
    if direction == -1 && extrainfo.ll(end) < extrainfo.ll(end-1) && abs(extrainfo.ll(end)/extrainfo.ll(end-1)-1)>0.0003
        if ~isnan(obj.tdhigh_)
            bslowidx = find(extrainfo.bs >= 9,1,'last');
            bslow = extrainfo.bs(bslowidx);
            if bslow >= 16
                exceptionflag = false;
            else
                lastllidx = find(extrainfo.idxll(1:end-1) == -1,1,'last');
                if lastllidx < bslowidx
                    exceptionflag = true;
                else
                    exceptionflag = false;
                end
            end
        else
            exceptionflag = false;
        end
        if ~exceptionflag
            if extrainfo.p(end,5) <= extrainfo.ll(end-1)
                if extrainfo.p(end,5) >= extrainfo.p(end,2)
                    closeflag = true;
                    shadowlineratio = (extrainfo.p(end,5) - extrainfo.p(end,4))/(extrainfo.p(end,3) - extrainfo.p(end,4));
                    if shadowlineratio > 0.5
                        obj.pxstoploss_ = extrainfo.p(end,5);
                    else
                        obj.pxstoploss_ = extrainfo.p(end,3);
                    end
                else
                    lastllidx = find(extrainfo.idxll(1:end-1) == -1,1,'last');
                    if isempty(lastllidx)
                        lastllidx = 1;
                    end
                    bshighidx = find(extrainfo.bs >= 9,1,'last');
                    if lastllidx < bshighidx
                        bshigh = extrainfo.bs(bshighidx);
                        if bshigh >= 16
                            closeflag = true;
                            obj.pxstoploss_ = extrainfo.p(end,5) -ticksize;
                        else
                            closeflag = false;
                        end
                    else
                        closeflag = false;
                    end
                end
            else
                closeflag = true;
                if ~isempty(strfind(val,'conditional-'))
                    if ~strcmpi(obj.trade_.opensignal_.frequency_,'daily')
                        obj.pxstoploss_ = extrainfo.p(end,5) - ticksize;
                    else
                        if extrainfo.p(end,5) < extrainfo.p(end,2)
                            obj.pxstoploss_ = extrainfo.p(end,3) - ticksize;
                        else
                            obj.pxstoploss_ = extrainfo.p(end,5) - ticksize;
                        end
                    end
                else
                    if extrainfo.bc(end) == 13 || extrainfo.bs(end) >= 9
                        obj.pxstoploss_ = extrainfo.p(end,5) - ticksize;
                    else
                        obj.pxstoploss_ = extrainfo.p(end,3) - ticksize;
                    end
                end
            end
            if closeflag
                obj.closestr_ = 'fractal:dnupdate';
                if runriskmanagementbeforemktclose && extrainfo.p(end,5) > extrainfo.lips(end)
                    obj.status_ = 'closed';
                    obj.trade_.closedatetime1_ = extrainfo.p(end,1);
                    obj.trade_.closeprice_ = extrainfo.p(end,5);
                    volume = trade.openvolume_;
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
        end
    end
    %
    if isempty(instrument)
        obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_);
    else
        obj.trade_.runningpnl_ = direction*volume*(candleClose-trade.openprice_)/instrument.tick_size * instrument.tick_value;
    end
    
end
