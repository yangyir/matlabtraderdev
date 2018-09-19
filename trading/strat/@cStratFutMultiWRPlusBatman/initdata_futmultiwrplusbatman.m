function [] = initdata_futmultiwrplusbatman(obj)
   
    instruments = obj.getinstruments;
    for i = 1:obj.count
        samplefreq = obj.getsamplefreq(instruments{i});
        
        if samplefreq == 1
            nbdays = 1;
        elseif samplefreq == 3
            nbdays = 3;
        elseif samplefreq == 5
            nbdays = 5;
        elseif samplefreq == 15
            nbdays = 10;
        end
        obj.mde_fut_.initcandles(instruments{i},'NumberofPeriods',nbdays);
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti)
            obj.wr_(i) = ti(end);
        end
        obj.highnperiods_(i) = obj.gethighnperiods(instruments{i});
        obj.lownperiods_(i) = obj.getlownperiods(instruments{i});
    end
    
    
end