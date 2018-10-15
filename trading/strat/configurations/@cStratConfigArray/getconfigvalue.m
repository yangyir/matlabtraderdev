function [val] = getconfigvalue(obj,varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('code','',@ischar);
p.addParameter('propname','',@ischar);
p.parse(varargin{:});
code = p.Results.code;
propname = p.Results.propname;

config = obj.getconfig('code',code);
if isempty(config)
    errmessage = [class(obj),':getconfigvalue:config of ',code,' not found'];
    error(errmessage)
end

propname = [lower(propname),'_'];

try
    val = config.(propname);
catch e
    error([class(obj),':getconfigvalue:',e.message]);
end
    


end
