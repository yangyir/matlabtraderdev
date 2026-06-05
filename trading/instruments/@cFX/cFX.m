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
                obj.asset_name = upper(obj.code_ctp);
            else
                if strcmpi(codestr,'xau') || strcmpi(codestr,'xag')
                    obj.code_wind = upper(codestr);
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = upper(obj.code_ctp);
                elseif strcmpi(codestr,'wti') || strcmpi(codestr,'brent')
                    if strcmpi(codestr,'wti')
                        obj.code_wind = 'CL.NYM';
                    else
                        obj.code_wind = 'B00.IPE';
                    end
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = upper(obj.code_ctp);
                elseif strcmpi(codestr,'AD')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'AD';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'EC')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'EC';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'BP')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'BP';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'CD')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'CD';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'SF')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'SF';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'JY')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'JY';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'NE')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'NE';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'GC')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'GC';
                    obj.exchange = 'COMEX';
                elseif strcmpi(codestr,'SI')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'SI';
                    obj.exchange = 'COMEX';
                elseif strcmpi(codestr,'NQ')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'NQ';
                    obj.exchange = 'CME';
                elseif strcmpi(codestr,'ES')
                    obj.code_wind = 'n/a';
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = 'ES';
                    obj.exchange = 'CME';
                else
                    obj.code_wind = [upper(codestr),'.FX'];
                    obj.code_ctp = lower(codestr);
                    obj.asset_name = upper(obj.code_ctp);
                end
            end
            
            if strcmpi(codestr,'usdx') 
                obj.contract_size = 100;
                obj.tick_size = 0.01;
                obj.tick_value = 1;
            elseif strcmpi(codestr,'eurusd') || strcmpi(codestr,'gbpusd') || ...
                    strcmpi(codestr,'audusd') || strcmpi(codestr,'usdcad') || ...
                    strcmpi(codestr,'usdchf') || strcmpi(codestr,'eurchf') || ...
                    strcmpi(codestr,'gbpeur') || strcmpi(codestr,'usdcnh')
                obj.contract_size = 100000;
                obj.tick_size = 0.00001;
                obj.tick_value = 1;
            elseif strcmpi(codestr,'usdjpy') || strcmpi(codestr,'eurjpy') || ...
                    strcmpi(codestr,'gbpjpy') || strcmpi(codestr,'audjpy')
                obj.contract_size = 1000;
                obj.tick_size = 0.001;
                obj.tick_value = 1;
            elseif strcmpi(codestr,'xau') || strcmpi(codestr,'xauusd')
                obj.contract_size = 100;
                obj.tick_size = 0.01;
                obj.tick_value = 1;
            elseif strcmpi(codestr,'xag') || strcmpi(codestr,'xagusd')
                obj.contract_size = 5000;
                obj.tick_size = 0.001;
                obj.tick_value = 5;
            elseif strcmpi(codestr,'brent') || strcmpi(codestr,'wti')
                obj.contract_size = 100;
                obj.tick_size = 0.01;
                obj.tick_value = 1;
            elseif strcmpi(codestr,'AD') || strcmpi(codestr,'EC') || strcmpi(codestr,'BP') || ...
                    strcmpi(codestr,'CD') || strcmpi(codestr,'SF') || strcmpi(codestr,'NE')
                obj.contract_size = 100000;
                obj.tick_size = 0.00005;
                obj.tick_value = 5;
            elseif strcmpi(codestr,'JY')
                obj.contract_size = 12500000;
                obj.tick_size = 0.0000005;
                obj.tick_value = 6.25;
            elseif strcmpi(codestr,'GC')
                obj.contract_size = 100;
                obj.tick_size = 0.1;
                obj.tick_value = 10;
            elseif strcmpi(codestr,'SI')
                obj.contract_size = 5000;
                obj.tick_size = 0.005;
                obj.tick_value = 25;
            elseif strcmpi(codestr,'NQ')
                obj.contract_size = 20;
                obj.tick_size = 0.25;
                obj.tick_value = 5;
            elseif strcmpi(codestr,'ES')
                obj.contract_size = 50;
                obj.tick_size = 0.25;
                obj.tick_value = 12.5;            
            end
        end
        %end of constructor
        
        [] = init_bbg(obj,ds_)
        [] = init_wind(obj,ds_)
        [assetname,exch] = getexchangestr(obj)
        
    end
end