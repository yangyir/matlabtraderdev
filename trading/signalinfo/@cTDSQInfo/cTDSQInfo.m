classdef cTDSQInfo < cSignalInfo
    properties
        scenario_@char
    end
    
    methods
        function obj = cTDSQInfo
            obj.name_ = 'TDSQ';
        end
        
        function [] = set.scenario_(obj,val)
            %todo:some variable controls
            obj.scenario_ = val;
        end
    end
end