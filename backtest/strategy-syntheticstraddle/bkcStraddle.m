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
                if ~isempty(idxSpot) && ~isempty(idxVol)
                    [cleg,pleg] = blkprice(S(idxSpot,2),obj.strike_,0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2));
                    obj.pvs_(i) = cleg+pleg;
                else
                    obj.pvs_(i) = NaN;
                end
            end
        end
        %
        function [] = plot(obj,spots)
            if isempty(obj.pvs_),return;end
            idxSpot1 = find(spots(:,1) == obj.opendt1_,1,'first');
            idxSpot2 = find(spots(:,1) == obj.expirydt1_,1,'first');
            if isempty(idxSpot1) || isempty(idxSpot2), return;end
            figure(1);
            subplot(211);plot(obj.pvs_);title('straddle pv');
            subplot(212);plot(spots(idxSpot1:idxSpot2,2));title('spot');
        end
        %
        function outputs = stats(obj)
            outputs = [];
            if isempty(obj.pvs_),return;end
            rets = obj.pvs_(2:end)./obj.pvs_(1)-1;
            maxret = max(rets);
            outputs = struct('maxret',maxret);
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
            else
                obj.tradedts_ = gendates('fromdate',obj.opendt1_,'todate',obj.expirydt1_);
                obj.pvs_ = zeros(length(obj.tradedts_),1);
                obj.deltas_ = obj.pvs_;
            end
        end
    end
end