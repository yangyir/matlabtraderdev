function signals = gensignals_futmultiwrplusbatman(obj)
%note:both the highest high price and lowest low price for the given length
%of period are computed for all the registered instrument. If either the
%highest high price or the lowest low price changes, we replace it/them
%with the lastest one
    signals = cell(size(obj.count,1),1);
    instruments = obj.instruments_.getinstrument;

    for i = 1:obj.count
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti), obj.wr_(i) = ti(end); end
        %
        %note;here we are inline with the backtesting process, i.e. we
        %exclude the last candle stick, which might not be fully feeded
        %yet, to compute the highest high and lowest low
        highestpx_last = obj.gethighnperiods(instruments{i});
        lowestpx_last = obj.getlownperiods(instruments{i});
        
        firstH = false;
        if isempty(obj.highnperiods_(i)) || isnan(obj.highnperiods_(i))
            obj.highnperiods_(i) = highestpx_last;
            firstH = true;
        end
        
        firstL = false;
        if isempty(obj.lownperiods_(i)) || isnan(obj.lownperiods_(i))
            obj.lownperiods_(i) = lowestpx_last;
            firstL = true;
        end
        
        highestpx_before = obj.highnperiods_(i);
        if highestpx_last > highestpx_before, obj.highnperiods_(i) = highestpx_last;end
        
        lowestpx_before = obj.lownperiods_(i);
        if lowestpx_last < lowestpx_before, obj.lownperiods_(i) = lowestpx_last;end       
        
        %note:first time set highest and lowest
        if firstH || firstL
            signals{i,1} = struct('instrument',instruments{i},...
                'checkflag',1,...
                'highestprice',highestpx_last,...
                'lowestprice',lowestpx_last);
            continue;
        end
        
        %note:first time set entrusts
        n = obj.helper_.entrusts_.latest;
        if n == 0
            signals{i,1} = struct('instrument',instruments{i},...
                'checkflag',1,...
                'highestprice',highestpx_last,...
                'lowestprice',lowestpx_last);
            continue;    
        end
        
        if highestpx_last > highestpx_before || lowestpx_last < lowestpx_before
            signals{i,1} = struct('instrument',instruments{i},...
                'checkflag',1,...
                'highestprice',highestpx_last,...
                'lowestprice',lowestpx_last);
            continue; 
        end
        
        signals{i,1} = {};
                               
    end
    
end