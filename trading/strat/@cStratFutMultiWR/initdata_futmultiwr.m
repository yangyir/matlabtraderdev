function [] = initdata_futmultiwr(obj)
%cStratFutMultiWR

    instruments = obj.getinstruments;
    for i = 1:obj.count
        try
            samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
        catch
            samplefreqstr = '5m';
        end

        samplefreqnum = str2double(samplefreqstr(1:end-1));

        if samplefreqnum == 1
            nbdays = 1;
        elseif samplefreqnum == 3
            nbdays = 3;
        elseif samplefreqnum == 5
            nbdays = 5;
        elseif samplefreqnum == 15
            nbdays = 10;
        else
            error('ERROR:%s:initdata_futmultiwr:unsupported sample freq %s of %s',class(obj),samplefreqstr,instruments{i}.code_ctp)
        end
        
        obj.mde_fut_.initcandles(instruments{i},'NumberofPeriods',nbdays);
        
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i},'includeextraresults',true);
        if ~isempty(ti)
            obj.wr_(i) = ti{1}(1);
            wrmode = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrmode');
            if strcmpi(wrmode,'flashma')
                lead = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrmalead');
                lag = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrmalag');
                if abs(lead+9.99) > 1e-5 && abs(lag+9.99) > 1e-5
                    wrseries = ti{2};
                    [short,long] = movavg(wrseries,lead,lag,'e');
                    obj.wrmashort_(i) = short(end);
                    obj.wrmalong_(i) = long(end);
                end
            end
        end
        %
        obj.maxnperiods_(i) = obj.getmaxnperiods(instruments{i});
        obj.minnperiods_(i) = obj.getminnperiods(instruments{i});
    end
    
    
end