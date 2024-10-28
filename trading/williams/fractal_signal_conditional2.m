function [output] = fractal_signal_conditional2(varargin)
%return conditional signal given kelly distribution tables
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.addParameter('TickSize',0,@isnumeric);
    p.addParameter('nFractal',4,@isnumeric);
    p.addParameter('UseLastCandle',true,@islogical);
    p.addParameter('AssetName','',@ischar);
    p.addParameter('KellyTables',{},@isstruct);
    p.addParameter('TickSizeRatio',1,@isnumeric);
    p.parse(varargin{:});
    ei = p.Results.ExtraInfo;
    ticksize = p.Results.TickSize;
    nfractal = p.Results.nFractal;
    uselastcandle = p.Results.UseLastCandle;
    assetname = p.Results.AssetName;
    kellytables = p.Results.KellyTables;
    ticksizeratio = p.Results.TickSizeRatio;
    
    try
        ei.px;
    catch
        ei.px = ei.p;
    end
    
    try
        [signal,op,flags] = fractal_signal_conditional(ei,ticksizeratio*ticksize,nfractal,'uselastcandle',uselastcandle);
    catch
        output = {};
        return
    end
    
    if isempty(signal)
        output = {};
        return
    end
    
    if ~isempty(signal) && ~isempty(signal{1,1}) && signal{1,1}(1) == 1
        %extracheck to avoid conditional open on fractal ll update point
        highs = ei.px(end-nfractal+1:end,3);
        highest = max(highs);
        if highs(1) == highest && highest > ei.hh(end) && nfractal ~= 6
            output = {};
            return
        end
        %
        %extracheck to avoid conditional open on reverse trend, i.e. the
        %price has fallen from the fractal hh already
        lastss = find(ei.ss >= 9,1,'last');
        if size(ei.ss,1) - lastss <= nfractal
            lastssval = ei.ss(lastss);
            sshigh = max(ei.px(lastss-lastssval+1:lastss,3));
            sshighidx = find(ei.px(lastss-lastssval+1:lastss,3) == sshigh,1,'last')+lastss-lastssval;
            sslow = ei.px(sshighidx,4);
            if ei.hh(end) <= 2*sslow-sshigh+1e-6 && ei.hh(end) < sshigh
                output = {};
                return
            end
        end
        %
        signalkellied = signal{1,1};
        opkellied = '';
        isbreachuplvlup = flags.islvlupbreach;
        isbreachupsshigh = flags.issshighbreach;
        isbreachupschigh = flags.isschighbreach;
        %
        if isbreachuplvlup || isbreachupsshigh || isbreachupschigh
            if isbreachuplvlup
                vlookuptbl = kellytables.breachuplvlup_tc;
            elseif isbreachupsshigh
                vlookuptbl = kellytables.breachupsshighvalue_tc;
            elseif isbreachupschigh
                vlookuptbl = kellytables.breachuphighsc13;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly), kelly = -9.99;end
            if isempty(wprob), wprob = 0;end
            %
            if isbreachuplvlup
                if kelly >= 0.088
                    signalkellied(1) = 1;
                    opkellied = 'conditional breachup-lvlup';
                else
                    signalkellied(1) = 0;
                    opkellied = 'conditional breachup-lvlup not to place';
                end
            else
                if kelly >= 0.088
                    signalkellied(1) = 1;
                    if isbreachupsshigh
                        opkellied = 'conditional breachup-sshighvalue';
                    elseif isbreachupschigh
                        opkellied = 'conditional breachup-highsc13';
                    end
                else
                    signalkellied(1) = 0;
                    if isbreachupsshigh
                        opkellied = 'conditional breachup-sshighvalue not to place';
                    elseif isbreachupschigh
                        opkellied = 'conditional breachup-highsc13 not to place';
                    end
                end
            end
        else
            if strcmpi(op{1,1},'conditional:mediumbreach-trendconfirmed')
                vlookuptbl = kellytables.bmtc;
                try
                    kelly2 = kelly_k('mediumbreach-trendconfirmed',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                    wprob2 = kelly_w('mediumbreach-trendconfirmed',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
            elseif strcmpi(op{1,1},'conditional:strongbreach-trendconfirmed')
                vlookuptbl = kellytables.bstc;
                try
                    kelly2 = kelly_k('strongbreach-trendconfirmed',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                    wprob2 = kelly_w('strongbreach-trendconfirmed',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly), kelly = -9.99;end
            if isempty(wprob), wprob = 0;end
            %
            try
                kelly3 = kelly_k('volblowup',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                wprob3 = kelly_w('volblowup',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
            catch
                kelly3 = -9.99;
                wprob3 = 0;
            end
            %
            if kelly >= 0.088
                signalkellied(1) = 1;
                opkellied = op{1,1};
            else
                %here we shall compare with unconditional mediumbreach or
                %strongbreach-trendconfirmed as it is not known whether
                %the conditional bid would turn out to be a volblowup
                if kelly3 >= 0.145 || (kelly3 > 0.11 && wprob3 > 0.41)
                    if kelly < 0
                        extracheck = isempty(find(ei.px(end-2*nfractal+1:end,5)-ei.teeth(end-2*nfractal+1:end)-ticksizeratio*ticksize<0,1,'first'));
                        if extracheck
                            signalkellied(1) = 1;
                            opkellied = 'potential high kelly with volblowup breach up';
                        else
                            signalkellied(1) = 0;
                            opkellied = [op{1,1},' not to place as extra check failed'];
                        end
                    else
                        signalkellied(1) = 1;
                        opkellied = 'potential high kelly with volblowup breach up';
                    end
                elseif kelly2 >= 0.145 || (kelly2 > 0.11 && wprob2 > 0.41)
                    if kelly < 0
                        extracheck = isempty(find(ei.px(end-2*nfractal+1:end,5)-ei.teeth(end-2*nfractal+1:end)-ticksizeratio*ticksize<0,1,'first'));
                        if extracheck
                            signalkellied(1) = 1;
                            opkellied = 'potential high kelly with ordinary trending breach up';
                        else
                            signalkellied(1) = 0;
                            opkellied = [op{1,1},' not to place as extra check failed'];
                        end 
                    else
                        signalkellied(1) = 1;
                        opkellied = 'potential high kelly with ordinary trending breach up';
                    end
                else
                    signalkellied(1) = 0;
                    opkellied = [op{1,1},' not to place'];
                end
            end
        end
        %
        %
        if ei.px(end,5) < ei.lips(end) && ei.hh(end) < ei.lips(end) && ~isnan(ei.lvlup(end)) && ei.px(end,5) < ei.lvlup(end)
            signal{1,1}(1) = 0;
            signalkellied(1) = 0;
            if isbreachuplvlup
                opkellied = 'conditional:breachup-lvlup-tc not to placed as price and hh is below lips';
            elseif isbreachupsshigh
                opkellied = 'conditional:breachup-sshighvalue-tc not to placed as price and hh is below lips';
            elseif isbreachupschigh
                opkellied = 'conditional:breachup-highsc13-tc not to placed as price and hh is below lips';
            else
                opkellied = [op{1,1},' not to placed as price and hh is below lips'];
            end
        end
        %
        output.signal = signal;
        output.op = op;
        output.flags = flags;
        output.directionkellied = signalkellied(1);
        output.signalkellied = signalkellied;
        output.opkellied = opkellied;
        output.kelly = kelly;
        output.wprob = wprob;
        return
    end
    %
    if ~isempty(signal) && ~isempty(signal{1,2}) && signal{1,2}(1) == -1
        %extracheck to avoid conditional open on fractal ll update point
        lows = ei.px(end-nfractal+1:end,4);
        lowest = min(lows);
        if lows(1) == lowest && lowest < ei.ll(end) && nfractal ~= 6
            output = {};
            return
        end
        %
        %extracheck to avoid conditional open on reverse trend, i.e. the
        %price has rallied from the fractal ll already
        lastbs = find(ei.bs >= 9,1,'last');
        if size(ei.bs,1) - lastbs <= nfractal
            lastbsval = ei.bs(lastbs);
            bslow = min(ei.px(lastbs-lastbsval+1:lastbs,4));
            bslowidx = find(ei.px(lastbs-lastbsval+1:lastbs,4) == bslow,1,'last')+lastbs-lastbsval;
            bshigh = ei.px(bslowidx,3);
            if ei.ll(end) >= 2*bshigh-bslow-1e-6 && ei.ll(end) > bslow
                output = {};
                return
            end
        end
        %
        %NOTE:we dont have a symmetry in the long case for the case below
        waspxbelowll = isempty(find(ei.px(end-nfractal+1:end-1,5)-ei.ll(end-nfractal+1:end-1)>0,1,'first'));
        wasllabovelips = ei.ll(end)-ei.lips(end)>-ticksizeratio*ticksize;
        if waspxbelowll && wasllabovelips
            output = {};
            return
        end
        
        signalkellied = signal{1,2};
        opkellied = '';
        isbreachdnlvldn = flags.islvldnbreach;
        isbreachdnbslow = flags.isbslowbreach;
        isbreachdnbclow = flags.isbclowbreach;
        %
        if isbreachdnlvldn || isbreachdnbslow || isbreachdnbclow
            if isbreachdnlvldn
                vlookuptbl = kellytables.breachdnlvldn_tc;
            elseif isbreachdnbslow
                if ~isbreachdnbclow
                    vlookuptbl = kellytables.breachdnbshighvalue_tc;
                else
                    %need to make sure the ll is the same as bc13 low
                    lastbcidx = find(ei.bc == 13,1,'last');
                    bc13low = ei.px(lastbcidx,4);
                    if bc13low == ei.ll(end)
                        vlookuptbl = kellytables.breachdnlowbc13;
                    else
                        vlookuptbl = kellytables.breachdnbshighvalue_tc;
                    end
                end
            elseif isbreachdnbclow
                vlookuptbl = kellytables.breachdnlowbc13;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly), kelly = -9.99;end
            if isempty(wprob), wprob = 0;end
            %
            if isbreachdnlvldn
                if kelly >= 0.088
                    signalkellied(1) = -1;
                    opkellied = 'conditional breachdn-lvldn';
                else
                    signalkellied(1) = 0;
                    opkellied = 'conditional breachdn-lvldn not to place';
                end
            else
                if kelly >= 0.088
                    signalkellied(1) = 1;
                    if isbreachdnbslow
                        if ~isbreachdnbclow
                            opkellied = 'conditional breachdn-bshighvalue';
                        else
                            %need to make sure the ll is the same as bc13 low
                            lastbcidx = find(ei.bc == 13,1,'last');
                            bc13low = ei.px(lastbcidx,4);
                            if bc13low == ei.ll(end)
                                opkellied = 'conditional breachdn-lowbc13';
                            else
                                opkellied = 'conditional breachdn-bshighvalue';
                            end
                        end
                    elseif isbreachdnbclow
                        opkellied = 'conditional breachdn-lowbc13';
                    end
                else
                    signalkellied(1) = 0;
                    if isbreachdnbslow
                        if ~isbreachdnbclow
                            opkellied = 'conditional breachdn-bshighvalue not to place';
                        else
                            %need to make sure the ll is the same as bc13 low
                            lastbcidx = find(ei.bc == 13,1,'last');
                            bc13low = ei.px(lastbcidx,4);
                            if bc13low == ei.ll(end)
                                opkellied = 'conditional breachdn-lowbc13 not to place';
                            else
                                opkellied = 'conditional breachdn-bshighvalue not to place';
                            end
                        end
                    elseif isbreachdnbclow
                        opkellied = 'conditional breachdn-lowbc13 not to place';
                    end     
                end
            end
        else
            if strcmpi(op{1,2},'conditional:mediumbreach-trendconfirmed')
                vlookuptbl = kellytables.smtc;
                try
                    kelly2 = kelly_k('mediumbreach-trendconfirmed',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                    wprob2 = kelly_w('mediumbreach-trendconfirmed',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
            elseif strcmpi(op{1,2},'conditional:strongbreach-trendconfirmed')
                vlookuptbl = kellytables.sstc;
                try
                    kelly2 = kelly_k('strongbreach-trendconfirmed',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                    wprob2 = kelly_w('strongbreach-trendconfirmed',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
                catch
                    kelly2 = -9.99;
                    wprob2 = 0;
                end
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly), kelly = -9.99;end
            if isempty(wprob), wprob = 0;end
            %
            try
                kelly3 = kelly_k('volblowup',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                wprob3 = kelly_w('volblowup',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
            catch
                kelly3 = -9.99;
                wprob3 = 0;
            end
            %
            if kelly >= 0.088
                signalkellied(1) = -1;
                opkellied = op{1,2};
            else
                %here we shall compare with unconditional mediumbreach or
                %strongbreach-trendconfirmed as it is not known whether
                %the conditional bid would turn out to be a volblowup
                if kelly3 >= 0.145 || (kelly3 > 0.11 && wprob3 > 0.41)
                    if kelly < 0
                        extracheck = isempty(find(ei.px(end-2*nfractal+1:end,5)-ei.teeth(end-2*nfractal+1:end)+ticksizeratio*ticksize>0,1,'first'));
                        if extracheck
                            signalkellied(1) = -1;
                            opkellied = 'potential high kelly with volblowup breach dn';
                        else
                            signalkellied(1) = 0;
                            opkellied = [op{1,2},' not to place as extra check failed'];
                        end 
                    else
                        signalkellied(1) = -1;
                        opkellied = 'potential high kelly with volblowup breach dn';
                    end
                elseif kelly2 >= 0.145 || (kelly2 > 0.11 && wprob2 > 0.41)
                    if kelly < 0
                        extracheck = isempty(find(ei.px(end-2*nfractal+1:end,5)-ei.teeth(end-2*nfractal+1:end)+ticksizeratio*ticksize>0,1,'first'));
                        if extracheck
                            signalkellied(1) = -1;
                            opkellied = 'potential high kelly with ordinary trending breach dn';
                        else
                            signalkellied(1) = 0;
                            opkellied = [op{1,2},' not to place as extra check failed'];
                        end 
                    else
                        signalkellied(1) = -1;
                        opkellied = 'potential high kelly with ordinary trending breach dn';
                    end
                else
                    signalkellied(1) = 0;
                    opkellied = [op{1,2},' not to place'];
                end
            end
        end
        output.signal = signal;
        output.op = op;
        output.flags = flags;
        output.directionkellied = signalkellied(1);
        output.signalkellied = signalkellied;
        output.opkellied = opkellied;
        output.kelly = kelly;
        output.wprob = wprob;
        return
    end
    
    
    output = {};
end