function [qfail,tableoutput] = calcqfail(obj)
% a cForm utility function
% every time the HF system triggers at the barrier
% scenario 1 (confirmed): trades where in the end LF triggers as well
% scenario 2 (failed): trades where in the end LF fails
    codes = obj.codes_;
    ncodes = size(codes,1);

    tableoutput = cell(ncodes,1);
    qfail = cell(ncodes,1);

    for i = 1:ncodes
        trades_i = obj.trades_empirical_{i};
        ntrades = trades_i.latest_;
        fut_i = obj.instruments_{i};
        code = cell(ntrades,1);
        opendatetime = cell(ntrades,1);
        direction = zeros(ntrades,1);
        signal = cell(ntrades,1);
        tradername = cell(ntrades,1);
        confirm = zeros(ntrades,1);
        for j = 1:ntrades
            trade_ij = trades_i.node_(j);
            code{j} = trade_ij.code_;
            opendatetime{j} = trade_ij.opendatetime2_;
            direction(j) = trade_ij.opendirection_;
            signal{j} = trade_ij.opensignal_.mode_;
            tradername{j} = trade_ij.tradername_;
            idx = find(obj.ei_signal_{i}.px(:,1) >= trade_ij.opendatetime1_,1,'first');
            lfclose = obj.ei_signal_{i}.px(idx,5);
            if trade_ij.opendirection_ == 1
                confirm(j) = lfclose - trade_ij.opensignal_.hh_ - fut_i.tick_size > -1e-6;
            elseif trade_ij.opendirection_ == -1
                confirm(j) = lfclose - trade_ij.opensignal_.ll_ + fut_i.tick_size < 1e-6;
            end

        end
        tableoutput{i} = table(code,opendatetime,direction,signal,tradername,confirm);
    end


    Modes = {'bmtc';...
        'bstc';...
        'breachuplvlup_tc';...
        'breachupsshighvalue_tc';...
        'breachuphighsc13';...
        'smtc';...
        'sstc';...
        'breachdnlvldn_tc';...
        'breachdnbshighvalue_tc';...
        'breachdnlowbc13'};

    nmodes = length(Modes);
    
    for i = 1:ncodes
        tableoutput_i = tableoutput{i};
        Code = cell(nmodes,1);
        Ntotal = zeros(nmodes,1);
        Nfail = zeros(nmodes,1);
        q = zeros(nmodes,1);

        for j = 1:nmodes
            Code{j} = obj.codes_{i};
            if strcmpi(Modes{j},'bmtc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-uptrendconfirmed') & strcmpi(tableoutput_i.tradername,'medium');
            elseif strcmpi(Modes{j},'bstc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-uptrendconfirmed') & strcmpi(tableoutput_i.tradername,'strong');
            elseif strcmpi(Modes{j},'breachuplvlup_tc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-uptrendconfirmed-1');
            elseif strcmpi(Modes{j},'breachupsshighvalue_tc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-uptrendconfirmed-2');
            elseif strcmpi(Modes{j},'breachuphighsc13')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-uptrendconfirmed-3');
            elseif strcmpi(Modes{j},'smtc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-dntrendconfirmed') & strcmpi(tableoutput_i.tradername,'medium');
            elseif strcmpi(Modes{j},'sstc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-dntrendconfirmed') & strcmpi(tableoutput_i.tradername,'strong');
            elseif strcmpi(Modes{j},'breachdnlvldn_tc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-dntrendconfirmed-1');
            elseif strcmpi(Modes{j},'breachdnbshighvalue_tc')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-dntrendconfirmed-2');
            elseif strcmpi(Modes{j},'breachdnlowbc13')
                idx_j = strcmpi(tableoutput_i.signal,'conditional-dntrendconfirmed-3');
            end
            Ntotal(j) = length(tableoutput_i.confirm(idx_j));
            Nfail(j) = Ntotal(j) - sum(tableoutput_i.confirm(idx_j));
            if Ntotal(j) > 0
                q(j) = Nfail(j) / Ntotal(j);
            end
        end
        

        qfail{i} = table(Code,Modes,Ntotal,Nfail,q);

    end

end