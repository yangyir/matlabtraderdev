function [resstruct] = charlotte_plot(varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('futcode','',@ischar);
p.addParameter('datefrom','',@ischar);
p.addParameter('dateto','',@ischar);
p.addParameter('frequency','intraday',@ischar);
p.addParameter('figureindex',2,@isnumeric);
p.parse(varargin{:});

futcode = p.Results.futcode;
dt1str = p.Results.datefrom;
dt2str = p.Results.dateto;
freq = p.Results.frequency;
if ~(strcmpi(freq,'intraday') || ...
        strcmpi(freq,'intraday-5m') || ...
        strcmpi(freq,'intrday-15m') || ...
        strcmpi(freq,'daily'))
    error('charlotte_plot:invalid frequency input,must be intraday,intraday-5m,intraday-15m or daily only...')
end
figureindex = p.Results.figureindex;

instrument = code2instrument(futcode);
if strcmpi(freq,'intraday-5m') || strcmpi(freq,'intraday-15m')
    if ~(strcmpi(instrument.asset_name,'govtbond_5y') || ...
            strcmpi(instrument.asset_name,'govtbond_10y') || ...
            strcmpi(instrument.asset_name,'govtbond_30y'))
        error('charlotte_plot:intraday-5m or intraday-15m is only supported with govtbond for now...')
    end
end

if strcmpi(freq,'intraday-5m')
    nfractal = 6;
elseif strcmpi(freq,'intraday-15m')
    nfractal = 4;
elseif strcmpi(freq,'intraday')
    nfractal = 4;
    if strcmpi(instrument.asset_name,'eqindex_300')
        data =load([getenv('onedrive'),'\matlabdev\eqindex\if\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'eqindex_50')
        data =load([getenv('onedrive'),'\matlabdev\eqindex\ih\',futcode,'.mat']);    
    elseif strcmpi(instrument.asset_name,'eqindex_500')
        data =load([getenv('onedrive'),'\matlabdev\eqindex\ic\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'eqindex_1000')
        data =load([getenv('onedrive'),'\matlabdev\eqindex\im\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'govtbond_5y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\tf\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'govtbond_10y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\t\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'govtbond_30y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\tl\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'gold')
        data =load([getenv('onedrive'),'\matlabdev\preciousmetal\au\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'silver')
        data =load([getenv('onedrive'),'\matlabdev\preciousmetal\ag\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'copper')
        data =load([getenv('onedrive'),'\matlabdev\basemetal\cu\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'aluminum')
        data =load([getenv('onedrive'),'\matlabdev\basemetal\al\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'zinc')
        data = load([getenv('onedrive'),'\matlabdev\basemetal\zn\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'lead')
        data = load([getenv('onedrive'),'\matlabdev\basemetal\pb\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'nickel')
        data = load([getenv('onedrive'),'\matlabdev\basemetal\ni\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'tin')
        data = load([getenv('onedrive'),'\matlabdev\basemetal\sn\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'pta')
        data =load([getenv('onedrive'),'\matlabdev\energy\ta\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'lldpe')
        data =load([getenv('onedrive'),'\matlabdev\energy\l\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'pp')
        data =load([getenv('onedrive'),'\matlabdev\energy\pp\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'methanol')
        data =load([getenv('onedrive'),'\matlabdev\energy\ma\',futcode,'.mat']);    
    elseif strcmpi(instrument.asset_name,'thermal coal')
        data =load([getenv('onedrive'),'\matlabdev\energy\zc\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'crude oil')
        data =load([getenv('onedrive'),'\matlabdev\energy\sc\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name, 'fuel oil')
        data =load([getenv('onedrive'),'\matlabdev\energy\fu\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'sugar')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\sr\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'cotton')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\cf\',futcode,'.mat']);    
    elseif strcmpi(instrument.asset_name,'corn')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\c\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name, 'egg')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\jd\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name, 'soybean')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\a\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'soymeal')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\m\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name, 'live hog')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\lh\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'soybean oil')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\y\',futcode,'.mat']);      
    elseif strcmpi(instrument.asset_name,'palm oil')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\p\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name, 'rapeseed oil')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\oi\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name, 'rapeseed meal')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\rm\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name, 'apple')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\ap\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'rubber')
        data =load([getenv('onedrive'),'\matlabdev\agriculture\ru\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'coke')
        data =load([getenv('onedrive'),'\matlabdev\industrial\j\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'coking coal')
        data =load([getenv('onedrive'),'\matlabdev\industrial\jm\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'deformed bar')
        data =load([getenv('onedrive'),'\matlabdev\industrial\rb\',futcode,'.mat']);    
    elseif strcmpi(instrument.asset_name,'iron ore')
        data =load([getenv('onedrive'),'\matlabdev\industrial\i\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'hotroiled coil')
        data =load([getenv('onedrive'),'\matlabdev\industrial\hc\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'glass')
        data =load([getenv('onedrive'),'\matlabdev\industrial\fg\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'lpg')
        data =load([getenv('onedrive'),'\matlabdev\energy\pg\',futcode,'.mat']);
    elseif strcmpi(instrument.asset_name,'soda ash')
        data =load([getenv('onedrive'),'\matlabdev\energy\sa\',futcode,'.mat']);
    else
        error('charlotte_plot:unsupported code %s...',futcode);
    end
    if isempty(data)
        error('charlotte_plot:intraday data load failure,pls check!!!')
    end
    p = data.data;
elseif strcmpi(freq,'daily')
    nfractal = 2;
    data = cDataFileIO.loadDataFromTxtFile([futcode,'_daily.txt']);
    try
        p = data(:,1:5);
    catch
        error('charlotte_plot:daily data load failure,pls check!!!')
    end
end

[res,resstruct] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);
res(:,1) = x2mdate(res(:,1));

set(0,'defaultfigurewindowstyle','docked');

if isempty(dt1str) && isempty(dt2str)
    if size(res,1) > 80
        tools_technicalplot2(res(end-79:end,:),figureindex,[futcode,'-',freq],true);
    else
        tools_technicalplot2(res(1:end,:),figureindex,[futcode,'-',freq],true);
    end
elseif ~isempty(dt1str) && isempty(dt2str)
    dt1num = datenum(dt1str,'yyyy-mm-dd HH:MM');
    idx = find(res(:,1)>=dt1num,1,'first');
    if ~isempty(idx)
        tools_technicalplot2(res(idx:end,:),figureindex,[futcode,'-',freq],true);
    else
        error('charlotte_script:invalid datefrom input...')
    end
elseif isempty(dt1str) && ~isempty(dt2str)
    dt2num = datenum(dt2str,'yyyy-mm-dd HH:MM');
    idx = find(res(:,1)<=dt2num,1,'last');
    if ~isempty(idx)
        tools_technicalplot2(res(1:idx,:),figureindex,[futcode,'-',freq],true);
    else
        error('charlotte_script:invalid datefrom input...')
    end
elseif ~isempty(dt1str) && ~isempty(dt2str)
    dt1num = datenum(dt1str,'yyyy-mm-dd HH:MM');
    dt2num = datenum(dt2str,'yyyy-mm-dd HH:MM');
    idx = res(:,1)>=dt1num & res(:,1)<=dt2num;
    d = res(idx,:);
    if ~isempty(d)
        tools_technicalplot2(d,figureindex,[futcode,'-',freq],true);
    else
        error('charlotte_script:invalid datefrom and dateto input...')
    end

end