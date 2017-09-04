function obj = loadobjfromfile(objHandle,objType)
%todo:re-writeup once the object database is done

    directory = [getenv('home'),'objs\'];

    if strcmpi(objType,'yieldcurve')
        currency = objHandle(1:3);
        valdate = datenum(objHandle(4:end),'yyyymmdd');
        obj = CreateObj(objHandle,'YieldCurve','ValuationDate',valdate,...
            'Currency',currency);
        
    elseif strcmpi(objType,'vol')
        temp = load([directory,'vol\',objHandle]);
        info = temp.volinfo;
        assetname = info.AssetName;
        refspot = info.ReferenceSpot;
        strikes = info.Strikes;
        expiries = info.Expiries;
        vols = info.Vols;
        
        obj = CreateObj(objHandle,objType,'VolName','MarketVol',...
            'VolType','StrikeVol',...
            'AssetName',assetname,...
            'InterpolationMethod','Next',...
            'ReferenceSpot',refspot,...
            'Strikes',strikes,...
            'Expiries',expiries,...
            'Vols',vols);
        
    elseif strcmpi(objType,'mktdata')
        temp = load([directory,'mktdata\',objHandle]);
        obj = temp.mktdata;
    elseif strcmpi(objType,'model')
        temp = load([directory,'model\',objHandle]);
        info = temp.modelinfo;
        obj = CreateObj(objHandle,objType,'ModelName',info.ModelName,...
            'CalcIntrinsic',info.CalcIntrinsic,...
            'ExtraResults',info.ExtraResults);
    else
        error('loadobjfromfile:invalid or unknown object type')
    end
    
end