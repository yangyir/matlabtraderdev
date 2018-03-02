function [] = registeroptionswithstrikes(stratopt,code_ctp_underlier,strikes)

    underlier = cFutures(code_ctp_underlier);
    underlier.loadinfo([code_ctp_underlier,'_info.txt']); 
    numstrikes = length(strikes);
    code_c = cell(numstrikes,1);
    code_p = cell(numstrikes,1);
    calls = cell(numstrikes,1);
    puts = cell(numstrikes,1);
    
    if ~isempty(strfind(code_ctp_underlier,'m'))
        for i = 1:numstrikes
            code_c{i} = [code_ctp_underlier,'-C-',num2str(strikes(i))];
            calls{i} = cOption(code_c{i});
            calls{i}.loadinfo([code_c{i},'_info.txt']);
            %
            code_p{i} = [code_ctp_underlier,'-P-',num2str(strikes(i))];
            puts{i} = cOption(code_p{i});
            puts{i}.loadinfo([code_p{i},'_info.txt']);
            
        end
    elseif ~isempty(strfind(code_ctp_underlier,'SR'))
        for i = 1:numstrikes
            code_c{i} = [code_ctp_underlier,'C',num2str(strikes(i))];
            calls{i} = cOption(code_c{i});
            calls{i}.loadinfo([code_c{i},'_info.txt']);
            %
            code_p{i} = [code_ctp_underlier,'P',num2str(strikes(i))];
            puts{i} = cOption(code_p{i});
            puts{i}.loadinfo([code_p{i},'_info.txt']);
        end
    else
        error('getlistedoptions:unknown underlier')
    end

    for i = 1:size(calls,1)
        stratopt.registerinstrument(calls{i});
        stratopt.registerinstrument(puts{i});
        %
        stratopt.mde_opt_.registerinstrument(calls{i});
        stratopt.mde_opt_.registerinstrument(puts{i});
    end

    stratopt.setriskvalue(underlier,'delta',0);

    [~,idxu] = stratopt.underliers_.hasinstrument(underlier);
    data = cDataFileIO.loadDataFromTxtFile([underlier.code_ctp,'_daily.txt']);
    priceunderlier = data(data(:,1)==datenum(getlastbusinessdate),end);
    if isempty(priceunderlier)
        error(['underlier ',underlier.code_ctp,' historical price not saved!'])
    end
    stratopt.closeyesterday_underlier_(idxu,1) = priceunderlier;

end
%end of registeroptionswithstrikes