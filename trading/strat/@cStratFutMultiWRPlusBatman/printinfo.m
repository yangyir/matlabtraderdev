function [] = printinfo(obj)
    instruments = obj.getinstruments;
    for i = 1:obj.count
        ticks = obj.mde_fut_.getlasttick(instruments{i});
        if ~isempty(ticks)
            t = ticks(1);
            fprintf('%s %6s: trade:%6s; wlpr:%5.1f; lowest:%6s; highest:%6s\n',...
                datestr(t,'yyyy-mm-dd HH:MM:SS'),instruments{i}.code_ctp,...
                num2str(ticks(4)),obj.wr_(i),...
                num2str(obj.lownperiods_(i)),...
                num2str(obj.highnperiods_(i)));
        else
            candlecount = obj.mde_fut_.getcandlecount(instruments{i});
            if candlecount ~= 0
                candles = obj.mde_fut_.getlastcandle(instruments{i});
                candles = candles{1};
            else
                candles = obj.mde_fut_.gethistcandles(instruments{i});
                candles = candles{1};
            end
            t = candles(end,1);
            fprintf('%s %6s: trade:%6s; wlpr:%5.1f; lowest:%6s; highest:%6s\n',...
                datestr(t,'yyyy-mm-dd HH:MM:SS'),instruments{i}.code_ctp,...
                num2str(candles(end,5)),obj.wr_(i),...
                num2str(obj.lownperiods_(i)),...
                num2str(obj.highnperiods_(i)));
        end
    end
    fprintf('\n');
end
%end of printinfo