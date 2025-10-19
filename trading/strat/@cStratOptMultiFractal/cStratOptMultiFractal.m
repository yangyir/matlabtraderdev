classdef cStratOptMultiFractal < cStrat
    events
        DummyTradeOpen
        DummyTradeClose
    end
    
    properties
        call_@char
        put_@char
    end
    
    properties
        %technical variables
        hh_@double                                                            %highest high
        ll_@double                                                            %lowest low
        jaw_@double                                                           %alligator's jaw
        teeth_@double                                                         %alligator's teeth
        lips_@double                                                          %alligator's lips
        bs_@double                                                            %TDST Buy Setup 
        ss_@double                                                            %TDST Sell Setup
        bc_@double                                                            %TDST Buy Countdown
        sc_@double                                                            %TDST Sell Countdown
        lvlup_@double                                                         %TDST Resistence,i.e.highest of a buy sequential
        lvldn_@double                                                         %TDST Support,i.e.lowest of a sell sequential
        wad_@double                                                           %Williams' acculate/distribute
        %
        signals_@cell
        %
        tbl_all_intraday_@struct
        %
        tbl_all_daily_@struct
        
    end
    
    methods
        function obj = cStratOptMultiFractal
            obj.name_ = 'multifractalopt';
        end
        %
    end
    
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_optmultifractal;
        end
        
        function signals = gensignalssingle(obj,varargin)
            variablenotused(obj);
        end
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_optmultifractal(signals);
        end
        %
        function [] = autoplacenewentrustssingle(obj,varargin)
            variablenotused(obj);
        end
         
        function [] = updategreeks(obj)
            obj.updategreeks_optmultifractal;
        end
        %
        function [] = riskmanagement(obj,dtnum)
            riskmanagement@cStrat(obj,dtnum)
        end
        %
        function [] = initdata(obj)
            obj.initdata_optmultifractal;
        end

    end
    
    methods
        [] = registerinstrument(obj,instrument)
        [] = OnDummyTradeOpen(obj,~,eventData);
        [] = OnDummyTradeClose(obj,~,eventData);
        %
        [] = load_kelly_intraday(obj,varargin)
    end
    
    methods (Access = private)
        signals = gensignals_optmultifractal(obj)
        [] = autoplacenewentrusts_optmultifractal(obj,signals)
        [] = updategreeks_optmultifractal(obj)
        [] = riskmanagement_optmultifractal(obj,dtnum)
        [] = initdata_optmultifractal(obj)
        %
        [techvar,techvarstruct] = calctechnicalvariable(obj,varargin)
        [] = processcondentrust(obj,varargin)
    end
    
end

