classdef cStratFutSingleSyntheticOpt < cStrat
    properties
        opt_legs_@cell
    end
    
    methods
        function obj = cStratFutSingleSyntheticOpt
            obj.name_ = 'futsinglesyntheticopt';
        end
        
        function [] = addoptleg(obj,opt_type,opt_strike,opt_expiry,opt_notional,opt_vol)
            %
            leg = cSyntheticOptLeg;
            instruments = obj.instruments_.getinstrument;
            
            leg.fill(instruments{1},opt_expiry,opt_type,opt_strike,opt_notional);
            leg.vol_ = opt_vol;
            %
            n = size(obj.opt_legs_,1);
            legs = cell(n+1,1);
            legs{n+1} = leg;
            
            for i = 1:n
                legs{i} = obj.opt_legs_{i};
            end
            
            obj.opt_legs_ = legs;
            
        end
            
        function obj = calibrate(obj)
        end

        
        function signals = gensignal(obj,portfolio, quotes)
            pnl = obj.calcpnl(portfolio,quotes);
            
            %nothing to do once the stoploss is breached
%             if pnl < 0 && pnl < -obj.notional_*obj.stoploss_
%                 signals = {};
%                 return
%             end
            
            list = obj.instruments_.getinstrument;
            %this is a single underlier strategy
            instrument = list{1};
            
            qidx = 0;
            for i = 1:size(quotes)
                if strcmpi(instrument.code_ctp,quotes{i}.code_ctp)
                    qidx = i;
                    break
                end
            end
            if qidx == 0
                error('cStratFutSingleSyntheticOpt:gensignal:invalid quotes')
            end
            
            
            delta = 0;
            if ~isempty(obj.opt_legs_)
                for i = 1:size(obj.opt_legs_,1)
                    obj.opt_legs_{i}.update(quotes{qidx});
                    delta = delta + obj.opt_legs_{i}.delta_;
                end
            end
            
            px_last = quotes{qidx}.last_trade;
%             code_ctp = quotes{qidx}.code_ctp;
            [flag,idx] = portfolio.hasinstrument(instrument);
            if ~flag
                error('cStratFutSingleSyntheticOpt:gensignal:invalid input portfolio')
            end
            contract_size = instrument.contract_size;
            rescale = 1;
            if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_ctp,'TFT'))
                rescale = 100;
            end
        
            volume_carried = portfolio.instrument_volume(idx);
            delta_carried = px_last * volume_carried * contract_size / rescale;
            
            fprintf('delta residual:%4.0f\n',delta-delta_carried);
            
            volume = round((delta-delta_carried)/(px_last*contract_size/rescale));
            
            signals = cell(1);
            signals{1} = struct('time',quotes{qidx}.update_time2,...
                'instrument',instrument,...
                'volume',volume);
        end
        %end of gensignal
        

                
    end
        
end