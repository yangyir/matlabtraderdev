function [ret,tbl] = bkfunc_loadrollinfotbl(assetname)
    dir_ = getenv('DATAPATH');
    if strcmpi(assetname,'crude')
        assetname = 'crude oil';
    end
    info = getassetinfo(assetname);
    xlsxfn = [info.AssetNameMap,'_RollInfo.xlsx'];
    try
        [~,~,tbl] = xlsread([dir_,xlsxfn],'Sheet1');
        ret = 1;
    catch e
        fprintf('Error:bkfunc_loadrollinfotbl:%s\n',e.message);
        ret = 0;
        return
    end
    
end