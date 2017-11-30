function [] = registeroptions(stratopt,code_ctp_underlier,numoptions)
    if nargin < 3
        [calls,puts,underlier] = getlistedoptions(code_ctp_underlier);
    else
        [calls,puts,underlier] = getlistedoptions(code_ctp_underlier,numoptions);
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
%end of registeroptions