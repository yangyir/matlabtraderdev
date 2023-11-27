function mdefx = init(mdefx,varargin)
%cMDEFX
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','mdefx',@ischar);
    p.addParameter('Pairs',{},@iscell);
    p.addParameter('TradesDirectory','',@ischar);
    p.parse(varargin{:});
    mdefx.name_ = p.Results.Name;
    pairs = p.Results.Pairs;
    tradesdir = p.Results.TradesDirectory;
    if isempty(tradesdir)
        tradesdir = 'E:\matlabdatabase\bookfx\';
    end
    mdefx.trades_dir_ = tradesdir;    
    
    npairs = size(pairs,1);
    codes_fx = cell(npairs,1);
    instruments_fx = cell(npairs,1);
    for i = 1:npairs
        fx = code2instrument(pairs{i});
        codes_fx{i} = fx.code_wind;
        instruments_fx{i} = fx;
    end
    mdefx.codes_fx_ = codes_fx;
    mdefx.instruments_fx_ = instruments_fx;
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
            mdefx.dailybar_fx_{i} = cDataFileIO.loadDataFromTxtFile([getenv('datapath'),'globalmacro\',pairs{i},'_daily.txt']);
            [mdefx.mat_fx_{i},mdefx.struct_fx_{i}] = tools_technicalplot1(mdefx.dailybar_fx_{i},2,false);
            mdefx.mat_fx_{i}(:,1) = x2mdate(mdefx.mat_fx_{i}(:,1));
        catch
            fprintf('cMDEFX:data not loaded for %s...\n',pairs{i});
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
    %
    % load kelly tables
    try
        dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
        fn_ = 'strat_daily_fx.mat';
        d = load([dir_,fn_]);
        props = fields(d);
        mdefx.kelly_table_ = d.(props{1});
    catch
        fprintf('cMDEFX:init:load_kelly_daily:error!!!\n')
    end
    
end 