function [] = autoplacenewentrusts_optmultifractal(stratoptfractal,signals)
    %cStratOptMultiFractal
    if isempty(stratoptfractal.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(stratoptfractal));end

    signal_long = signals{1,1};
    signal_short = signals{1,2};
    %to check whether there is a valid signal
    if isempty(signal_long) && isempty(signal_short), return; end
    
    sum_direction = 0;
    if ~isempty(signal_long), sum_direction = sum_direction + abs(signal_long(1));end
    if ~isempty(signal_short), sum_direction = sum_direction + abs(signal_short(1));end
    if sum_direction == 0, return;end
    %
    sum_use = 0;
    if ~isempty(signal_long), sum_use = sum_use + abs(signal_long(4));end
    if ~isempty(signal_short), sum_use = sum_use + abs(signal_short(4));end
    if sum_use == 0, return;end
    
    volume = 1;
    maxvolume = 1;
    
    %to check whether running time is tradable
    if strcmpi(stratoptfractal.mode_,'replay')
        runningt = stratoptfractal.replay_time1_;
    else
        runningt = now;
    end
    ismarketopen = stratoptfractal.mde_opt_.ismarketopen('time',runningt);
    if ~ismarketopen, return;end
    
    %to check whether position for the underlier exists,
    underlier = stratoptfractal.mde_opt_.underlier_;
    try
        [flag,idx] = stratoptfractal.helper_.book_.hasposition(underlier);
    catch
        flag = false;
        idx = 0;
    end
    if ~flag
        volume_exist = 0;
    else
        pos = stratoptfractal.helper_.book_.positions_{idx};
        volume_exist = pos.position_total_;
    end
    
    if volume_exist >= maxvolume, return;end

    freqnum = stratoptfractal.mde_opt_.getcandlefreq(underlier);
    freq = [num2str(freqnum),'m'];
    if strcmpi(freq,'5m')
        ticksizeratio = 0;
    elseif strcmpi(freq,'15m') || strcmpi(freq,'30m')
        ticksizeratio = 1;
    elseif strcmpi(freq,'1440m')
        ticksizeratio = 1;
    else
        ticksizeratio = 1;
    end
    
    ticksize = underlier.tick_size;
    nfractals = stratoptfractal.mde_opt_.nfractals_(1);
    
    %here below we are about to place an order
    %but we shall withdraw any pending entrust with opening
    passplaceentrust = false;
    ne = stratoptfractal.helper_.entrustspending_.latest;
    for jj = 1:ne
        e = stratoptfractal.helper_.entrustspending_.node(jj);
        if e.offsetFlag ~= 1, continue; end
        if ~strcmpi(e.instrumentCode,underlier.code_ctp), continue;end%the same instrument
        %very interesting case that found on j2405 on 20240320
        %as the market moves so fast that an orignal conditional
        %entrust was triggerd to be a 'real' entrust but not filled
        if ~isempty(strfind(e.signalinfo_.mode,'conditional-uptrendconfirmed')) && ...
                e.direction == 1 && ~isempty(signal_long) && signal_long(1) == 1 && signal_long(4) == 2 && e.price == signal_long(2) + ticksizeratio*ticksize && e.volume == volume
            passplaceentrust = true;
            continue;
        elseif ~isempty(strfind(e.signalinfo_.mode,'conditional-dntrendconfirmed')) && ...
                e.direction == -1 && ~isempty(signal_short) && signal_short(1) == -1 && signal_short(4) == -2 && e.price == signal_short(2) - ticksizeratio*ticksize && e.volume == volume
            passplaceentrust = true;
            continue;
        end
        %if the code reaches here, the existing entrust shall be canceled
        if strcmpi(stratoptfractal.mode_,'realtime')
            stratoptfractal.helper_.getcounter.withdrawEntrust(e);
        else
            stratoptfractal.withdrawentrusts(instrument,'offset',1);
        end
    end
    
    if passplaceentrust, return;end
    
    %to check whether there is a valid tick price
    tick = stratoptfractal.mde_opt_.getlasttick(underlier);
    if isempty(tick),return;end
    bid = tick(2);
    ask = tick(3);
    lasttrade = tick(4);
    %in case the market is stopped when the upper or lower limit is breached
    if abs(bid) > 1e10 || abs(ask) > 1e10, return; end
    if bid <= 0 || ask <= 0, return;end
    
    if ~strcmpi(freq,'1440m')
        kellytables = stratoptfractal.tbl_all_intraday_;
    else
        kellytables = stratoptfractal.tbl_all_daily_;
    end
    
    if ~isempty(signal_short) && signal_short(1) == -1
        type = 'breachdn-S';
        [~,extrainfo] = stratoptfractal.calctechnicalvariable('IncludeLastCandle',0,'RemoveLimitPrice',1);
        if signal_short(4) == -2 || signal_short(4) == -3 || signal_short(4) == -4
            %here we place conditional entrust or an entrust directly
            %if the price is below LL already
            if signal_short(4) == -2
                if signal_short(9) == -21
                    mode = 'conditional-dntrendconfirmed-1';
                elseif signal_short(9) == -22
                    mode = 'conditional-dntrendconfirmed-2';
                elseif signal_short(9) == -23
                    mode = 'conditional-dntrendconfirmed-3';
                else
                    mode = 'conditional-dntrendconfirmed';
                end
            elseif signal_short(4) == -3
                mode = 'conditional-close2lvldn';
            elseif signal_short(4) == -4
                mode = 'conditional-breachdnlvldn';
            end
            info = struct('name','fractal','type',type,...
                'hh',signal_short(2),'ll',signal_short(3),'mode',mode,'nfractal',nfractals,...
                'hh1',signal_short(5),'ll1',signal_short(6),...
                'kelly',signal_short(end));
            if bid <= signal_short(3)-ticksizeratio*ticksize && bid > signal_short(3)-2.0*(signal_short(2)-signal_short(3)) && ...
                    lasttrade <= signal_short(3)-ticksizeratio*ticksize && lasttrade > signal_short(3)-2.0*(signal_short(2)-signal_short(3))
                px = extrainfo.px;
                idxLL = extrainfo.idxll;
                idx_lastll = find(idxLL == -1,1,'last');
                nkfromll = size(px,1) - idx_lastll+nfractals+1;
                barsizerest = px(end-nkfromll+1:end,3)-px(end-nkfromll+1:end,4);
                retlast = lasttrade-px(end,5);
                isvolblowup2 = retlast<0 & (abs(retlast)-mean(barsizerest))/std(barsizerest)>norminv(0.99);
                lllast = extrainfo.ll(end);
                bsidxlast = find(extrainfo.bs>=9,1,'last');
                if ~isempty(bsidxlast)
                    bsvallast = extrainfo.bs(bsidxlast);
                    bslow = min(px(bsidxlast-bsvallast+1:bsidxlast,4));
                    isbslowbreach = lllast == bslow;
                else
                    isbslowbreach = false;
                end
                if isvolblowup2 && ~isbslowbreach
                    try
                        kelly = kelly_k('volblowup2',underlier.asset_name,kellytables.signal_s,kellytables.asset_list,kellytables.kelly_matrix_s,0);
                    catch
                        idxvolblowup2 = strcmpi(kellytables.kelly_table_s.opensignal_unique_s,'volblowup2');
                        kelly = kellytables.kelly_table_s.kelly_unique_s(idxvolblowup2);
                    end
                    %
                    if ~isnan(kelly)
                        if kelly >= 0.088
                            %NOTE:here we shall place an order on the selected
                            %option INSTEAD
                            stratoptfractal.shortopen(underlier.code_ctp,volume,'signalinfo',info);
                        else
                            fprintf('autoplacenewentrusts:low kelly of volblowup2 mode...\n');
                        end
                    else
                        fprintf('autoplacenewentrusts:low kelly of volblowup2 mode...\n');
                    end
                else
                    %NOTE:here we shall place an order on the selected
                    %option instead
                    stratoptfractal.shortopen(underlier.code_ctp,volume,'signalinfo',info);
                end
            elseif bid > signal_short(3)-ticksizeratio*ticksize && lasttrade > signal_short(3)-ticksizeratio*ticksize
                %conditional entrust shall be placed
                ncondpendingall = stratoptfractal.helper_.condentrustspending_.latest;
                ncondpendingvolume = 0;
                for ii = 1:ncondpendingall
                    epending = stratoptfractal.helper_.condentrustspending_.node(ii);
                    if strcmpi(epending.instrumentCode,underlier.code_ctp) && ...
                            epending.direction == -1
                        ncondpendingvolume = ncondpendingvolume + epending.volume;
                    end
                end
                if ncondpendingvolume < volume
                    if signal_short(4) == -2
                        stratoptfractal.condshortopen(underlier.code_ctp,signal_short(3)-ticksizeratio*ticksize,volume,'signalinfo',info);
                    elseif signal_short(4) == -3
                        stratoptfractal.condshortopen(underlier.code_ctp,signal_short(3),volume,'signalinfo',info);
                    elseif signal_short(4) == -4
                        stratoptfractal.condshortopen(underlier.code_ctp,signal_short(3)-ticksizeratio*ticksize,volume,'signalinfo',info);
                    end
                end
            end
        elseif signal_short(4) == -1
            [~,op,~] = fractal_signal_unconditional(extrainfo,ticksizeratio*ticksize,nfractals);
            mode = op.comment;
            %
            if bid <= signal_short(7)-ticksizeratio*ticksize && ...
                    bid < signal_short(6) + 0.382*(signal_short(2)-signal_short(6)) && ...
                    lasttrade <= signal_short(7) && ...
                    lasttrade < signal_short(6) + 0.382*(signal_short(2)-signal_short(6))
                info = struct('name','fractal','type',type,...
                    'hh',signal_short(2),'ll',signal_short(3),'mode',mode,'nfractal',nfractals,...
                    'hh1',signal_short(5),'ll1',signal_short(6),...
                    'kelly',signal_short(8));
                if bid <= signal_short(3) && lasttrade <= signal_short(3)
                    %NOTE:here we shall place an order on the selected
                            %option INSTEAD
                    ret = stratoptfractal.shortopen(underlier.code_ctp,volume,'signalinfo',info);
                    if ret && ~stratoptfractal.helper_.book_.hasposition(stratoptfractal.put_)
                        stratoptfractal.longopen(stratoptfractal.put_,volume,'signalinfo',info);
                    end
                else
                    
                end
            end
        end
    end
    %
    if ~isempty(signal_long) && signal_long(1) == 1
        type = 'breachup-B';
        [~,extrainfo] = stratoptfractal.calctechnicalvariable('IncludeLastCandle',0,'RemoveLimitPrice',1);
        if signal_long(4) == 2 || signal_long(4) == 3 || signal_long(4) == 4
            %here we place conditional entrust or an entrust directly
            %if the price is above HH already
            if signal_long(4) == 2
                if signal_long(9) == 21
                    mode = 'conditional-uptrendconfirmed-1';
                elseif signal_long(9) == 22
                    mode = 'conditional-uptrendconfirmed-2';
                elseif signal_long(9) == 23
                    mode = 'conditional-uptrendconfirmed-3';
                else
                    mode = 'conditional-uptrendconfirmed';
                end
            elseif signal_long(4) == 3
                mode = 'conditional-close2lvlup';
            elseif signal_long(4) == 4
                mode = 'conditional-breachuplvlup';
            end
            info = struct('name','fractal','type',type,...
                'hh',signal_long(2),'ll',signal_long(3),'mode',mode,'nfractal',nfractals,...
                'hh1',signal_long(5),'ll1',signal_long(6),...
                'kelly',signal_long(end));
            if ask >= signal_long(2) + ticksizeratio*ticksize && ask < signal_long(2)+2.0*(signal_long(2)-signal_long(3)) && ...
                    lasttrade >= signal_long(2)+ticksizeratio*ticksize && lasttrade < signal_long(2)+2.0*(signal_long(2)-signal_long(3))
                px = extrainfo.px;
                idxHH = extrainfo.idxhh;
                idx_lasthh = find(idxHH == 1,1,'last');
                nkfromhh = size(px,1) - idx_lasthh+nfractals+1;
                barsizerest = px(end-nkfromhh+1:end,3)-px(end-nkfromhh+1:end,4);
                retlast = lasttrade-px(end,5);
                isvolblowup2 = retlast>0 & (retlast-mean(barsizerest))/std(barsizerest)>norminv(0.99);
                hhlast = extrainfo.hh(end);
                ssidxlast = find(extrainfo.ss>=9,1,'last');
                if ~isempty(ssidxlast)
                    ssvallast = extrainfo.ss(ssidxlast);
                    sshigh = max(px(ssidxlast-ssvallast+1:ssidxlast,3));
                    issshighbreach = hhlast == sshigh;
                else
                    issshighbreach = false;
                end
                if isvolblowup2 && ~issshighbreach
                    try
                        kelly = kelly_k('volblowup2',underlier.asset_name,kellytables.signal_l,kellytables.asset_list,kellytables.kelly_matrix_l,0);
                    catch
                        idxvolblowup2 = strcmpi(kellytables.kelly_table_l.opensignal_unique_l,'volblowup2');
                        kelly = kellytables.kelly_table_l.kelly_unique_l(idxvolblowup2);
                    end
                    %
                    if ~isnan(kelly)
                        if kelly >= 0.088
                            stratoptfractal.longopen(underlier.code_ctp,volume,'signalinfo',info);
                        else
                            fprintf('autoplacenewentrusts:low kelly of volblowup2 mode...\n');
                        end
                    else
                        fprintf('autoplacenewentrusts:low kelly of volblowup2 mode...\n');
                    end
                else
                    stratoptfractal.longopen(underlier.code_ctp,volume,'signalinfo',info);
                end
            elseif ask < signal_long(2) + ticksizeratio*ticksize && lasttrade < signal_long(2) + ticksizeratio*ticksize
                %conditional entrust shall be placed
                ncondpendingall = stratoptfractal.helper_.condentrustspending_.latest;
                ncondpendingvolume = 0;
                for ii = 1:ncondpendingall
                    epending = stratoptfractal.helper_.condentrustspending_.node(ii);
                    if strcmpi(epending.instrumentCode,underlier.code_ctp) && ...
                            epending.direction == 1
                        ncondpendingvolume = ncondpendingvolume + epending.volume;
                    end
                end
                if ncondpendingvolume < volume
                    if signal_long(4) == 2
                        stratoptfractal.condlongopen(underlier.code_ctp,signal_long(2)+ticksizeratio*ticksize,volume,'signalinfo',info);
                    elseif signal_long(4) == 3
                        stratoptfractal.condlongopen(underlier.code_ctp,signal_long(2),volume,'signalinfo',info);
                    elseif signal_long(4) == 4
                        stratoptfractal.condlongopen(underlier.code_ctp,signal_long(2)+ticksizeratio*ticksize,volume,'signalinfo',info);
                    end
                end
            end
        elseif signal_long(4) == 1
            [~,op,~] = fractal_signal_unconditional(extrainfo,ticksizeratio*ticksize,nfractals);
            mode = op.comment;
            jcut = strfind(mode,'-invalid');
            if ~isempty(jcut)
                mode = mode(1:jcut-1);
            end
            
            if ask >= signal_long(7)+ticksizeratio*ticksize && ...
                    ask > signal_long(5) - 0.382*(signal_long(5)-signal_long(3)) && ...
                    lasttrade >= signal_long(7) && ...
                    lasttrade > signal_long(5) - 0.382*(signal_long(5)-signal_long(3))
                info = struct('name','fractal','type',type,...
                    'hh',signal_long(2),'ll',signal_long(3),'mode',mode,'nfractal',nfractals,...
                    'hh1',signal_long(5),'ll1',signal_long(6),...
                    'kelly',signal_long(8));
                if ask >= signal_long(2) && lasttrade >= signal_long(2)
                    ret = stratoptfractal.longopen(underlier.code_ctp,volume,'signalinfo',info);
                    %a call option shall be placed as well
                    if ret && ~stratoptfractal.helper_.book_.hasposition(stratoptfractal.call_)
                        stratoptfractal.longopen(stratoptfractal.call_,volume,'signalinfo',info);
                    end
                else
                end
            end
        end
    end
    %
    
end