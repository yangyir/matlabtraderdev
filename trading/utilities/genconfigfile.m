function [instruments] = genconfigfile(stratname,filename,varargin)
    if ~(strcmpi(stratname,'manual') || ...
           strcmpi(stratname,'batman') || ...
           strcmpi(stratname,'wlpr') || ...
           strcmpi(stratname,'wlprbatman') || ...
           strcmpi(stratname,'fractal'))
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
    elseif strcmpi(stratname,'fractal')
        rownames = properties(cStratConfigFractal);
        classname = 'cStratConfigFractal';
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
                strcmpi(assettype,'all') || ...
                strcmpi(assettype,'equity'))
                error('genconfigfile:invalid asset type input:must either be eqindex,govtbond,preciousmetal,basemetal,energy,agriculture,industrial,all or equity') 
            end
            if strcmpi(assettype, 'equity')
                warning('genconfigfile:asset type equity not supported with empty instrument input...')
            end
        end
        %note:the code below doesn't support with equity
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
                fprintf(fid,'%s','30m');%default 30m interval
            elseif strcmpi(rownames{i},'riskmanagername_')
                fprintf(fid,'%s','standard');
            elseif strcmpi(rownames{i},'stoptypepertrade_')
                fprintf(fid,'%s','ABS');
            elseif strcmpi(rownames{i},'stopamountpertrade_')
                fprintf(fid,'%s','-9.99');
            elseif strcmpi(rownames{i},'limittypepertrade_')
                fprintf(fid,'%s','ABS');
            elseif strcmpi(rownames{i},'limitamountpertrade_')
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
            elseif strcmpi(rownames{i},'use_')
                fprintf(fid,'%s','1');
            %wlpr
            elseif strcmpi(rownames{i},'wrmode_')
                fprintf(fid,'%s','classic');
            elseif strcmpi(rownames{i},'includelastcandle_')
                fprintf(fid,'%s','0');
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
                fprintf(fid,'%s','-9.99');
            elseif strcmpi(rownames{i},'bandtarget_')
                fprintf(fid,'%s','-9.99');
            elseif strcmpi(rownames{i},'bandtype_')
                fprintf(fid,'%s','0');
            %fractal
            elseif strcmpi(rownames{i},'tdsqlag_')
                fprintf(fid,'%s','4');
            elseif strcmpi(rownames{i},'tdsqconsecutive_')
                fprintf(fid,'%s','9');
            elseif strcmpi(rownames{i},'nfractals_')
                fprintf(fid,'%s','4');
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


