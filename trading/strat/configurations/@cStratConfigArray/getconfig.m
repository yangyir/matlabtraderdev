function [config] = getconfig(obj,varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.parse(varargin{:});
code = p.Results.code;

config = [];
if ~isempty(code)
    n = obj.latest_;
    for i = 1:n
        if strcmpi(obj.node_(i).codectp_,code)
            config = obj.node_(i);
            break
        end
    end
    
else
    config = [];
end

end