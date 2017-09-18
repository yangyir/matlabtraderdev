classdef cStratOptMultiCPArb < cStrat
    %class to monitor all possible option arbitrage opportunies with the
    %call-put parity relationship
    
    properties (Access = private)
        numofoptsperunderlier_@double = 5
    end
    
    methods
        function obj = cStratOptMultiCPArb
            obj.name_ = 'optmulticparb';
        end
        
        
        function signals = gensignal(obj,~,quotes)
            %note:here the strategy itself has nothing to do with the
            %portfolio
            signals = cell(100,1);
            nsignals = 0;
            underliers = obj.underliers_.getinstrument;
            for i = 1:obj.countunderliers
                [strikes,callsarray,putsarray] = obj.breakdownopt(underliers{i});
                idx_f = 0;
                for j = 1:size(quotes,1)
                    if strcmpi(quotes{j}.code_ctp,underliers{i}.code_ctp)
                        idx_f = j;
                        break
                    end
                end
                if idx_f == 0, error('cStratOptMultiCPArb:gensignal:input quotes and option underlier mismatch'); end
                q_f = quotes{idx_f};
                bid_f = q_f.bid1;
                ask_f = q_f.ask1;
                
                c = callsarray.getinstrument;
                p = putsarray.getinstrument;
                nstrikes = size(strikes,1);
                quotec = zeros(nstrikes,2);
                quotep = zeros(nstrikes,2);
                                
                for j = 1:nstrikes
                    strike_c = c{j}.opt_strike;
                    if ischar(strike_c), strike_c = str2double(strike_c); end
                    strike_p = p{j}.opt_strike;
                    if ischar(strike_p), strike_p = str2double(strike_p); end
                    
                    if strikes(j) ~= strike_c || strikes(j) ~= strike_p
                        error('cStratOptMultiCPArb:gensignal:internal error')
                    end
                    code_c = c{j}.code_ctp;
                    code_p = p{j}.code_ctp;
                    idx_c = 0;
                    idx_p = 0;
                    for k = 1:size(quotes,1)
                        if strcmpi(quotes{k}.code_ctp,code_c)
                            idx_c = k;
                            break
                        end
                    end
                    for k = 1:size(quotes,1)
                        if strcmpi(quotes{k}.code_ctp,code_p)
                            idx_p = k;
                            break
                        end
                    end
                    if idx_c == 0 || idx_p == 0
                        error('cStratOptMultiCPArb:gensignal:input quotes and options mismatch')
                    end
                    quotec(j,1) = quotes{idx_c}.bid1;
                    quotec(j,2) = quotes{idx_c}.ask1;
                    quotep(j,1) = quotes{idx_p}.bid1;
                    quotep(j,2) = quotes{idx_p}.ask1;
                    %monitor1: call-put parity same strikes
                    %we short call and long put and long futures
                    %synthetic short forward with strike k and cost at
                    %put premium - call premium
                    if strikes(j)-(quotep(j,2)-quotec(j,1))-ask_f > 0
                        %todo:transaction cost shall be included
                        
                        %signals shall be generated here
                        fprintf('c-p parity arb:short call/long put at strike %d / long fut\n',strikes(j));
                        %
                        nsignals = nsignals+1;
                        signal = struct('instrument',c{j},'direction',-1,'volume',1,'price',quotec(j,1),'type','arb');
                        signals(nsignals,1) = signal;
                        %
                        nsignals = nsignals+1;
                        signal = struct('instrument',p{j},'direction',1,'volume',1,'price',quotep(j,2),'type','arb');
                        signals(nsignals,1) = signal;
                        %
                        nsignals = nsignals+1;
                        signal = struct('instrument',underliers{i},'direction',1,'volume',1,price,ask_f,'type','arb');
                        signals(nsignals,1) = signal;
                    end
                       
                    %we long call and short put and short futures
                    %synthetic long forward with strike k and cost at
                    %call premium - put premium
                    if strikes(j)+(quotec(j,2)-quotep(j,1))- bid_f < 0;
                        
                        %signals shall be generated here
                        fprintf('c-p parity arb:long call/short put at strike %d / short fut\n',strikes(j));
                        %
                        nsignals = nsignals+1;
                        signal = struct('instrument',c{j},'direction',1,'volume',1,'price',quotec(j,2),'type','arb');
                        signals(nsignals,1) = signal;
                        %
                        nsignals = nsignals+1;
                        signal = struct('instrument',p{j},'direction',-1,'volume',1,'price',quotep(j,1),'type','arb');
                        signals(nsignals,1) = signal;
                        %
                        nsignals = nsignals+1;
                        signal = struct('instrument',underliers{i},'direction',-1,'volume',1,price,bid_f,'type','arb');
                        signals(nsignals,1) = signal;
                    end
                    
                end
                %monitor 2
                %call-put parity2 (box arb)
                %different strikes call-put
                synthetic_l = zeros(nstrikes,1);
                synthetic_s = zeros(nstrikes,1);
                for j = 1:nstrikes
                    %synthetic long is to long call and short put
                    %the real synthetic strike is the strike plus the call ask
                    %subtracted by the put ask
                    synthetic_l(j) = strikes(j)+quotec(j,2)-quotep(j,1);
                    %
                    %synthetic short is to short call and long put
                    %the real synthetic strike is the strike plus the call bid subtracted
                    %by the put bid
                    synthetic_s(j) = strikes(j)+quotec(j,1)-quotep(j,2);
                end
                
                %if any synthetic long is smaller than synthetic short, long the synthetic
                %foward
                for j = 1:nstrikes
                    for k = j:nstrikes
                        if synthetic_l(j) < synthetic_s(k)
                            %signals here
                            fprintf('box arb:long call and short put at strike %d; short call and long put at strike %d\n',...
                                strikes(j),strikes(k));
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',c{j},'direction',1,'volume',1,'price',quotec(j,2),'type','arb');
                            signals(nsignals,1) = signal;
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',p{j},'direction',-1,'volume',1,'price',quotep(j,1),'type','arb');
                            signals(nsignals,1) = signal;
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',c{j},'direction',-1,'volume',1,'price',quotec(k,1),'type','arb');
                            signals(nsignals,1) = signal;
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',p{j},'direction',1,'volume',1,'price',quotep(k,2),'type','arb');
                            signals(nsignals,1) = signal;
                            %
                        elseif synthetic_s(j) > synthetic_l(k)
                            %signals here
                            fprintf('box arb:long put and short call at strike %d; long call and short put at strike %d\n',...
                                strikes(j),strikes(k));
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',c{j},'direction',-1,'volume',1,'price',quotec(j,1),'type','arb');
                            signals(nsignals,1) = signal;
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',p{j},'direction',1,'volume',1,'price',quotep(j,2),'type','arb');
                            signals(nsignals,1) = signal;
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',c{j},'direction',1,'volume',1,'price',quotec(k,2),'type','arb');
                            signals(nsignals,1) = signal;
                            %
                            nsignals = nsignals+1;
                            signal = struct('instrument',p{j},'direction',-1,'volume',1,'price',quotep(k,1),'type','arb');
                            signals(nsignals,1) = signal;
                        end
                    end
                end
                
            end
            signals = signals(1:nsignals);
            
        end
        %end of gensignals
        
    end
    
    methods (Access = private)

    end
end