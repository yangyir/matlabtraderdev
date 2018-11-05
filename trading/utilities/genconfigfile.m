function [instruments] = genconfigfile(stratname,filename,varargin)
    if ~(strcmpi(stratname,'manual') || ...
           strcmpi(stratname,'batman') || ...
           strcmpi(stratname,'wlpr') || ...
           strcmpi(stratname,'wlprbatman'))
        error('genconfigfile:invalid stratname input:must either be manual,batman,wlpr or wlprbatman')
    end
    
    if strcmpi(stratname,'manual') 
        rownames = properties(cStratConfig);
        classname = 'cStratConfig';
    elseif strcmpi(stratname,'batman')
        rownames = properties(cStratConfigBatman);
        classname = 'cStratConfigBatman';
    elseif strcmpi(stratname,'wlpr')
        rownames = properties(cStratConfigWR);
        classname = 'cStratConfigWR';
    elseif strcmpi(stratname,'wlprbatman')
        rownames = properties(cStratConfigWRBatman);
        classname = 'cStratConfigWRBatman';
    end
    
    nrows = size(rownames,1);
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('instruments',{},@iscell);
    p.addParameter('types',{'all'},@iscell);
    
    p.parse(varargin{:});
    instruments = p.Results.instruments;
    if isempty(instruments)
        assettypes = p.Results.types;
        for i = 1:size(assettypes,1)
            assettype = assettypes{i};
            if ~(strcmpi(assettype,'eqindex') || ...
                strcmpi(assettype,'govtbond') || ...
                strcmpi(assettype,'preciousmetal') || ...
                strcmpi(assettype,'basemetal') || ...
                strcmpi(assettype,'energy') || ...
                strcmpi(assettype,'agriculture') || ...
                strcmpi(assettype,'industrial') || ...
                strcmpi(assettype,'all'))
                error('genconfigfile:invalid asset type input:must either be eqindex,govtbond,preciousmetal,basemetal,energy,agriculture,industrial or all') 
            end
        end
        [~,typelist] = getassetmaptable;
        lastbd = getlastbusinessdate;
        path = [getenv('DATAPATH'),'activefutures\activefutures_'];
        futlist = cDataFileIO.loadDataFromTxtFile([path,datestr(lastbd,'yyyymmdd'),'.txt']);
        instruments = cell(size(futlist,1),1);
        count = 0;
        for i = 1:size(futlist,1)
            type_i = typelist{i};
            ifound = false;
            for j = 1:size(assettypes,1)
                if strcmpi(type_i,assettypes{j}) || strcmpi('all',assettypes{j})
                    ifound = true;
                    break
                end
            end
            if ifound
                count = count + 1;
                instruments{count,1} = futlist{i};
            end
        end
        instruments = instruments(1:count,:);
    end
    %
    ncols = size(instruments,1);
    
    fid = fopen(filename,'w');
    for i = 1:nrows
        if strcmpi(rownames{i},'instrument_'), continue; end
        fprintf(fid,'%s\t',rownames{i}(1:end-1));
        for j = 1:ncols   
            if strcmpi(rownames{i},'name_')
                fprintf(fid,'%s',classname);
            elseif strcmpi(rownames{i},'codectp_')
                fprintf(fid,'%s',instruments{j});
            elseif strcmpi(rownames{i},'samplefreq_')
                fprintf(fid,'%s','15m');
            elseif strcmpi(rownames{i},'pnlstoptype_')
                fprintf(fid,'%s','ABS');
            elseif strcmpi(rownames{i},'pnlstop_')
                fprintf(fid,'%s','-9.99');
            elseif strcmpi(rownames{i},'pnllimittype_')
                fprintf(fid,'%s','ABS');
            elseif strcmpi(rownames{i},'pnllimit_')
                fprintf(fid,'%s','-9.99');
            elseif strcmpi(rownames{i},'bidopenspread_')
                fprintf(fid,'%s','0');
            elseif strcmpi(rownames{i},'bidclosespread_')
                fprintf(fid,'%s','0');
            elseif strcmpi(rownames{i},'askopenspread_')
                fprintf(fid,'%s','0');
            elseif strcmpi(rownames{i},'askclosespread_')
                fprintf(fid,'%s','0');
            elseif strcmpi(rownames{i},'baseunits_')
                fprintf(fid,'%s','1');
            elseif strcmpi(rownames{i},'maxunits_')
                fprintf(fid,'%s','10');
            elseif strcmpi(rownames{i},'autotrade_')
                if strcmpi(stratname,'wlpr') || strcmpi(stratname,'wlprbatman')
                    fprintf(fid,'%s','1');
                else
                    fprintf(fid,'%s','0');
                end
            elseif strcmpi(rownames{i},'executionperbucket_')
                fprintf(fid,'%s','1');
            elseif strcmpi(rownames{i},'maxexecutionperbucket_')
                fprintf(fid,'%s','1');
            %wlpr
            elseif strcmpi(rownames{i},'numofperiod_')
                fprintf(fid,'%s','144');
            elseif strcmpi(rownames{i},'overbought_')
                fprintf(fid,'%s','0');
            elseif strcmpi(rownames{i},'oversold_')
                fprintf(fid,'%s','-100');
            elseif strcmpi(rownames{i},'executiontype_')
                fprintf(fid,'%s','fixed');    
            %batman
            elseif strcmpi(rownames{i},'bandwidthmin_')
                fprintf(fid,'%s','0.333333');
            elseif strcmpi(rownames{i},'bandwidthmax_')
                fprintf(fid,'%s','0.5');
            elseif strcmpi(rownames{i},'bandstoploss_')
                fprintf(fid,'%s','0.01');
            elseif strcmpi(rownames{i},'bandtarget_')
                fprintf(fid,'%s','0.02');
            elseif strcmpi(rownames{i},'bandtype_')
                fprintf(fid,'%s','0');    
            else
                %TODO:add more properties
            end
            if j < ncols
                fprintf(fid,'\t');
            else
                fprintf(fid,'\n');
            end
        end

    end
    fclose(fid);
    
end


