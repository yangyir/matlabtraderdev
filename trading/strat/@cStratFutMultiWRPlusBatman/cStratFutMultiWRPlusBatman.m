classdef cStratFutMultiWRPlusBatman < cStrat
    properties
        nperiods_@double
        samplefreq_@double
        overbought_@double
        oversold_@double
        wr_@double                  %william%R
        highnperiods_@double
        lownperiods_@double
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
        [] = printinfo(obj)
        [] = readparametersfromtxtfile(obj,fn)
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futmultiwrplusbatman;
%             signals = obj.gensignals_futmultiwrplusbatman_sunq;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futmultiwrplusbatman(signals)
%             obj.autoplacenewentrusts_futmultiwrplusbatman_sunq(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futmultiwrplusbatman
        end
            
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_futmultiwrplusbatman(dtnum)
%             obj.riskmanagement_futmultiwrplusbatman_sunq(dtnum)
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