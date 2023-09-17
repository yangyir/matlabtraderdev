function macrocn = init(macrocn,varargin)
%cMacroCN
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','macrocn',@ischar);
    p.addParameter('GovtBondFutures',{},@iscell);
%     p.addParameter('GovtBonds',{},@iscell);
    p.parse(varargin{:});
    macrocn.name_ = p.Results.Name;
    macrocn.codes_govtbondfut_ = p.Results.GovtBondFutures;
%     macrocn.codes_govtbond_ = p.Results.GovtBonds;
    macrocn.codes_govtbond_ = {'TB1Y.WI';'TB3Y.WI';'TB5Y.WI';'TB7Y.WI';'TB10Y.WI';'TB30Y.WI'};
    %
    try
        macrocn.w_ = cWind;
    catch
        macrocn.w_ = [];
    end
    %
    %refresh every minute
    macrocn.settimerinterval(1);
    %
    try
        macrocn.dailybar_dr007_ = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'macrochina\dr007_daily.txt']);
    catch
    end
    
    nfut = size(macrocn.codes_govtbondfut_,1);
    macrocn.dailybar_govtbondfut_ = cell(nfut,1);
    macrocn.mat_govtbondfut_ = cell(nfut,1);
    macrocn.struct_govtbondfut_ = cell(nfut,1);
    for i = 1:nfut
        try
            macrocn.dailybar_govtbondfut_{i} = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'macrochina\',macrocn.codes_govtbondfut_{i},'_daily.txt']);
        catch
        end
    end
    
    for i = 1:nfut
        fut = code2instrument(macrocn.codes_govtbondfut_{i});
        macrocn.codes_govtbondfut_{i} = fut.code_wind;
    end
    
    nbond = size(macrocn.codes_govtbond_,1);
    macrocn.dailybar_govtbondyields_ = cell(nbond,1);
    macrocn.mat_govtbondyields_ = cell(nbond,1);
    macrocn.struct_govtbondyields_ = cell(nbond,1);
    codes = {'tb01y';'tb03y';'tb05y';'tb07y';'tb10y';'tb30y'};
    for i = 1:length(codes)
        try
            macrocn.dailybar_govtbondyields_{i} = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'macrochina\',codes{i},'_daily.txt']);
        catch
        end
    end
    
    try
        macrocn.dailybar_fx_ = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'macrochina\usdcnh_daily.txt']);
    catch
    end
    %
    try
        macrocn.dailybar_eqindex_ = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'macrochina\csi300_daily.txt']);
    catch
    end
    %
end 