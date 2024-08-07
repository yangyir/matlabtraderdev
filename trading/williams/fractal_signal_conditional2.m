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
    p.parse(varargin{:});
    ei = p.Results.ExtraInfo;
    ticksize = p.Results.TickSize;
    nfractal = p.Results.nFractal;
    uselastcandle = p.Results.UseLastCandle;
    assetname = p.Results.AssetName;
    kellytables = p.Results.KellyTables;
    
    try
        ei.px;
    catch
        ei.px = ei.p;
    end
    
    try
        [signal,op,flags] = fractal_signal_conditional(ei,ticksize,nfractal,'uselastcandle',uselastcandle);
    catch
        output = {};
        return
    end
    
    if ~isempty(signal) && ~isempty(signal{1,1}) && signal{1,1}(1) == 1
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
                if kelly > 0.088 && wprob >= 0.4
                    opkellied = 'conditional breachup-lvlup';
                else
                    opkellied = 'conditional breachup-lvlup not to place';
                end
            else
                if kelly >= 0.145 || (kelly>0.11 && wprob>0.41)
                    signalkellied(1) = 1;
                    if isbreachuplvlup
                        opkellied = 'conditional breachup-lvlup';
                    elseif isbreachupsshigh
                        opkellied = 'conditional breachup-sshighvalue';
                    elseif isbreachupschigh
                        opkellied = 'conditional breachup-highsc13';
                    end
                else
                    signalkellied(1) = 0;
                    if isbreachuplvlup
                        opkellied = 'conditional breachup-lvlup not to place';
                    elseif isbreachupsshigh
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
            if kelly >= 0.145 || (kelly>0.11 && wprob>0.41)
                signalkellied(1) = 1;
                opkellied = op{1,1};
            else
                %here we shall compare with unconditional mediumbreach or
                %strongbreach-trendconfirmed as it is not known whether
                %the conditional bid would turn out to be a volblowup
                if kelly3 >= 0.145 || (kelly3 > 0.11 && wprob3 > 0.41)
                    signalkellied(1) = 1;
                    opkellied = 'potential high kelly with volblowup breach up';
                elseif kelly2 >= 0.145 || (kelly2 > 0.11 && wprob2 > 0.41)
                    signalkellied(1) = 1;
                    opkellied = 'potential high kelly with ordinary trending breach up';
                else
                    signalkellied(1) = 0;
                    opkellied = [op{1,1},' not to place'];
                end
            end
        end
        output.signal = signal;
        output.op = op;
        output.flags = flags;
        output.directionkellied = signalkellied(1);
        output.signalkellied = signalkellied;
        output.opkellied = opkellied;
        return
    end
    %
    if ~isempty(signal) && ~isempty(signal{1,2}) && signal{1,2}(1) == -1
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
                vlookuptbl = kellytables.breachdnbshighvalue_tc;
            elseif isbreachdnbclow
                vlookuptbl = kellytables.breachdnlowbc13;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly), kelly = -9.99;end
            if isempty(wprob), wprob = 0;end
            %
            if kelly >= 0.145 || (kelly>0.11 && wprob>0.41)
                signalkellied(1) = -1;
                if isbreachdnlvldn
                    opkellied = 'conditional breachdn-lvldn';
                elseif isbreachdnbslow
                    opkellied = 'conditional breachdn-bshighvalue';
                elseif isbreachdnbclow
                    opkellied = 'conditional breachdn-lowbc13';
                end
            else
                signalkellied(1) = 0;
                if isbreachdnlvldn
                    opkellied = 'conditional breachdn-lvldn not to place';
                elseif isbreachdnbslow
                    opkellied = 'conditional breachdn-bshighvalue not to place';
                elseif isbreachdnbclow
                    opkellied = 'conditional breachdn-lowbc13 not to place';
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
            if kelly >= 0.145 || (kelly>0.11 && wprob>0.41)
                signalkellied(1) = -1;
                opkellied = op{1,2};
            else
                %here we shall compare with unconditional mediumbreach or
                %strongbreach-trendconfirmed as it is not known whether
                %the conditional bid would turn out to be a volblowup
                if kelly3 >= 0.145 || (kelly3 > 0.11 && wprob3 > 0.41)
                    if kelly < 0
                        extracheck = isempty(find(ei.px(end-2*nfractal+1:end,5)-ei.teeth(end-2*nfractal+1:end)+ticksize>0,1,'first'));
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
                        extracheck = isempty(find(ei.px(end-2*nfractal+1:end,5)-ei.teeth(end-2*nfractal+1:end)+ticksize>0,1,'first'));
                        if extracheck
                            signalkellied(1) = -1;
                            opkellied = 'potential high kelly with volblowup breach dn';
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
        return
    end
    
    
    output = {};
end