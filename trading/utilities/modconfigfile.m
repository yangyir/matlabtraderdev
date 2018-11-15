function [ret] = modconfigfile(filename,varargin)
    try
        configs = cStratConfigArray;
        configs.loadfromfile('filename',filename);
    catch e
        ret = 0;
        fprintf('ERROR:modconfigfile:%s\n',e.message);
        return
    end
    
    p = inputParser;
    p.CaseSensitive = true;p.KeepUnmatched = false;
    p.addParameter('Code','',@ischar);
    p.addParameter('PropNames',{},@iscell);
    p.addParameter('PropValues',{},@iscell);
    p.parse(varargin{:});
    code = p.Results.Code;
    propnames = p.Results.PropNames;
    propvalues = p.Results.PropValues;
    
    nconfigs = configs.latest_;
    
    if ~isempty(code)
        %modify properties values only for given instruments
        foundflag = false;
        idx = -1;
        for i = 1:nconfigs
            config_i = configs.node_(i);
            if strcmpi(config_i.codectp_,code)
                foundflag = true;
                idx = i;
                break
            end
        end
        if ~foundflag
            fprintf('WARNING:modconfigfile:%s not found in file!!!\n',code)
            ret = 0;
            return
        end
        config2mod = configs.node_(idx);
        for i = 1:size(propnames);
            try
                config2mod.([lower(propnames{i},'_']) = propvalues{i};
            catch
                fprintf('WARNING:modconfigfile:%s is not a property of %s!!!\n',propnames{i},class(config2mode));
            end
        end
        configs.to
        
        
    else
        %modify properties values for all instruments
    end
    
    ret = 1;
    
end