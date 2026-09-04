function [unwindflag,msg] = riskmanagementwithcandleonopen(obj, varargin)
%this func is applied to fractal strategy ONLY
%this func is for conditional-open trade ONLY
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Trade',{},@(x) validateattributes(x,{'cTradeOpen'},{},'','Trade'));
    p.addParameter('ExtraInfo',{},@isstruct);
    p.addParameter('RunRiskManagementBeforeMktClose',false,@islogical);
    p.addParameter('KellyTables',{},@isstruct);
    p.parse(varargin{:});
    unwindflag = false;
    msg = '';
    trade = p.Results.Trade;
    signalinfo = trade.opensignal_;
    if ~isa(signalinfo,'cFractalInfo'), return;end
    val = signalinfo.mode_;
    if ~(strcmpi(val,'conditional-uptrendconfirmed') || ...
            strcmpi(val,'conditional-uptrendconfirmed-1') || ...
            strcmpi(val,'conditional-uptrendconfirmed-2') || ...
            strcmpi(val,'conditional-uptrendconfirmed-3') || ...
            strcmpi(val,'conditional-dntrendconfirmed') || ...
            strcmpi(val,'conditional-dntrendconfirmed-1') || ...
            strcmpi(val,'conditional-dntrendconfirmed-2') || ...
            strcmpi(val,'conditional-dntrendconfirmed-3'))
        return;
    end
    %
    ei = p.Results.ExtraInfo;
    try
        ei.p(end,1);
    catch
        ei.p = ei.px;
    end

    if trade.opendatetime1_ - ei.p(end,1) > ei.p(end,1) - ei.p(end-1,1)
        %the candle hasn't reached the open candle yet
        return
    end
    
    freq_ = trade.opensignal_.frequency_;
    nfractal = trade.opensignal_.nfractal_;
    if strcmpi(freq_,'30m') || strcmpi(freq_,'m30') 
        ticksizeratio = 0.5;
    elseif strcmpi(freq_,'15m') || strcmpi(freq_,'m15') 
        ticksizeratio = 0.5;
    elseif strcmpi(freq_,'60m') || strcmpi(freq_,'m60')
        ticksizeratio = 0.5;
    elseif strcmpi(freq_,'5m') || strcmpi(freq_,'m5')
        ticksizeratio = 0;
    elseif strcmpi(freq_,'1h') || strcmpi(freq_,'60m') || strcmpi(freq_,'h1')
        ticksizeratio = 1;
    elseif strcmpi(freq_,'4h') || strcmpi(freq_,'240m') || strcmpi(freq_,'h4')
        ticksizeratio = 1;    
    elseif strcmpi(freq_,'1440m') || strcmpi(freq_,'daily') || strcmpi(freq_,'d1')
        ticksizeratio = 1;
    end
    %
    runriskmanagementbeforemktclose = p.Results.RunRiskManagementBeforeMktClose;
    kellytables = p.Results.KellyTables;
    
    breachupfailed = ei.p(end,5) < ei.hh(end-1) &...
        ei.p(end,3) > ei.hh(end-1);
    %
    breachupsuccess = ei.p(end,5) - ei.hh(end-1) - ticksizeratio*trade.instrument_.tick_size > -1e-6 &....
        ei.p(end-1,5) < ei.hh(end-1);
    %
    breachdnfailed = ei.p(end,5) > ei.ll(end-1) &...
        ei.p(end,4) < ei.ll(end-1);
    %
    breachdnsuccess = ei.p(end,5) - ei.ll(end-1) + ticksizeratio*trade.instrument_.tick_size < 1e-6 &...
        ei.p(end-1,5) > ei.ll(end-1);
    
    onopenflag = ei.p(end,1) <= trade.opendatetime1_;
    
    lflag = strcmpi(val,'conditional-uptrendconfirmed') || strcmpi(val,'conditional-uptrendconfirmed-1') || strcmpi(val,'conditional-uptrendconfirmed-2') || strcmpi(val,'conditional-uptrendconfirmed-3');
    sflag = strcmpi(val,'conditional-dntrendconfirmed') || strcmpi(val,'conditional-dntrendconfirmed-1') || strcmpi(val,'conditional-dntrendconfirmed-2') || strcmpi(val,'conditional-dntrendconfirmed-3');
    
    if lflag
        shadowlineratio = (ei.p(end,3) - ei.p(end,5))/(ei.p(end,3) - ei.p(end,4));
    elseif sflag
        shadowlineratio = (ei.p(end,5) - ei.p(end,4))/(ei.p(end,3) - ei.p(end,4));
    else
        shadowlineratio = NaN;
    end

    tr1 = ei.p(end,3) - ei.p(end,4);
    tr2 = abs(ei.p(end,3) - ei.p(end-1,5));
    tr3 = abs(ei.p(end,4) - ei.p(end-1,5));
    tr = max([tr1,tr2,tr3]);
    
    isbull = ei.p(end,5) > ei.p(end,2);
