classdef cStratOptMultiFractal < cStrat
    %CSTRATOPTMULTIFRACTAL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hh_@cell                                                            %highest high
        ll_@cell                                                            %lowest low
        jaw_@cell                                                           %alligator's jaw
        teeth_@cell                                                         %alligator's teeth
        lips_@cell                                                          %alligator's lips
        bs_@cell                                                            %TDST Buy Setup 
        ss_@cell                                                            %TDST Sell Setup
        bc_@cell                                                            %TDST Buy Countdown
        sc_@cell                                                            %TDST Sell Countdown
        lvlup_@cell                                                         %TDST Resistence,i.e.highest of a buy sequential
        lvldn_@cell                                                         %TDST Support,i.e.lowest of a sell sequential
        wad_@cell                                                           %Williams' acculate/distribute
        %
        signals_@cell
        %
        kellytable_@struct
        
    end
    
    methods
        function obj = cStratOptMultiFractal
            obj.name_ = 'multifractalusingoption';
        end
        %
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = loadkellytable(obj,varargin)
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_optmultifractal;
        end
        %
        
        signals = gensignalssingle(obj,varargin)
        
        %
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_optmultifractal(signals);
        end
        %
        
        [] = autoplacenewentrustssingle(obj,varargin)
        
        %
        function [] = updategreeks(obj)
            obj.updategreeks_optmultifractal;
        end
        %
        function [] = riskmanagement(obj,dtnum)
            obj.riskmanagement_optmultifractal(dtnum);
        end
        %
        function [] = initdata(obj)
            obj.initdata_optmultifractal;
        end
        % 
    end
    
    methods (Access = private)
        signals = gensignals_optmultifractal(obj)
        [] = autoplacenewentrusts_optmultifractal(obj,signals)
        [] = updategreeks_optmultifractal(obj)
        [] = riskmanagement_optmultifractal(obj,dtnum)
        [] = initdata_optmultifractal(obj)
    end
    
end

