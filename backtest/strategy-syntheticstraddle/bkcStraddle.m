classdef bkcStraddle < handle
    properties
        id_@double
        code_@char
        strike_@double
        opendt1_@double
        expirydt1_@double
        tradedts_@double
        pvs_@double
        deltas_@double
        S_@double
        thetapnl_@double
        deltapnl_@double
    end
    
    properties (Dependent = true, SetAccess = private, GetAccess = public)
        opendt2_@char
        expirydt2_@char
    end
    
    methods
        function obj = bkcStraddle(varargin)
            obj = init(obj,varargin{:});
        end
        %
        function opendt2 = get.opendt2_(obj)
            if isempty(obj.opendt1_)
                opendt2 = '';
            else
                opendt2 = datestr(obj.opendt1_,'yyyy-mm-dd');
            end
        end
        %
        function expirydt2 = get.expirydt2_(obj)
            if isempty(obj.expirydt1_)
                expirydt2 = '';
            else
                expirydt2 = datestr(obj.expirydt1_,'yyyy-mm-dd');
            end 
        end
        %
        function [] = valuation(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('spots',[],@isnumeric);
            p.addParameter('vols',[],@isnumeric);
            p.addParameter('volmethod','dynamic',@ischar);
            p.parse(varargin{:});
            S = p.Results.spots;
            sigma = p.Results.vols;
            volmethod = p.Results.volmethod;
            for i = 1:length(obj.tradedts_)
                dt_i = obj.tradedts_(i);
                idxSpot = find(S(:,1) == dt_i,1,'first');
                if strcmpi(volmethod,'dynamic')
                    idxVol = find(sigma(:,1) == dt_i,1,'first');
                elseif strcmpi(volmethod,'static')
                    idxVol = find(sigma(:,1) == obj.opendt1_,1,'first');
                else
                    idxVol = [];
                end
                if ~isempty(idxSpot)
                    obj.S_(i) = S(idxSpot,2);
                else
                    obj.S_(i) = NaN;
                end
                if ~isempty(idxSpot) && ~isempty(idxVol)
                    
                    [cleg,pleg] = blkprice(S(idxSpot,2),obj.strike_,0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2));
                    if i == length(obj.tradedts_)
                        clegdelta = 0;
                        plegdelta = 0;
                    else
                        [clegdelta,plegdelta] = blsdelta(S(idxSpot,2),obj.strike_,0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2),0);
                    end
                    obj.pvs_(i) = cleg+pleg;
                    obj.deltas_(i) = clegdelta + plegdelta;
                    if i == 1
                        obj.deltapnl_(i) = 0;
                    else
                        obj.deltapnl_(i) = obj.deltas_(i-1)*(obj.S_(i)-obj.S_(i-1));
                    end
                    %
                    %theta pnl
                    if i == length(obj.tradedts_)
                        obj.thetapnl_(i) = 0;
                    else
                        [cleg,pleg] = blkprice(S(idxSpot,2),obj.strike_,0,(length(obj.tradedts_)-i-1)/252,sigma(idxVol,2));
                        obj.thetapnl_(i) = cleg+pleg-obj.pvs_(i);
                    end
                else
                    obj.pvs_(i) = NaN;
                    obj.deltas_(i) = NaN;
                    obj.deltapnl_(i) = NaN;
                    obj.thetapnl_(i) = NaN;
                end
            end
        end
        %
        function [] = plot(obj)
            if isempty(obj.pvs_),return;end
            figure(1);
            subplot(211);plot(obj.pvs_);title('straddle pv');
            subplot(212);plot(obj.S_);title('spot');
        end
        %
        function outputs = stats(obj)
            outputs = [];
            if isempty(obj.pvs_),return;end
            rets = obj.pvs_(2:end)./obj.pvs_(1)-1;
            maxret = max(rets);
            maxretidx = find(rets == maxret,1,'first');
            if ~isempty(maxretidx)
                minretb4max = min(rets(1:maxretidx));
            else
                minretb4max = NaN;
                maxretidx = -1;
            end
            outputs = struct('maxret',maxret,'maxretidx',maxretidx+1,...
                'minretbeforemax',minretb4max);
        end
        %
        function [idxunwind,unwinddt] = unwindinfo(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Limit',inf,@isnumeric);
            p.addParameter('Stop',-inf,@isnumeric);
            p.addParameter('DaysCut',[],@isnumeric);
            p.addParameter('Criterial','pv',@ischar);
            p.parse(varargin{:});
            upperbound = p.Results.Limit;
            lowerbound = p.Results.Stop;
            dayscut = p.Results.DaysCut;
            usedaycut = ~isempty(dayscut);
            criterial = p.Results.Criterial;
            
            if isempty(obj.pvs_)
                idxunwind = [];
                unwinddt = [];
                return
            end
            
            if strcmpi(criterial,'pv')
                rets = obj.pvs_/obj.pvs_(1);
            elseif strcmpi(criterial,'delta')
                rets = cumsum(obj.deltapnl_)/obj.pvs_(1)+1;
            else
                error('%s:unwindinfo:invalid criterial input!',class(obj));
            end
            idx1 = find(rets >= upperbound,1,'first');
            if isempty(idx1), idx1 = length(obj.pvs_);end
            idx2 = find(rets <= lowerbound,1,'first');
            if isempty(idx2), idx2 = length(obj.pvs_);end
            idx3 = length(obj.pvs_);
            if usedaycut, idx3 = dayscut;end

            idx4 = find(isnan(rets),1,'first');
            if ~isempty(idx4)
                idx4 = idx4-1;
            else
                idx4 = idx3;
            end

            idxunwind = min([idx1,idx2,idx3,idx4]);
            unwinddt = obj.tradedts_(idxunwind);
            
        end
        %
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('id',[],@isnumeric);
            p.addParameter('code','',@ischar);
            p.addParameter('strike',[],@isnumeric);
            p.addParameter('opendt',[],@isnumeric);
            p.addParameter('expirydt',[],@isnumeric);
            p.parse(varargin{:});
            obj.id_ = p.Results.id;
            obj.code_ = p.Results.code;
            obj.strike_ = p.Results.strike;
            obj.opendt1_ = p.Results.opendt;
            obj.expirydt1_ = p.Results.expirydt;
            if isempty(obj.opendt1_) || isempty(obj.expirydt1_)
                obj.tradedts_ = [];
                obj.pvs_ = [];
                obj.deltas_ = [];
                obj.S_ = [];
                obj.thetapnl_ = [];
                obj.deltapnl_ = [];
            else
                obj.tradedts_ = gendates('fromdate',obj.opendt1_,'todate',obj.expirydt1_);
                obj.pvs_ = zeros(length(obj.tradedts_),1);
                obj.deltas_ = obj.pvs_;
                obj.S_ = obj.pvs_;
                obj.thetapnl_ = obj.pvs_;
                obj.deltapnl_ = obj.pvs_;
            end
        end
    end
end