%     isbear = ei.p(end,5) < ei.p(end,2);
%     isflat = ei.p(end,5) == ei.p(end,2);

    if ei.ss(end) == 9 && isnan(obj.tdlow_)
        [pxhigh,pxhighidx] = min(ei.p(end-8:end,3));
        pxhighidx = pxhighidx+size(ei.ss,1)-9;
        obj.tdhigh_ = pxhigh;
        obj.tdlow_ = ei.p(pxhighidx,4);
    end
    
    if isnan(obj.td13low_)
        lastsc13 = find(ei.sc == 13,1,'last');
        if size(ei.sc,1) - lastsc13 < 2*nfractal
            tdlow = ei.p(lastsc13,4);
            if tdlow < ei.hh(end-1)
                obj.td13low_ = tdlow;
            end
        end
    end
    
    if lflag && runriskmanagementbeforemktclose && ~breachupsuccess && ei.ss(end) >= 9
        sslastval = ei.ss(end);
        pxhigh = max(ei.p(end-sslastval+1:end,3));
        if pxhigh > ei.hh(end-1)
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:mktclose';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
    end
    
    if lflag && breachupfailed
        %
        if tr > 3*ei.atr(end)
            unwindflag = true;
            msg = 'condtional uptrendconfirmed failed:tr significantly exceed atr';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            trade.closeprice_ = ei.p(end,5);
            return;
        end
        
        if strcmpi(trade.riskmanager_.closestr_,'conditional:atr')
            if ei.p(end,4) < trade.riskmanager_.pxstoploss_
                unwindflag = true;
                msg = 'condtional uptrendconfirmed failed:atr';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                trade.closeprice_ = trade.riskmanager_.pxstoploss_;
                return;
            end
        end
        %
        if ei.sc(end) == 13
            exceptionflag = (strcmpi(val,'conditional-uptrendconfirmed-1') && ei.p(end,5) > ei.lvlup(end)) || ...
                (shadowlineratio < 0.618 && isbull);
            if ~exceptionflag
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:sc13break';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if shadowlineratio > 0.618 && tr > 0.6*ei.atr(end) && onopenflag
            exceptionflag = (ei.p(end,4) > ei.p(end-1,4) & shadowlineratio <= 0.75) | ...
                (ei.p(end,4) > ei.p(end-1,4) & ei.p(end,5) > ei.p(end-1,3) & shadowlineratio <= 0.85) | ...
                (ei.p(end,4) > ei.p(end-1,4) & ei.p(end-1,3) > ei.hh(end-2) & ei.p(end-1,5) <= ei.hh(end-2) & ei.hh(end-1) >= ei.hh(end-2) & shadowlineratio <= 0.85) | ...
                (strcmpi(val,'conditional-uptrendconfirmed-1') & ei.p(end,3) > ei.lvlup(end) & shadowlineratio <= 0.85) | ...
                (ei.p(end,5) > ei.lvlup(end-1) & ei.p(end-1,5) < ei.lvlup(end-1)) | ...
                ((~isnan(obj.tdlow_) | ~isnan(obj.td13low_)) & shadowlineratio <= 0.85);
            if ~exceptionflag
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:shadowline1';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if runriskmanagementbeforemktclose
            if (strcmpi(val,'conditional-uptrendconfirmed-3') && shadowlineratio > 0.382) || ei.ss(end) > 9
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:mktclose';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
            if strcmpi(freq_,'5m') && ei.p(end,3)-ei.hh(end-1) <= 2*trade.instrument_.tick_size
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:mktclose';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if strcmpi(val,'conditional-uptrendconfirmed-2')
            if ~isnan(obj.tdlow_)
                obj.pxstoploss_ = obj.tdlow_ - (obj.tdhigh_-obj.tdlow_);
            end   
        end
        %
        %
        % here we force the hard stop to be the highest price of the open
        % candle
