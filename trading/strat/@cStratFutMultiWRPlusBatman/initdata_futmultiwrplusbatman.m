function [] = initdata_futmultiwrplusbatman(obj)
   
    instruments = obj.getinstruments;
    for i = 1:obj.count
        try
            samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
        catch
            samplefreqstr = '5m';
        end

%         samplefreq = obj.getsamplefreq(instruments{i});
        samplefreq = str2double(samplefreqstr(1:end-1));

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
            obj.wr_(i) = ti{i}(1);
        end
        obj.highnperiods_(i) = obj.gethighnperiods(instruments{i});
        obj.lownperiods_(i) = obj.getlownperiods(instruments{i});
    end
    
    
end