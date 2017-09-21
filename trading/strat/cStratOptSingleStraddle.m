
classdef cStratOptSingleStraddle < cStrat
    properties
        
    end
    
    methods
        function obj = cStratOptSingleStraddle
            obj.name_ = 'optsinglestraddle';
        end
        
        
    end
    
    methods
        function signals = gensignal(obj,portfolio,quotes)
            underliers = obj.underliers_.getinstrument;
            underlier = underliers{1};
            
            
        end
        
        function [] = querypositions(obj,counter,qms)
            nu = obj.countunderliers;
            list_u = obj.underliers_.getinstrument;
            list_opt = obj.instruments_.getinstrument;
            if nu == 1
                [opt_delta,opt_gamma,opt_vega,opt_theta] = opt_querypositions(obj.instruments_,counter,qms);
                q = qms.getquote(list_opt{1});
                last_trade = q.last_trade_underlier;
                [pos_u,ret_u] = counter.queryPositions(list_u{1}.code_ctp);
                if ret_u
                    fut_delta = pos_u.direction*pos_u.total_position*last_trade*list_u{1}.contract_size;
                else
                    fut_delta = 0;
                end
                nresidual = -(opt_delta + fut_delta)/last_trade/list_u{1}.contract_size;
                fprintf('spot:%4.0f; ',last_trade);
                fprintf('theta:%4.0f; ',opt_theta);
                fprintf('gamma:%4.0f; ',opt_gamma);
                fprintf('vega:%4.0f; ',opt_vega);
                fprintf('delta opt:%4.0f; ',opt_delta);
                fprintf('delta fut:%4.0f; ',fut_delta);
                fprintf('lots:%d; ',round(nresidual));
                fprintf('\n');
            else
                %group the information by underlier
                
                
                opt_delta = zeros(nu,1);
                for i = 1:nu
                    opts = cInstrumentArray;
                    for j = 1:size(list_opt,1)
                        if strcmpi(list_opt{j}.code_ctp_underlier,list_u{i}.code_ctp);
                            opts.addinstrument(list_opt{j});
                        end
                    end
                    opt_querypositions(opts,counter,qms);
                    
                end
                
            end
            
            
            
            
            
            
        end
        
    end
    
    methods (Access = private)
        function strikes = getstrikes(obj)
            opts = obj.instruments_.getinstrument;
            n = obj.count;
            strikes = zeros(n,1);
            for i = 1:n
                strikes(i) = opts{i}.opt_strike;
            end
            strikes = unique(strikes);
            strikes = sort(strikes);
                
        end
    end
end