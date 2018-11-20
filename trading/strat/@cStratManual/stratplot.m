function [] = stratplot(obj,instrument,varargin)
%cStratManual
    if ~obj.usehistoricaldata_
        fprintf('%s:candelplot:invalid function call without historical data\n',class(obj));
        return
    end
    
    histcandles = obj.mde_fut_.gethistcandles(instrument);
    candlesticks = obj.mde_fut_.getcandles(instrument);
    if ~isempty(histcandles)
        histcandles = histcandles{1};
    else
        histcandles = [];
    end
    
    if ~isempty(candlesticks)
        candlesticks = candlesticks{1};
    else
        candlesticks = [];
    end
    
    if isempty(histcandles) && isempty(candlesticks)
        fprintf('%s:candelplot:invalid function call without data\n',class(obj));
        return
    elseif isempty(histcandles) && ~isempty(candlesticks)
        candle2plot = candlesticks;
    elseif ~isempty(histcandles) && isempty(candlesticks)
        candle2plot = histcandles;
    else
        candle2plot = [histcandles;candlesticks];
    end
    %remove candles with zero entries
    idx1 = candle2plot(:,2) ~= 0;
    idx2 = candle2plot(:,3) ~= 0;
    idx3 = candle2plot(:,4) ~= 0;
    idx4 = candle2plot(:,5) ~= 0;
    idx = idx1&idx2&idx3&idx4;
    candle2plot = candle2plot(idx,:);
    if ~isempty(candle2plot)
        samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instrument,'propname','samplefreq');
        h1 = subplot(211);
        candle(candle2plot(:,3),candle2plot(:,4),candle2plot(:,5),candle2plot(:,2),'b');
        grid on;
        date_format = 'dd/mmm HH:MM';
        n = size(candle2plot,1);
        nmax = ceil(n/25)*25;
        xgrid = 0:25:nmax;
        xgrid = xgrid';
        idx = xgrid < size(candle2plot,1);
        xgrid = xgrid(idx,:);
        t_num = zeros(1,length(xgrid));
        for i = 1:length(t_num)
            if xgrid(i) == 0
                t_num(i) = candle2plot(1,1);
            elseif xgrid(i) > size(candle2plot,1)
                t_start = candle2plot(1,1);
                t_last = candle2plot(end,1);
                t_num(i) = t_last + (xgrid(i)-size(candle2plot,1))*...
                    (t_last - t_start)/size(candle2plot,1);
            else
                t_num(i) = candle2plot(xgrid(i),1);
            end
        end
        if isempty(date_format)
            t_str = datestr(t_num);
        else
            t_str = datestr(t_num,date_format);
        end
%         axes = get(g,'CurrentAxes');
        set(h1,'XTick',xgrid);
        set(h1,'XTickLabel',t_str);
        title([samplefreqstr,'-candles of ',instrument]);
        %
        wlpr = willpctr(candle2plot(:,3),candle2plot(:,4),candle2plot(:,5),144);
        h2 = subplot(212);
        plot(wlpr,'r');
        grid on;
        set(h2,'XTick',xgrid);
        set(h2,'XTickLabel',t_str);
        hold on;
        plot(144*ones(101),-100:0,'b');
        hold off;
        title(['WiiliamR of ',instrument]);
        
    end
    
    
    
end