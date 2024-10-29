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
    
    if lflag && breachupfailed
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
            exceptionflag = ~isnan(obj.tdlow_) || (strcmpi(val,'conditional-uptrendconfirmed-1') && ei.p(end,3) > ei.lvlup(end));
            if ~onopenflag
                if ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed failed:within2ticks2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
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
                if ei.p(end,4) < ei.p(end-1,4) && ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed failed:shadowline2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                isopencandle = abs(datenum([datestr(floor(ei.p(end,1)),'yyyy-mm-dd'), ' ',trade.instrument_.break_interval{1,1}],'yyyy-mm-dd HH:MM:SS')-ei.p(end,1)) < 1e-5;
                if isopencandle
                    %the open market vol might be too high
                    if ei.p(end,5) <= max(ei.lips(end),ei.teeth(end))
                        unwindflag = true;
                        msg = 'conditional uptrendconfirmed failed:shadowline1';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                else
                    %exception found on y2409 on 20240628
                    exceptionflag = (ei.p(end,4) > ei.p(end-1,4) && shadowlineratio < 0.75) || ...
                        (strcmpi(val,'conditional-uptrendconfirmed-1') && ei.p(end,3) > ei.lvlup(end)) || ...
                        ~isnan(obj.tdlow_);
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
            if strcmpi(val,'conditional-uptrendconfirmed-3') || ei.ss(end) > 9
                unwindflag = true;
                msg = 'conditional uptrendconfirmed failed:mktclose';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
            if strcmpi(freq_,'5m') && ei.p(end,3)-ei.hh(end-1) <= 2*trade.instrument_.tick_size
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:mktclose';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
    end
    %end of lflag && breachupfailed
    %
    if lflag && breachupsuccess
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
                if kelly < 0.088
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
            end
        else
            unwindflag = true;
            msg = 'conditional uptrendconfirmed success:lowkelly';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
    end
    %end of lflag && breachupsuccess
    %
    if lflag && ~breachupfailed && ~breachupsuccess
        %the trade has moved on from its openning candle
%         if onopenflag, error('riskmanagementwithcandleonopen:internal error with lflag!');end
        if runriskmanagementbeforemktclose && strcmpi(freq_,'5m') && ei.p(end,3)-ei.hh(end-1) <= 2*trade.instrument_.tick_size 
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:mktclose';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
        if ei.p(end,5) >= ei.hh(end-1) && ei.p(end-1,5) < ei.hh(end-1)
            status = fractal_b1_status(nfractal,ei,trade.instrument_.tick_size);
            if strcmpi(val,'conditional-uptrendconfirmed-1')
                trade.opensignal_.mode_ = 'breachup-lvlup';
            elseif strcmpi(val,'conditional-uptrendconfirmed-2')
                trade.opensignal_.mode_ = 'breachup-sshighvalue';
            elseif strcmpi(val,'conditional-uptrendconfirmed-3')
                trade.opensignal_.mode_ = 'breachup-highsc13';
            elseif strcmpi(val,'conditional-uptrendconfirmed')
                if status.isvolblowup
                    trade.opensignal_.mode_ = 'volblowup';
                elseif status.isvolblowup2
                    trade.opensignal_.mode_ = 'volblowup2';
                else
                    if status.b1type == 2
                        trade.opensignal_.mode_ = 'mediumbreach-trendconfirmed';
                    elseif status.b1type == 3
                        trade.opensignal_.mode_ = 'strongbreach-trendconfirmed';
                    end
                end    
            end
        end
        unwindflag = false;
        msg = '';
        return
    end
    %end of lflag && ~breachupfailed && ~breachupsuccess
    %
    %
    % ------- BELOW IS FOR SHORT POSITION ------- %
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
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:fractalllupdate';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
                return
            end
        end
        %
        if within2ticks
            exceptionflag = ~isnan(obj.tdhigh_) || (strcmpi(val,'conditional-dntrendconfirmed-1') && ei.p(end,4) < ei.lvldn(end));
            if ~onopenflag
                if ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:within2ticks2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
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
                exceptionflag = (strcmpi(val,'conditional-dntrendconfirmed-1') && ei.p(end,4) < ei.lvldn(end)) || ...
                    ~isnan(obj.tdhigh_) || ~isnan(obj.td13high_);
                if ei.p(end,3) > ei.p(end-1,3) && ~exceptionflag
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:shadowline2';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                    return
                end
            else
                isopencandle = abs(datenum([datestr(floor(ei.p(end,1)),'yyyy-mm-dd'), ' ',trade.instrument_.break_interval{1,1}],'yyyy-mm-dd HH:MM:SS')-ei.p(end,1)) < 1e-5;
                if isopencandle
                    %the open market vol might be too high
                    if ei.p(end,5) >= min(ei.lips(end),ei.teeth(end))
                        unwindflag = true;
                        msg = 'conditional dntrendconfirmed failed:shadowline1';
                        obj.status_ = 'closed';
                        obj.closestr_ = msg;
                        return
                    end
                else
                    %exception found on p2409 on 20240418
                    exceptionflag = ei.p(end,3) < ei.p(end-1,3) & ...
                        shadowlineratio < 0.8;
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
        end
        %
        %CASE8:special treatment for conditional breachdn-lvldn
        isbreachdnlvldn = ei.ll(end) <= ei.lvldn(end) && ei.p(end,5) > ei.lvldn(end);
        if isbreachdnlvldn
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
        if ndiff <= 13
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
                if kelly < 0.088
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed success:lowkelly';
                    obj.status_ = 'closed';
                    obj.closestr_ = msg;
                end
            else
                unwindflag = true;
                msg = 'conditional dntrendconfirmed success:lowkelly';
                obj.status_ = 'closed';
                obj.closestr_ = msg;
            end
        else
            unwindflag = true;
            msg = 'conditional dntrendconfirmed success:lowkelly';
            obj.status_ = 'closed';
            obj.closestr_ = msg;
            return
        end
        %
    end
    %end of sflag && breachdnsuccess
    %
    if sflag && ~breachdnfailed && ~breachdnsuccess
        %the trade has moved on from its openning candle
%         if onopenflag, error('riskmanagementwithcandleonopen:internal error with slfag!');end
        if runriskmanagementbeforemktclose && strcmpi(freq_,'5m') && ei.ll(end-1)-ei.p(end,4) <= 2*trade.instrument_.tick_size
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:mktclose';
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