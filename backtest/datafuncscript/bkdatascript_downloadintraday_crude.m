ui_assetname = 'crude';
updateflag = input('update rolltable or not:1-update / 0-not update:  ');
if updateflag
    ret = bkfunc_saverollinfotbl(ui_assetname);
    if ret
        fprintf('rollinfo table of crude saved...\n');
    else
        fprintf('failed to save rollinfo table of crude...\n');
        return
    end    
end
%%
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
if ret
    fprintf('rollinfo table of crude loaded...\n');
else
    fprintf('failed to load rollinfo table of crude...\n');
    return
end
%%
ret = bkdatafunc_loadintradaydata('assetname',ui_assetname,...
    'rolltable',tbl,...
    'firstfutures', 'sc1812');
if ret
    fprintf('intraday data for futures contract of crude downloaded...\n');
else
    fprintf('failed to download intraday data for futures contract of crude...\n');
end
%%
backhome