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
%     if extrainfo.p(end,1) > trade.opendatetime1_
%         %the candle has passed the open candle
%         return
%     end
    if trade.opendatetime1_ - ei.p(end,1) > ei.p(end,1) - ei.p(end-1,1)
        %the candle hasn't reached the open candle yet
        return
    end
    
    freq_ = trade.opensignal_.frequency_;
    if strcmpi(freq_,'30m')
        nfractal = 4;
        ticksizeratio = 0.5;
    elseif strcmpi(freq_,'15m')
        nfractal = 4;
        ticksizeratio = 0.5;
    elseif strcmpi(freq_,'5m')
        nfractal = 6;
        ticksizeratio = 0;
    elseif strcmpi(freq_,'1440m') || strcmpi(freq_,'daily')
        nfractal = 2;
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
        within2ticks = ei.p(end,2) > ei.p(end,5) & ei.p(end,3) - ei.hh(end-1) <= 2*trade.instrument_.tick_size;
        shadowlineratio = (ei.p(end,3) - ei.p(end,5))/(ei.p(end,3) - ei.p(end,4));
        fractalupdate = ei.hh(end) > ei.hh(end-1);
    elseif sflag
        within2ticks = ei.p(end,2) < ei.p(end,5) & ei.ll(end-1) - ei.p(end,4) <= 2*trade.instrument_.tick_size;
        shadowlineratio = (ei.p(end,5) - ei.p(end,4))/(ei.p(end,3) - ei.p(end,4));
        fractalupdate = ei.ll(end) < ei.ll(end-1);
    else
        within2ticks = false;
        shadowlineratio = NaN;
        fractalupdate = false;
    end
    
    if ei.ss(end) == 9 && isnan(obj.tdlow_)
        pxhigh = min(ei.p(end-8:end,3));
        pxhighidx = find(ei.p(end-8:end,3) == pxhigh,1,'last')+size(ei.ss,1)-9;
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
        if ei.sc(end) == 13
            exceptionflag = (strcmpi(val,'conditional-uptrendconfirmed-1') && ei.p(end,5) > ei.lvlup(end)) || ...
                (shadowlineratio < 0.618 && ei.p(end,5) > ei.p(end,2));
            if ~exceptionflag
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:sc13break';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if fractalupdate
            exceptionflag = strcmpi(val,'conditional-uptrendconfirmed-1') && ei.p(end,3) > ei.lvlup(end);
            if ~exceptionflag
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:fractalhhupdate';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %        
        if within2ticks
            exceptionflag = ~isnan(obj.tdlow_) || (strcmpi(val,'conditional-uptrendconfirmed-1') && ei.p(end,3) > ei.lvlup(end)) || ...
                (ei.p(end,3) > ei.lvlup(end) && ei.p(end,4) < ei.lvlup(end));
            if ~onopenflag
                if ~exceptionflag
                    exceptionflag = ei.p(end,4) > ei.p(end-1,4) & ei.p(end-1,3) - ei.hh(end-2) <= 2*trade.instrument_.tick_size;
                end
                if ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed failed:within2ticks2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                if ~exceptionflag
                    exceptionflag = ei.p(end,4) > ei.p(end-1,4) & ei.p(end,5) > ei.p(end-1,5) & ei.p(end,3) > ei.p(end-1,3) & shadowlineratio < 0.382;
                end
                if ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed failed:within2ticks1';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            end
        end
        %
        if shadowlineratio > 0.618
            if ~onopenflag
                exceptionflag = (strcmpi(val,'conditional-uptrendconfirmed-1') && ei.p(end,3) > ei.lvlup(end)) || ...
                    ~isnan(obj.tdlow_) || ~isnan(obj.td13low_);
                exceptionflag = exceptionflag & shadowlineratio < 0.9 & ...
                    ~(ei.p(end,4) < ei.p(end-1,4) & ei.p(end,5) < ei.p(end-1,5) & ei.p(end,3) < ei.p(end-1,3) & shadowlineratio > 0.8);
                if ((ei.p(end,4) < ei.p(end-1,4)) || (ei.p(end,5) < ei.p(end-1,5) && ei.p(end,3) < ei.p(end-1,3))) && ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed failed:shadowline2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                try
                    isopencandle = abs(datenum([datestr(floor(ei.p(end,1)),'yyyy-mm-dd'), ' ',trade.instrument_.break_interval{1,1}],'yyyy-mm-dd HH:MM:SS')-ei.p(end,1)) < 1e-5;
                catch
                    isopencandle = false;
                end
                if isopencandle
                    %the open market vol might be too high
                    if ei.p(end,5) <= max(ei.lips(end),ei.teeth(end)) || ...
                            (~isnan(obj.tdlow_) && ei.p(end,5) < obj.tdlow_) || ...
                            (~isnan(obj.td13low_) && ei.p(end,5) < obj.td13low_) || ...
                            (ei.p(end,4) <= ei.p(end-1,4) && shadowlineratio > 0.9) || ...
                            (ei.p(end,4) < ei.p(end-1,4) && ei.p(end,5) < ei.p(end-1,5) && ei.p(end,5) < ei.p(end,2) && shadowlineratio > 0.8) || ...
                            (ei.ss(end) > 9 && shadowlineratio > 0.9)
                        unwindflag = true;
                        msg = 'conditional uptrendconfirmed failed:shadowline1';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                else
                    %exception found on y2409 on 20240628
                    exceptionflag = (ei.p(end,4) > ei.p(end-1,4) & shadowlineratio <= 0.75) | ...
                        (ei.p(end,4) > ei.p(end-1,4) & ei.p(end,5) > ei.p(end-1,3) & shadowlineratio <= 0.85) | ...
                        (ei.p(end,4) > ei.p(end-1,4) & ei.p(end-1,3) > ei.hh(end-2) & ei.p(end-1,5) <= ei.hh(end-2) & ei.hh(end-1) >= ei.hh(end-2)) | ...
                        (strcmpi(val,'conditional-uptrendconfirmed-1') & ei.p(end,3) > ei.lvlup(end)) | ...
                        (ei.p(end,5) > ei.lvlup(end-1) & ei.p(end-1,5) < ei.lvlup(end-1)) | ...
                        ((~isnan(obj.tdlow_) | ~isnan(obj.td13low_)) & shadowlineratio <= 0.88);
                    if ~exceptionflag
                        unwindflag = true;
                        msg = 'conditional uptrendconfirmed failed:shadowline1';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                end
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
                    trade.opensignal_.mode_ = signaluncond.opkellied;
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
        isgovtbond = strcmpi(trade.instrument_.asset_name,'govtbond_30y') || ...
            strcmpi(trade.instrument_.asset_name,'govtbond_10y');
        
        if abs(ei.p(end,3) - ei.hh(end-1)) <= 2*trade.instrument_.tick_size && shadowlineratio > 0.618 && ~isgovtbond
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:within2ticks2andshadowline2';
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
        pxlow = min(ei.p(end-8:end,4));
        pxlowidx = find(ei.p(end-8:end,4) == pxlow,1,'last')+size(ei.bs,1)-9;
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
        if fractalupdate
            if ~isnan(obj.tdhigh_)
                bslow = find(ei.bs >= 9,1,'last');
                bslow = ei.bs(bslow);
                if bslow > 16
                    exceptionflag = false;
                else
                    exceptionflag = true;
                end
            else
                exceptionflag = strcmpi(val,'conditional-dntrendconfirmed-1') && ei.p(end,4) < ei.lvldn(end);
            end
            
            if ~exceptionflag
