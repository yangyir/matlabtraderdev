classdef cStratFutMultiFractal < cStrat
    properties
        %technical variables
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
        targetportfolio_@double
        %
        displaysignalonly_@logical = false
        %
        tbl_all_intraday_@cell
        tbl_tc_intraday_@cell
        tbl_tb_intraday_@cell
        tbl_exotics_intraday_@cell
        %
        tbl_all_daily_@cell
        tbl_tc_daily_@cell
        tbl_tb_daily_@cell
        tbl_exotics_daily_@cell
        
    end
    
    methods
        function obj = cStratFutMultiFractal
            obj.name_ = 'multifractal';
            obj.load_kelly_intraday;
            obj.load_kelly_daily;
        end
    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = printinfo(obj)
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            if ~obj.displaysignalonly_
                signals = obj.gensignals_futmultifractal1;
            else
                signals = obj.gensignals_futmultifractal2;
            end
        end
        
        function [] = autoplacenewentrusts(obj,signals)
            if obj.displaysignalonly_, return;end
            obj.autoplacenewentrusts_futmultifractal(signals)
        end
        
        function [] = updategreeks(obj)
            variablenotused(obj);
        end
        
        function [] = riskmanagement(obj,dtnum)
            if obj.displaysignalonly_, return;end
            riskmanagement@cStrat(obj,dtnum)
        end
        
        function [] = initdata(obj)
            obj.initdata_futmultifractal;
        end
    end
    
    methods (Access = private)
        signals = gensignals_futmultifractal1(obj)
        signals = gensignals_futmultifractal2(obj)
        [] = autoplacenewentrusts_futmultifractal(obj,signals)
        [] = initdata_futmultifractal(obj)
        [] = riskmanagement_futmultifractal(obj,dtnum)
        %
        [techvar] = calctechnicalvariable(obj,instrument,varargin)
        [] = processcondentrust(obj, instrument, varargin)
        signals = gencondsignals__futmultifractal(obj, instrument, varargin)
        %
        [] = load_kelly_intraday(obj,varargin)
        [] = load_kelly_daily(obj,varargin)
    end
end