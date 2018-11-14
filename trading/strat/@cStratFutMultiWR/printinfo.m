function [] = printinfo(strategy)
    instruments = strategy.getinstruments;
    for i = 1:strategy.count
        ticks = strategy.mde_fut_.getlasttick(instruments{i});
        if ~isempty(ticks)
            t = ticks(1);
            fprintf('%s %s: trade:%4.1f; williamr:%4.1f\n',...
                datestr(t,'yyyy-mm-dd HH:MM:SS'),instruments{i}.code_ctp,ticks(4),strategy.wr_(i));
        else
            candlecount = strategy.mde_fut_.getcandlecount(instruments{i});
            if candlecount ~= 0
                candles = strategy.mde_fut_.getlastcandle(instruments{i});
                candles = candles{1};
            else
                candles = strategy.mde_fut_.gethistcandles(instruments{i});
            end
            t = candles{1}(end,1);
            fprintf('%s %s: trade:%4.1f; williamr:%4.1f\n',...
                datestr(t,'yyyy-mm-dd HH:MM:SS'),instruments{i}.code_ctp,candles{1}(end,5),strategy.wr_(i));
        end
    end
    fprintf('\n');
end
%end of printinfo