classdef cFORM < handle
    % Fractal Organization & Risk-adjusted Morphology
    % Focues on strcutural regime dectection and risk-managed alpha
    % execution
    
    properties
        codes_
        signal_freq_
        ei_signal_
        ei_special_
    end
    
    properties (Access = private)
        include_tdsqlvl_ = 0
        include_tdsqhv_ = 0
        use_mt5_ = 1
        instruments_
        %
        %
        trades_best_
        condsignals_empirical_
        trades_empirical_

    end
    
    methods
        function obj = cFORM(varargin)
            obj = init_form(obj,varargin{:});
        end
    end
    
    methods
        % best open price
        [stratbest,tablebest,tradesbest] = kellybest(obj,varargin)
        [tradesout] = gettradesbest(obj,varargin)
        [tradeout] = runsingletradebest(obj,tradein,varargin)
        
        % empirical study
        [stratempirical,tableempirical,tradesempirical] = kellyempirical(obj,varargin)
        [tradesout] = gettradesempirical(obj,varargin)
        [qfail,tableoutput] = calcqfail(obj)
        [tableoutput] = makedecisionscenario2(obj)
    end
    
    % some of class utility functions
    methods
        
        
        [flag,idx] = hascode(obj,code)
    end

    % static methods to conduct statistical analysis
    methods (Static)
        
    end
    
    methods (Access = private)
        obj = init_form(obj,varargin)
        [] = gen_trades_best(obj)
        [] = gen_condsignals_empirical(obj,varargin)
        [] = gen_trades_empirical(obj,varargin)
        [tradeout] = gen_trade_empirical(obj,varargin)
        [tradestable,tradesarrayout] = run_trades_best(obj,varargin)
    end
end