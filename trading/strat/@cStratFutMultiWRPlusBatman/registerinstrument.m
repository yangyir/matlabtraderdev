function [] = registerinstrument(obj,instrument)
    if ~(ischar(instrument) || isa(instrument,'cInstrument'))
        error('cStratFutMultiWRPlusBatman:registerinstrument:invalid data type of instrument')
    end
    %registerinstrument of superclass
    registerinstrument@cStrat(obj,instrument);
    
    %nperiods_
    default_nperiods_ = 144;
    if isempty(obj.nperiods_)
        obj.nperiods_ = default_nperiods_*ones(obj.count,1); 
        params = struct('numofperiods',default_nperiods_);
        obj.setparameters(instrument,params);
    else
        if size(obj.nperiods_,1) < obj.count
            obj.nperiods_ = [obj.nperiods_;default_nperiods_];
            params = struct('numofperiods',default_nperiods_);
            obj.setparameters(instrument,params);
        end
    end

    %samplefreq_
    default_samplefreq_ = 1;
    if isempty(obj.samplefreq_)
        obj.samplefreq_ = default_samplefreq_*ones(obj.count,1);
        obj.setsamplefreq(instrument,default_samplefreq_);
    else
        if size(obj.samplefreq_,1) < obj.count
            obj.samplefreq_ = [obj.samplefreq_;default_samplefreq_];
            obj.setsamplefreq(instrument,default_samplefreq_);
        end
    end

    %overbought_
    default_overbought_ = 0;
    if isempty(obj.overbought_)
        obj.overbought_ = default_overbought_*ones(obj.count,1);
    else
        if size(obj.overbought_,1) < obj.count
            obj.overbought_ = [obj.overbought_;default_overbought_];
        end
    end

    %oversold_
    default_oversold_ = -100;
    if isempty(obj.oversold_)
        obj.oversold_ = default_oversold_*ones(obj.count,1);
    else
        if size(obj.oversold_,1) < obj.count
            obj.oversold_ = [obj.oversold_;default_oversold_];
        end
    end

    %william %r
    if isempty(obj.wr_)
        obj.wr_ = NaN(obj.count,1);
    else
        if size(obj.wr_,1) < obj.count
            obj.wr_ = [obj.wr_;NaN];
        end
    end
    
    %highest of nperiods
    if isempty(obj.highnperiods_)
        obj.highnperiods_ = NaN(obj.count,1);
    else
        if size(obj.highnperiods_,1) < obj.count
            obj.highnperiods_ = [obj.highnperiods_;NaN];
        end
    end
    
    %lowest of nperiods
    if isempty(obj.lownperiods_)
        obj.lownperiods_ = NaN(obj.count,1);
    else
        if size(obj.lownperiods_,1) < obj.count
            obj.lownperiods_ = [obj.lownperiods_;NaN];
        end
    end
    
    %bandwidthmin_
    if isempty(obj.bandwidthmin_)
        obj.bandwidthmin_ = ones(obj.count,1)/3;
    else
        if size(obj.bandwidthmin_,1) < obj.count
            obj.bandwidthmin_ = [obj.bandwidthmin_;1/3];
        end
    end
    
    %bandwidthmax_
    if isempty(obj.bandwidthmax_)
        obj.bandwidthmax_ = ones(obj.count,1)/2;
    else
        if size(obj.bandwidthmax_,1) < obj.count
            obj.bandwidthmax_ = [obj.bandwidthmax_;1/2];
        end
    end
    
    %bandstoploss_
    if isempty(obj.bandstoploss_)
        obj.bandstoploss_ = 0.01*ones(obj.count,1);
    else
        if size(obj.bandstoploss_,1) < obj.count
            obj.bandstoploss_ = [obj.bandstoploss_;0.01];
        end
    end
    
    %bandtarget_
    if isempty(obj.bandtarget_)
        obj.bandtarget_ = 0.01*ones(obj.count,1);
    else
        if size(obj.bandtarget_,1) < obj.count
            obj.bandtarget_ = [obj.bandtarget_;0.01];
        end
    end
    
    %bandtype_
    if isempty(obj.bandtype_)
        obj.bandtype_ = zeros(obj.count,1);
    else
        if size(obj.bandtype_,1) < obj.count
            obj.bandtype_ = [obj.bandtype_;0];
        end
    end
    
end