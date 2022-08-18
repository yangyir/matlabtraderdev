% build-up cFX - yangyiran 2022/08/18
classdef cFX < cInstrument
    properties
        code_ctp@char
        code_wind@char
        code_bbg@char
        code_H5@char
        
        contract_size@double = 10000
        tick_size@double = 0.0001
        tick_value@double = 100
        asset_name@char
        exchange@char
        
    end
    
    methods
        function [] = delete(obj)
            obj.code_ctp = '';
            obj.code_wind = '';
            obj.code_bbg = '';
            obj.code_H5 = '';
            obj.contract_size = [];
            obj.tick_size = [];
            obj.tick_value = [];
            obj.asset_name = '';
            obj.exchange = '';
            delete@cInstrument(obj);
        end
        
        function obj = cFX(codestr)
            % check number of function input arguments
            if nargin < 1
                return
            end
            
            
            obj.code_bbg = 'n/a';
            obj.code_H5 = 'n/a';
            
            idx = strfind(upper(codestr),'.FX');
            if ~isempty(idx)
                obj.code_wind = upper(codestr);
                obj.code_ctp = lower(codestr(1:idx-1))';
            else
                obj.code_wind = [upper(codestr),'.FX'];
                obj.code_ctp = lower(codestr);
            end
        end
        %end of constructor
        
        [] = init_bbg(obj,ds_)
        [] = init_wind(obj,ds_)
        [assetname,exch] = getexchangestr(obj)
        
    end
end