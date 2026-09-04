function [tableoutput] = makedecisionscenario2(obj)
% a cFORM utility function to make decision whether to cut or carry on
% At the moment the LF period closes and fails to confirm, scenario 1 is
% completely ruled out...
% We are standing at a decision node where we know for a fact that LF
% failed. Therefore, to make a statistically sound decision on whether to
% cut immediately or carry on.

    ncodes = size(obj.codes_,1);
    tradesScenario2 = cell(ncodes,1);
    tableoutput = cell(ncodes,1);

    % select trades for Scenario 2
    for i = 1:ncodes
        trades_i = obj.trades_empirical_{i};
        ntrades = trades_i.latest_;
        fut_i = obj.instruments_{i};
        
        tradesFailed_i = cTradeOpenArray;

        for j = 1:ntrades
            trade_ij = trades_i.node_(j);
            idx = find(obj.ei_signal_{i}.px(:,1) >= trade_ij.opendatetime1_,1,'first');
            lfclose = obj.ei_signal_{i}.px(idx,5);
            if trade_ij.opendirection_ == 1
                confirmed = lfclose - trade_ij.opensignal_.hh_ - fut_i.tick_size > -1e-6;
            elseif trade_ij.opendirection_ == -1
                confirmed = lfclose - trade_ij.opensignal_.ll_ + fut_i.tick_size < 1e-6;
            else
                error('invalid trade:long/short only...')
            end
            if ~confirmed
%                 tradeCopied = trade_ij.copy;
                tradesFailed_i.push(trade_ij);
            end
        end

        tradesScenario2{i} = tradesFailed_i;
        
    end
    %
    % make decision->either cut immediately or carry on for the LF risk
    % management
    for i = 1:ncodes
        ei_signal_i = obj.ei_signal_{i};
        nbars_i = size(ei_signal_i.px,1);
        tradesFailed_i = tradesScenario2{i};
        ntrades_i = tradesFailed_i.latest_;
        Code = cell(ntrades_i,1);
        Mode = cell(ntrades_i,1);
        CI = zeros(ntrades_i,1);
        Carry = CI;
        CloseStr = cell(ntrades_i,1);
        for j = 1:ntrades_i
            trade_ij = tradesFailed_i.node_(j);
            tradername_ij = trade_ij.tradername_;
            Code{j} = trade_ij.code_;
            signal = trade_ij.opensignal_.mode_;
            if strcmpi(signal,'conditional-uptrendconfirmed')
                if strcmpi(tradername_ij,'medium')
                    Mode{j} = 'bmtc';
                else
                    Mode{j} = 'bstc';
                end
            elseif strcmpi(signal,'conditional-uptrendconfirmed-1')
                Mode{j} = 'breachuplvlup_tc';
            elseif strcmpi(signal,'conditional-uptrendconfirmed-2')
                Mode{j} = 'breachupsshighvalue_tc';
            elseif strcmpi(signal,'conditional-uptrendconfirmed-3')
                Mode{j} = 'breachuphighsc13';
            elseif strcmpi(signal,'conditional-dntrendconfirmed')
                if strcmpi(tradername_ij,'medium')
                    Mode{j} = 'smtc';
                else
                    Mode{j} = 'sstc';
                end
            elseif strcmpi(signal,'conditional-dntrendconfirmed-1')
                Mode{j} = 'breachdnlvldn_tc';
            elseif strcmpi(signal,'conditional-dntrendconfirmed-2')
                Mode{j} = 'breachdnbshighvalue_tc';
            elseif strcmpi(signal,'conditional-dntrendconfirmed-3')
                Mode{j} = 'breachdnlowbc13';
            else
                error('invalid signal')
            end
            %
            idx = find(ei_signal_i.px(:,1) >= trade_ij.opendatetime1_,1,'first');
            lfclose = ei_signal_i.px(idx,5);
            CI(j) = trade_ij.opendirection_*(lfclose-trade_ij.openprice_)/trade_ij.openprice_; 
            %
            % now we need to do the back-test assuming the trade is carried
            % on
            trade_bk = trade_ij.copy;
            for k = idx:nbars_i
                extrainfo = fractal_truncate(ei_signal_i,k);
                extrainfo.latestopen = extrainfo.px(end,5);
                extrainfo.latestdt = extrainfo.px(end,1);
                output = trade_bk.riskmanager_.riskmanagementwithcandle([],...
                    'usecandlelastonly',false,...
                    'updatepnlforclosedtrade',true,...
                    'extrainfo',extrainfo);
                if ~isempty(output)
                    Carry(j) = trade_bk.opendirection_*(trade_bk.closeprice_-trade_bk.openprice_)/trade_bk.openprice_;
                    CloseStr{j} = trade_bk.closestr_;
                    break
                end
            end

        end
        tableoutput{i} = table(Code,Mode,CI,Carry,CloseStr);
    end

end