%         sl1 = ei.hh(end-1) - ei.atr(end);
%         totalrange = ei.p(end,3) - ei.p(end,4);
%         if totalrange > 0.618*ei.atr(end-1)
%             sl2 = ei.px(end,4);
%         else
%             sl2 = ei.p(end,3) - 2*totalrange;
%         end
%         sl3 = obj.pxstoploss_;
%         sl = max([sl1,sl2,sl3]);
%         sl = ceil(sl / trade.instrument_.tick_size)*trade.instrument_.tick_size;
%         obj.pxstoploss_ = sl;
%         obj.closestr_ = 'conditional uptrendconfirmed failed:uncertainty prob';
    end
    %end of lflag && breachupfailed
    %
    if lflag && breachupsuccess
        if ~isempty(strfind(obj.closestr_,'conditional uptrendconfirmed failed'))
            obj.pxstoploss_ = floor(ei.teeth(end)/trade.instrument_.tick_size)*trade.instrument_.tick_size;
            obj.closestr_ = 'teeth';
        end
        if isempty(kellytables)
            [~,opuncond,~] = fractal_signal_unconditional(ei,ticksizeratio*trade.instrument_.tick_size,nfractal);
            try
                temp = opuncond.comment;
                idx = strfind(temp,'-invalid');
                if isempty(idx)
                    trade.opensignal_.mode_ = temp;
                else
                    trade.opensignal_.mode_ = temp(1:idx-1);
                end
            catch
                if strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-1')
                    trade.opensignal_.mode_ = 'breachup-lvlup';
                elseif strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-2')
                    trade.opensignal_.mode_ = 'breachup-sshighvalue';
                elseif strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-3')
                    trade.opensignal_.mode_ = 'breachup-highsc13';
                else
                    if ei.teeth(end-1) > ei.jaw(end-1)
                        trade.opensignal_.mode_ = 'strongbreach-trendconfirmed';
                    else
                        trade.opensignal_.mode_ = 'mediumbreach-trendconfirmed';
                    end
                end
                unwindflag = true;
                msg = 'conditional uptrendconfirmed success:invalid breach';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        else
            if ei.hh(end) > ei.hh(end-1)
            else
                signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
                    'ticksize',trade.instrument_.tick_size,...
                    'nfractal',nfractal,...
                    'assetname',trade.instrument_.asset_name,...
                    'kellytables',kellytables,...
                    'ticksizeratio',ticksizeratio);
                if ~isempty(signaluncond)
                    if signaluncond.directionkellied == 1
                        kelly = signaluncond.kelly;
                        trade.opensignal_.mode_ = signaluncond.opkellied;
                        trade.opensignal_.kelly_ = kelly;
                        if kelly < 0.088
                            unwindflag = true;
                            msg = 'conditional uptrendconfirmed success:lowkelly';
                            obj.status_ = 'closed';
                            obj.closestr_ = msg;
                        end
                    else
                        try
                            trade.opensignal_.mode_ = signaluncond.opkellied;
                        catch
                            invalidindex = strfind(signaluncond.opkellied,'-invalid');
                            if ~isempty(invalidindex)
                                trade.opensignal_.mode_ = signaluncond.opkellied(1:invalidindex-1);
                            end
                        end
                        trade.opensignal_.kelly_ = signaluncond.kelly;
                        unwindflag = true;
                        msg = 'conditional uptrendconfirmed success:lowkelly';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                    end
                else
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed success:lowkelly';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            end
            %
        end
    end
    %end of lflag && breachupsuccess
    %
    if lflag && ~breachupfailed && ~breachupsuccess
        if runriskmanagementbeforemktclose && strcmpi(freq_,'5m') && ei.p(end,3)-ei.hh(end-1) <= 2*trade.instrument_.tick_size 
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:mktclose';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        if ei.p(end,5) - ei.hh(end-1) - ticksizeratio*trade.instrument_.tick_size > -1e-6
            if isempty(kellytables)
                [~,opuncond,~] = fractal_signal_unconditional(ei,ticksizeratio*trade.instrument_.tick_size,nfractal);
                try
                    temp = opuncond.comment;
                    idx = strfind(temp,'-invalid');
                    if isempty(idx)
                        trade.opensignal_.mode_ = temp;
                    else
                        trade.opensignal_.mode_ = temp(1:idx-1);
                    end
                catch
                    if strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-1')
                        trade.opensignal_.mode_ = 'breachup-lvlup';
                    elseif strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-2')
                        trade.opensignal_.mode_ = 'breachup-sshighvalue';
                    elseif strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-3')
                        trade.opensignal_.mode_ = 'breachup-highsc13';
                    else
                        if ei.teeth(end-1) > ei.jaw(end-1)
                            trade.opensignal_.mode_ = 'strongbreach-trendconfirmed';
                        else
                            trade.opensignal_.mode_ = 'mediumbreach-trendconfirmed';
                        end
                    end
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed success:invalid breach';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
                    'ticksize',trade.instrument_.tick_size,...
                    'nfractal',nfractal,...
                    'assetname',trade.instrument_.asset_name,...
                    'kellytables',kellytables,...
                    'ticksizeratio',ticksizeratio);
                if ~isempty(signaluncond)
                    if signaluncond.directionkellied == 1
                        kelly = signaluncond.kelly;
                        try
                            trade.opensignal_.mode_ = signaluncond.opkellied;
                        catch
                        end
                        trade.opensignal_.kelly_ = kelly;
                        obj.wadopen_ = ei.wad(end);
                        %                     obj.wadlow_ = ei.wad(end);
                        %                     obj.cpopen_ = ei.px(end,5);
                        %                     obj.cplow_ = ei.px(end,5);
                        if kelly < 0.088
                            unwindflag = true;
                            msg = 'conditional uptrendconfirmed success:lowkelly';
                            obj.status_ = 'closed';
                            obj.closestr_ = msg;
                            return
                        end
                    else
                        kelly = signaluncond.kelly;
                        try
                            trade.opensignal_.mode_ = signaluncond.opkellied;
                        catch
                        end
                        trade.opensignal_.kelly_ = kelly;
                        unwindflag = true;
                        msg = 'conditional uptrendconfirmed success:lowkelly';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                else
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed success:lowkelly';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            end
        end
        %
        if strcmpi(val,'conditional-uptrendconfirmed-2')
            if ~isnan(obj.tdlow_)
                obj.pxstoploss_ = obj.tdlow_ - (obj.tdhigh_-obj.tdlow_);
            end   
        end
        %
        if strcmpi(val,'conditional-uptrendconfirmed-3')
            if ~isnan(obj.td13low_)
                obj.pxstoploss_ = obj.td13low_;
            end
            if shadowlineratio > 0.94
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:shadowline3';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if runriskmanagementbeforemktclose && strcmpi(freq_,'30m') && ...
                (shadowlineratio > 0.9 || ...
                (shadowlineratio >= 0.75 && ei.p(end,5) < ei.p(end-1,5)))
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:mktclose';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        unwindflag = false;
        msg = '';
        return
    end
    %end of lflag && ~breachupfailed && ~breachupsuccess
    %
    %
    
    % ------- BELOW IS FOR SHORT POSITION ------- %
    if ei.bs(end) == 9 && isnan(obj.tdhigh_)
        [pxlow,pxlowidx] = min(ei.p(end-8:end,4));
        pxlowidx = pxlowidx+size(ei.bs,1)-9;
        obj.tdlow_ = pxlow;
        obj.tdhigh_ = ei.p(pxlowidx,3);
    end
    
    if isnan(obj.td13high_)
        lastbc13 = find(ei.bc == 13,1,'last');
        if size(ei.bc,1) - lastbc13 < 2*nfractal
            tdhigh = ei.p(lastbc13,3);
            if tdhigh >= ei.ll(end-1)
                obj.td13high_ = tdhigh;
            end
        end
    end
    
    if sflag && breachdnfailed
        %
        if tr > 3*ei.atr(end)
            unwindflag = true;
            msg = 'condtional dntrendconfirmed failed:tr signficantly exceed atr';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            trade.closeprice_ = ei.p(end,5);
            return;
        end
        %
        if strcmpi(trade.riskmanager_.closestr_,'conditional:atr')
            if ei.p(end,3) > trade.riskmanager_.pxstoploss_
                unwindflag = true;
                msg = 'condtional uptrendconfirmed failed:atr';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                trade.closeprice_ = trade.riskmanager_.pxstoploss_;
                return;
            end
        end
        %
        if shadowlineratio > 0.618 && tr > 0.6*ei.atr(end) && onopenflag         
            exceptionflag = (ei.p(end,3) < ei.p(end-1,3) & shadowlineratio <= 0.75) | ...
                (ei.p(end,3) < ei.p(end-1,3) & ei.p(end,5) < ei.p(end-1,4) & shadowlineratio <= 0.85) | ...
                (ei.p(end,3) < ei.p(end-1,3) & ei.p(end-1,4) < ei.ll(end-2) & ei.p(end-1,5) >= ei.ll(end-2) & ei.ll(end-1) <= ei.ll(end-2) & shadowlineratio <= 0.85) | ...
               (strcmpi(val,'conditional-dntrendconfirmed-1') & ei.p(end,4) < ei.lvldn(end) & shadowlineratio <= 0.85) | ...
               (ei.p(end,5) < ei.lvldn(end-1) & ei.p(end-1,5) > ei.lvldn(end-1)) | ...
                ((~isnan(obj.tdhigh_) | ~isnan(obj.td13high_)) & shadowlineratio <= 0.85);
            if ~exceptionflag
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:shadowline1';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if runriskmanagementbeforemktclose
            if (strcmpi(val,'conditional-dntrendconfirmed-3') && shadowlineratio > 0.382) || ei.bs(end) > 9
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:mktclose';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
            if strcmpi(freq_,'5m') && ei.ll(end-1)-ei.p(end,4) <= 2*trade.instrument_.tick_size
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:mktclose';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        %
        if strcmpi(val,'conditional-dntrendconfirmed-2')
            if ~isnan(obj.tdhigh_)
                obj.pxstoploss_ = obj.tdhigh_ + (obj.tdhigh_-obj.tdlow_);
            end   
        end
        % here we force the hard stop to be the highest price of the open
        % candle
