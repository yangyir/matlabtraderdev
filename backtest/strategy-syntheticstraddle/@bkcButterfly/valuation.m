function [] = valuation(obj,varargin)
%bkcButterfly
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
            leg1 = blkprice(obj.S_(i),obj.strike_(1),0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2));
            leg2 = blkprice(obj.S_(i),obj.strike_(2),0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2));
            leg3 = blkprice(obj.S_(i),obj.strike_(3),0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2));
            if i == length(obj.tradedts_)
                leg1delta = 0;
                leg2delta = 0;
                leg3delta = 0;
            else
                leg1delta = blsdelta(obj.S_(i),obj.strike_(1),0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2),0);
                leg2delta = blsdelta(obj.S_(i),obj.strike_(2),0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2),0);
                leg3delta = blsdelta(obj.S_(i),obj.strike_(3),0,(length(obj.tradedts_)-i)/252,sigma(idxVol,2),0);
            end
            obj.pvs_(i) = leg1-2*leg2*leg3;
            obj.deltas_(i) = leg1delta -2*leg2delta+ leg3delta;
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
                leg1 = blkprice(obj.S_(i),obj.strike_(1),0,(length(obj.tradedts_)-i-1)/252,sigma(idxVol,2));
                leg2 = blkprice(obj.S_(i),obj.strike_(2),0,(length(obj.tradedts_)-i-1)/252,sigma(idxVol,2));
                leg3 = blkprice(obj.S_(i),obj.strike_(3),0,(length(obj.tradedts_)-i-1)/252,sigma(idxVol,2));
                obj.thetapnl_(i) = leg1-2*leg2*leg3-obj.pvs_(i);
            end
        else
            obj.pvs_(i) = NaN;
            obj.deltas_(i) = NaN;
            obj.deltapnl_(i) = NaN;
            obj.thetapnl_(i) = NaN;
        end
    end
end