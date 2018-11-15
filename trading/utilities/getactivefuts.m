function [futs] = getactivefuts(varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('CobDate',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','CobDate'));
    p.addParameter('AssetTypes',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','AssetTypes'));
    p.addParameter('AssetNames',{},...
        @(x) validateattributes(x,{'char','cell'},{},'','AssetNames'));
    p.addParameter('ConditionType','or',@ischar);
    p.parse(varargin{:});
    cobdate = p.Results.CobDate;
    assettypes = p.Results.AssetTypes;
    assetnames = p.Results.AssetNames;
    conditiontype = p.Results.ConditionType;
    if ~(strcmpi(conditiontype,'or') || strcmpi(conditiontype,'and'))
        error('getactivefuts:ConditionType must either be Or or And')
    end
    
    useassettypes = false;
    useassetnames = false;
    if ~isempty(assettypes)
        useassettypes = true;
        if ischar(assettypes)
            assettypes = {assettypes};
        end
    end
    if ~isempty(assetnames)
        useassetnames = true; 
        if ischar(assetnames)
            assetnames = {assetnames};
        end
    end        
    
    if isempty(cobdate), cobdate = datestr(getlastbusinessdate,'yyyymmdd'); end
    if ~ischar(cobdate), cobdate = datestr(cobdate,'yyyymmdd');end
    
    activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
    activefuturesfn = ['activefutures_',cobdate,'.txt'];
    allfuts = cDataFileIO.loadDataFromTxtFile([activefuturesdir,activefuturesfn]);
    
    if useassettypes || useassetnames
        [assetnamelist,assettypelist] = getassetmaptable;
        idx = true(size(allfuts,1),1);
        for i = 1:size(allfuts,1)
            if useassettypes
                f1 = false;
                type_i = assettypelist{i};
                for j = 1:size(assettypes,1)
                    if strcmpi(type_i,assettypes{j})
                        f1 = true;
                        break
                    end 
                end
            else
                f1 = true;
            end
            if useassetnames
                f2 = false;
                name_i = assetnamelist{i};
                for j = 1:size(assetnames,1)
                    if strcmpi(name_i,assetnames{j})
                        f2 = true;
                        break
                    end
                end
            else
                f2 = true;
            end
            if strcmpi(conditiontype,'or')
                idx(i) = f1|f2;
            else
                idx(i) = f1&f2;
            end
        end
        futs = allfuts(idx);
    else
        futs = allfuts;
    end
    
        
end