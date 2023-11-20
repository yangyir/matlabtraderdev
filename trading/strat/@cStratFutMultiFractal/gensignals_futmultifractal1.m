function signals = gensignals_futmultifractal1(stratfractal)
%cStratFutMultiFractal
%NEW CHANGE:signals are not generated with the price before the market
%close as we don't know whether the open price (once the market open again)
%would still be valid for a signal. however, we might miss big profit in
%case the market jumps in favor of the strategy. Of course, we might loose
%in case the market moves against the strategy

    n = stratfractal.count;
%     signals = zeros(n,6);
    signals = cell(n,2);
    %column1:direction
    %column2:fractal hh
    %column3:fractal ll
    %column4:use flag
    %column5:hh1:open candle high
    %column6:ll1:open candle low
    
    
    if stratfractal.displaysignalonly_, return;end
    
    if strcmpi(stratfractal.mode_,'replay')
        runningt = stratfractal.replay_time1_;
    else
        runningt = now;
    end
    
    twominb4mktopen = is2minbeforemktopen(runningt);
    
    instruments = stratfractal.getinstruments;
        
    if twominb4mktopen
        for i = 1:n
            try
                techvar = stratfractal.calctechnicalvariable(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
                stratfractal.hh_{i} = techvar(:,8);
                stratfractal.ll_{i} = techvar(:,9);
                stratfractal.jaw_{i} = techvar(:,10);
                stratfractal.teeth_{i} = techvar(:,11);
                stratfractal.lips_{i} = techvar(:,12);
                stratfractal.bs_{i} = techvar(:,13);
                stratfractal.ss_{i} = techvar(:,14);
                stratfractal.lvlup_{i} = techvar(:,15);
                stratfractal.lvldn_{i} = techvar(:,16);
                stratfractal.bc_{i} = techvar(:,17);        
                stratfractal.sc_{i} = techvar(:,18);
                stratfractal.wad_{i} = techvar(:,19);
            catch e
                msg = sprintf('ERROR:%s:calctechnicalvariable:%s:%s\n',class(stratfractal),instruments{i}.code_ctp,e.message);
                fprintf(msg);
            end
        end        
        return
    end
    
    calcsignalflag = zeros(n,1);
    for i = 1:n
        try
            calcsignalflag(i) = stratfractal.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag(i) = 0;
            msg = sprintf('ERROR:%s:getcalcsignalflag:%s\n',class(stratfractal),e.message);
            fprintf(msg);
        end
    end
    %
    if sum(calcsignalflag) == 0, return;end
    
    fprintf('\n%s->%s:signal calculated...\n',stratfractal.name_,datestr(runningt,'yyyy-mm-dd HH:MM'));
    
    for i = 1:n
        if ~calcsignalflag(i);continue;end
        
        if calcsignalflag(i)
            try
                techvar = stratfractal.calctechnicalvariable(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
                p = techvar(:,1:5);
                idxHH = techvar(:,6);
                idxLL = techvar(:,7);
                hh = techvar(:,8);
                ll = techvar(:,9);
                jaw = techvar(:,10);
                teeth = techvar(:,11);
                lips = techvar(:,12);
                bs = techvar(:,13);
                ss = techvar(:,14);
                lvlup = techvar(:,15);
                lvldn = techvar(:,16);
                bc = techvar(:,17);
                sc = techvar(:,18);
                wad = techvar(:,19); 
            catch e
                msg = sprintf('ERROR:%s:calctechnicalvariable:%s:%s\n',class(stratfractal),instruments{i}.code_ctp,e.message);
                fprintf(msg);
                continue
            end
            %
            stratfractal.hh_{i} = hh;
            stratfractal.ll_{i} = ll;
            stratfractal.jaw_{i} = jaw;
            stratfractal.teeth_{i} = teeth;
            stratfractal.lips_{i} = lips;
            stratfractal.bs_{i} = bs;
            stratfractal.ss_{i} = ss;
            stratfractal.lvlup_{i} = lvlup;
            stratfractal.lvldn_{i} = lvldn;
            stratfractal.bc_{i} = bc;
            stratfractal.sc_{i} = sc;
            stratfractal.wad_{i} = wad;
            
            nfractal = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
            freq = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
            
            try
                ticksize = instruments{i}.tick_size;
            catch
                ticksize = 0;
            end
            
            try
                assetname = instruments{i}.asset_name;
            catch
                assetname = 'unknown';
            end
            
            extrainfo = struct('px',p,...
                'ss',ss,'sc',sc,...
                'bs',bs,'bc',bc,...
                'lvlup',lvlup,'lvldn',lvldn,...
                'idxhh',idxHH,'hh',hh,...
                'idxll',idxLL,'ll',ll,...
                'lips',lips,'teeth',teeth,'jaw',jaw,...
                'wad',wad);
            
            tick = stratfractal.mde_fut_.getlasttick(instruments{i});
            
            [signal_i,op,status] = fractal_signal_unconditional(extrainfo,ticksize,nfractal,'lasttick',tick);
            if ~isempty(signal_i)
                if signal_i(1) == 0
                    if ~strcmpi(freq,'1440m')
                        if op.direction == 1
                            try
                                kelly = kelly_k(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_l,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.kelly_matrix_l);
                                wprob = kelly_w(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_l,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.winprob_matrix_l);
                            catch
                                idx = strcmpi(op.comment,stratfractal.tbl_all_intraday_.kelly_table_l.opensignal_unique_l);
                                kelly = stratfractal.tbl_all_intraday_.kelly_table_l.kelly_unique_l(idx);
                                wprob = stratfractal.tbl_all_intraday_.kelly_table_l.winp_unique_l(idx);
                                if isempty(kelly)
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                            end
                        elseif op.direction == -1
                            try
                                kelly = kelly_k(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_s,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.kelly_matrix_s);
                                wprob = kelly_w(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_s,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.winprob_matrix_s);
                            catch
                                idx = strcmpi(op.comment,stratfractal.tbl_all_intraday_.kelly_table_s.opensignal_unique_s);
                                kelly = stratfractal.tbl_all_intraday_.kelly_table_s.kelly_unique_s(idx);
                                wprob = stratfractal.tbl_all_intraday_.kelly_table_s.winp_unique_s(idx);
                                if isempty(kelly)
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                            end
                        else
                            kelly = 0;
                            wprob = 0;
                        end
<<<<<<< HEAD
                        if kelly >= 0.15 && wprob >= 0.5
=======
                        if kelly >= 0.13 && wprob >= 0.4
>>>>>>> b7fcc6a779fbf455dd232c76ef9dbd993b5f72d9
                            signal_i(1) = op.direction;
                            signal_i(4) = op.direction;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                    else
                        if op.direction == 1
                            idx = strcmpi(op.comment,stratfractal.tbl_all_daily_.kelly_table_l.opensignal_unique_l);
                            kelly = stratfractal.tbl_all_daily_.kelly_table_l.kelly_unique_l(idx);
                            wprob = stratfractal.tbl_all_daily_.kelly_table_l.winp_unique_l(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                        elseif op.direction == -1
                            idx = strcmpi(op.comment,stratfractal.tbl_all_daily_.kelly_table_s.opensignal_unique_s);
                            kelly = stratfractal.tbl_all_daily_.kelly_table_s.kelly_unique_s(idx);
                            wprob = stratfractal.tbl_all_daily_.kelly_table_s.winp_unique_s(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                        else
                            kelly = 0;
                            wprob = 0;
                        end
                        if kelly >= 0.13 && wprob >= 0.4
                            signal_i(1) = op.direction;
                            signal_i(4) = op.direction;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                    end
                    %
                    try
                        stratfractal.processcondentrust(instruments{i},'techvar',techvar);
                    catch e
                        fprintf('processcondentrust failed:%s\n', e.message);
                        stratfractal.stop;
                    end
                    %
                elseif signal_i(1) == 1
                    %20230613:further check of signals
                    if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                            strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
                        %do nothing as this is for sure trending trades
                        if ~strcmpi(freq,'1440m')
                            kelly = kelly_k(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_l,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.kelly_matrix_l);
                            wprob = kelly_w(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_l,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.winprob_matrix_l);
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                        else
                            idx = strcmpi(op.comment,stratfractal.tbl_all_daily_.kelly_table_l.opensignal_unique_l);
                            kelly = stratfractal.tbl_all_daily_.kelly_table_l.kelly_unique_l(idx);
                            wprob = stratfractal.tbl_all_daily_.kelly_table_l.winp_unique_l(idx);
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                        end
                        if kelly < 0.1
                            signal_i(1) = 0;
                            signal_i(4) = 0;
                            %unwind position as the kelly or
                            %winning probability is low
                            stratfractal.unwindpositions(instruments{i});
                        end
                    elseif strcmpi(op.comment,'breachup-highsc13')
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachuphighsc13;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachuphighsc13;
                        end
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        try
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                        catch
                            kelly = -9.99;
                            wprob = 0;
                        end
                        if kelly < 0.15 || wprob < 0.4
                            signal_i(1) = 0;
                            stratfractal.unwindpositions(instruments{i});
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                    else
                        if ~isempty(strfind(op.comment,'breachup-lvlup'))
                            if ~status.istrendconfirmed
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachuplvlup_tb;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachuplvlup_tb;                                    
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if kelly < 0.15, signal_i(1) = 0;end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachup-lvlup-tb',100*kelly,100*wprob);
                            else
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachuplvlup_tc;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachuplvlup_tc;                                    
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if kelly < 0.15 || wprob < 0.4
                                    signal_i(1) = 0;
                                    %unwind position as the kelly or
                                    %winning probability is low
                                    %in case there are any positions
                                    stratfractal.unwindpositions(instruments{i});
                                end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachup-lvlup-tc',100*kelly,100*wprob);
                            end
                        elseif ~isempty(strfind(op.comment,'breachup-sshighvalue')) 
                            if ~status.istrendconfirmed
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachupsshighvalue_tb;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachupsshighvalue_tb;
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if kelly < 0.15, signal_i(1) = 0;end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachup-sshighvalue-tb',100*kelly,100*wprob);
                            else
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachupsshighvalue_tc;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachupsshighvalue_tc;
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachup-sshighvalue-tc',100*kelly,100*wprob);
                                if kelly < 0.15 || wprob < 0.4
                                    signal_i(1) = 0;
                                    %unwind position as the kelly or
                                    %winning probability is low
                                    %in case there are any positions
                                    stratfractal.unwindpositions(instruments{i});
                                end
                            end
                        else
                            if ~strcmpi(freq,'1440m')
                                try
                                    kelly = kelly_k(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_l,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.kelly_matrix_l);
                                    wprob = kelly_w(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_l,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.winprob_matrix_l);
                                catch
                                    idx = strcmpi(op.comment,stratfractal.tbl_all_intraday_.kelly_table_l.opensignal_unique_l);
                                    kelly = stratfractal.tbl_all_intraday_.kelly_table_l.kelly_unique_l(idx);
                                    wprob = stratfractal.tbl_all_intraday_.kelly_table_l.winp_unique_l(idx);
                                    signal_i(1) = 0;
                                end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                            else
                                idx = strcmpi(op.comment,stratfractal.tbl_all_daily_.kelly_table_l.opensignal_unique_l);
                                kelly = stratfractal.tbl_all_daily_.kelly_table_l.kelly_unique_l(idx);
                                wprob = stratfractal.tbl_all_daily_.kelly_table_l.winp_unique_l(idx);
                                if ~stratfractal.tbl_all_daily_.kelly_table_l.use_unique_l(idx), signal_i(1) = 0;end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                            end
                        end
                    end
                    %
                elseif signal_i(1) == -1
                    %20230613:further check of signals
                    if strcmpi(op.comment,'volblowup') || strcmpi(op.comment,'volblowup2') || ...
                            strcmpi(op.comment,'strongbreach-trendconfirmed') || strcmpi(op.comment,'mediumbreach-trendconfirmed')
                        %do nothing as this is for sure trending trades
                        if ~strcmpi(freq,'1440m')
                            kelly = kelly_k(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_s,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.kelly_matrix_s);
                            wprob = kelly_w(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_s,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.winprob_matrix_s);
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                        else
                            idx = strcmpi(op.comment,stratfractal.tbl_all_daily_.kelly_table_s.opensignal_unique_s);
                            kelly = stratfractal.tbl_all_daily_.kelly_table_s.kelly_unique_s(idx);
                            wprob = stratfractal.tbl_all_daily_.kelly_table_s.winp_unique_s(idx);
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                        end
                        if kelly < 0.1
                            signal_i(1) = 0;
                            %unwind position as the kelly or
                            %winning probability is low
                            stratfractal.unwindpositions(instruments{i});
                        end
                    elseif strcmpi(op.comment,'breachdn-lowbc13')
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachdnlowbc13;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachdnlowbc13;
                        end  
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        try
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                        catch
                            kelly = -9.99;
                            wprob = 0;
                        end
                        if kelly < 0.146
                            signal_i(1) = 0;
                            stratfractal.unwindpositions(instruments{i});
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachdn-lowbc13',100*kelly,100*wprob);
                    else
                        if ~isempty(strfind(op.comment,'breachdn-lvldn')) 
                            if ~status.istrendconfirmed
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachdnlvldn_tb;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachdnlvldn_tb;
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if kelly < 0.146, signal_i(1) = 0;end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachdn-lvldn-tb',100*kelly,100*wprob);
                            else
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachdnlvldn_tc;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachdnlvldn_tc;
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if kelly < 0.146
                                    signal_i(1) = 0;
                                    stratfractal.unwindpositions(instruments{i});
                                end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachdn-lvldn-tc',100*kelly,100*wprob);
                            end
                        elseif ~isempty(strfind(op.comment,'breachdn-bshighvalue')) 
                            if ~status.istrendconfirmed
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachdnbshighvalue_tb;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachdnbshighvalue_tb;
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if kelly < 0.146 || wprob < 0.4, signal_i(1) = 0;end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachdn-bshighvalue-tb',100*kelly,100*wprob);
                            else
                                if ~strcmpi(freq,'1440m')
                                    vlookuptbl = stratfractal.tbl_all_intraday_.breachdnbshighvalue_tc;
                                else
                                    vlookuptbl = stratfractal.tbl_all_daily_.breachdnbshighvalue_tc;
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                    if isempty(kelly)
                                        kelly = -9.99;
                                        wprob = 0;
                                    end
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),'breachdn-bshighvalue-tc',100*kelly,100*wprob);
                                if kelly < 0.146 || wprob < 0.4
                                    signal_i(1) = 0;
                                    %unwind position as the kelly or
                                    %winning probability is low
                                    %in case there are any positions
                                    stratfractal.unwindpositions(instruments{i});
                                end
                            end
                        else
                            if ~strcmpi(freq,'1440m')
                                try
                                    kelly = kelly_k(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_s,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.kelly_matrix_s);
                                    wprob = kelly_w(op.comment,assetname,stratfractal.tbl_all_intraday_.signal_s,stratfractal.tbl_all_intraday_.asset_list,stratfractal.tbl_all_intraday_.winprob_matrix_s);
                                    if kelly < 0.146 || wprob < 0.4
                                        signal_i(1) = 0;
                                    end
                                catch
                                    idx = strcmpi(op.comment,stratfractal.tbl_all_intraday_.kelly_table_s.opensignal_unique_s);
                                    kelly = stratfractal.tbl_all_intraday_.kelly_table_s.kelly_unique_s(idx);
                                    wprob = stratfractal.tbl_all_intraday_.kelly_table_s.winp_unique_s(idx);
                                    signal_i(1) = 0;
                                end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                            else
                                idx = strcmpi(op.comment,stratfractal.tbl_all_daily_.kelly_table_s.opensignal_unique_s);
                                kelly = stratfractal.tbl_all_daily_.kelly_table_s.kelly_unique_s(idx);
                                wprob = stratfractal.tbl_all_daily_.kelly_table_s.winp_unique_s(idx);
                                if ~stratfractal.tbl_all_daily_.kelly_table_s.use_unique_s(idx), signal_i(1) = 0;end
                                fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                            end
                        end
                    end
                    %
                else
                    %do nothing
                    %internal errror
                end
                if signal_i(1) == 1
                    signals{i,1} = signal_i;
                else
                    signals{i,2} = signal_i;
                end
            else
                try
                    stratfractal.processcondentrust(instruments{i},'techvar',techvar);
                catch e
                    fprintf('processcondentrust failed:%s\n', e.message);
                    stratfractal.stop;
                end
                
                %
                [signal_cond_i,op_cond_i,flags_i] = fractal_signal_conditional(extrainfo,ticksize,nfractal);
                %20230613:further check of conditional signals
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 1
%                     %20231025:further check whether it is a breachup-sshighvalue
%                     isbreachupsshighvalue = false;
%                     sslastidx = find(extrainfo.ss >= 9,1,'last');
%                     sslastval = extrainfo.ss(sslastidx);
%                     ndiff = size(extrainfo.ss,1)-sslastidx;
%                     if ndiff <= 13
%                         sshigh = max(extrainfo.px(sslastidx-sslastval+1:sslastidx,3));
%                         isbreachupsshighvalue = extrainfo.hh(end) == sshigh;
%                     end
%                     %20231031:further check whether it is a breachup-lvlup
%                     isbreachuplvlup = extrainfo.hh(end) >= extrainfo.lvlup(end) && extrainfo.px(end,5) < extrainfo.lvlup(end);
                    %
                    isbreachuplvlup = flags_i.islvlupbreach;
                    isbreachupsshigh = flags_i.issshighbreach;
                    isbreachupschigh = flags_i.isschighbreach;
                    
                    if isbreachuplvlup
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachuplvlup_tc;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachuplvlup_tc;
                        end
                    elseif isbreachupsshigh
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachupsshighvalue_tc;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachupsshighvalue_tc;
                        end
                    elseif isbreachupschigh
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachuphighsc13;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachuphighsc13;
                        end
                    else
                        if strcmpi(op_cond_i{1,1},'conditional:mediumbreach-trendconfirmed')
                            if ~strcmpi(freq,'1440m')
                                vlookuptbl = stratfractal.tbl_all_intraday_.bmtc;
                            else
                                vlookuptbl = stratfractal.tbl_all_daily_.bmtc;
                            end
                        elseif strcmpi(op_cond_i{1,1},'conditional:strongbreach-trendconfirmed')
                            if ~strcmpi(freq,'1440m')
                                vlookuptbl = stratfractal.tbl_all_intraday_.bstc;
                            else
                                vlookuptbl = stratfractal.tbl_all_daily_.bstc;
                            end
                        else
                            %internal errror
                        end
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end       
                    if kelly >= 0.145 || (kelly > 0.11 && wprob > 0.45)      %release condition for long trades
                        signal_cond_i{1,1}(1) = 1;
                    else
                        signal_cond_i{1,1}(1) = 0;
                        if isbreachuplvlup
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional breachup-lvlup',100*kelly,100*wprob);
                        elseif isbreachupsshigh
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional breachup-sshighvalue',100*kelly,100*wprob);
                        elseif isbreachupschigh
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional breachup-highsc13',100*kelly,100*wprob);
                        else
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),op_cond_i{1,1},100*kelly,100*wprob);
                        end
                    end
                end
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1
%                     %20231025:further check whether it is a breachdn-bshighvalue
%                     isbreachdnbslow = false;
%                     bslastidx = find(extrainfo.bs >= 9,1,'last');
%                     bslastval = extrainfo.bs(bslastidx);
%                     ndiff = size(extrainfo.bs,1)-bslastidx;
%                     if ndiff <= 13
%                         bslow = min(extrainfo.px(bslastidx-bslastval+1:bslastidx,4));
%                         isbreachdnbslow = extrainfo.ll(end) == bslow;
%                     end
%                     %20231026:further check whether it is a breachdn-lvldn
%                     isbreachdnlvldn = extrainfo.ll(end) <= extrainfo.lvldn(end) && extrainfo.px(end,5) > extrainfo.lvldn(end);
                    %
                    isbreachdnlvldn = flags_i.islvldnbreach;
                    isbreachdnbslow = flags_i.isbslowbreach;
                    isbreachdnbclow = flags_i.isbclowbreach;
                    
                    if isbreachdnlvldn
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachdnlvldn_tc;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachdnlvldn_tc;
                        end
                    elseif isbreachdnbslow
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachdnbshighvalue_tc;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachdnbshighvalue_tc;
                        end
                    elseif isbreachdnbclow
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachdnlowbc13;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachdnlowbc13;
                        end   
                    else
                        if strcmpi(op_cond_i{1,2},'conditional:mediumbreach-trendconfirmed')
                            if ~strcmpi(freq,'1440m')
                                vlookuptbl = stratfractal.tbl_all_intraday_.smtc;
                            else
                                vlookuptbl = stratfractal.tbl_all_daily_.smtc;
                            end
                        elseif strcmpi(op_cond_i{1,2},'conditional:strongbreach-trendconfirmed')
                            if ~strcmpi(freq,'1440m')
                                vlookuptbl = stratfractal.tbl_all_intraday_.sstc;
                            else
                                vlookuptbl = stratfractal.tbl_all_daily_.sstc;
                            end
                        else
                            %internal error
                        end
                    end
                    idx = strcmpi(vlookuptbl.asset,assetname);
                    try
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                    catch
                        kelly = -9.99;
                        wprob = 0;
                    end
                    if kelly >= 0.145
                        signal_cond_i{1,2}(1) = -1;
                    else
                        signal_cond_i{1,2}(1) = 0;
                        if isbreachdnlvldn
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),'conditional breachdn-lvldn',100*kelly,100*wprob);
                        elseif isbreachdnbslow
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),'conditional breachdn-bshighvalue',100*kelly,100*wprob);
                        elseif isbreachdnbclow
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),'conditional breachdn-lowbc13',100*kelly,100*wprob);
                        else
                            fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),op_cond_i{1,2},100*kelly,100*wprob);
                        end
                    end
                end               
                %
                [hhstatus,llstatus] = fractal_barrier_status(extrainfo,ticksize);
                hhupward = strcmpi(hhstatus,'upward');
                lldnward = strcmpi(llstatus,'dnward');
                
                %1b.HH is above TDST level-up
                %HH is also above alligator's teeth
                %the latest close price is still below HH
                %the alligator's lips is above alligator's teeth OR
                %HH is well above jaw
                %some of the last 2*nfracal candles' low price was below TDST level-up
                %some of the last 2*nfractal candles' close was below TDST level-up
                %i.e.not all candles above TDST level-up
                %if HH is breached, it shall also breach TDST level up
                hhabovelvlup = hh(end)>=lvlup(end) ...
                    & hh(end)>teeth(end) ...
                    & p(end,5)<=hh(end) ...
                    & p(end,5)<=lvlup(end) ...
                    & (lips(end)>teeth(end) || (lips(end)<=teeth(end) && hh(end)>jaw(end))) ...
                    & ~isempty(find(p(end-2*nfractal+1:end,4)-lvlup(end)+2*ticksize<0,1,'first')) ...
                    & ~isempty(find(p(end-2*nfractal+1:end,5)-lvlup(end)+2*ticksize<0,1,'first')) ...
                    & tick(4) >= min(lips(end),teeth(end));
                if ~hhabovelvlup && p(end,5) <= hh(end) && p(end,5)<=lvlup(end)
                    sslast = find(ss==9,1,'last');
                    if ~isempty(sslast)
                        sslastval = ss(sslast);
                        for kk = sslast+1:size(ss,1)
                            if ss(kk) == 0
                                sslast = kk-1;
                                sslastval = ss(sslast);
                                break
                            end
                        end
                        sshigh = max(p(sslast-sslastval+1:sslast,3));
                        if hh(end)>=sshigh && hh(end)>=lvlup(end) && tick(4) >= min(lips(end),teeth(end))
                            hhabovelvlup = true;
                        end
                    end
                end
                %the latest HH is above the previous, indicating an
                %upper-trend
                if hhabovelvlup    
                    if ~hhupward
                        %we regard the upper trend is valid if nfractal+1
                        %candle close above the alligator's lips
                        hhabovelvlup = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)+2*ticksize<0,1,'first'));
                        %also need at least nfractal+1 alligator's lips
                        %above teeth
                        hhabovelvlup = hhabovelvlup & isempty(find(lips(end-nfractal:end)-teeth(end-nfractal:end)+ticksize<0,1,'first'));
                    end
                end
                if hhabovelvlup
                    if lvlup(end) > lvldn(end)
                        hhabovelvlup = p(end,3) >= lvldn(end);
                    end
                end
                %
                %1c.HH is below TDST level up
                %HH is also above alligator's teeth
                %the alligator's lips is above alligator's teeth
                %the latest close price is still below HH
                hhbelowlvlup = hh(end)<lvlup(end) ...
                    & hh(end)>teeth(end) ...
                    & lips(end)>teeth(end) ...
                    & p(end,5)<hh(end) ...
                    & p(end,5)>teeth(end);
                
                if ~hhabovelvlup
                    %we shall withdraw any pending conditional entrsut with
                    %mode 'conditional-breachup'
                    if ~hhbelowlvlup
                        ne = stratfractal.helper_.condentrustspending_.latest;
                        condentrusts2remove = EntrustArray;
                        for jj = 1:ne
                            e = stratfractal.helper_.condentrustspending_.node(jj);
                            if e.offsetFlag ~= 1, continue; end
                            if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                            if ~strcmpi(e.signalinfo_.mode,'conditional-breachuplvlup'),continue;end
                            condentrusts2remove.push(e);
                        end
                        if condentrusts2remove.latest > 0
                            stratfractal.removecondentrusts(condentrusts2remove);
                            fprintf('\t%s:conditional-breachuplvlup cancled as fractal hh is not above lvlup....\n',instruments{i}.code_ctp);
                        end
                    else
                        if ~isempty(status) && ~status.istrendconfirmed
                            
                            if ~strcmpi(freq,'1440m')
                                vlookuptbl = stratfractal.tbl_all_intraday_.breachuplvlup_tb;
                            else
                                vlookuptbl = stratfractal.tbl_all_daily_.breachuplvlup_tb;
                            end
                            idx = strcmpi(vlookuptbl.asset,assetname);
                            try
                                kelly = vlookuptbl.K(idx);
                                wprob = vlookuptbl.W(idx);
                                if isempty(kelly)
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                            catch
                                kelly = -9.99;
                                wprob = 0;
                            end
                            if kelly < 0.4
                                ne = stratfractal.helper_.condentrustspending_.latest;
                                condentrusts2remove = EntrustArray;
                                for jj = 1:ne
                                    e = stratfractal.helper_.condentrustspending_.node(jj);
                                    if e.offsetFlag ~= 1, continue; end
                                    if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                                    if ~strcmpi(e.signalinfo_.mode,'conditional-breachuplvlup'),continue;end
                                    condentrusts2remove.push(e);
                                end
                                idx = strcmpi(vlookuptbl.asset,assetname);
                                try
                                    kelly = vlookuptbl.K(idx);
                                    wprob = vlookuptbl.W(idx);
                                catch
                                    kelly = -9.99;
                                    wprob = 0;
                                end
                                if kelly < 0.4
                                    ne = stratfractal.helper_.condentrustspending_.latest;
                                    condentrusts2remove = EntrustArray;
                                    for jj = 1:ne
                                        e = stratfractal.helper_.condentrustspending_.node(jj);
                                        if e.offsetFlag ~= 1, continue; end
                                        if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                                        if ~strcmpi(e.signalinfo_.mode,'conditional-breachuplvlup'),continue;end
                                        condentrusts2remove.push(e);
                                    end
                                    if condentrusts2remove.latest > 0
                                        stratfractal.removecondentrusts(condentrusts2remove);
                                        fprintf('\t%s:conditional-breachuplvlup cancled as kelly is below 0.4....\n',instruments{i}.code_ctp);
                                    end
                                end
                            end
                        end
                    end
                end
                
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 1
                    %TREND has priority over TDST breakout
                    %note:20211118
                    %it is necessary to withdraw pending conditional
                    %entrust with higher price to long
                    ne = stratfractal.helper_.condentrustspending_.latest;
                    if ne > 0
                        condentrusts2remove = EntrustArray;
                        for jj = 1:ne
                            e = stratfractal.helper_.condentrustspending_.node(jj);
                            if e.offsetFlag ~= 1, continue; end
                            if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                            if e.direction ~= 1, continue;end %the same direction
                            if e.price <= hh(end)+ticksize,continue;end
                            %if the code reaches here, the existing entrust shall be canceled
                            condentrusts2remove.push(e);
                        end
                        if condentrusts2remove.latest > 0
                            stratfractal.removecondentrusts(condentrusts2remove);
                        end
                    end
                    signals{i,1} = signal_cond_i{1,1};
                    if isbreachuplvlup
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup-tc',100*kelly,100*wprob);
                    elseif isbreachupsshigh
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-sshighvalue-tc',100*kelly,100*wprob);
                    elseif isbreachupschigh
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-highsc13',100*kelly,100*wprob);
                    else
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),op_cond_i{1,1},100*kelly,100*wprob);
                    end
                else
                    if hhabovelvlup
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachuplvlup_tb;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachuplvlup_tb;
                        end
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        try
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                        catch
                            kelly = -9.99;
                            wprob = 0;
                        end
                        %here we change rule for breachup-lvlup
                        %generally we take it as kelly is greater than 0.15
                        if kelly >= 0.15
                            this_signal = zeros(1,7);
                            this_signal(1,1) = 1;
                            this_signal(1,2) = hh(end);                             %HH is already above TDST-lvlup
                            this_signal(1,3) = ll(end);
                            this_signal(1,5) = p(end,3);
                            this_signal(1,6) = p(end,4);
                            this_signal(1,7) = lips(end);
                            this_signal(1,4) = 4;
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup',100*kelly,100*wprob);
                            signals{i,1} = this_signal;
                        end
                    elseif hhbelowlvlup && (p(end,3)>lvldn(end) || isnan(lvldn(end)))
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachuplvlup_tb;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachuplvlup_tb;
                        end
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        try
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                        catch
                            kelly = -9.99;
                            wprob = 0;
                        end
                        if kelly > 0.3 && wprob > 0.5                        
                            this_signal = zeros(1,7);
                            this_signal(1,1) = 1;
                            this_signal(1,2) = lvlup(end);                          %HH is still below TDST-lvlup
                            this_signal(1,3) = ll(end);
                            this_signal(1,5) = p(end,3);
                            this_signal(1,6) = p(end,4);
                            this_signal(1,7) = lips(end);
                            this_signal(1,4) = 4;
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(1),'conditional:breachup-lvlup',100*kelly,100*wprob);
                            signals{i,1} = this_signal;
                        end
                    end
                end
                %
                %
                %2b.LL is below TDST level-dn
                %LL is also below alligator's teeth
                %the latest close price is still above LL
                %the alligator's lips is below alligator's teeth
                %some of the latest 2*nfractal candle's high price was
                %above TDST level-dn
                llbelowlvldn = ll(end)<=lvldn(end) ...
                    & ll(end)<teeth(end) ...
                    & p(end,5)>ll(end) ...
                    & p(end,5)>=lvldn(end) ...
                    & lips(end)<teeth(end) ...
                    & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,3)+2*ticksize<0,1,'first'))...
                    & ~isempty(find(lvldn(end)-p(end-2*nfractal+1:end,5)+2*ticksize<0,1,'first')) ...
                    & tick(4) <= max(lips(end),teeth(end));
                if ~llbelowlvldn && p(end,5) > ll(end) && p(end,5)>=lvldn(end)
                    bslast = find(bs==9,1,'last');
                    if ~isempty(bslast)
                        bslastval = bs(bslast);
                        for kk = bslast+1:size(bs,1)
                            if bs(kk) == 0
                                bslast = kk-1;
                                bslastval = bs(bslast);
                                break
                            end
                        end
                        bslow = min(p(bslast-bslastval+1:bslast,4));
                        if ll(end) <= bslow && ll(end)<=lvldn(end) && tick(4) <= max(lips(end),teeth(end))
                            llbelowlvldn = true;
                        end
                    end
                end
                
                %the latest LL is below the previous, indicating a
                %down-trend
                if llbelowlvldn
                    if ~lldnward
                        %we regard the down trend is valid if nfractal+1
                        %candle close below the alligator's lips
                        llbelowlvldn = isempty(find(p(end-nfractal:end,5)-lips(end-nfractal:end)-2*ticksize>0,1,'first'));
                        %also need at least nfractal+1 alligator's lips
                        %below teeth
                        llbelowlvldn = llbelowlvldn & isempty(find(lips(end-nfractal:end)-teeth(end-nfractal:end)-ticksize>0,1,'first'));
                    end
                end
                if llbelowlvldn
                    if lvlup(end) > lvldn(end)
                        llbelowlvldn = p(end,4) <= lvlup(end);
                    end
                end
                if ~llbelowlvldn
                    %we shall withdraw any pending conditional entrust with
                    %mode 'conditional-breachdn'
                    ne = stratfractal.helper_.condentrustspending_.latest;
                    condentrusts2remove = EntrustArray;
                    for jj = 1:ne
                        e = stratfractal.helper_.condentrustspending_.node(jj);
                        if e.offsetFlag ~= 1, continue; end
                        if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                        if ~strcmpi(e.signalinfo_.mode,'conditional-breachdnlvldn'),continue;end
                        condentrusts2remove.push(e);
                    end
                    if condentrusts2remove.latest > 0
                        stratfractal.removecondentrusts(condentrusts2remove);
                        fprintf('\t%s:conditional-breachdnlvldn cancled as fractal ll is not below lvldn....\n',instruments{i}.code_ctp);
                    end
                end
                %
                %2c.LL is above TDST level dn
                %LL is also below alligator's teeth
                %the alligator's lips is below alligator's teeth
                %the latest close price is still above LL
                llabovelvldn = ll(end)>lvldn(end) ...
                    & ll(end)<teeth(end) ...
                    & lips(end)<teeth(end) -2*ticksize...
                    & p(end,5)>ll(end);
                
                if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1
                    %TREND has priority over TDST breakout
                    %note:20211118
                    %it is necessary to withdraw pending conditional
                    %entrust with lower price to short
                    ne = stratfractal.helper_.condentrustspending_.latest;
                    if ne > 0
                        condentrusts2remove = EntrustArray;
                        for jj = 1:ne
                            e = stratfractal.helper_.condentrustspending_.node(jj);
                            if e.offsetFlag ~= 1, continue; end
                            if ~strcmpi(e.instrumentCode,instruments{i}.code_ctp), continue;end%the same instrument
                            if e.direction ~= -1, continue;end %the same direction
                            if e.price >= ll(end)-ticksize,continue;end
                            %if the code reaches here, the existing entrust shall be canceled
                            condentrusts2remove.push(e);
                        end
                        if condentrusts2remove.latest > 0
                            stratfractal.removecondentrusts(condentrusts2remove);
                        end
                    end
                    signals{i,2} = signal_cond_i{1,2};
                    if isbreachdnlvldn
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn-tc',100*kelly,100*wprob);
                    elseif isbreachdnbslow
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-bshighvalue-tc',100*kelly,100*wprob);
                    elseif isbreachdnbclow
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-bclow13',100*kelly,100*wprob);
                    else
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),op_cond_i{1,2},100*kelly,100*wprob);
                    end
                        
                else
                    %NOT BELOW TEETH
                    if llbelowlvldn
                        if ~strcmpi(freq,'1440m')
                            vlookuptbl = stratfractal.tbl_all_intraday_.breachdnlvldn_tb;
                        else
                            vlookuptbl = stratfractal.tbl_all_daily_.breachdnlvldn_tb;
                        end
                        idx = strcmpi(vlookuptbl.asset,assetname);
                        try
                            kelly = vlookuptbl.K(idx);
                            wprob = vlookuptbl.W(idx);
                            if isempty(kelly)
                                kelly = -9.99;
                                wprob = 0;
                            end
                        catch
                            kelly = -9.99;
                            wprob = 0;
                        end
                        if kelly >= 0.15
                            this_signal = zeros(1,7);
                            this_signal(1,1) = -1;
                            this_signal(1,2) = hh(end);
                            this_signal(1,3) = ll(end);                         %LL is already below TDST-lvldn
                            this_signal(1,5) = p(end,3);
                            this_signal(1,6) = p(end,4);
                            this_signal(1,7) = lips(end);
                            this_signal(1,4) = -4;
                            signals{i,2} = this_signal;
                            fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn',100*kelly,100*wprob);
                        end
%                     elseif llabovelvldn && p(end,4)<lvlup(end)
                      elseif llabovelvldn
%                         this_signal = zeros(1,6);
%                         this_signal(1,1) = -1;
%                         this_signal(1,2) = hh(end);
%                         this_signal(1,3) = lvldn(end);                      %LL is still above TDST-lvldn
%                         this_signal(1,5) = p(end,3);
%                         this_signal(1,6) = p(end,4);
%                         this_signal(1,7) = lips(end);
%                         this_signal(1,4) = -4;
%                         signals{i,2} = this_signal;
%                         fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),'conditional:breachdn-lvldn');
                    end   
                end
            end
            %
        end
    end
   
    
    sum_signal = 0;
    for i = 1:n
        signal_long = signals{i,1};
        signal_short = signals{i,2};
        if ~isempty(signal_long)
            sum_signal = sum_signal + abs(signal_long(1));
        end
        if ~isempty(signal_short)
            sum_signal = sum_signal + abs(signal_short(1));
        end
    end
    
    if sum_signal == 0, return;end
    
    fprintf('\n');
end