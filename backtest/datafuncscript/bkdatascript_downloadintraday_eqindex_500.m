ui_assetname = 'eqindex_500';
updateflag = input('update rolltable or not:1-update / 0-not update:  ');
if updateflag
    ret = bkfunc_saverollinfotbl(ui_assetname);
    if ret
        fprintf('rollinfo table of eqindex_500 saved...\n');
    else
        fprintf('failed to save rollinfo table of eqindex_500...\n');
        return
    end    
end
%%
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
if ret
    fprintf('rollinfo table of eqindex_500 loaded...\n');
else
    fprintf('failed to load rollinfo table of eqindex_500...\n');
    return
end
%%
ret = bkdatafunc_loadintradaydata('assetname',ui_assetname,...
    'rolltable',tbl,...
    'firstfutures','IC1809');
if ret
    fprintf('intraday data for futures contract of eqindex_500 downloaded...\n');
else
    fprintf('failed to download intraday data for futures contract of eqindex_500...\n');
end
%%
backhome

    

