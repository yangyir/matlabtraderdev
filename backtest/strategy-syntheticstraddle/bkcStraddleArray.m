classdef bkcStraddleArray < cArray
    properties(Abstract = false)
        %note:
        %we cannot use node_@cSyntheticStraddle since the base class cArray has no
        %restriction in defining node_
        %all restrictions shall be implemented only in set methods
        %with the correct elemement class initialized
        node_ = bkcStraddle;
    end
    
    methods
        function set.node_(obj, node)
            if isa(node, 'bkcStraddle')
                obj.node_ = node;
            else
                error('bkcStraddleArray£ºinvalid node input');
            end
        end
    end
    %
    %
    methods
        function premium = premiumused(obj,datein,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('Limit',inf,@isnumeric);
            p.addParameter('Stop',-inf,@isnumeric);
            p.addParameter('DaysCut',[],@isnumeric);
            p.addParameter('FixedPremium',[],@isnumeric);
            p.parse(varargin{:});
            upperbound = p.Results.Limit;
            lowerbound = p.Results.Stop;
            dayscut = p.Results.DaysCut;
            usedaycut = ~isempty(dayscut);
            fixedpremium = p.Results.FixedPremium;
            usefixedpremium = ~isempty(fixedpremium);
            premium = 0;
            n = obj.latest_;
            for i = 1:n
                straddle_i = obj.node_(i);
                if straddle_i.opendt1_ <= datein && straddle_i.expirydt1_ >= datein
                    pv0 = straddle_i.pvs_(1);
                    idxdate = find(straddle_i.tradedts_ == datein,1,'first');
                    ret = straddle_i.pvs_(idxdate)/pv0;
                    if ret < upperbound && ret > lowerbound && (~usedaycut || (usedaycut && idxdate < dayscut))
                        if usefixedpremium
                            premium = premium + fixedpremium;
                        else
                            premium = premium + pv0;
                        end
                    end                    
                end
            end
        end
        %
        function premium = premiumreturned(obj,datein,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('FixedPremium',[],@isnumeric);
            p.parse(varargin{:});
            fixedpremium = p.Results.FixedPremium;
            usefixedpremium = ~isempty(fixedpremium);
            premium = 0;
            n = obj.latest_;
            for i = 1:n
                straddle_i = obj.node_(i);
                [unwindidx,unwinddt] = straddle_i.unwindinfo(varargin{:});
                if unwinddt == datein
                    ret = straddle_i.pvs_(unwindidx)/straddle_i.pvs_(1);
                    if usefixedpremium
                        premium = premium + fixedpremium*ret;
                    else
                        premium = premium + pv0*ret;
                    end
                end
            end
        end
    end
    
end