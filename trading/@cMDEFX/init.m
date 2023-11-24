function mdefx = init(mdefx,varargin)
%cMDEFX
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','mdefx',@ischar);
    p.addParameter('Pairs',{},@iscell);
    p.parse(varargin{:});
    mdefx.name_ = p.Results.Name;
    mdefx.codes_fx_ = p.Results.Pairs;

    %
    %refresh every second
    mdefx.settimerinterval(1);
    %
    npairs = size(mdefx.codes_fx_,1);
    mdefx.dailybar_fx_ = cell(npairs,1);
    mdefx.mat_fx_ = cell(npairs,1);
    mdefx.struct_fx_ = cell(npairs,1);
    for i = 1:npairs
        try
            mdefx.dailybar_fx_{i} = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'macrochina\',mdefx.codes_fx_{i},'_daily.txt']);
            [mdefx.mat_fx_{i},mdefx.struct_fx_{i}] = tools_technicalplot1(mdefx.dailybar_fx_{i},2,false);
            mdefx.mat_fx_{i}(:,1) = x2mdate(mdefx.mat_fx_{i}(:,1));
        catch
        end
    end
    %
    if npairs == 0, return,end
    %
    try
        mdefx.w_ = cWind;
    catch
        mdefx.w_ = [];
    end
end 