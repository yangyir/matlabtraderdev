function signals = gensignals_futmultiwrplusbatman_sunq(obj)
%     error('cStratFutMultiWRPlusBatman:gensignals_futmultiwrplusbatman not implemented')
    
    signals = cell(size(obj.count,1),1);
    instruments = obj.instruments_.getinstrument;

    for i = 1:obj.count
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti), obj.wr_(i) = ti(end); end
        %
        highestpx = obj.gethighnperiods(instruments{i});
        lowestpx = obj.getlownperiods(instruments{i});

        if highestpx > obj.highnperiods_(i) || lowestpx < obj.lownperiods_(i)
            signals{i,1} = struct('instrument',instruments{i},...
                'checkflag',1,...
                'highprice',highestpx,'lowprice',lowestpx);
            if highestpx > obj.highnperiods_(i)
                obj.highnperiods_(i) = highestpx;
            end
            if lowestpx < obj.lownperiods_(i)
                obj.lownperiods_(i) = lowestpx;
            end
            return 
        end
      
        signals{i,1} = struct('instrument',instruments{i},...
                'checkflag',0,...
                'highprice',-9.99,'lowprice',-9.99);
    end
    
end