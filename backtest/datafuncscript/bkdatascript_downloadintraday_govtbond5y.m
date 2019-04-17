ui_assetname = 'govtbond_5y';
updateflag = input('update rolltable or not:1-update / 0-not update:  ');
if updateflag
    ret = bkfunc_saverollinfotbl(ui_assetname);
    if ret
        fprintf('rollinfo table of 5y-govtbond saved...\n');
    else
        fprintf('failed to save rollinfo table of 5y-govtbond...\n');
        return
    end    
end
%%
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
if ret
    fprintf('rollinfo table of 5y-govtbond loaded...\n');
else
    fprintf('failed to load rollinfo table of 5y-govtbond...\n');
    return
end
%%
ret = bkdatafunc_loadintradaydata('assetname',ui_assetname,...
    'rolltable',tbl,...
    'firstfutures','TF1706');
if ret
    fprintf('intraday data for futures contract of 5y-govtbond downloaded...\n');
else
    fprintf('failed to download intraday data for futures contract of 5y-govtbond...\n');
end
%%
backhome

    

