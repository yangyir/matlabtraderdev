function contracts = listcontracts(assetName,varargin)
%listed all actively traded contracts in the past
%with all actively traded contracts at the moments
%
p = inputParser;
p.CaseSensitive = false; p.KeepUnmatched = true;
p.addRequired('AssetName',@ischar);
p.addParameter('Connection','Wind',...
                    @(x) validateattributes(x,{'char'},{},'','Name'));
p.parse(assetName,varargin{:});
assetName = p.Results.AssetName;
connection = p.Results.Connection;
if strcmpi(connection,'Wind')
    iswind = true;
elseif strcmpi(connection,'Bloomberg')
    iswind = false;
else
    error('listcontracts:invalid connection input');
end

[assets,types,bcodes,wcodes,exchanges] = getassetmaptable;
idx = -1;
for i = 1:length(assets)
    if strcmpi(assets{i},assetName)
        idx = i;
        break;
    end
end
if idx < 0
    error(['invalid asset name:',assetName]);
end

type = types{idx};
bcode = bcodes{idx};
wcode = wcodes{idx};
exchange = exchanges{idx};

if strcmpi(type,'eqindex')
    if iswind
        contracts = listcontracts_eqindex(assetName,...
                                        'WindCode',wcode,...
                                        'Exchange',exchange);
    else
        contracts = listcontracts_eqindex(assetName,...
                                        'BloombergCode',bcode);
    end
%
elseif strcmpi(type,'govtbond')
    if iswind
        contracts = listcontracts_govtbond(assetName,...
                                        'WindCode',wcode,...
                                        'Exchange',exchange);
    else
        contracts = listcontracts_govtbond(assetName,...
                                        'BloombergCode',bcode);
    end
%
elseif strcmpi(type,'preciousmetal')
    if iswind
        contracts = listcontracts_preciousmetal(assetName,...
                                        'WindCode',wcode,...
                                        'Exchange',exchange);
    else
        contracts = listcontracts_preciousmetal(assetName,...
                                        'BloombergCode',bcode);
    end
%    
elseif strcmpi(type,'basemetal')
    if iswind
        contracts = listcontracts_basemetal(assetName,...
                                        'WindCode',wcode,...
                                        'Exchange',exchange);
    else
        contracts = listcontracts_basemetal(assetName,...
                                        'BloombergCode',bcode);
    end                                  
%
elseif strcmpi(type,'energy')
    if iswind
        contracts = listcontracts_energy(assetName,...
                                        'WindCode',wcode,...
                                        'Exchange',exchange);
    else
        contracts = listcontracts_energy(assetName,...
                                        'BloombergCode',bcode);
    end
%
elseif strcmpi(type,'agriculture')
    if iswind
        contracts = listcontracts_agriculture(assetName,...
                                        'WindCode',wcode,...
                                        'Exchange',exchange);
    else
        contracts = listcontracts_agriculture(assetName,...
                                        'BloombergCode',bcode);
    end
%
elseif strcmpi(type,'industrial')
    if iswind
        contracts = listcontracts_industrial(assetName,...
                                        'WindCode',wcode,...
                                        'Exchange',exchange);
    else
        contracts = listcontracts_industrial(assetName,...
                                        'BloombergCode',bcode);
    end
%
else
    error(['invalid input of asset name:',assetName]);
end
    