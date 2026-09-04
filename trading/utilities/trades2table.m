function [tableout] = trades2table(tradesin,ei)
    if nargin < 2
        ei = {};
    end


    ntrades = tradesin.latest_;
    code = cell(ntrades,1);
    direction = zeros(ntrades,1);
    opendatetime = cell(ntrades,1);
    openprice = zeros(ntrades,1);
    closedatetime = cell(ntrades,1);
    closeprice = zeros(ntrades,1);
    opensignal = cell(ntrades,1);
    closestr = cell(ntrades,1);
    closepnl = zeros(ntrades,1);
    pnlrel = zeros(ntrades,1);
    opennotial = zeros(ntrades,1);
    tradername = cell(ntrades,1);
    countername = cell(ntrades,1);
    barrierfractal = zeros(ntrades,1);
    scenarioinfo = zeros(ntrades,1);

    for itrade = 1:ntrades
        this_trade = tradesin.node_(itrade);
        code{itrade} = this_trade.code_;
        direction(itrade) = this_trade.opendirection_;
        opendatetime{itrade} = datestr(this_trade.opendatetime1_,'yyyy-mm-dd HH:MM');
        openprice(itrade) = this_trade.openprice_;
        opensignal{itrade} = this_trade.opensignal_.mode_;
        if strcmpi(this_trade.code_,'audusd') || strcmpi(this_trade.code_,'eurusd') || strcmpi(this_trade.code_,'gbpusd')
            opennotial(itrade) = openprice(itrade)*1e5;
        elseif strcmpi(this_trade.code_,'usdcad') || strcmpi(this_trade.code_,'usdchf') || strcmpi(this_trade.code_,'usdjpy')
            opennotial(itrade) = 1e5;
        elseif strcmpi(this_trade.code_,'xauusd')
            opennotial(itrade) = openprice(itrade)* 100;
        else
            opennotial(itrade) = openprice(itrade);
        end
        tradername{itrade} = this_trade.tradername_;
        countername{itrade} = this_trade.countername_;

        if this_trade.opendirection_ == 1
            barrierfractal(itrade) = this_trade.opensignal_.hh_;
        elseif this_trade.opendirection_ == -1
            barrierfractal(itrade) = this_trade.opensignal_.ll_;
        end
        closeprice(itrade) = this_trade.closeprice_;
        closestr{itrade} = this_trade.closestr_;
        closepnl(itrade) = this_trade.closepnl_;
        closedatetime{itrade} = datestr(this_trade.closedatetime1_,'yyyy-mm-dd HH:MM');
        pnlrel(itrade) = direction(itrade) * (closeprice(itrade)/openprice(itrade)-1);
        
        if ~isempty(ei)
            idx = find(ei.px(:,1) >= this_trade.opendatetime1_,1,'first');
            lfclose = ei.px(idx,5);
            if direction(itrade) == 1
                confirmed = lfclose - this_trade.opensignal_.hh_ - this_trade.instrument_.tick_size > -1e-6;
            elseif direction(itrade) == -1
                confirmed = lfclose - this_trade.opensignal_.ll_ + this_trade.instrument_.tick_size < 1e-6;
            else
                error('invalid trade:long/short only...')
            end
            if confirmed
                scenarioinfo(itrade) = 1;
            else
                scenarioinfo(itrade) = 2;
            end
        end
        
    end

    tableout = table(code,direction,opendatetime,openprice,closedatetime,closeprice,opensignal,closestr,closepnl,pnlrel,opennotial,tradername,countername,barrierfractal,scenarioinfo);
end