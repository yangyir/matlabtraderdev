classdef cTraderMaster < handle
    %class of a master trader who can have access to multiple trading
    %accounts and link 
    properties
        mdefut_@cMDEFut
        mdeopt_@cMDEOpt
        counterfut_@CounterCTP
        counteropt1_@CounterCTP
        counteropt2_@CounterCTP
    end
    
    properties (Hidden = true)
        qms_@cQMS
    end
    
    methods
        %constructor
        function obj = cTraderMaster
            obj = init(obj);
        end
    end
    
    methods
        %counter utilities
        ret = counterlogoff(obj,logoffstr)
        ret = counterlogin(obj,loginstr)
        ret = mdlogin(obj)
        ret = querycounters(obj,querystr)
        ret = querycountertrades(obj,querystr)
    end
    
        
        
        
    
    methods (Access = private)
        obj = init(obj)
        ret = querycounter(obj,querystr)
        ret = querytrades(obj,querystr)
    end
end