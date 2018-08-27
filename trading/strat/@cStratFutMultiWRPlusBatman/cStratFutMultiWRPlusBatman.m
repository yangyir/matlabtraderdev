classdef cStratFutMultiWRPlusBatman < cStrat
    properties
        % signal related
        nperiods_@double
        samplefreq_@double
        overbought_@double          %legacy property which is not used anymore
        oversold_@double            %legacy property which is not used anymore
        wr_@double                  %william%R
        highnperiods_@double
        lownperiods_@double
        %
        % riskmanagement related
        % batman-specified
        bandwidthmin_@double
        bandwidthmax_@double
        bandstoploss_@double
        bandtarget_@double
        bandtype_@double    %0:normal 1:option
        
    end
    
    methods
        function obj = cStratFutMultiWRPlusBatman
            obj.name_ = 'stratfutwrbatman';
        end
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = setparameters(obj,instrument,params)
        [] = setsamplefreq(obj,instrument,freq)
        freq = getsamplefreq(obj,instrument)
        [] = setboundary(obj,instrument,overbought,oversold)
        [overbought,oversold] = getboundary(obj,instrument)
        [wr,wrts] = getlastwr(obj,instrument)
        [highp,hight] = gethighnperiods(obj,instrument)
        [lowp,lowt] = getlownperiods(obj,instrument)
        [] = setbandwidthmin(obj,instrument,vin)
        vout = getbandwidthmin(obj,instrument)
        [] = setbandwidthmax(obj,instrument,vin)
        vout = getbandwidthmax(obj,instrument)
        [] = setbandstoploss(obj,instrument,vin)
        vout = getbandstoploss(obj,instrument)
        [] = setbandtarget(obj,instrument,vin)
        vout = getbandtarget(obj,instrument)
        [] = setbandtype(obj,instrument,vin)
        vout = getbandtype(obj,instrument)
        
        %
        [] = printinfo(obj)
        [] = readparametersfromtxtfile(obj,fn)
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futmultiwrplusbatman;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futmultiwrplusbatman(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futmultiwrplusbatman
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_futmultiwrplusbatman(dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futmultiwrplusbatman;
        end
        %end of initdata
                
    end
    
    methods (Access = private)
        [] = riskmanagement_futmultiwrplusbatman(obj,dtnum)
        [] = riskmanagement_futmultiwrplusbatman_sunq(obj,dtnum)
        [] = updategreeks_futmultiwrplusbatman(obj)
        signals = gensignals_futmultiwrplusbatman(obj)
        signals = gensignals_futmultiwrplusbatman_sunq(obj)
        [] = autoplacenewentrusts_futmultiwrplusbatman(obj,signals)
        [] = autoplacenewentrusts_futmultiwrplusbatman_sunq(obj,signals)
        [] = initdata_futmultiwrplusbatman(obj)
    end
    

end