ui_assetname = 'eqindex_300';
updateflag = input('update rolltable or not:1-update / 0-not update:  ');
if updateflag
    ret = bkfunc_saverollinfotbl(ui_assetname);
    if ret
        fprintf('rollinfo table of eqindex_300 saved...\n');
    else
        fprintf('failed to save rollinfo table of eqindex_300...\n');
        return
    end    
end
%%
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
if ret
    fprintf('rollinfo table of eqindex_300 loaded...\n');
else
    fprintf('failed to load rollinfo table of eqindex_300...\n');
    return
end
%%
ret = bkdatafunc_loadintradaydata('assetname',ui_assetname,...
    'rolltable',tbl,...
    'firstfutures','IF1809');
if ret
    fprintf('intraday data for futures contract of eqindex_300 downloaded...\n');
else
    fprintf('failed to download intraday data for futures contract of eqindex_300...\n');
end
%%
backhome

    

