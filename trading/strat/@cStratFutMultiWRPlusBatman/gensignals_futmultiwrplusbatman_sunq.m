function signals = gensignals_futmultiwrplusbatman_sunq(obj)
%     error('cStratFutMultiWRPlusBatman:gensignals_futmultiwrplusbatman not implemented')
    
    signals = cell(size(obj.count,1),1);
    instruments = obj.instruments_.getinstrument;

    for i = 1:obj.count
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti)
            obj.wr_(i) = ti(end); 
        end
        %
        if obj.wr_(i) <= obj.oversold_(i)
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',1);
        elseif obj.wr_(i) >= obj.overbought_(i)
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',-1);
        else
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',0);
        end
    end
end
%end of gensignals_futmultiwr_sunq