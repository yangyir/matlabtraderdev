classdef cInstrumentArray < handle
    properties (Access = private)
       list_@cell
    end
    
    methods
        function delete(obj)
            n = obj.count;
            for i = 1:n
                obj.list_{i}.delete;
            end
            obj.list_ = {};
        end
        
        function [bool,idx] = hasinstrument(obj,instrument)
            if ~obj.isvalid
                bool = false;
                idx = 0;
                return
            end
            
            if ischar(instrument)
                code_str = instrument;
            elseif isa(instrument,'cInstrument')
                code_str = instrument.code_ctp;
            else
                error('cInstrumentArray:hasinstrument:cInstrument or char type of input expected')
            end
            n = obj.count;
            bool = false;
            idx = 0;
            for i = 1:n
                if strcmpi(code_str,obj.list_{i}.code_ctp)
                    bool = true;
                    idx = i;
                    break;
                end
            end
            
        end
        %end of hasinstrument
        
        function n = count(obj)
            if ~obj.isvalid
                n = 0;
            else
                if isempty(obj)
                    n = 0;
                else
                    n = length(obj.list_);
                end
            end
        end
        %end of count
    
        function obj = addinstrument(obj,instrument)
            if ~obj.isvalid, return; end
            bool = obj.hasinstrument(instrument);
            if ~bool
                n = obj.count;
                list = cell(n+1,1);
                list{n+1,1} = instrument;
                
                for i = 1:n
                    list{i,1} = obj.list_{i,1};    
                end
                obj.list_ = list; 
            end
        end
        %end of addinstrument
        
        function obj = removeinstrument(obj,instrument)
            if ~obj.isvalid, return; end
            [bool,idx] = obj.hasinstrument(instrument);
            if ~bool
                %a warning or error message shall be issued
                return;
            else
                n = obj.count;
                if n == 1
                    obj.list_ = {};
                else
                    list = cell(n-1,1);
                    for i = 1:idx-1
                        list{i,1} = obj.list_{i,1};
                    end
                    for i = idx+1:n
                        list{i-1,1} = obj.list_{i,1};
                    end
                    obj.list_ = list;
                end
                
            end
        end
        %end of removeinstrument
        
        function [] = clear(obj)
            if ~obj.isvalid, return; end
            obj.list_ = {};
        end
        %end of clear
        
        function list = getinstrument(obj,codestr)
            if ~obj.isvalid
                list = {};
                return
            end
            
            if nargin < 2
                list = obj.list_;
            else
                n = obj.count;
                for i = 1:n
                    if strcmpi(obj.list_{i}.code_ctp,codestr)
                        list = cell(1);
                        list{1} = obj.list_{i};
                        return
                    end
                end
                list = {};
            end
               
        end
        %end of getinstrument
        
    end
        
        
        
end