function [signal_out,kelly,wprob] = fractal_strategy_gensignal(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('extrainfo',{},@isstruct);
    p.addParameter('instrument',{},...
        @(x) validateattributes(x,{'char','cInstrument'},{},'','instrument'));
    p.addParameter('nfractal',4,@isnumeric);
    p.addParameter('lasttick',[],@isnumeric);
    p.addParameter('strategytable',[],@isstruct);
    p.parse(varargin{:});
    extrainfo = p.Results.extrainfo;
    instrument = p.Results.instrument;
    nfractal = p.Results.nfractal;
    if ischar(instrument)
        instrument = code2instrument(instrument);
    end
    ticksize = instrument.tick_size;
    try
        assetname = instrument.asset_name;
    catch
        assetname = 'unknown';
    end
    tick = p.Results.lasttick;
    strategytbl = p.Results.strategytable;
    if isempty(strategytbl)
        error('fractal_strategy_gensignal:empty input of strategytable....')
    end
    
    [signal_i,op,status] = fractal_signal_unconditional(extrainfo,ticksize,nfractal,'lasttick',tick);
    
    if isempty(signal_i)
        %TODO
        %conditional signal generator
        signal_out = [];
        kelly = -9.99;
        wprob = 0;
        return
    end
    %
    if signal_i(1) == 0
        if op.direction == 1
            try
                kelly = kelly_k(op.comment,assetname,strategytbl.signal_l,strategytbl.asset_list,strategytbl.kelly_matrix_l);
                wprob = kelly_w(op.comment,assetname,strategytbl.signal_l,strategytbl.asset_list,strategytbl.winprob_matrix_l);
                useflag = 1;
            catch
                idx = strcmpi(strategytbl.kelly_table_l.opensignal_unique_l,op.comment);
                kelly = strategytbl.kelly_table_l.kelly_unique_l(idx);
                wprob = strategytbl.kelly_table_l.winp_unique_l(idx);
                useflag = strategytbl.kelly_table_l.use_unique_l(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                    useflag = 0;
                end
            end
        elseif op.direction == -1
            try
                kelly = kelly_k(op.comment,assetname,strategytbl.signal_s,strategytbl.asset_list,strategytbl.kelly_matrix_s);
                wprob = kelly_w(op.comment,assetname,strategytbl.signal_s,strategytbl.asset_list,strategytbl.winprob_matrix_s);
                useflag = 1;
            catch
                idx = strcmpi(strategytbl.kelly_table_s.opensignal_unique_s,op.comment);
                kelly = strategytbl.kelly_table_s.kelly_unique_s(idx);
                wprob = strategytbl.kelly_table_s.winp_unique_s(idx);
                useflag = strategytbl.kelly_table_s.use_unique_s(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                    useflag = 0;
                end
            end
        else
            kelly = -9.99;
            wprob = 0;
            useflag = 0;
        end
        %
        %NOTE:here kelly and wprob threshold shall be set via userinput
        %TODO
        if kelly >= 0.141 && wprob >= 0.41 && useflag
            signal_i(1) = op.direction;
            signal_i(4) = op.direction;
        end
        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
        signal_out = signal_i;
        return
    end
    %
    if signal_i(1) == 1
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            try
                kelly = kelly_k(op.comment,assetname,strategytbl.signal_l,strategytbl.asset_list,strategytbl.kelly_matrix_l);
                wprob = kelly_w(op.comment,assetname,strategytbl.signal_l,strategytbl.asset_list,strategytbl.winprob_matrix_l);
            catch
                idx = strcmpi(strategytbl.kelly_table_l.opensignal_unique_l,op.comment);
                kelly = strategytbl.kelly_table_l.kelly_unique_l(idx);
                wprob = strategytbl.kelly_table_l.winp_unique_l(idx);
            end
            %NOTE:here kelly and wprob threshold shall be set via userinput
            %TODO
            if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                %in case the conditional uptrend trade was opened with
                %breachsshighvalue but it turns out to be a normal trend
                %trade,e.g.check with live hog on 24th Jan 2024
                if extrainfo.ss(end) >= 9 || extrainfo.ss(end-1) >= 9
                    idxss9 = find(extrainfo.ss == 9,1,'last');
                    pxhightillss9 = max(extrainfo.px(idxss9-8:idxss9,3));
                    if pxhightillss9 == extrainfo.hh(end)
                        op.comment = 'breachup-sshighvalue';
                        vlookuptbl = strategytbl.breachupsshighvalue_tc;
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                        if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                            %request to unwind trade if there is any
                            signal_i(1) = 0;
                            signal_i(4) = 0;    
                        end
                    else
                        lasthh - find(extrainfo.idxhh == 1,1,'last');
                        if lasthh < idxss9-extrainfo.ss(idxss9)+1
                            op.comment = 'breachup-sshighvalue';
                            vlookuptbl = strategytbl.breachupsshighvalue_tc;
                            idx = strcmpi(vlookuptbl.asset,assetname);
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                            if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                                %request to unwind trade if there is any
                                signal_i(1) = 0;
                                signal_i(4) = 0;    
                            end
                        else
                            %request to unwind trade if there is any
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        end
                    end
                else
                    %request to unwind trade if there is any
                    signal_i(1) = 0;
                    signal_i(4) = 0;                   
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            else
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            end
            %
        elseif strcmpi(op.comment,'breachup-highsc13')
            vlookuptbl = strategytbl.breachuphighsc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                %request to unwind trade if there is any
                signal_i(1) = 0;
                signal_i(4) = 0;
            end
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
            signal_out = signal_i;
        else
            if ~isempty(strfind(op.comment,'breachup-lvlup'))
                if status.istrendconfirmed
                    vlookuptbl = strategytbl.breachuplvlup_tc;
                else
                    vlookuptbl = strategytbl.breachuplvlup_tb;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
                if status.istrendconfirmed
                    if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    if kelly < 0.145 || wprob < 0.41
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            elseif ~isempty(strfind(op.comment,'breachup-sshighvalue')) 
                if status.istrendconfirmed
                    vlookuptbl = strategytbl.breachupsshighvalue_tc;
                else
                    vlookuptbl = strategytbl.breachupsshighvalue_tb;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
                if status.istrendconfirmed
                    if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    if kelly < 0.145 || wprob < 0.41
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            else
                %not trending signal
                try
                    kelly = kelly_k(op.comment,assetname,strategytbl.signal_l,strategytbl.asset_list,strategytbl.kelly_matrix_l);
                    wprob = kelly_w(op.comment,assetname,strategytbl.signal_l,strategytbl.asset_list,strategytbl.winprob_matrix_l);
                    if kelly < 0.145 || wprob < 0.41
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                catch
                    idx = strcmpi(strategytbl.kelly_table_l.opensignal_unique_l,op.comment);
                    kelly = strategytbl.kelly_table_l.kelly_unique_l(idx);
                    wprob = strategytbl.kelly_table_l.winp_unique_l(idx);
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            end
        end           
        return
    end
    %
    if signal_i(1) == -1
        if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
            try
                kelly = kelly_k(op.comment,assetname,strategytbl.signal_s,strategytbl.asset_list,strategytbl.kelly_matrix_s);
                wprob = kelly_w(op.comment,assetname,strategytbl.signal_s,strategytbl.asset_list,strategytbl.winprob_matrix_s);
            catch
                idx = strcmpi(strategytbl.kelly_table_s.opensignal_unique_s,op.comment);
                kelly = strategytbl.kelly_table_s.kelly_unique_s(idx);
                wprob = strategytbl.kelly_table_s.winp_unique_s(idx);
            end
            %NOTE:here kelly and wprob threshold shall be set via userinput
            %TODO
            if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                %in case the conditional uptrend trade was opened with
                %breachsshighvalue but it turns out to be a normal trend
                %trade,e.g.check with zn2403 on 17th Jan 2024
                if extrainfo.bs(end) >= 9 || extrainfo.bs(end-1) >= 9
                    idxbs9 = find(extrainfo.bs == 9,1,'last');
                    pxlowtillbs9 = min(extrainfo.px(idxbs9-8:idxbs9,4));
                    if pxlowtillbs9 == extrainfo.ll(end)
                        op.comment = 'breachdn-bshighvalue';
                        vlookuptbl = strategytbl.breachdnbshighvalue_tc;
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                        if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                            %request to unwind trade if there is any
                            signal_i(1) = 0;
                            signal_i(4) = 0;    
                        end
                    else
                        lastll = find(extrainfo.idxll == -1,1,'last');
                        if lastll < idxbs9-extrainfo.bs(idxbs9)+1
                            op.comment = 'breachdn-bshighvalue';
                            vlookuptbl = strategytbl.breachdnbshighvalue_tc;
                            idx = strcmpi(vlookuptbl.asset,assetname);
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                            if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                                %request to unwind trade if there is any
                                signal_i(1) = 0;
                                signal_i(4) = 0;    
                            end
                        else 
                            %request to unwind trade if there is any
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                        end
                    end
                else
                    %request to unwind trade if there is any
                    signal_i(1) = 0;
                    signal_i(4) = 0;                   
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            else
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            end
            %
        elseif strcmpi(op.comment,'breachdn-lowbc13')
            vlookuptbl = strategytbl.breachdnlowbc13;
            idx = strcmpi(vlookuptbl.asset,assetname);
            kelly = vlookuptbl.K(idx);
            wprob = vlookuptbl.W(idx);
            if isempty(kelly)
                kelly = -9.99;
                wprob = 0;
            end
            if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                %request to unwind trade if there is any
                signal_i(1) = 0;
                signal_i(4) = 0;
            end
            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
            signal_out = signal_i;
        else
            if ~isempty(strfind(op.comment,'breachdn-lvldn'))
                if status.istrendconfirmed
                    vlookuptbl = strategytbl.breachdnlvldn_tc;
                else
                    vlookuptbl = strategytbl.breachdnlvldn_tb;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
                if status.istrendconfirmed
                    if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    if kelly < 0.145 || wprob < 0.41
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            elseif ~isempty(strfind(op.comment,'breachdn-bshighvalue'))
                if status.istrendconfirmed
                    vlookuptbl = strategytbl.breachdnbshighvalue_tc;
                else
                    vlookuptbl = strategytbl.breachdnbshighvalue_tb;
                end
                idx = strcmpi(vlookuptbl.asset,assetname);
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
                if status.istrendconfirmed
                    if ~(kelly >= 0.145 || (kelly > 0.11 && wprob > 0.41))
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                else
                    if kelly < 0.145 || wprob < 0.41
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            else
                %not trending signal
                try
                    kelly = kelly_k(op.comment,assetname,strategytbl.signal_s,strategytbl.asset_list,strategytbl.kelly_matrix_s);
                    wprob = kelly_w(op.comment,assetname,strategytbl.signal_s,strategytbl.asset_list,strategytbl.winprob_matrix_s);
                    if kelly < 0.145 || wprob < 0.41
                        %request to unwind trade if there is any
                        signal_i(1) = 0;
                        signal_i(4) = 0;
                    end
                catch
                    idx = strcmpi(strategytbl.kelly_table_s.opensignal_unique_s,op.comment);
                    kelly = strategytbl.kelly_table_s.kelly_unique_s(idx);
                    wprob = strategytbl.kelly_table_s.winp_unique_s(idx);
                    signal_i(1) = 0;
                    signal_i(4) = 0;
                end
                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instrument.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                signal_out = signal_i;
            end
        end
        return
    end
end