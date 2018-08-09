function [ table, headers ] = totable(obj, start_pos, end_pos)
    if ~exist('start_pos', 'var')
        start_pos = 1;
    end

    if ~exist('end_pos', 'var')
        end_pos = start_pos + length(obj.node_) - 1; 
    end    

    trades = obj.node_(start_pos : end_pos);
    N = length(trades);

    %assume all the trades are using the same opensignal and riskmanager
    %approach
    flds = properties( trades );
    F = length(flds);
    headers = cell(255,1);
    table = cell(N+1,255);
    ncols = 0;
    
    for i = 1:N
        trade = trades(i);
        ncols = 0;
        for j = 1:F
            propname = flds{j};
            propvalue = trade.(propname);
            if strcmpi(propname,'opensignal_')
                if isempty(propvalue)
                    ncols = ncols + 1;
                    table{i+1,ncols} = 'n/a';
                    if i == 1, headers{ncols,1} = propname;end
                    if i == 1, table{1,ncols} = propname;end
                else
                    if isa(propvalue,'cWilliamsRInfo')
                        flds_info = properties(cWilliamsRInfo);
                        for k = 1:size(flds_info)
                            ncols = ncols + 1;
                            table{i+1,ncols} = propvalue.(flds_info{k});
                            if i == 1, headers{ncols,1} = [propname,flds_info{k}];end
                            if i == 1, table{1,ncols} = [propname,flds_info{k}];end
                        end
                    else
                        error('opensignal not implemented')
                    end
                end
            elseif strcmpi(propname,'riskmanager_')
                if isempty(propvalue)
                    ncols = ncols + 1;
                    table{i+1,ncols} = 'n/a';
                    if i == 1, headers{ncols,1} = propname;end
                    if i == 1, table{1,ncols} = propname;end
                elseif isa(propvalue,'cBatman')
                    flds_info = properties(cBatman);
                    for k = 1:size(flds_info)
                        if strcmpi(flds_info{k},'trade_'), continue;end
                        ncols = ncols + 1;
                        val = propvalue.(flds_info{k});
                        if isempty(val)
                            table{i+1,ncols} = 'n/a';
                        else
                            table{i+1,ncols} = val;
                        end
                        if i == 1, headers{ncols,1} = [propname,flds_info{k}];end
                        if i == 1, table{1,ncols} = [propname,flds_info{k}];end
                    end
                elseif isa(propvalue,'cStandard')
                    flds_info = properties(cStandard);
                    for k = 1:size(flds_info)
                        if strcmpi(flds_info{k},'trade_'), continue;end
                        ncols = nclos + 1;
                        table{i+1,ncols} = propvalue.(flds_info{k});
                        if i == 1, headers{ncols,1} = [propname,flds_info{k}];end
                        if i == 1, table{1,ncols} = [propname,flds_info{k}];end
                    end
                else
                    error('riskmanager not implemented');
                end
            elseif strcmpi(propname,'instrument_')
                continue;
%                 ncols = ncols + 1;
%                 table{i+1,ncols} = '';
%                 if i == 1, headers{ncols,1} = propname;end
%                 if i == 1, table{1,ncols} = propname;end
            else
                ncols = ncols + 1;
                if isempty(propvalue)
                    table{i+1,ncols} = 'n/a';
                else
                    table{i+1,ncols} = propvalue;
                end
                if i == 1, headers{ncols,1} = propname;end
                if i == 1, table{1,ncols} = propname;end
            end
        end
    end
    
    table = table(:,1:ncols);

    obj.table_   = table;
    obj.headers_ = headers;

end