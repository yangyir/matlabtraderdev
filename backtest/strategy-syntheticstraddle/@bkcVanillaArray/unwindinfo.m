function output = unwindinfo(obj,varargin)
%bkcVanillaArray
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Criterial','pv',@ischar);
    p.parse(varargin{:});
    criterial = p.Results.Criterial;
    
    n = obj.latest_;
    output = zeros(n,4);
    %1st col:final pv
    %2nd col:unwind idx
    %3rd col:open pv
    %4th col:unwind date
    for i = 1:n
        vanilla_i = obj.node_(i);
        [unwindidx,unwinddt] = vanilla_i.unwindinfo(varargin{:});
        if unwindidx ~= -1
            if strcmpi(criterial,'pv')
                output(i,1) = vanilla_i.pvs_(unwindidx)/vanilla_i.pvs_(1);
            else
                temp = cumsum(vanilla_i.deltapnl_);
                output(i,1) = 1+temp(unwindidx)/vanilla_i.pvs_(1);
            end
        else
            idxlastrunning = find(isnan(vanilla_i.pvs_),1,'first')-1;
            if strcmpi(criterial,'pv')
                output(i,1) = vanilla_i.pvs_(idxlastrunning)/vanilla_i.pvs_(1);
            else
                temp = cumsum(vanilla_i.deltapnl_);
                output(i,1) = 1+temp(idxlastrunning)/vanilla_i.pvs_(1);
            end
        end
        output(i,2) = unwindidx;
        output(i,3) = vanilla_i.pvs_(1);
        output(i,4) = unwinddt;
    end
end