classdef cStratFutPairCointegration < cStrat
    properties
        data_@double
        lookbackperiod_@double = 270
        rebalanceperiod_@double = 60
        upperbound_@double = 1.96
        lowerbound_@double = -1.96
    end
    
    properties (Access = public)
        cointegrationparams_
    end
    
    methods
        function obj = cStratFutPairCointegration
            obj.name_ = 'futpaircointegration';
            warning('off','econ:egcitest:LeftTailStatTooSmall')
            warning('off','econ:egcitest:LeftTailStatTooBig')
        end    
    end
    
    %derived (abstract) methods from superclass
    methods
        function signals = gensignals(obj)
            signals = obj.gensignals_futpaircointegration;
        end
        %end of gensignals
        
        function [] = autoplacenewentrusts(obj,signals)
            obj.autoplacenewentrusts_futpaircointegration(signals)
        end
        %end of autoplacenewentrusts
        
        function [] = updategreeks(obj)
            obj.updategreeks_futpaircointegration
        end
            
        
        function [] = initdata(obj)
            obj.initdata_futpaircointegration;
        end
        %end of initdata
                
    end
    
    methods
       
%         function signals = gensignal(obj,portfolio,quotes)
%             
%             list = obj.instruments_.getinstrument;
%             instrument1 = list{1};
%             instrument2 = list{2};
%             [flag1,pidx1] = portfolio.hasinstrument(instrument1);
%             [flag2,pidx2] = portfolio.hasinstrument(instrument2);
%             if ~flag1 || ~flag2 
%                 error('cStratFutPairCointegration:gensignal:invalid input portfolio')
%             end
%             volume1_ = portfolio.instrument_volume(pidx1);
%             volume2_ = portfolio.instrument_volume(pidx2);
%             
%             [ret,qidx1,qidx2] = updatedata(obj,quotes);
%             if ~ret
%                 signals = {};
%                 return
%             end
%             M = obj.lookbackperiod_;
%             N = obj.rebalanceperiod_;
%             count = size(obj.data_,1);
%             doRebalance = mod(count-M,N) == 0;
%             nRebalance =  floor((count - M)/N);
%             if doRebalance
%                 % rebalance the model parameters
%                 fprintf('rebalancing cointegration params......\n');
%                 idx = max(M,N)+N*nRebalance;
%                 [h,~,~,~,reg1] = egcitest(obj.data_(max(idx-M+1,1):idx,2:3));
%                 if h ~= 0
%                     obj.cointegrationparams_ = reg1;
%                 else
%                     obj.cointegrationparams_ = {};
%                 end
%             end
%             
%             if ~isempty(obj.cointegrationparams_)
%                 res = obj.data_(end,2) ...
%                     - (obj.cointegrationparams_.coeff(1) ...
%                     + obj.cointegrationparams_.coeff(2) *obj.data_(end,3));
%                 indicate = res/obj.cointegrationparams_.RMSE;
%                 fprintf('indicate:%4.2f\n',indicate);
%     
%                 % If the residuals are large and positive, then the first series
%                 % is likely to decline vs. the seond series. Short the first series
%                 % by a scaled number of shares and long the second series by 1
%                 % share. If the residuals are large and negative, do the opposite
%                 if indicate > obj.upperbound_
%                     volume1 = round(-obj.cointegrationparams_.coeff(2)*10);
%                     volume2 = 10;
%                     fprintf('%s overbought\n',instrument1.code_ctp);
%                 elseif indicate < obj.lowerbound_
%                     volume1 = round(obj.cointegrationparams_.coeff(2)*10);
%                     volume2 = -10;
%                     fprintf('%s oversold\n',instrument1.code_ctp);
%                 else
%                     volume1 = 0;
%                     volume2 = 0;
%                 end
%             else
%                 %no cointegration between pairs are found
%                 fprintf('no cointegration\n');
%                 volume1 = 0;
%                 volume2 = 0;
%             end
%             volume1 = volume1 - volume1_;
%             volume2 = volume2 - volume2_;
%             signals = cell(2,1);
%             signals{1} = struct('time',quotes{qidx1}.update_time2,...
%                 'instrument',instrument1,...
%                 'volume',volume1);
%             signals{2} = struct('time',quotes{qidx2}.update_time2,...
%                 'instrument',instrument2,...
%                 'volume',volume2);
%         end
%         %end of gensignal
        
    end
    
    methods (Access = private)
%         function [ret,qidx1,qidx2] = updatedata(obj,quotes)
%             try
%             list = obj.instruments_.getinstrument;
%             %this is a dual underlier strategy
%             instrument1 = list{1};
%             instrument2 = list{2};
%             
%             qidx1 = 0;
%             for i = 1:size(quotes)
%                 if strcmpi(instrument1.code_ctp,quotes{i}.code_ctp)
%                     qidx1 = i;
%                     break
%                 end
%             end
%             if qidx1 == 0, error('cStratFutPairCointegration:gensignal:invalid quotes');end
%             
%             qidx2 = 0;
%             for i = 1:size(quotes)
%                 if strcmpi(instrument2.code_ctp,quotes{i}.code_ctp)
%                     qidx2 = i;
%                     break
%                 end
%             end
%             if qidx2 == 0, error('cStratFutPairCointegration:gensignal:invalid quotes');end
%             
%             last_trade1 = quotes{qidx1}.last_trade;
%             last_trade2 = quotes{qidx2}.last_trade;
%             
%             n = size(obj.data_,1);
%             data = zeros(n+1,3);
%             data(n+1,1) = max(quotes{qidx1}.update_time1,quotes{qidx2}.update_time1);
%             data(n+1,2) = last_trade1;
%             data(n+1,3) = last_trade2;
%             data(1:n,:) = obj.data_;
%             obj.data_ = data;
%             
%             ret = 1;
%             catch
%                 ret = 0;
%             end
%             
%         end
%         %end of updatedata
        [] = updategreeks_futpaircointegration(obj)
        signals = gensignals_futpaircointegration(obj)
        [] = autoplacenewentrusts_futpaircointegration(obj,signals)
        [] = initdata_futpaircointegration(obj)
        [] = updatapairdata(obj)
    end
    
    
    
    
end