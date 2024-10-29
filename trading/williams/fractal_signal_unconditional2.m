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
        if status.istrendconfirmed && strcmpi(op.comment,'breachup-lvlup-invalid long as close moves too high')
            vlookuptbl = kellytables.breachuplvlup_tc;
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if kelly >= 0.088
                useflag = 1;
                op.comment = 'breachup-lvlup';
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
            if kelly >= 0.088
                useflag = 1;
                op.comment = 'volblowup';
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
            if kelly >= 0.088
                useflag = 1;
                op.comment = 'volblowup';
            else
                useflag = 0;
            end     
        end
        %
        %NOTE:here kelly and wprob threshold shall be set
        %via configuration files, TODO:
        %in line with @kellydistributionreport
        if kelly >= 0.088 && useflag
            signal_i(1) = op.direction;
            signal_i(4) = op.direction;
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
            %%NOTE:here kelly or wprob threshold shall be set
            %%via configuration files,TODO:
            if ~(kelly >= 0.088) && ~strcmpi(op.comment,'volblowup')
                %in case the condtional uptrend trade was opened with conditional breachsshighvalue 
                %but it turns out to be a normal trend trade, e.g.check
                ei_ = fractal_truncate(ei,size(ei.px,1)-1);
                output_ = fractal_signal_conditional2('extrainfo',ei_,'ticksize',ticksize,...
                    'nfractal',nfractal,'assetname',assetname,...
                    'kellytables',kellytables,'ticksizeratio',ticksizeratio);
                if ~isempty(output_)
                    if output_.directionkellied == 1
                        signal_i(1) = 1;
                        signal_i(4) = 1;
                        if ~isempty(strfind(output_.opkilled,'breachup-lvlup'))
                            op.comment = 'breachup-lvlup';
                        elseif ~isempty(strfind(output_.opkilled,'breachup-sshighvalue'))
                            op.comment = 'breachup-sshighvalue';
                        elseif ~isempty(strfind(output_.opkilled,'breachup-highsc13'))
                            op.comment = 'breachup-highsc13';
                        elseif ~isempty(strfind(output_.opkilled,'mediumbreach-trendconfirmed'))
                            op.comment = 'mediumbreach-trendconfirmed';
                        elseif ~isempty(strfind(output_.opkilled,'strongbreach-trendconfirmed'))
                            op.comment = 'strongbreach-trendconfirmed';
                        end
                    else
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end                
                else
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
            else
                %special case found on backest of y2409 on
                %20240802
                if ei.ss(end-1) >= 9
                    sslastval = ei.ss(end-1);
                    sshighpx = max(ei.px(end-sslastval:end-1,3));
                    sshighidx = find(ei.px(end-sslastval:end-1,3) == sshighpx,1,'last') + size(ei.px,1) - sslastval - 1;
                    sslowpx = ei.px(sshighidx,4);
                    if ei.hh(end-1) <= sslowpx
                        signal_i(1) = 0;
                        signal_i(4) = 0; 
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
            if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
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
                catch
                    idx = strcmpi(op.comment,kellytables.kelly_table_l.opensignal_unique_l);
                    kelly = kellytables.kelly_table_l.kelly_unique_l(idx);
                    wprob = kellytables.kelly_table_l.winp_unique_l(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
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
                        if ~(kelly >= 0.088)
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
            
            if ~(kelly>=0.088) && ~strcmpi(op.comment,'volblowup')
                %in case the conditional dntrend was opened with breachdnbshighvalue 
                %but it turns out to be a normal trend trend, e.g zn2403 on 20240117
                ei_ = fractal_truncate(ei,size(ei.px,1)-1);
                output_ = fractal_signal_conditional2('extrainfo',ei_,'ticksize',ticksize,...
                    'nfractal',nfractal,'assetname',assetname,...
                    'kellytables',kellytables,'ticksizeratio',ticksizeratio);
                if ~isempty(output_)
                    if output_.directionkellied == -1
                        signal_i(1) = -1;
                        signal_i(4) = -1;
                        if ~isempty(strfind(output_.opkilled,'breachdn-lvldn'))
                            op.comment = 'breachdn-lvldn';
                        elseif ~isempty(strfind(output_.opkilled,'breachdn-bshighvalue'))
                            op.comment = 'breachdn-bshighvalue';
                        elseif ~isempty(strfind(output_.opkilled,'breachdn-lowbc13'))
                            op.comment = 'breachdn-lowbc13';
                        elseif ~isempty(strfind(output_.opkilled,'mediumbreach-trendconfirmed'))
                            op.comment = 'mediumbreach-trendconfirmed';
                        elseif ~isempty(strfind(output_.opkilled,'strongbreach-trendconfirmed'))
                            op.comment = 'strongbreach-trendconfirmed';
                        end
                    else
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end                
                else
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end 
            else
                %special case
                if ei.bs(end-1) >= 9
                    bslastval = ei.bs(end-1);
                    bslowpx = min(ei.px(end-bslastval:end-1,4));
                    bslowidx = find(ei.px(end-bslastval:end-1,4) == bslowpx,1,'last') + size(ei.px,1) - bslastval - 1;
                    bshighpx = ei.px(bslowidx,3);
                    if ei.ll(end-1) >= bshighpx
                        signal_i(1) = 0;
                        signal_i(4) = 0;
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
            if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
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
                    if ~(kelly >= 0.088)
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
            else
                %not trending signals
                try
                    kelly = kelly_k(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                    wprob = kelly_w(op.comment,assetname,kellytables.signal_s,kellytables.asset_list,kellytables.winprob_matrix_s,0);
                catch
                    idx = strcmpi(op.comment,kellytables.kelly_table_s.opensignal_unique_s);
                    kelly = kellytables.kelly_table_s.kelly_unique_s(idx);
                    wprob = kellytables.kelly_table_s.winp_unique_s(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
                if ~(kelly >= 0.145 || (kelly > 0.1 && wprob > 0.41))
                    signal_i(1) = 0;
                    signal_i(4) = 0;
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
        
    else
        if ~isempty(strfind(op.comment,'breachdn-bshighvalue'))
            bshighidx = find(ei.bs >= 9,1,'last');
            bshighval = ei.bs(bshighidx);
            bslowpx = min(ei.px(bshighidx-bshighval+1:bshighidx,4));
            lowpxidx = bshighidx-bshighval+find(ei.px(bshighidx-bshighval+1:bshighidx,4) == bslowpx,1,'last');
            highpx = ei.px(lowpxidx,3);
            signal_i(7) = min(highpx,signal_i(7));
        end
        
    end
    
    
    output.directionkellied = signal_i(1);
    output.signalkellied = signal_i;
    output.opkellied = op.comment;
    output.kelly = kelly;
    output.wprob = wprob;
    return
end