%         sl1 = ei.ll(end-1) + ei.atr(end);
%         totalrange = ei.p(end,3) - ei.p(end,4);
%         if totalrange > 0.618*ei.atr(end-1)
%             sl2 = ei.px(end,3);
%         else
%             sl2 = ei.px(end,4) + 2*totalrange;
%         end
%         sl3 = obj.pxstoploss_;
%         sl = min([sl1,sl2,sl3]);
%         sl = ceil(sl / trade.instrument_.tick_size)*trade.instrument_.tick_size;
%         obj.pxstoploss_ = sl;
%         obj.closestr_ = 'conditional dntrendconfirmed failed:uncertainty prob';
    end
    %end of sflag && breachdnfailed
    %
    if sflag && breachdnsuccess
        if ~isempty(strfind(obj.closestr_,'conditional dntrendconfirmed failed'))
            obj.pxstoploss_ = ceil(ei.teeth(end)/trade.instrument_.tick_size)*trade.instrument_.tick_size;
            obj.closestr_ = 'teeth';
        end
        if isempty(kellytables)
            [~,opuncond,~] = fractal_signal_unconditional(ei,ticksizeratio*trade.instrument_.tick_size,nfractal);
            try
                temp = opuncond.comment;
                idx = strfind(temp,'-invalid');
                if isempty(idx)
                    trade.opensignal_.mode_ = temp;
                else
                    trade.opensignal_.mode_ = temp(1:idx-1);
                end
            catch
                if strcmpi(trade.opensignal_.mode_,'conditional-dntrendconfirmed-1')
                    trade.opensignal_.mode_ = 'breachdn-lvldn';
                elseif strcmpi(trade.opensignal_.mode_,'conditional-dntrendconfirmed-2')
                    trade.opensignal_.mode_ = 'breachdn-bshighvalue';
                elseif strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-3')
                    trade.opensignal_.mode_ = 'breachdn-lowbc13';
                else
                    if ei.teeth(end-1) < ei.jaw(end-1)
                        trade.opensignal_.mode_ = 'strongbreach-trendconfirmed';
                    else
                        trade.opensignal_.mode_ = 'mediumbreach-trendconfirmed';
                    end
                end
                unwindflag = true;
                msg = 'conditional dntrendconfirmed success:invalid breach';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        else
            signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
                'ticksize',trade.instrument_.tick_size,...
                'nfractal',nfractal,...
                'assetname',trade.instrument_.asset_name,...
                'kellytables',kellytables,...
                'ticksizeratio',ticksizeratio);
            if ~isempty(signaluncond)
                if signaluncond.directionkellied == -1
                    kelly = signaluncond.kelly;
                    try
                        trade.opensignal_.mode_ = signaluncond.opkellied;
                    catch
                    end
                    trade.opensignal_.kelly_ = signaluncond.kelly;
                    if kelly < 0.088
                        unwindflag = true;
                        msg = 'conditional dntrendconfirmed success:lowkelly';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                else
                    try
                        trade.opensignal_.mode_ = signaluncond.opkellied;
                    catch
                    end
                    trade.opensignal_.kelly_ = signaluncond.kelly;
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed success:lowkelly';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                unwindflag = true;
                msg = 'conditional dntrendconfirmed success:lowkelly';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
    end
    %end of sflag && breachdnsuccess
    %
    if sflag && ~breachdnfailed && ~breachdnsuccess
       if runriskmanagementbeforemktclose && strcmpi(freq_,'5m') && ei.ll(end-1)-ei.p(end,4) <= 2*trade.instrument_.tick_size
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:mktclose';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        if ei.p(end,5) - ei.ll(end-1) + ticksizeratio*trade.instrument_.tick_size < 1e-6
            [~,opuncond,~] = fractal_signal_unconditional(ei,ticksizeratio*trade.instrument_.tick_size,nfractal);
            if isempty(kellytables)
               try
                    temp = opuncond.comment;
                    idx = strfind(temp,'-invalid');
                    if isempty(idx)
                        trade.opensignal_.mode_ = temp;
                    else
                        trade.opensignal_.mode_ = temp(1:idx-1);
                    end
                catch
                    if strcmpi(trade.opensignal_.mode_,'conditional-dntrendconfirmed-1')
                        trade.opensignal_.mode_ = 'breachdn-lvldn';
                    elseif strcmpi(trade.opensignal_.mode_,'conditional-dntrendconfirmed-2')
                        trade.opensignal_.mode_ = 'breachdn-bshighvalue';
                    elseif strcmpi(trade.opensignal_.mode_,'conditional-uptrendconfirmed-3')
                        trade.opensignal_.mode_ = 'breachdn-lowbc13';
                    else
                        if ei.teeth(end-1) < ei.jaw(end-1)
                            trade.opensignal_.mode_ = 'strongbreach-trendconfirmed';
                        else
                            trade.opensignal_.mode_ = 'mediumbreach-trendconfirmed';
                        end
                    end
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed success:invalid breach';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                signaluncond = fractal_signal_unconditional2('extrainfo',ei,...
                    'ticksize',trade.instrument_.tick_size,...
                    'nfractal',nfractal,...
                    'assetname',trade.instrument_.asset_name,...
                    'kellytables',kellytables,...
                    'ticksizeratio',ticksizeratio);
                if ~isempty(signaluncond)
                    if signaluncond.directionkellied == -1
                        kelly = signaluncond.kelly;
                        trade.opensignal_.mode_ = signaluncond.opkellied;
                        trade.opensignal_.kelly_ = kelly;
                        obj.wadopen_ = ei.wad(end);
                        %                     obj.wadlow_ = ei.wad(end);
                        %                     obj.cpopen_ = ei.px(end,5);
                        %                     obj.cplow_ = ei.px(end,5);
                        if kelly < 0.088
                            unwindflag = true;
                            msg = 'conditional dntrendconfirmed success:lowkelly';
                            obj.status_ = 'closed';
                            obj.closestr_ = msg;
                            return
                        end
                    else
                        kelly = signaluncond.kelly;
                        try
                            trade.opensignal_.mode_ = signaluncond.opkellied;
                        catch
                            invalidindex = strfind(signaluncond.opkellied,'-invalid');
                            if ~isempty(invalidindex)
                                trade.opensignal_.mode_ = signaluncond.opkellied(1:invalidindex-1);
                            end
                        end
                        trade.opensignal_.kelly_ = kelly;
                        unwindflag = true;
                        msg = 'conditional dntrendconfirmed success:lowkelly';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                else
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed success:lowkelly';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            end
        end
        %
        if strcmpi(val,'conditional-dntrendconfirmed-2')
            if ~isnan(obj.tdhigh_)
                obj.pxstoploss_ = obj.tdhigh_ + (obj.tdhigh_-obj.tdlow_);
            end   
        end
        %
        if strcmpi(val,'conditional-dntrendconfirmed-3')
            if ~isnan(obj.td13high_)
                obj.pxstoploss_ = obj.td13high_;
            end
            if shadowlineratio > 0.94
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:shadowline3';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if runriskmanagementbeforemktclose && strcmpi(freq_,'30m') && ...
                (shadowlineratio > 0.9 || ...
                (shadowlineratio >= 0.75 && ei.p(end,5) > ei.p(end-1,3) && ei.p(end-1,4) < ei.ll(end-2)))
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:mktclose';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        unwindflag = false;
        msg = '';
    end
    %end of sflag && ~breachdnfailed && ~breachdnsuccess
    %
    %
end