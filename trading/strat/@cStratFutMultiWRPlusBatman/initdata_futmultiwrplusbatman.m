function [] = initdata_futmultiwrplusbatman(obj)
   
    instruments = obj.getinstruments;
    for i = 1:obj.count
        if obj.samplefreq_(i) == 1
            nbdays = 1;
        elseif obj.samplefreq_(i) == 3
            nbdays = 3;
        elseif obj.samplefreq_(i) == 5
            nbdays = 5;
        elseif obj.samplefreq_(i) == 15
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