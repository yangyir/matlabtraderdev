function [obj] = fromtable(obj,table)
    if ~iscell(table), error('cTradeOpenArray:fromtable:invalid table input');end
    
    nodeClassName = class(obj.node_);
    
    [nrows, ncols] = size(table);
    % find fields of open signal
    nsignalflds = 0;
    signalflds = cell(ncols,2);
    signalnameidx = -1;
    signalname = '';
    for i = 1:ncols
        if strfind(table{1,i},'opensignal_') == 1
            nsignalflds = nsignalflds + 1;
            signalflds{nsignalflds,1} = table{1,i}(length('opensignal_')+1:end);
            signalflds{nsignalflds,2} = i;
        end
        if strcmpi(table{1,i},'opensignal_name_')
            signalnameidx = i;
        end
    end
    signalflds = signalflds(1:nsignalflds,:);
    %sanity check to make sure all the open signals are the same
    if signalnameidx ~= -1
        signalname = table{2,signalnameidx};
        for i = 3:nrows
            if ~strcmpi(table{i,signalnameidx},signalname)
                error('cTradeOpenArray:fromtable:all trades shall have the same signal name')
            end
        end
    end
    
    %
    % find fields of risk manager
    nriskmanagerflds = 0;
    riskmanagerflds = cell(ncols,2);
    riskmanageridx = -1;
    riskmanagername = '';
    for i = 1:ncols
        if strfind(table{1,i},'riskmanager_') == 1
            nriskmanagerflds = nriskmanagerflds + 1;
            riskmanagerflds{nriskmanagerflds,1} = table{1,i}(length('riskmanager_')+1:end);
            riskmanagerflds{nriskmanagerflds,2} = i;
        end
        if strcmpi(table{1,i},'riskmanager_name_')
            riskmanageridx = i;
        end      
    end
    riskmanagerflds = riskmanagerflds(1:nriskmanagerflds,:);
    %sanity check to make sure all the risk managers are the same
    if riskmanageridx ~= -1
        riskmanagername = table{2,riskmanageridx};
        for i = 3:nrows
            if ~strcmpi(table{i,riskmanageridx},riskmanagername)
                error('cTradeOpenArray:fromtable:all trades shall have the same risk manager')
            end
        end
    end
    
    eval( ['obj.node_ = ' nodeClassName ';' ] );
   
    for i = 2:nrows
        eval( ['anode = ', nodeClassName, ';'] );
        for j = 1:ncols
            try
                fd = table{1,j};
                if isempty(strfind(fd,'opensignal_')) && isempty(strfind(fd,'riskmanager_'))
                    if strcmpi(fd,'instrument_'), continue;end
                    anode.(fd) = table{i,j};
                end
            catch
            end            
        end
        
        anode.instrument_ = code2instrument(anode.code_);
        %
        if signalnameidx ~= -1
            if strcmpi(signalname,'WilliamsR')
                signal = cWilliamsRInfo;
                for k = 1:size(signalflds,1)
                    if signalflds{k,2} == signalnameidx, continue;end
                    if strcmpi(table{i,signalflds{k,2}},'n/a')
                        try
                            signal.(signalflds{k,1}) = [];
                        catch
                            signal.(signalflds{k,1}) = '';
                        end
                    else
                        signal.(signalflds{k,1}) = table{i,signalflds{k,2}};
                    end
                end
            else
                error('signal name:%s not implemented',signalname);
            end
            anode.opensignal_ = signal;
        end
        %
        if riskmanageridx ~= -1
            if strcmpi(riskmanagername,'batman')
                riskmanager = struct;
                for k = 1:size(riskmanagerflds)
                    if riskmanagerflds{k,2} == riskmanageridx, continue;end
                    if strcmpi(table{i,riskmanagerflds{k,2}},'n/a')
                        riskmanager.(riskmanagerflds{k,1}) = [];
                    else
                        riskmanager.(riskmanagerflds{k,1}) = table{i,riskmanagerflds{k,2}};
                    end
                end
            else
                error('signal name:%s not implemented',riskmanagername);
            end
            anode.setriskmanager('name','batman','extrainfo',riskmanager);
        end
        %
        obj.node_(i-1) = anode;
        obj.latest_ = i-1;
    end
end