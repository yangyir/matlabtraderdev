ui_assetname = 'eqindex_50';
updateflag = input('update rolltable or not:1-update / 0-not update:  ');
if updateflag
    ret = bkfunc_saverollinfotbl(ui_assetname);
    if ret
        fprintf('rollinfo table of eqindex_50 saved...\n');
    else
        fprintf('failed to save rollinfo table of eqindex_50...\n');
        return
    end    
end
%%
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
if ret
    fprintf('rollinfo table of eqindex_50 loaded...\n');
else
    fprintf('failed to load rollinfo table of eqindex_50...\n');
    return
end
%%
ret = bkdatafunc_loadintradaydata('assetname',ui_assetname,...
    'rolltable',tbl,...
    'firstfutures','IH1809');
if ret
    fprintf('intraday data for futures contract of eqindex_50 downloaded...\n');
else
    fprintf('failed to download intraday data for futures contract of eqindex_50...\n');
end
%%
backhome

    

