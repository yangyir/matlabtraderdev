function [] = autoplacenewentrusts_futmultifractal(stratfractal,signals)
    %cStratFutMultiFractal
    if isempty(stratfractal.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(stratfractal));end

    n = stratfractal.count;
    instruments = stratfractal.getinstruments;
    for i = 1:n
        signal_long = signals{i,1};
        signal_short = signals{i,2};
        %to check whether there is a valid signal
        if isempty(signal_long) && isempty(signal_short), continue; end
        
%         if ~isempty(signal_long) && ~isempty(signal_short)
%            fprintf('found\n'); 
%         end
        sum_direction = 0;
        if ~isempty(signal_long), sum_direction = sum_direction + abs(signal_long(1));end
        if ~isempty(signal_short), sum_direction = sum_direction + abs(signal_short(1));end
        if sum_direction == 0, continue;end
        %
        sum_use = 0;
        if ~isempty(signal_long), sum_use = sum_use + abs(signal_long(4));end
        if ~isempty(signal_short), sum_use = sum_use + abs(signal_short(4));end
        if sum_use == 0, continue;end

        %to check whether the instrument is set with autotrade flag
        instrument = instruments{i};
        autotrade = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
        if ~autotrade,continue;end

        %to check whether the instrument is allowed to trade with valid size
        volume = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','baseunits');
        maxvolume = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','maxunits');
        if volume == 0 || maxvolume == 0, continue;end

        %to check whether running time is tradable
        if strcmpi(stratfractal.mode_,'replay')
            runningt = stratfractal.replay_time1_;
        else
            runningt = now;
        end        
        ismarketopen = istrading(runningt,instrument.trading_hours,'tradingbreak',instrument.trading_break);    
        if ~ismarketopen, continue;end

        %to check whether there is a valid tick price
        tick = stratfractal.mde_fut_.getlasttick(instrument);
        if isempty(tick),continue;end
        bid = tick(2);
        ask = tick(3);
        %in case the market is stopped when the upper or lower limit is breached
        if abs(bid) > 1e10 || abs(ask) > 1e10, continue; end
        if bid <= 0 || ask <= 0, continue;end

        %to check whether position for the instrument exists,
        try
            [flag,idx] = stratfractal.helper_.book_.hasposition(instrument);
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist = 0;
        else
            pos = stratfractal.helper_.book_.positions_{idx};
            volume_exist = pos.position_total_;
        end

        %to check whether maximum volume has been reached
        if volume_exist >= maxvolume, continue;end

        %here below we are about to place an order
        %but we shall withdraw any pending entrust with the same direction
        ne = stratfractal.helper_.entrustspending_.latest;
        for jj = 1:ne
            e = stratfractal.helper_.entrustspending_.node(jj);
            if e.offsetFlag ~= 1, continue; end
            if ~strcmpi(e.instrumentCode,instrument.code_ctp), continue;end%the same instrument
            if e.direction ~= direction, continue;end %the same direction
            if e.volume ~= volume,continue;end  %the same volume
            %if the code reaches here, the existing entrust shall be canceled
            stratfractal.helper_.getcounter.withdrawEntrust(e);
        end

        if ~isempty(signal_short) && signal_short(1) == -1
            type = 'breachdn-S';
            if signal_short(4) == -2 || signal_short(4) == -3 || signal_short(4) == -4
                %here we place conditional entrust or an entrust directly
                %if the price is below LL already
                ticksize = instrument.tick_size;
                nfractals = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');
                if signal_short(4) == -2
                    mode = 'conditional-dntrendconfirmed';
                elseif signal_short(4) == -3
                    mode = 'conditional-close2lvldn';
                elseif signal_short(4) == -4
                    mode = 'conditional-breachdnlvldn';
                end
                info = struct('name','fractal','type',type,...
                        'hh',signal_short(2),'ll',signal_short(3),'mode',mode,'nfractal',nfractals,...
                        'hh1',signal_short(5),'ll1',signal_short(6));
                if bid < signal_short(3) && bid > signal_short(3)-1.618*(signal_short(2)-signal_short(3))
                    stratfractal.shortopen(instrument.code_ctp,volume,'signalinfo',info);
                elseif bid > signal_short(3)
                    %conditional entrust shall be placed
                    ncondpendingall = stratfractal.helper_.condentrustspending_.latest;
                    ncondpendingvolume = 0;
                    for ii = 1:ncondpendingall
                        epending = stratfractal.helper_.condentrustspending_.node(ii);
                        if strcmpi(epending.instrumentCode,instrument.code_ctp) && ...
                                epending.direction == -1
                            ncondpendingvolume = ncondpendingvolume + epending.volume;
                        end                                
                    end
                    if ncondpendingvolume < volume
                        if signal_short(4) == -2
                            stratfractal.condshortopen(instrument.code_ctp,signal_short(3)-ticksize,volume,'signalinfo',info);
                        elseif signal_short(4) == -3
                            stratfractal.condshortopen(instrument.code_ctp,signal_short(3),volume,'signalinfo',info);
                        elseif signal_short(4) == -4
                            stratfractal.condshortopen(instrument.code_ctp,signal_short(3),volume,'signalinfo',info);
                        end
                    end
                end
            else
                if signal_short(4) == 1
                    mode = 'breachdn-lvldn';
                else
                    mode = 'unset';
                end
                if bid < signal_short(3) && bid > signal_short(3)-1.618*(signal_short(2)-signal_short(3))
                    nfractals = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');
                    info = struct('name','fractal','type',type,...
                        'hh',signal_short(2),'ll',signal_short(3),'mode',mode,'nfractal',nfractals,...
                        'hh1',signal_short(5),'ll1',signal_short(6));
                    stratfractal.shortopen(instrument.code_ctp,volume,'signalinfo',info);
                end
            end
        end
        %
        if ~isempty(signal_long) && signal_long(1) == 1
            type = 'breachup-B';
            if signal_long(4) == 2 || signal_long(4) == 3 || signal_long(4) == 4
                %here we place conditional entrust or an entrust directly
                %if the price is above HH already
                ticksize = instrument.tick_size;
                nfractals = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');
                if signal_long(4) == 2
                    mode = 'conditional-uptrendconfirmed';
                elseif signal_long(4) == 3
                    mode = 'conditional-close2lvlup';
                elseif signal_long(4) == 4
                    mode = 'conditional-breachuplvlup';
                end                
                info = struct('name','fractal','type',type,...
                        'hh',signal_long(2),'ll',signal_long(3),'mode',mode,'nfractal',nfractals,...
                        'hh1',signal_long(5),'ll1',signal_long(6));
                if ask > signal_long(2)+ticksize && ask < signal_long(2)+1.618*(signal_long(2)-signal_long(3))
                    stratfractal.longopen(instrument.code_ctp,volume,'signalinfo',info);
                elseif ask < signal_long(2)
                    %conditional entrust shall be placed
                    ncondpendingall = stratfractal.helper_.condentrustspending_.latest;
                    ncondpendingvolume = 0;
                    for ii = 1:ncondpendingall
                        epending = stratfractal.helper_.condentrustspending_.node(ii);
                        if strcmpi(epending.instrumentCode,instrument.code_ctp) && ...
                                epending.direction == 1
                            ncondpendingvolume = ncondpendingvolume + epending.volume;
                        end                                
                    end
                    if ncondpendingvolume < volume
                        if signal_long(4) == 2
                            stratfractal.condlongopen(instrument.code_ctp,signal_long(2)+ticksize,volume,'signalinfo',info);
                        elseif signal_long(4) == 3
                            stratfractal.condlongopen(instrument.code_ctp,signal_long(2),volume,'signalinfo',info);
                        elseif signal_long(4) == 4
                            stratfractal.condlongopen(instrument.code_ctp,signal_long(2),volume,'signalinfo',info);
                        end
                    end
                end
            else                
                if signal_long(4) == 1
                    mode = 'breachup-lvlup';
                else
                    mode = 'unset';
                end
                if ask > signal_long(2) && ask < signal_long(2)+1.618*(signal_long(2)-signal_long(3))
                    nfractals = stratfractal.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','nfractals');
                    info = struct('name','fractal','type',type,...
                        'hh',signal_long(2),'ll',signal_long(3),'mode',mode,'nfractal',nfractals,...
                        'hh1',signal_long(5),'ll1',signal_long(6));
                    stratfractal.longopen(instrument.code_ctp,volume,'signalinfo',info);
                end
            end
        end
        %
    end    
    
end