function [] = updatesignal_fx(mdefx,varargin)
%cMDEFX method
    %
    nfractal = 2;
    nfx = length(mdefx.codes_fx_);
    for i = 1:nfx
        [signal_i,op_i,status_i] = fractal_signal_unconditional(mdefx.struct_fx_{i},mdefx.instruments_fx_{i}.tick_size,nfractal);
        if ~isempty(signal_i)
            if signal_i(1) == 0
            elseif signal_i(1) == 1
                if strcmpi(op_i.comment,'volblowup') || strcmpi(op_i.comment,'volblowup2') || ...
                        strcmpi(op_i.comment,'strongbreach-trendconfirmed') || strcmpi(op_i.comment,'mediumbreach-trendconfirmed')
                    kelly = kelly_k(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_l,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.kelly_matrix_l);
                    wprob = kelly_w(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_l,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.winprob_matrix_l);
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),op_i.comment,100*kelly,100*wprob);
                elseif strcmpi(op_i.comment,'breachup-highsc13')
                    vlookuptbl = mdefx.kelly_table_.breachuphighsc13;
                    idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),op_i.comment,100*kelly,100*wprob);
                else
                    if ~isempty(strfind(op_i.comment,'breachup-lvlup'))
                        if ~status_i.istrendconfirmed
                            vlookuptbl = mdefx.kelly_table_.breachuplvlup_tb;
                            commentstr = 'breachup-lvlup-tb';
                        else
                            vlookuptbl = mdefx.kelly_table_.breachuplvlup_tc;
                            commentstr = 'breachup-lvlup-tc';
                        end
                        idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),commentstr,100*kelly,100*wprob);
                    elseif ~isempty(strfind(op_i.comment,'breachup-sshighvalue'))
                        if ~status_i.istrendconfirmed
                            vlookuptbl = mdefx.kelly_table_.breachupsshighvalue_tb;
                            commentstr = 'breachup-sshighvalue-tb';
                        else
                            vlookuptbl = mdefx.kelly_table_.breachupsshighvalue_tc;
                            commentstr = 'breachup-sshighvalue-tc';
                        end
                        idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),commentstr,100*kelly,100*wprob);
                    else
                        try
                            kelly = kelly_k(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_l,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.kelly_matrix_l);
                            wprob = kelly_w(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_l,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.winprob_matrix_l);
                            if kelly < 0.146 || wprob < 0.4
                                signal_i(1) = 0;
                            end
                        catch
                            idx = strcmpi(op_i.comment,mdefx.kelly_table_.kelly_table_l.opensignal_unique_l);
                            kelly = mdefx.kelly_table_.kelly_table_l.kelly_unique_l(idx);
                            wprob = mdefx.kelly_table_.kelly_table_l.winp_unique_l(idx);
                            signal_i(1) = 0;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),op.comment,100*kelly,100*wprob);
                    end
                end     
            elseif signal_i(1) == -1
                if strcmpi(op_i.comment,'volblowup') || strcmpi(op_i.comment,'volblowup2') || ...
                        strcmpi(op_i.comment,'strongbreach-trendconfirmed') || strcmpi(op_i.comment,'mediumbreach-trendconfirmed')
                    kelly = kelly_k(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_s,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.kelly_matrix_s);
                    wprob = kelly_w(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_s,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.winprob_matrix_s);
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),op_i.comment,100*kelly,100*wprob);
                elseif strcmpi(op_i.comment,'breachdn-lowbc13')
                    vlookuptbl = mdefx.kelly_table_.breachdnlowbc13;
                    idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                    kelly = vlookuptbl.K(idx);
                    wprob = vlookuptbl.W(idx);
                    if isempty(kelly)
                        kelly = -9.99;
                        wprob = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),op_i.comment,100*kelly,100*wprob);
                else
                    if ~isempty(strfind(op_i.comment,'breachdn-lvldn'))
                        if ~status_i.istrendconfirmed
                            vlookuptbl = mdefx.kelly_table_.breachdnlvldn_tb;
                            commentstr = 'breachdn-lvldn-tb';
                        else
                            vlookuptbl = mdefx.kelly_table_.breachdnlvldn_tc;
                            commentstr = 'breachdn-lvldn-tc';
                        end
                        idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),commentstr,100*kelly,100*wprob);
                    elseif ~isempty(strfind(op_i.comment,'breachdn-bshighvalue'))
                        if ~status_i.istrendconfirmed
                            vlookuptbl = mdefx.kelly_table_.breachdnbshighvalue_tb;
                            commentstr = 'breachdn-bshighvalue-tb';
                        else
                            vlookuptbl = mdefx.kelly_table_.breachdnbshighvalue_tc;
                            commentstr = 'breachdn-bshighvalue-tc';
                        end
                        idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                        kelly = vlookuptbl.K(idx);
                        wprob = vlookuptbl.W(idx);
                        if isempty(kelly)
                            kelly = -9.99;
                            wprob = 0;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),commentstr,100*kelly,100*wprob);
                    else
                        try
                            kelly = kelly_k(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_s,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.kelly_matrix_s);
                            wprob = kelly_w(op_i.comment,mdefx.codes_fx_{i}(1:end-3),mdefx.kelly_table_.signal_s,mdefx.kelly_table_.asset_list,mdefx.kelly_table_.winprob_matrix_s);
                            if kelly < 0.146 || wprob < 0.4
                                signal_i(1) = 0;
                            end
                        catch
                            idx = strcmpi(op_i.comment,mdefx.kelly_table_.kelly_table_s.opensignal_unique_s);
                            kelly = mdefx.kelly_table_.kelly_table_s.kelly_unique_s(idx);
                            wprob = mdefx.kelly_table_.kelly_table_s.winp_unique_s(idx);
                            signal_i(1) = 0;
                        end
                        fprintf('\t%6s:%4s\t%10s\tk:%2.1f%%\twinp:%2.1f%%\n',mdefx.codes_fx_{i}(1:end-3),num2str(signal_i(1)),op_i.comment,100*kelly,100*wprob);
                    end 
                end
            end   
        else
            [signal_cond_i,op_cond_i,flags_i] = fractal_signal_conditional(mdefx.struct_fx_{i},mdefx.instruments_fx_{i}.tick_size,nfractal);
            if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,1}) && signal_cond_i{1,1}(1) == 1
                isbreachuplvlup = flags_i.islvlupbreach;
                isbreachupsshigh = flags_i.issshighbreach;
                isbreachupschigh = flags_i.isschighbreach;
                if isbreachuplvlup
                    vlookuptbl = mdefx.kelly_table_.breachuplvlup_tc;
                elseif isbreachupsshigh
                    vlookuptbl = mdefx.kelly_table_.breachupsshighvalue_tc;
                elseif isbreachupschigh
                    vlookuptbl = mdefx.kelly_table_.breachuphighsc13;
                else
                    if strcmpi(op_cond_i{1,1},'conditional:mediumbreach-trendconfirmed')
                        vlookuptbl = mdefx.kelly_table_.bmtc;
                    elseif strcmpi(op_cond_i{1,1},'conditional:strongbreach-trendconfirmed')
                        vlookuptbl = mdefx.kelly_table_.bstc;
                    else
                        %internal error
                    end
                end
                idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
                %
                if kelly >= 0.145 || (kelly > 0.11 && wprob > 0.45)
                    if isbreachuplvlup
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),'conditional breachup-lvlup',100*kelly,100*wprob);
                    elseif isbreachupsshigh
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),'conditional breachup-sshighvalue',100*kelly,100*wprob);
                    elseif isbreachupschigh
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),'conditional breachup-highsc13',100*kelly,100*wprob);
                    else
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),op_cond_i{1,1},100*kelly,100*wprob);
                    end
                else
                    if isbreachuplvlup
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),'conditional breachup-lvlup',100*kelly,100*wprob);
                    elseif isbreachupsshigh
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),'conditional breachup-sshighvalue',100*kelly,100*wprob);
                    elseif isbreachupschigh
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),'conditional breachup-highsc13',100*kelly,100*wprob);
                    else
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),op_cond_i{1,1},100*kelly,100*wprob);
                    end
                end
            end
            if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1
                isbreachdnlvldn = flags_i.islvldnbreach;
                isbreachdnbslow = flags_i.isbslowbreach;
                isbreachdnbclow = flags_i.isbclowbreach;
                if isbreachdnlvldn
                    vlookuptbl = mdefx.kelly_table_.breachdnlvldn_tc;
                elseif isbreachdnbslow
                    vlookuptbl = mdefx.kelly_table_.breachdnbshighvalue_tc;
                elseif isbreachdnbclow
                    vlookuptbl = mdefx.kelly_table_.breachdnlowbc13;
                else
                    if strcmpi(op_cond_i{1,2},'conditional:mediumbreach-trendconfirmed')
                        vlookuptbl = mdefx.kelly_table_.smtc;
                    elseif strcmpi(op_cond_i{1,2},'conditional:strongbreach-trendconfirmed')
                        vlookuptbl = mdefx.kelly_table_.sstc;
                    else
                        %internal error
                    end
                end
                idx = strcmpi(vlookuptbl.asset,mdefx.codes_fx_{i}(1:end-3));
                kelly = vlookuptbl.K(idx);
                wprob = vlookuptbl.W(idx);
                if isempty(kelly)
                    kelly = -9.99;
                    wprob = 0;
                end
                %
                if kelly >= 0.145 || (kelly > 0.11 && wprob > 0.45)
                    if isbreachdnlvldn
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(-1),'conditional breachdn-lvldn',100*kelly,100*wprob);
                    elseif isbreachdnbslow
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(-1),'conditional breachdn-bshighvalue',100*kelly,100*wprob);
                    elseif isbreachdnbclow
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(-1),'conditional breachdn-lowbc13',100*kelly,100*wprob);
                    else
                        fprintf('\t%6s:%4s\t%10s to be placed\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(-1),op_cond_i{1,2},100*kelly,100*wprob);
                    end
                else
                    if isbreachdnlvldn
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),'conditional breachdn-lvldn',100*kelly,100*wprob);
                    elseif isbreachdnbslow
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),'conditional breachdn-bshighvalue',100*kelly,100*wprob);
                    elseif isbreachdnbclow
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),'conditional breachdn-lowbc13',100*kelly,100*wprob);
                    else
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(0),op_cond_i{1,2},100*kelly,100*wprob);
                    end
                end
            end
        end
    end
end