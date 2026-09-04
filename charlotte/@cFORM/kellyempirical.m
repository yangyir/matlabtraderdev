function [stratempirical,tableempirical,tradesempirical] = kellyempirical(obj,varargin)
% a cFORM public function
% to generate all relevant statistics of empirical trades

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('kellytables',[],@isstruct);
    p.addParameter('datefrom','',@ischar);
    p.addParameter('dateto','',@ischar);
    p.addParameter('overridesignals',0,@isnumeric);
    p.addParameter('overridetrades',0,@isnumeric);
    p.addParameter('executionmethod','HFI',@ischar);
    p.parse(varargin{:});
    strattable = p.Results.kellytables;
    dt1str = p.Results.datefrom;
    dt2str = p.Results.dateto;
    overridesignals = p.Results.overridesignals;
    overridetrades = p.Results.overridetrades;
    em = p.Results.executionmethod;

    obj.gen_condsignals_empirical('kellytables',strattable,...
        'datefrom',dt1str,...
        'dateto',dt2str,...
        'override',overridesignals);

    obj.gen_trades_empirical('executionmethod',em,...
        'override',overridetrades);

    codes = obj.codes_;
    ncodes = length(codes);
    tradesempirical = cell(ncodes,1);

    nfractal = charlotte_freq2nfractal(obj.signal_freq_);

    if strcmpi(obj.signal_freq_,'h1') || strcmpi(obj.signal_freq_,'1h')
        tickratio = 0.5;
    elseif strcmpi(obj.signal_freq_,'h4') || strcmpi(obj.signal_freq_,'4h')
        tickratio = 1.0;
    else
        tickratio = 1.0;
    end

    ei_signal = obj.ei_signal_;
    condsignals_empirical = obj.condsignals_empirical_;
    trades_empirical = obj.trades_empirical_;
    instruments = obj.instruments_;

    parfor i = 1:ncodes
        tradesempirical_i = cTradeOpenArray;
        ei_i = ei_signal{i};
        condsignals = condsignals_empirical{i};
        fut_i = instruments{i};
        trades_i = trades_empirical{i};
        ntrades_i = trades_i.latest_;
        opendtvec_i = zeros(ntrades_i,1);
        for j = 1:ntrades_i
            opendtvec_i(j) = trades_i.node_(j).opendatetime1_;
        end
        nbars_i = size(ei_i.px,1);
        idx = find(ei_i.px(:,1) >= opendtvec_i(1),1,'first');
        thisTrade = trades_i.node_(1).copy;

        while idx <= nbars_i
            for j = idx:nbars_i
                ei_j = fractal_truncate(ei_i,j);
                ei_j.latestopen = ei_j.px(end,5);
                ei_j.latestdt = ei_j.px(end,1);
                thisTrade.riskmanager_.riskmanagementwithcandle([],...
                    'usecandlelastonly',false,...
                    'debug',false,...
                    'updatepnlforclosedtrade',true,...
                    'extrainfo',ei_j,...
                    'kellytables',strattable,...
                    'compulsorycheckforconditional',true);
                if strcmpi(thisTrade.riskmanager_.status_,'closed') || strcmpi(thisTrade.status_,'closed')
                    thisTrade.status_ = 'closed';
                    thisTrade.riskmanager_.status_ = 'closed';
                    tradesempirical_i.push(thisTrade);
                    break;
                else
                    uncondsignal = fractal_signal_unconditional2('extrainfo',ei_j,...
                        'ticksize',fut_i.tick_size,...
                        'nfractal',nfractal,...
                        'assetname',codes{i},...
                        'kellytables',strattable,...
                        'ticksizeratio',tickratio);
                    if ~isempty(uncondsignal)
                        if uncondsignal.directionkellied == 0
                            thisTrade.status_ = 'closed';
                            thisTrade.riskmanager_.status_ = 'closed';
                            thisTrade.riskmanager_.closestr_ = ['unconditional signal with low kelly: ',num2str(uncondsignal.kelly)];
                            thisTrade.runningpnl_ = 0;
                            thisTrade.closeprice_ = ei_j.px(end,5);
                            thisTrade.closedatetime1_ = ei_j.px(end,1);
                            thisTrade.closepnl_ = thisTrade.opendirection_*(thisTrade.closeprice_-thisTrade.openprice_) /fut_i.tick_size * fut_i.tick_value;
                            tradesempirical_i.push(thisTrade);
                            break;
                        end
                    end
                    %
                    %
                    condsignal = condsignals{j,2};
                    if ~isempty(condsignal)
                        if condsignal.directionkellied == 0
                            exceptionflag = false;
                            if strcmpi(thisTrade.opensignal_.mode_,'breachup-lvlup')
                                samesignal = condsignal.flags.islvlupbreach;
                            elseif strcmpi(thisTrade.opensignal_,'breachup-sshighvalue')
                                samesignal = condsignal.flags.issshighbreach;
                            elseif strcmpi(thisTrade.opensignal_.mode_,'breachup-highsc13')
                                samesignal = condsignal.flags.isschighbreach;
                            elseif strcmpi(thisTrade.opensignal_.mode_,'breachdn-lvldn')
                                samesignal = condsignal.flags.islvldnbreach;
                            elseif strcmpi(thisTrade.opensignal_.mode_,'breachdn-bshighvalue')
                                samesignal = condsignal.flags.isbslowbreach;
                            elseif strcmpi(thisTrade.opensignal_.mode_,'breachdn-lowbc13')
                                samesignal = condsignal.flags.isbclowbreach;
                            elseif strcmpi(thisTrade.opensignal_.mode_,'mediumbreach-trendconfirmed')
                                if ~isempty(strfind(condsignal.opkellied,'mediumbreach-trendconfirmed'))
                                    samesignal = 1;
                                elseif ~isempty(strfind(condsignal.opkellied,'strongbreach-trendconfirmed'))
                                    samesignal = 0;
                                    exceptionflag = true;
                                else
                                    samesignal = 0;
                                end
                            elseif strcmpi(thisTrade.opensignal_.mode_,'strongbreach-trendconfirmed')
                                if ~isempty(strfind(condsignal.opkellied,'strongbreach-trendconfirmed'))
                                    samesignal = 1;
                                elseif ~isempty(strfind(condsignal.opkellied,'mediumbreach-trendconfirmed'))
                                    samesignal = 0;
                                    exceptionflag = true;
                                else
                                    samesignal = 0;
                                end
                            elseif ~isempty(strfind(thisTrade.opensignal_.mode_,'conditional'))
                                samesignal = 1;
                                if condsignal.directionkellied == 0
                                    if ~isempty(strfind(condsignal.opkellied,'strongbreach-trendconfirmed'))
                                        samesignal = 0;
                                        exceptionflag = true;
                                    end
                                end
                            else
                                %other non-trended signal
                                samesignal = 0;
                            end

                            if ~exceptionflag && (samesignal || (~samesignal && condsignal.directionkellied == 0))
                                thisTrade.status_ = 'closed';
                                thisTrade.riskmanager_.status_ = 'closed';
                                thisTrade.riskmanager_.closestr_ = ['conditional signal with low kelly: ',num2str(condsignal.kelly)];
                                thisTrade.runningpnl_ = 0;
                                thisTrade.closeprice_ = ei_j.px(end,5);
                                thisTrade.closedatetime1_ = ei_j.px(end,1);
                                thisTrade.closepnl_ = thisTrade.opendirection_*(thisTrade.closeprice_-thisTrade.openprice_) /fut_i.tick_size * fut_i.tick_value;
                                tradesempirical_i.push(thisTrade);
                                break;
                            end
                        end
                    end
                end
            end
            %end of trade valuation loop
            closedt = thisTrade.closedatetime1_;
            if ~isempty(closedt)
                nexttrade_idx = find(opendtvec_i > closedt,1,'first');
                if ~isempty(nexttrade_idx)
                    thisTrade = trades_i.node_(nexttrade_idx).copy;
                    idx = find(ei_i.px(:,1) >= opendtvec_i(nexttrade_idx),1,'first');
                else
                    idx = nbars_i + 1;
                end
            else
                idx = j + 1;
            end
        end
    tradesempirical{i,1} = tradesempirical_i;
    end

    stratempirical = {};
    tableempirical = {};
end