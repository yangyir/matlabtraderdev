function [tableout,tradesout] = run_trades_best(obj,varargin)
% a cFORM private methods
% to run (backtest) the trades with the best open price
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('DateFrom','',@ischar);
    p.addParameter('DateTo','',@ischar);
    
    p.parse(varargin{:});
    
    dt1str = p.Results.DateFrom;
    dt2str = p.Results.DateTo;

    if ~isempty(dt1str)
        dt1num = datenum([dt1str,' 00:00:00'],'yyyy-mm-dd HH:MM:SS');
    else
        dt1num = [];
    end

    if ~isempty(dt2str)
        dt2num = datenum([dt2str,' 23:59:59'],'yyyy-mm-dd HH:MM:SS');
    else
        dt2num = [];
    end

    ncodes = length(obj.codes_);

    tradesout = cell(ncodes,1);
    for i = 1:ncodes
        tradesout{i} = cTradeOpenArray;
        trades_best_i = obj.trades_best_{i};
        ntrades_i = trades_best_i.latest_;
        for j = 1:ntrades_i
            trade_ij = trades_best_i.node_(j);
            use_ij = 1;
            if ~isempty(dt1num) && trade_ij.opendatetime1_ < dt1num
                use_ij = 0;
            end
            if ~isempty(dt2num) && trade_ij.opendatetime1_ >= dt2num
                use_ij = 0;
            end
            if ~use_ij, continue;end
            tradenew_ij = trade_ij.copy;
            tradesout{i}.push(tradenew_ij);
        end
    end

    ei_ = obj.ei_signal_;
    tableout = cell(ncodes,1);

    parfor i = 1:ncodes
        ntrades = tradesout{i}.latest_;
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

        nbars = size(ei_{i}.px,1);

        for itrade = 1:ntrades
            this_trade = tradesout{i}.node_(itrade);
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
            end
            tradername{itrade} = this_trade.tradername_;
            countername{itrade} = this_trade.countername_;

            if this_trade.opendirection_ == 1
                barrierfractal(itrade) = this_trade.opensignal_.hh_;
            elseif this_trade.opendirection_ == -1
                barrierfractal(itrade) = this_trade.opensignal_.ll_;
            end

            checkstartidx = find(ei_{i}.px(:,1) >= this_trade.opendatetime1_,1,'first');

            for k = checkstartidx:nbars
                extrainfo = fractal_truncate(ei_{i},k);
                extrainfo.latestopen = extrainfo.px(end,5);
                extrainfo.latestdt = extrainfo.px(end,1);
                ut = this_trade.riskmanager_.riskmanagementwithcandle([],...
                    'usecandlelastonly',false,...
                    'updatepnlforclosedtrade',true,...
                    'extrainfo',extrainfo);
                if ~isempty(ut)
                    closeprice(itrade) = this_trade.closeprice_;
                    closepnl(itrade) = this_trade.closepnl_;
                    pnlrel(itrade) = direction(itrade) * (closeprice(itrade)/openprice(itrade)-1);
                    closestr{itrade} = this_trade.closestr_;
                    closedatetime{itrade} = datestr(this_trade.closedatetime1_,'yyyy-mm-dd HH:MM');
                    break
                else
                    if k == nbars
                        closeprice(itrade) = extrainfo.px(end,5);
                        closepnl(itrade) = this_trade.runningpnl_;
                        pnlrel(itrade) = direction(itrade) * (closeprice(itrade)/openprice(itrade)-1);
                        closestr{itrade} = 'still live but time series reached';
                        closedatetime{itrade} = datestr(extrainfo.px(end,1),'yyyy-mm-dd HH:MM');
                    end
                end
            end
        end

        tableout{i} = table(code,direction,opendatetime,openprice,closedatetime,closeprice,opensignal,closestr,closepnl,pnlrel,opennotial,tradername,countername,barrierfractal);
    end
 
end