function signals = gensignals_futmultiwr(strategy)
    if strcmpi(strategy.mode_,'debug'),
        strategy.printinfo;
        fprintf('holdings:%4.0f\tclose pnl:%4.2f\trunning pnl:%4.2f\n',...
            strategy.portfolio_.instrument_volume(1),...
            strategy.pnl_close_(1),...
            strategy.pnl_running_(1));
    end

    signals = cell(size(strategy.count,1),1);
    instruments = strategy.instruments_.getinstrument;

    for i = 1:strategy.count
        ti = strategy.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti)
            strategy.wr_(i) = ti(end);
        end
        if strategy.wr_(i) <= strategy.oversold_(i)
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',1);
        elseif strategy.wr_(i) >= strategy.overbought_(i)
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',-1);
        else
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',0);
        end
    end
end
%end of gensignals_futmultiwr