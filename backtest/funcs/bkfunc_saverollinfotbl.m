function [ret] = bkfunc_saverollinfotbl(assetname)
 
    assets = getassetmaptable;
    nassets = size(assets,1);
    flag = false;
    for i = 1:nassets
        if strcmpi(assetname,assets{i})
            flag = true;
            break
        end
    end
    if ~flag, 
        fprintf('Error:bkfunc_saverollinfotbl:invald assetname input');
        ret = 0;
        return
    end
            
    try
        [rollinfo,~] = bkfunc_genfutrollinfo(assetname);
    catch e
        fprintf('Error:bkfunc_saverollinfotbl:%s\n',e.message);
        ret = 0;
        return
    end
    
    coldefs = {'RollDateNum';'NumofRecords1';'NumofRecords2';'Fut1';'Fut2';'RollDateStr'};
    dataoutput = cell(size(rollinfo,1)+1,size(rollinfo,2));
    dataoutput(1,:) = coldefs;
    dataoutput(2:end,:) = rollinfo;
    
    dir_ = getenv('DATAPATH');
    info = getassetinfo(assetname);
    xlsxfn = [info.AssetNameMap,'_RollInfo.xlsx'];
    try
        xlswrite([dir_,xlsxfn], dataoutput, 'Sheet1');
    catch e
        fprintf('Error:bkfunc_saverollinfotbl:%s\n',e.message);
        ret = 0;
        return
    end
    ret = 1;
end

