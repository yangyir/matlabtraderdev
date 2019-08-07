classdef cTDSQInfo < cSignalInfo
    properties
        scenario_@char
        mode_@char = 'reverse'
    end
    
    methods
        function obj = cTDSQInfo
            obj.name_ = 'tdsq';
        end
        
        function [] = set.scenario_(obj,val)
            %todo:some variable controls
            obj.scenario_ = val;
        end
        
        function [] = set.mode_(obj,val)
            if strcmpi(val,'reverse') || strcmpi(val,'follow')
                obj.mode_ = val;
            else
                error('cTDSQInfo:invalid mode_ input')
            end
        end
    end
end