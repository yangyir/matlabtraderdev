function [] = updatesignal_fx(mdefx,varargin)
%cMDEFX method
    %
    nfractal = 2;
    nfx = length(mdefx.codes_fx_);
    for i = 1:nfx
        [signal_i,op_i,status_i] = fractal_signal_unconditional(mdefx.struct_fx_{i},mdefx.instruments_fx_{i}.tick_size,nfractal);
        if ~isempty(signal_i)
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
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),'conditional breachup-lvlup',100*kelly,100*wprob);
                    elseif isbreachupsshigh
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),'conditional breachup-sshighvalue',100*kelly,100*wprob);
                    elseif isbreachupschigh
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),'conditional breachup-highsc13',100*kelly,100*wprob);
                    else
                        fprintf('\t%6s:%4s\t%10s not to place\tk:%2.1f%%\twinp:%2.1f%%\n',upper(mdefx.instruments_fx_{i}.code_ctp),num2str(1),op_cond_i{1,1},100*kelly,100*wprob);
                    end
                end
            end
            if ~isempty(signal_cond_i) && ~isempty(signal_cond_i{1,2}) && signal_cond_i{1,2}(1) == -1
                isbreachdnlvldn = flags_i.islvldnbreach;
                isbreachdnbslow = flags_i.isbslowbreach;
                isbreachdnbclow = flags_i.isbclowbreach;
            end
        end
    end
end