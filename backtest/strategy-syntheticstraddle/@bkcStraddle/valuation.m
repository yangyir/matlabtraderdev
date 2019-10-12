function [] = valuation(obj,varargin)
%bkcStraddle
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('spots',[],@isnumeric);
    p.addParameter('vols',[],@isnumeric);
    p.addParameter('volmethod','dynamic',@ischar);
    p.addParameter('calctheta',false,@islogical);
    p.parse(varargin{:});
    S = p.Results.spots;
    sigma = p.Results.vols;
    volmethod = p.Results.volmethod;
    calctheta = p.Results.calctheta;
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
            [cleg,pleg] = blkprice(obj.S_(i),obj.strike_,0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2));
            if i == length(obj.tradedts_)
                clegdelta = 0;
                plegdelta = 0;
            else
                [clegdelta,plegdelta] = blsdelta(obj.S_(i),obj.strike_,0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2),0);
            end
            obj.pvs_(i) = cleg+pleg;
            obj.deltas_(i) = clegdelta + plegdelta;
            if i == 1
                obj.deltapnl_(i) = 0;
            else
                obj.deltapnl_(i) = obj.deltas_(i-1)*(obj.S_(i)-obj.S_(i-1));
            end
            %
            if calctheta
                %theta pnl
                if i == length(obj.tradedts_)
                    obj.thetapnl_(i) = 0;
                else
                    [cleg,pleg] = blkprice(obj.S_(i),obj.strike_,0,(length(obj.tradedts_)-i-1)/252,sigma(idxVol,2));
                    obj.thetapnl_(i) = cleg+pleg-obj.pvs_(i);
                end
            else
                obj.thetapnl_(i) = NaN;
            end
        else
            obj.pvs_(i) = NaN;
            obj.deltas_(i) = NaN;
            obj.deltapnl_(i) = NaN;
            obj.thetapnl_(i) = NaN;
        end
    end
end