%                 unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:fractalllupdate';
%                 obj.status_ = 'closed';
                obj.closestr_ = msg;
                if ei.p(end,5) < ei.p(end,2)
                    checkpx = ei.p(end,3) - trade.instrument_.tick_size;
                else
                    checkpx = ei.p(end,5) - trade.instrument_.tick_size;
                end
                obj.pxstoploss_ = min(obj.pxstoploss_,checkpx);
                return
            end
        end
        %
        if within2ticks
            exceptionflag = ~isnan(obj.tdhigh_) || ...
                (strcmpi(val,'conditional-dntrendconfirmed-1') && ei.p(end,4) < ei.lvldn(end));
            if ~onopenflag
                if ~exceptionflag
                    exceptionflag = ei.p(end,3) < ei.p(end-1,3) & ei.p(end-1,4) & ei.p(end-1,4) - ei.ll(end-2) < 2*trade.instrument_.tick_size;
                end
                if ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:within2ticks2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                if ~exceptionflag
                    exceptionflag = ei.p(end,3) < ei.p(end-1,3) & ei.p(end,4) < ei.p(end-1,4) & ei.p(end-1,4) - ei.ll(end-2) < 2*trade.instrument_.tick_size;
                end
                if ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:within2ticks1';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return      
                end
            end
        end
        %
        if shadowlineratio > 0.618
            if ~onopenflag
                exceptionflag = (strcmpi(val,'conditional-dntrendconfirmed-1') & ei.p(end,4) < ei.lvldn(end)) | ...
                    ~isnan(obj.tdhigh_) | ~isnan(obj.td13high_);
                if ei.p(end,3) > ei.p(end-1,3) && ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:shadowline2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
                %
                if ei.p(end,4) < ei.p(end-1,4) && ...
                        ei.p(end,3) > ei.p(end-1,3) && ...
                        ei.p(end,5) > ei.p(end,2) && ...
                        ei.p(end-1,4) <= ei.ll(end-2) && ...
                        shadowlineratio > 0.8
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:shadowline2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
                %
                if (~(ei.p(end,3) < ei.p(end-1,3) && ei.p(end,4) < ei.p(end-1,4) && ei.p(end,5)-ei.p(end-1,5) - 2*trade.instrument_.tick_size<1e-5)) && ei.p(end-1,4) <= ei.ll(end-1)
                    obj.pxstoploss_ = ei.p(end,3)-2*trade.instrument_.tick_size;
                    msg = 'conditional dntrendconfirmed failed:shadowline2';
                    obj.closestr_ = msg; 
                end
                
            else
                if strcmpi(trade.opensignal_.frequency_,'daily') || strcmpi(trade.opensignal_.frequency_,'1440m')
                    isopencandle = false;
                else
                    isopencandle = abs(datenum([datestr(floor(ei.p(end,1)),'yyyy-mm-dd'), ' ',trade.instrument_.break_interval{1,1}],'yyyy-mm-dd HH:MM:SS')-ei.p(end,1)) < 1e-5;
                end
                if isopencandle
                    %the open market vol might be too high
                    if ei.p(end,5) >= min(ei.lips(end),ei.teeth(end)) || ...
                            (~isnan(obj.tdhigh_) && ei.p(end,5) > obj.tdhigh_) || ...
                            (~isnan(obj.td13high_) && ei.p(end,5) > obj.td13high_) || ...
                            (ei.p(end,3) >= ei.p(end-1,3) && shadowlineratio > 0.9) || ...
                            (ei.p(end,5) > ei.p(end-1,5) && shadowlineratio > 0.9) || ...
                            (ei.bs(end) >= 9 && shadowlineratio > 0.8)
                        unwindflag = true;
                        msg = 'conditional dntrendconfirmed failed:shadowline1';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                else
                    %exception found on p2409 on 20240418
                    exceptionflag = (ei.p(end,3) < ei.p(end-1,3) & shadowlineratio < 0.8) | ...
                        (ei.p(end,3) < ei.p(end-1,3) & ei.p(end-1,4) < ei.ll(end-2) & ei.p(end-1,5) >= ei.ll(end-2) & ei.ll(end-1) == ei.ll(end-2)) | ...
                        (ei.p(end,3) < ei.p(end-1,3) & ei.p(end,4) < ei.p(end-1,4) & ei.p(end-1,4) - ei.ll(end-2) < 2*trade.instrument_.tick_size) | ...
                        (ei.p(end,3) < ei.p(end-1,3) & ei.p(end,4) < ei.p(end-1,4) & ei.p(end,5) <= ei.p(end-1,5) & ei.bs(end) >= 2 & shadowlineratio < 0.8) | ...
                        ~isnan(obj.tdhigh_) | ~isnan(obj.td13high_);
                    if ~exceptionflag
                        unwindflag = true;
                        msg = 'conditional dntrendconfirmed failed:shadowline1';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                end
            end
        end
        %
        if runriskmanagementbeforemktclose
            if strcmpi(val,'conditional-dntrendconfirmed-3') || ei.bs(end) > 9
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
            if strcmpi(val,'conditional-dntrendconfirm-1')
                if ei.p(end,5) > ei.lvldn(end)
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:mktclose';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                else
                    obj.pxstoploss_ = ei.lvldn(end);
                end
            end
        end
        %
        %CASE8:special treatment for conditional breachdn-lvldn
        isbreachdnlvldn = ei.ll(end) <= ei.lvldn(end) && ei.p(end,5) > ei.lvldn(end);
        if isbreachdnlvldn && ~isempty(kellytables)
            tbl2lookup = kellytables.breachdnlvldn_tc;
            idx = strcmpi(tbl2lookup.asset,trade.instrument_.asset_name);
            kelly = tbl2lookup.K(idx);
            if kelly < 0.15
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:lowkelly:breachdnlvldn';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %CASE9:special treatment for conditional breachdn-bshighvalue
        lastbsidx = find(ei.bs >= 9,1,'last');
        if isempty(lastbsidx)
            ndiff = size(ei.bs,1);
        else
            ndiff = size(ei.bs,1)-lastbsidx;
        end
        isclose2lvldn = ~isnan(ei.lvlup(end)) && ~isnan(ei.lvldn(end)) && ...
            ei.lvlup(end)>ei.lvldn(end) && ...
            ei.ll(end)>ei.lvldn(end) && ...
            ((ei.ll(end)-ei.lvldn(end) <= 4*trade.instrument_.tick_size && nfractal > 2) || ...
            ((ei.ll(end)-ei.lvldn(end))/ei.ll(end) <= 0.003 && nfractal < 6));
        if ndiff <= 13 && ~isempty(kellytables) && ~isclose2lvldn
            lastbsval = ei.bs(lastbsidx);
            bslow = min(ei.p(lastbsidx-lastbsval+1:lastbsidx,4));
            if bslow == ei.ll(end)
                tbl2lookup = kellytables.breachdnbshighvalue_tc;
                idx = strcmpi(tbl2lookup.asset,trade.instrument_.asset_name);
                kelly = tbl2lookup.K(idx);
                if kelly < 0.145
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:lowkelly:breachdnbshighvalue';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            end
        end
        %
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
                    trade.opensignal_.mode_ = signaluncond.opkellied;
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
                        trade.opensignal_.mode_ = signaluncond.opkellied;
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
        isgovtbond = strcmpi(trade.instrument_.asset_name,'govtbond_30y') || ...
            strcmpi(trade.instrument_.asset_name,'govtbond_10y');
        
        if abs(ei.p(end,4) - ei.ll(end-1)) <= 2*trade.instrument_.tick_size && shadowlineratio > 0.618 && ~isgovtbond
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:within2ticks2andshadowline2';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        if abs(ei.p(end,4) - ei.ll(end-1)) <= 2*trade.instrument_.tick_size && ...
                ei.p(end,4) > ei.p(end-1,4) && ei.p(end,3) > ei.p(end-1,3) && ...
                ~(~isnan(obj.tdhigh_) && obj.tdhigh_ - ei.p(end,5) <= 4*trade.instrument_.tick_size) && ...
                ~isgovtbond
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:within2ticks2';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        if (ei.p(end,4) >= ei.p(end-1,3) && shadowlineratio >= 0.88) || ...
                (ei.p(end,4) > ei.p(end-1,4) && ei.p(end,3) > ei.p(end-1,3) && ei.p(end,5) > ei.p(end-1,5) && shadowlineratio > 0.85) && ...
                ~isgovtbond
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:shadowline2';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        if (ei.p(end,4) > ei.p(end-1,3) && ei.p(end,3) > ei.lips(end-1)) && ...
                ei.p(end-1,4) < ei.ll(end-2)
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:bigjump';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        unwindflag = false;
        msg = '';
    end
    %end of sflag && ~breachdnfailed && ~breachdnsuccess
    %
    %
end