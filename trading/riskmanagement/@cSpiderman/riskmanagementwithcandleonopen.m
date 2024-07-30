function [unwindflag,msg] = riskmanagementwithcandleonopen(varargin)
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
    extrainfo = p.Results.ExtraInfo;
    try
        extrainfo.p(end,1);
    catch
        extrainfo.p = extrainfo.px;
    end
    if extrainfo.p(end,1) > trade.opendatetime1_
        %the candle has passed the open candle
        return
    end
    if trade.opendatetime1_ - extrainfo.p(end,1) > extrainfo.p(end,1) - extrainfo.p(end-1,1)
        %the candle hasn't reached the open candle yet
        return
    end
    if extrainfo.p(end,1) - extrainfo.p(end-1,1) >= 1
        nfractal = 2;
    elseif extrainfo.p(end,1) - extrainfo.p(end-1,1) <= 5/1440
        nfractal = 6;
    else
        nfractal = 4;
    end
    %
    runriskmanagementbeforemktclose = p.Results.RunRiskManagementBeforeMktClose;
    kellytables = p.Results.KellyTables;
    
    lflag = strcmpi(val,'conditional-uptrendconfirmed') || strcmpi(val,'conditional-uptrendconfirmed-1') || strcmpi(val,'conditional-uptrendconfirmed-2') || strcmpi(val,'conditional-uptrendconfirmed-3');
    sflag = strcmpi(val,'conditional-dntrendconfirmed') || strcmpi(val,'conditional-dntrendconfirmed-1') || strcmpi(val,'conditional-dntrendconfirmed-2') || strcmpi(val,'conditional-dntrendconfirmed-3');
    breachupfailed = (extrainfo.p(end,5) <= extrainfo.hh(end-1) && extrainfo.p(end,3) > extrainfo.hh(end-1));
    breachupsuccess = extrainfo.p(end,5) > extrainfo.hh(end-1) && extrainfo.p(end-1,5) < extrainfo.hh(end-1);
    breachdnfailed = extrainfo.p(end,5) >= extrainfo.ll(end-1) && extrainfo.p(end,4) < extrainfo.ll(end-1);
    breachdnsuccess = extrainfo.p(end,5) < extrainfo.ll(end-1) && extrainfo.p(end-1,5) > extrainfo.ll(end-1);
    
    if lflag && breachupfailed
        %CASE1: special treatment for tin as it is very volatile
        %exception:close above open with sell setup sequential above 3
        %todo:might be removed later
        if strcmpi(trade.instrument_.asset_name,'tin') &&...
                ~(extrainfo.p(end,2) < extrainfo.p(end,5) && ...
                extrainfo.ss(end) >= 3)
            unwindflag = true;
            msg = 'contional uptrendconfirmed failed:tin';
            return
        end
        %CASE2:close above open but high is within 2 ticks above fractal hh
        if extrainfo.p(end,2) < extrainfo.p(end,5) && ...
                extrainfo.p(end,3) - extrainfo.hh(end-1) <= 2*trade.instrument_.tick_size
            unwindflag = true;
            msg = 'contional uptrendconfirmed failed:within2ticks';
            return
        end
        %CASE3:up shadow line is too long
        shadowlinewidth = extrainfo.p(end,3)-extrainfo.p(end,5);
        kwidth = extrainfo.p(end,3)-extrainfo.p(end,4);
        if shadowlinewidth/kwidth > 0.618
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:shadow line:shadowline';
            return
        end
        exceptionflag = extrainfo.p(end,5) > extrainfo.lvlup(end) && ...
            extrainfo.p(end,5) > extrainfo.teeth(end) && ...
            extrainfo.lips(end) > extrainfo.teeth(end);
        thisbd = floor(extrainfo.p(end,1));
        nextbd = dateadd(thisbd,'1b');
        exceptionflag = exceptionflag & nextbd - thisbd <= 3;
        %CASE4:close before market close
        if runriskmanagementbeforemktclose && ~exceptionflag
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:shadow line:mktclose';
            return
        end
        %CASE5:the price is low enough
        if extrainfo.p(end,5) < max(extrainfo.teeth(end),extrainfo.lips(end)) && ~exceptionflag
            unwindflag = true;
            msg = 'conditional uptrendconfirmed failed:lowprice';
            return
        end
        %CASE6:potential high kelly failed
        if strcmpi(val,'conditional-uptrendconfirmed')
            output = fractal_signal_conditional2('extrainfo',extrainfo,...
                'ticksize',trade.instrument_.tick_size,...
                'nfractal',nfractal,...
                'kellytables',kellytables,...
                'assetname',trade.instrument_.asset_name);
            if ~isempty(output)
                if ~isempty(strfind(output.opkellied,'potential'))
                    unwindflag = true;
                    msg = 'conditional uptrendconfirmed failed:lowkelly';
                    return
                end
            end
        end
        %  
    end
    %end of lfag with breachupfailed
    %
    %
    if runriskmanagementbeforemktclose && lflag && breachupsuccess
        status = fractal_b1_status(nfractal,extrainfo,trade.instrument_.tick_size);
        if strcmpi(val,'conditional-uptrendconfirmed-1')
            tbl = kellytables.breachuplvlup_tc;
            idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
            kelly = tbl.K(idx);
        elseif status.isvolblowup
            kelly = kelly_k('volblowup',trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
        elseif strcmpi(val,'conditional-uptrendconfirmed-2')
            tbl = kellytables.breachupsshighvalue_tc;
            idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
            kelly = tbl.K(idx);
        elseif strcmpi(val,'conditional-uptrendconfirmed-3')
            tbl = kellytables.breachuphighsc13;
            idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
            kelly = tbl.K(idx);
        else
            if status.b1type == 2
                kelly = kelly_k('mediumbreach-trendconfirmed',trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
            elseif status.b1type == 3
                kelly = kelly_k('strongbreach-trendconfirmed',trade.instrument_.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
            end
        end
        if kelly < 0.145
            unwindflag = true;
            msg = 'conditional uptrendconfirmed success:lowkelly';
            return
        end
    end
    %end of runriskmanagementbeforemktclose && lflag && breachupsuccess
    %
    %
    if sflag && breachdnfailed
        %CASE1: special treatment for tin as it is very volatile
        %exception:close below open with high below lips
        %todo:might be removed later
        if strcmpi(trade.instrument_.asset_name,'tin') && ...
                ~(extrainfo.p(end,3) < extrainfo.lips(end) && ...
                extrainfo.p(end,5) < extrainfo.p(end,2))
            unwindflag = true;
            msg = 'contional dntrendconfirmed failed:tin';
            return
        end
        %CASE2:close below open but low is within 2 ticks below fractal ll
        if (extrainfo.p(end,2) > extrainfo.p(end,5) || strcmpi(val,'conditional-dntrendconfirmed-2')) && ...
                extrainfo.ll(end-1) - extrainfo.p(end,4) <= 2*trade.instrument_.tick_size
            unwindflag = true;
            msg = 'contional dntrendconfirmed failed:within2ticks';
            return
        end
        %CASE3:dn shadow line is too long
        shadowlinewidth = extrainfo.p(end,5)-extrainfo.p(end,4);
        kwidth = extrainfo.p(end,3)-extrainfo.p(end,4);
        if shadowlinewidth/kwidth > 0.618
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:shadow line:shadowline';
            return
        end  
        %CASE4:close before market close
        if runriskmanagementbeforemktclose
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:shadow line:mktclose';
            return
        end
        %CASE5:the price is high enough
        if extrainfo.p(end,5) > min(extrainfo.teeth(end),extrainfo.lips(end))
            unwindflag = true;
            msg = 'conditional dntrendconfirmed failed:highprice';
            return
        end
        %CASE6:potential high kelly failed
        if strcmpi(val,'conditional-dntrendconfirmed')
            output = fractal_signal_conditional2('extrainfo',extrainfo,...
                'ticksize',trade.instrument_.tick_size,...
                'nfractal',nfractal,...
                'kellytables',kellytables,...
                'assetname',trade.instrument_.asset_name);
            if ~isempty(output)
                if ~isempty(strfind(output.opkellied,'potential'))
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:lowkelly';
                end
            end
        end
        %CASE7:special treatment for conditional breachdn-lvldn
        isbreachdnlvldn = extrainfo.ll(end) <= extrainfo.lvldn(end) && extrainfo.p(end,5) > extrainfo.lvldn(end);
        if isbreachdnlvldn
            tbl2lookup = kellytables.breachdnlvldn_tc;
            idx = strcmpi(tbl2lookup.asset,trade.instrument_.asset_name);
            kelly = tbl2lookup.K(idx);
            if kelly < 0.15
                unwindflag = true;
                msg = 'conditional dntrendconfirmed failed:shadow line:breachdnlvldn';
                return
            end
        end
        %CASE8:special treatment for conditional breachdn-bshighvalue
        lastbsidx = find(extrainfo.bs >= 9,1,'last');
        if isempty(lastbsidx)
            ndiff = size(extrainfo.bs,1);
        else
            ndiff = size(extrainfo.bs,1)-lastbsidx;
        end
        if ndiff <= 13
            lastbsval = extrainfo.bs(lastbsidx);
            bslow = min(extrainfo.p(lastbsidx-lastbsval+1:lastbsidx,4));
            if bslow == extrainfo.ll(end)
                tbl2lookup = kellytables.breachdnbshighvalue_tc;
                idx = strcmpi(tbl2lookup.asset,trade.instrument_.asset_name);
                kelly = tbl2lookup.K(idx);
                if kelly < 0.145
                    unwindflag = true;
                    msg = 'conditional dntrendconfirmed failed:shadow line:breachdnbshighvalue';
                    return
                end
            end
        end
    end
    %end of sflag with breachdnfailed
    %
    %
    if runriskmanagementbeforemktclose && sflag && breachdnsuccess
        status = fractal_s1_status(nfractal,extrainfo,trade.instrument_.tick_size);
        if strcmpi(val,'conditional-dntrendconfirmed-1')
            tbl = kellytables.breachdnlvldn_tc;
            idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
            kelly = tbl.K(idx);
        elseif status.isvolblowup
            kelly = kelly_k('volblowup',trade.instrument_.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s);
        elseif strcmpi(val,'conditional-dntrendconfirmed-2')
            tbl = kellytables.breachdnbshighvalue_tc;
            idx = strcmpi(tbl.asset,trade.instrument_.asset_name);
            kelly = tbl.K(idx);
        elseif strcmpi(val,'conditional-dntrendconfirmed-3')
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
            unwindflag = true;
            msg = 'conditional dntrendconfirmed success:lowkelly';
            return
        end
    end
    %end of runriskmanagementbeforemktclose && sflag && breachdnsuccess
end