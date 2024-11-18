function [trade] = getlivetrade(obj,varargin)
%a cOps function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','',@(x) validateattributes(x,{'char','cInstrument'},{},'','Code'));
    p.parse(varargin{:});
    code = p.Results.Code;
    
    hasposition = obj.book_.hasposition(code);
    
    if isa(code,'cInstrument')
        code = code.code_ctp;
    end
    
    if ~hasposition
        trade = [];
    else
        alltrades = obj.trades_;
        for i = 1:alltrades.latest_
            trade_i = alltrades.node_(i);
            if ~strcmpi(trade_i.status_,'closed') && ...
                    strcmpi(trade_i.instrument_.code_ctp,code)
                trade = trade_i;
                break
            end
        end
    end
end