function [output] = fractal_signal_unconditional2(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('ExtraInfo',{},@isstruct);
    p.addParameter('TickSize',0,@isnumeric);
    p.addParameter('nFractal',4,@isnumeric);
    p.addParameter('AssetName','',@ischar);
    p.addParameter('KellyTables',{},@isstruct);
    p.addParameter('TickSizeRatio',1,@isnumeric);
    p.parse(varargin{:});
    ei = p.Results.ExtraInfo;
    ticksize = p.Results.TickSize;
    nfractal = p.Results.nFractal;
    assetname = p.Results.AssetName;
    kellytables = p.Results.KellyTables;
    ticksizeratio = p.Results.TickSizeRatio;
    
    try
        ei.px;
    catch
        ei.px = ei.p;
    end
    
    try
        [signal_i,op,status] = fractal_signal_unconditional(ei,ticksizeratio*ticksize,nfractal);
        output.signal = signal_i;
        output.op = op;
        output.status = status;
    catch
        output = {};
        return
    end
    
    if isempty(signal_i)
        %fractal_signal_unconditional returns EMPTY signal in case there
        %was a invalid breach
        output = {};
        return
    end
    
    if signal_i(1) == 0
        if op.direction == 1
            try
                kelly = kelly_k(op.comment,assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                wprob = kelly_w(op.comment,assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
                useflag = 1;
            catch
                idx = strcmpi(op.comment,kellytables.kelly_table_l.opensignal_unique_l);
                kelly = kellytables.kelly_table_l.kelly_unique_l(idx);
                wprob = kellytables.kelly_table_l.winp_unique_l(idx);
                useflag = kellytables.kelly_table_l.use_unique_l(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                    useflag = 0;
                end
            end
        elseif op.direction == -1
            try
                kelly = kelly_k(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                wprob = kelly_w(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
                useflag = 1;
            catch
                idx = strcmpi(op.comment,kellytables.kelly_table_s.opensignal_unique_s);
                kelly = kellytables.kelly_table_s.kelly_unique_s(idx);
                wprob = kellytables.kelly_table_s.winp_unique_s(idx);
                useflag = kellytables.kelly_table_s.use_unique_s(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                    useflag = 0;
                end
            end
        else
            %op.direction = 0
            kelly = -9.99;
            wprob = 0;
            useflag = 0;
        end
        %
        if strcmpi(op.comment,'breachup-lvlup-invalid long as close moves too high')
            if status.istrendconfirmed
                vlookuptbl = kellytables.breachuplvlup_tc;
            else
                vlookuptbl = kellytables.breachuplvlup_tb;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088 && wprob > 0.4
                useflag = 1;
                op.comment = 'breachup-lvlup';
                output.op = op;
            else
                useflag = 0;
            end
        end
        %
        if strcmpi(op.comment,'breachup-sshighvalue-invalid long as close moves too high')
            if status.istrendconfirmed
                vlookuptbl = kellytables.breachupsshighvalue_tc;
            else
                vlookuptbl = kellytables.breachupsshighvalue_tb;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if (status.istrendconfirmed && kelly >= 0.088 && wprob >= 0.3) ||...
                    (~status.istrendconfirmed && kelly >= 0.145)
                useflag = 1;
                op.comment = 'breachup-sshighvalue';
                output.op = op;
            else
                useflag = 0;
            end
        end
        %
        if status.istrendconfirmed && strcmpi(op.comment,'volblowup-invalid long as close moves too high')
            try
                kelly = kelly_k('volblowup',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                wprob = kelly_w('volblowup',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
            catch
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088 && wprob >= 0.3
                useflag = 1;
                op.comment = 'volblowup';
                output.op = op;
            else
                useflag = 0;
            end     
        end
        %
        if status.istrendconfirmed && strcmpi(op.comment,'volblowup2-invalid long as close moves too high')
            try
                kelly = kelly_k('volblowup2',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                wprob = kelly_w('volblowup2',assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
            catch
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088 && wprob >= 0.3
                useflag = 1;
                op.comment = 'volblowup2';
                output.op = op;
            else
                useflag = 0;
            end     
        end
        %
        if status.istrendconfirmed && strcmpi(op.comment,'breachup-lvlup-invalid long as close moves too high')
            if ei.hh(end-1) >= ei.lvlup(end-1)
                vlookuptbl = kellytables.breachuplvlup_tc;
            else
                vlookuptbl = kellytables.breachuplvlup_tc_all;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088 && wprob >= 0.3
                useflag = 1;
                op.comment = 'breachup-lvlup';
                output.op = op;
            else
                useflag = 0;
            end     
        end
        %
        if status.istrendconfirmed && strcmpi(op.comment,'volblowup-invalid short as close moves too low')
            try
                kelly = kelly_k('volblowup',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                wprob = kelly_w('volblowup',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
            catch
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088 && wprob >= 0.3
                useflag = 1;
                op.comment = 'volblowup';
                output.op = op;
            else
                useflag = 0;
            end     
        end
        %
        if status.istrendconfirmed && strcmpi(op.comment,'volblowup2-invalid short as close moves too low')
            try
                kelly = kelly_k('volblowup2',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                wprob = kelly_w('volblowup2',assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
            catch
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088 && wprob >= 0.3
                useflag = 1;
                op.comment = 'volblowup2';
                output.op = op;
            else
                useflag = 0;
            end     
        end
        %
        if status.istrendconfirmed && strcmpi(op.comment,'breachdn-lvldn-invalid short as close moves too low')
            if ei.ll(end-1) <= ei.lvldn(end-1)
                vlookuptbl = kellytables.breachdnlvldn_tc;
            else
                vlookuptbl = kellytables.breachdnlvldn_tc_all;
            end
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088 && wprob >= 0.3
                useflag = 1;
                op.comment = 'breachdn-lvldn';
                output.op = op;
            else
                useflag = 0;
            end     
        end
        %
        %NOTE:here kelly and wprob threshold shall be set
        %via configuration files, TODO:
        %in line with @kellydistributionreport
        if kelly >= 0.088 && wprob >= 0.3 && useflag
            signal_i(1) = op.direction;
            signal_i(4) = op.direction;
            signal_i(8) = kelly;
        else
            %do nothing
        end
        %
    elseif signal_i(1) == 1
        %20230613:further check of signals
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            %do nothing as this is for sure trending trades
            try
                kelly = kelly_k(op.comment,assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                wprob = kelly_w(op.comment,assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
            catch
                idx = strcmpi(kellytables.kelly_table_l.opensignal_unique_l,op.comment);
                kelly = kellytables.kelly_table_l.kelly_unique_l(idx);
                wprob = kellytables.kelly_table_l.winp_unique_l(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
            end
            try
                signal_i(8) = kelly;
            catch
                signal_i(8) = -9.99;
            end
            %%NOTE:here kelly or wprob threshold shall be set
            %%via configuration files,TODO:
            if ~(kelly >= 0.088 && wprob >= 0.3) && ~strcmpi(op.comment,'volblowup')
                %in case the condtional uptrend trade was opened with conditional breachsshighvalue 
                %but it turns out to be a normal trend trade, e.g.check
                ei_ = fractal_truncate(ei,size(ei.px,1)-1);
                output_ = fractal_signal_conditional2('extrainfo',ei_,'ticksize',ticksize,...
                    'nfractal',nfractal,'assetname',assetname,...
                    'kellytables',kellytables,'ticksizeratio',ticksizeratio);
                if ~isempty(output_)
                    if output_.directionkellied == 1
                        if ~isempty(strfind(output_.opkellied,'breachup-lvlup'))
                            signal_i(1) = 1;
                            signal_i(4) = 1;
                            signal_i(8) = output_.kelly;
                            op.comment = 'breachup-lvlup';
                            kelly = output_.kelly;
                            wprob = output_.wprob;
                        elseif ~isempty(strfind(output_.opkellied,'breachup-sshighvalue'))
                            signal_i(1) = 1;
                            signal_i(4) = 1;
                            signal_i(8) = output_.kelly;
                            op.comment = 'breachup-sshighvalue';
                            kelly = output_.kelly;
                            wprob = output_.wprob;
                        elseif ~isempty(strfind(output_.opkellied,'breachup-highsc13'))
                            signal_i(1) = 1;
                            signal_i(4) = 1;
                            signal_i(8) = output_.kelly;
                            op.comment = 'breachup-highsc13';
                            kelly = output_.kelly;
                            wprob = output_.wprob;
                        elseif ~isempty(strfind(output_.opkellied,'mediumbreach-trendconfirmed'))
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            op.comment = 'mediumbreach-trendconfirmed';
                        elseif ~isempty(strfind(output_.opkellied,'strongbreach-trendconfirmed'))
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            op.comment = 'strongbreach-trendconfirmed';
                        elseif ~isempty(strfind(output_.opkellied,'potential high kelly'))
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        end
                    else
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end                
                else
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
            elseif ~(kelly >= 0.088 && wprob >= 0.3) && strcmpi(op.comment,'volblowup')
                signal_i(1) = 0;
                signal_i(4) = 0;
            else
                %special case found on backest of y2409 on
                %20240802
                if ei.ss(end-1) >= 9
                    sslastval = ei.ss(end-1);
                    sshighpx = max(ei.px(end-sslastval:end-1,3));
                    sshighidx = find(ei.px(end-sslastval:end-1,3) == sshighpx,1,'last') + size(ei.px,1) - sslastval - 1;
                    sslowpx = ei.px(sshighidx,4);
                    if ei.hh(end-1) < sslowpx
                        signal_i(2) = sshighpx;
                    elseif ei.hh(end-1) < sshighpx && ei.hh(end-1) >= sslowpx
                        if nfractal < 6
                            signal_i(2) = sshighpx;
                        else
                            %case found on TL2503 on 20241210
                        end 
                    end
                end
            end
        elseif strcmpi(op.comment,'breachup-highsc13')
            vlookuptbl = kellytables.breachuphighsc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            signal_i(8) = kelly;
            if ~(kelly >= 0.088 && wprob >= 0.3)
                signal_i(1) = 0;
                signal_i(4) = 0;
            end
        else
            if ~isempty(strfind(op.comment,'breachup-lvlup'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytables.breachuplvlup_tb;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    if ei.hh(end-1) >= ei.lvlup(end-1)
                        vlookuptbl = kellytables.breachuplvlup_tc;
                    else
                        vlookuptbl = kellytables.breachuplvlup_tc_all;
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
                %
            elseif ~isempty(strfind(op.comment,'breachup-sshighvalue'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytables.breachupsshighvalue_tb;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    vlookuptbl = kellytables.breachupsshighvalue_tc;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
                %
            else
                %not trending signals
                try
                    kelly = kelly_k(op.comment,assetname,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                    wprob = kelly_w(op.comment,assetname,kellytables.signal_l,kellytables.asset_list,kellytables.winprob_matrix_l,0);
                    signal_i(8) = kelly;
                catch
                    idx = strcmpi(op.comment,kellytables.kelly_table_l.opensignal_unique_l);
                    kelly = kellytables.kelly_table_l.kelly_unique_l(idx);
                    wprob = kellytables.kelly_table_l.winp_unique_l(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
                if ~isempty(strfind(op.comment,'volblowup-')) || strcmpi(op.comment,'strongbreach-trendbreak')
                    if wprob > 0.5
                        if kelly <= 0.05
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        else
                            signal_i(1) = 1;
                            signal_i(4) = 1;
                        end
                    else
                        if ~(kelly >= 0.088 && wprob >= 0.3)
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        end
                    end
                else
                    if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
            end
        end
        %
    elseif signal_i(1) == -1
        %20230613:further check of signals
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            %do nothing as this is for sure trending trades
            try
                kelly = kelly_k(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                wprob = kelly_w(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
            catch
                idx = strcmpi(kellytables.kelly_table_s.opensignal_unique_s,op.comment);
                kelly = kellytables.kelly_table_s.kelly_unique_s(idx);
                wprob = kellytables.kelly_table_s.winp_unique_s(idx);
            end
            try
                signal_i(8) = kelly;
            catch
                signal_i(8) = -9.99;
            end
            if ~(kelly>=0.088 && wprob >= 0.3) && ~strcmpi(op.comment,'volblowup')
                %in case the conditional dntrend was opened with breachdnbshighvalue 
                %but it turns out to be a normal trend trend, e.g zn2403 on 20240117
                ei_ = fractal_truncate(ei,size(ei.px,1)-1);
                output_ = fractal_signal_conditional2('extrainfo',ei_,'ticksize',ticksize,...
                    'nfractal',nfractal,'assetname',assetname,...
                    'kellytables',kellytables,'ticksizeratio',ticksizeratio);
                if ~isempty(output_)
                    if output_.directionkellied == -1
                        if ~isempty(strfind(output_.opkellied,'breachdn-lvldn'))
                            signal_i(1) = -1;
                            signal_i(4) = -1;
                            signal_i(8) = output_.kelly;
                            op.comment = 'breachdn-lvldn';
                            kelly = output_.kelly;
                            wprob = output_.wprob;
                        elseif ~isempty(strfind(output_.opkellied,'breachdn-bshighvalue'))
                            signal_i(1) = -1;
                            signal_i(4) = -1;
                            signal_i(8) = output_.kelly;
                            op.comment = 'breachdn-bshighvalue';
                            kelly = output_.kelly;
                            wprob = output_.wprob;
                        elseif ~isempty(strfind(output_.opkellied,'breachdn-lowbc13'))
                            signal_i(1) = -1;
                            signal_i(4) = -1;
                            signal_i(8) = output_.kelly;
                            op.comment = 'breachdn-lowbc13';
                            kelly = output_.kelly;
                            wprob = output_.wprob;
                        elseif ~isempty(strfind(output_.opkellied,'mediumbreach-trendconfirmed'))
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            op.comment = 'mediumbreach-trendconfirmed';
                        elseif ~isempty(strfind(output_.opkellied,'strongbreach-trendconfirmed'))
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            op.comment = 'strongbreach-trendconfirmed';
                        elseif ~isempty(strfind(output_.opkellied,'potential high kelly'))
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        end
                    else
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end                
                else
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
            elseif ~(kelly>=0.088 && wprob >= 0.3) && strcmpi(op.comment,'volblowup')
                signal_i(1) = 0;
                signal_i(4) = 0;
            else
                %special case
                if ei.bs(end-1) >= 9
                    bslastval = ei.bs(end-1);
                    bslowpx = min(ei.px(end-bslastval:end-1,4));
                    bslowidx = find(ei.px(end-bslastval:end-1,4) == bslowpx,1,'last') + size(ei.px,1) - bslastval - 1;
                    bshighpx = ei.px(bslowidx,3);
                    if ei.ll(end-1) > bshighpx || (ei.ll(end-1) > bslowpx && ei.ll(end-1) <= bshighpx)
                        signal_i(3) = bslowpx;
                    end
                end
            end
            %
        elseif strcmpi(op.comment,'breachdn-lowbc13')
            vlookuptbl = kellytables.breachdnlowbc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            signal_i(8) = kelly;
            if ~(kelly >= 0.088 && wprob >= 0.3)
                signal_i(1) = 0;
                signal_i(4) = 0;    
            end
        else
            if ~isempty(strfind(op.comment,'breachdn-lvldn'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytables.breachdnlvldn_tb;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    if ei.ll(end-1) <= ei.lvldn(end-1)
                        vlookuptbl = kellytables.breachdnlvldn_tc;
                    else
                        vlookuptbl = kellytables.breachdnlvldn_tc_all;
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
            elseif ~isempty(strfind(op.comment,'breachdn-bshighvalue'))
                if ~status.istrendconfirmed
                    vlookuptbl = kellytables.breachdnbshighvalue_tb;                    
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    vlookuptbl = kellytables.breachdnbshighvalue_tc;
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    if ~(kelly >= 0.088 && wprob >= 0.3)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                    if signal_i(1) == -1 && ei.bs(end) >= 16
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                        op.comment = 'breachdn-bshighvalue-invalid with high bs';
                    end
                end
            else
                %not trending signals
                try
                    kelly = kelly_k(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                    wprob = kelly_w(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
                    signal_i(8) = kelly;
                catch
                    idx = strcmpi(op.comment,kellytables.kelly_table_s.opensignal_unique_s);
                    kelly = kellytables.kelly_table_s.kelly_unique_s(idx);
                    wprob = kellytables.kelly_table_s.winp_unique_s(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(8) = kelly;
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
                if ~isempty(strfind(op.comment,'volblowup-')) || strcmpi(op.comment,'strongbreach-trendbreak')
                    if wprob > 0.5
                        if kelly <= 0.05
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        else
                            signal_i(1) = -1;
                            signal_i(4) = -1;
                        end
                    else
                        if ~(kelly >= 0.088 && wprob >= 0.3)
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        end
                    end
                else
                    if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
            end
        end
        %
    else
        %do nothing
        %internal errror
    end
    if signal_i(1) == 1
        if ~isempty(strfind(op.comment,'breachup-sshighvalue'))
            sshighidx = find(ei.ss >= 9,1,'last');
            sshighval = ei.ss(sshighidx);
            sshighpx = max(ei.px(sshighidx-sshighval+1:sshighidx,3));
            highpxidx = sshighidx-sshighval+find(ei.px(sshighidx-sshighval+1:sshighidx,3) == sshighpx,1,'last');
            lowpx = ei.px(highpxidx,4);
            signal_i(7) = max(lowpx,signal_i(7));
        end
        
    elseif signal_i(1) == -1
        if ~isempty(strfind(op.comment,'breachdn-bshighvalue'))
            bshighidx = find(ei.bs >= 9,1,'last');
            bshighval = ei.bs(bshighidx);
            bslowpx = min(ei.px(bshighidx-bshighval+1:bshighidx,4));
            lowpxidx = bshighidx-bshighval+find(ei.px(bshighidx-bshighval+1:bshighidx,4) == bslowpx,1,'last');
            highpx = ei.px(lowpxidx,3);
            signal_i(7) = min(highpx,signal_i(7));
        end
        
    end
    
    output.op = op;
    output.directionkellied = signal_i(1);
    output.signalkellied = signal_i;
    output.opkellied = op.comment;
    output.kelly = kelly;
    output.wprob = wprob;
    return
end