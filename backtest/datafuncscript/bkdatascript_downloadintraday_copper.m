ui_assetname = 'copper';
updateflag = input('update rolltable or not:1-update / 0-not update:  ');
if updateflag
    ret = bkfunc_saverollinfotbl(ui_assetname);
    if ret
        fprintf('rollinfo table of copper saved...\n');
    else
        fprintf('failed to save rollinfo table of copper...\n');
        return
    end    
end
%%
[ret,tbl] = bkfunc_loadrollinfotbl(ui_assetname);
if ret
    fprintf('rollinfo table of copper loaded...\n');
else
    fprintf('failed to load rollinfo table of copper...\n');
    return
end
%%
ret = bkdatafunc_loadintradaydata('assetname',ui_assetname,...
    'rolltable',tbl,...
    'firstfutures', 'cu1709');
if ret
    fprintf('intraday data for futures contract of copper downloaded...\n');
else
    fprintf('failed to download intraday data for futures contract of copper...\n');
end
%%
backhome