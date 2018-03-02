classdef cTraderMaster < handle
    %class of a master trader who can have access to multiple trading
    %accounts and link 
    properties
        mdefut_@cMDEFut
        mdeopt_@cMDEOpt
        counterfut_@CounterCTP
        counteropt1_@CounterCTP
        counteropt2_@CounterCTP
        instruments_@cInstrumentArray
        portfut_@cPortfolio
        portopt1_@cPortfolio
        portopt2_@cPortfolio
        
    end
        
    properties (Hidden = true)
        qms_@cQMS
    end
    
    methods
        %constructor
        function obj = cTraderMaster
            obj = init(obj);
        end
        
        ret = registerinstruments(obj,instrumentstr)
        
    end
    
    %login/logoff
    methods
        ret = counterlogoff(obj,logoffstr)
        ret = counterlogin(obj,loginstr)
        ret = mdlogin(obj)
        
        function ret = mdlogoff(obj)
            variablenotused(obj);
            mdlogout;
            ret = 1;
        end
        
    end
    
    %query account info
    methods
        ret = queryaccounts(obj,counterstr)
        ret = querytrades(obj,counterstr)
    end
    
    %market data related
    methods
        
        
        qs = getquotes(obj)
        tbl = voltable(obj)
    end    
    
    methods (Access = private)
        %initiate the trader object
        obj = init(obj)
        
        ret = queryaccount(obj,counterstr)
        
        ret = registerinstrument(obj,instrument)
    end
end