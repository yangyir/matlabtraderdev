classdef cTDSQInfo < cSignalInfo
    properties
        scenario_@char
        mode_@char = 'unset'
        type_@char = 'unset'
        lvlup_@double
        lvldn_@double
        risklvl_@double
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
            if strcmpi(val,'reverse') || strcmpi(val,'trend') || strcmpi(val,'unset')
                obj.mode_ = val;
            else
                error('cTDSQInfo:invalid mode_ input')
            end
        end
        
        function [] = set.type_(obj,val)
            if strcmpi(val,'perfectbs') || ...
                    strcmpi(val,'semiperfectbs') || ...
                    strcmpi(val,'imperfectbs') || ...
                    strcmpi(val,'perfectss') || ...
                    strcmpi(val,'semiperfectss') || ...
                    strcmpi(val,'imperfectss') || ...
                    strcmpi(val,'single-lvldn') || ...
                    strcmpi(val,'single-lvlup') || ...
                    strcmpi(val,'double-range') || ...
                    strcmpi(val,'double-bullish') || ...
                    strcmpi(val,'double-bearish') || ...
                    strcmpi(val,'simpletrend') || ...
                    strcmpi(val,'unset')
                obj.type_ = val;
            else
               error('cTDSQInfo:invalid type input') 
            end
        end
        
    end
    
    methods (Static = true)
        function n = numofmode(~)
            n = 2;
        end
        
        function n = numoftype(~)
            n = 12;
        end
        
        function idx = gettypeidx(typein)
            switch typein
                case 'perfectbs'
                    idx = 1;
                case 'semiperfectbs'
                    idx = 2;
                case 'imperfectbs'
                    idx = 3;
                case 'perfectss'
                    idx = 4;
                case 'semiperfectss'
                    idx = 5;
                case 'imperfectss'
                    idx = 6;
                case 'single-lvldn'
                    idx = 7;
                case 'single-lvlup'
                    idx = 8;
                case 'double-range'
                    idx = 9;
                case 'double-bullish'
                    idx = 10;
                case 'double-bearish'
                    idx = 11;
                case 'simpletrend'
                    idx = 12;
                otherwise
                    idx = -1;
            end
        end
        
        function typestr = idx2type(idxin)
            switch idxin
                case 1
                    typestr = 'perfectbs';
                case 2
                    typestr = 'semiperfectbs';
                case 3
                    typestr = 'imperfectbs';
                case 4
                    typestr = 'perfectss';
                case 5
                    typestr = 'semiperfectss';
                case 6
                    typestr = 'imperfectss';
                case 7
                    typestr = 'single-lvldn';
                case 8
                    typestr = 'single-lvlup';
                case 9
                    typestr = 'double-range';
                case 10
                    typestr = 'double-bullish';
                case 11
                    typestr = 'double-bearish';
                case 12
                    typestr = 'simpletrend';
                otherwise
                    typestr = 'unset';
            end
        end
        
    end
    
end