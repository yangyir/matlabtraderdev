function signals = gensignals_futmultiwrplusbatman(obj)
%     error('cStratFutMultiWRPlusBatman:gensignals_futmultiwrplusbatman not implemented')
    
    signals = cell(size(obj.count,1),1);
    instruments = obj.instruments_.getinstrument;

    for i = 1:obj.count
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti), obj.wr_(i) = ti(end); end
        %
        highestpx = obj.gethighnperiods(instruments{i});
        lowestpx = obj.getlownperiods(instruments{i});
        if highestpx > obj.highnperiods_(i)
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',-1,...
                'price',highestpx);
            obj.highnperiods_(i) = highestpx;
            return
        end
        
        if lowestpx < obj.lownperiods_(i)
            signals{i,1} = struct('instrument',instruments{i},...
                'direction',1,...
                'price',lowestpx);
            obj.lownperiods_(i) = lowestpx;
            return
        end
        
        signals{i,1} = struct('instrument',instruments{i},...
                'direction',0,...
                'price',-9.99);
        
    end
    
end