function [resmat,resstruct] = charlotte_loaddata(varargin)
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('futcode','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.parse(varargin{:});

futcode = p.Results.futcode;
freq = p.Results.frequency;
if ~(strcmpi(freq,'30m') || ...
        strcmpi(freq,'5m') || ...
        strcmpi(freq,'15m') || ...
        strcmpi(freq,'1440m'))
    error('charlotte_loaddata:invalid frequency input,must be 30m,5m,15m and 1440m only...')
end

instrument = code2instrument(futcode);
if strcmpi(freq,'5m') || strcmpi(freq,'15m')
    if ~(strcmpi(instrument.asset_name,'govtbond_5y') || ...
            strcmpi(instrument.asset_name,'govtbond_10y') || ...
            strcmpi(instrument.asset_name,'govtbond_30y'))
        error('charlotte_loaddata:5m or 15m is only supported with govtbond fut for now...')
    end
end

if strcmpi(freq,'5m')
    nfractal = 6;
    if strcmpi(instrument.asset_name,'govtbond_5y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\tf\',futcode,'_5m.mat']);
    elseif strcmpi(instrument.asset_name,'govtbond_10y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\t\',futcode,'_5m.mat']);
    elseif strcmpi(instrument.asset_name,'govtbond_30y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\tl\',futcode,'_5m.mat']);
    end
    p = data.data;
elseif strcmpi(freq,'15m')
    nfractal = 4;
    if strcmpi(instrument.asset_name,'govtbond_5y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\tf\',futcode,'_15m.mat']);
    elseif strcmpi(instrument.asset_name,'govtbond_10y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\t\',futcode,'_15m.mat']);
    elseif strcmpi(instrument.asset_name,'govtbond_30y')
        data =load([getenv('onedrive'),'\matlabdev\govtbond\tl\',futcode,'_15m.mat']);
    end
    p = data.data;
elseif strcmpi(freq,'30m')
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
    elseif strcmpi(instrument.asset_name,'pvc')
        data =load([getenv('onedrive'),'\matlabdev\industrial\v\',futcode,'.mat']);
    else
        error('charlotte_loaddata:unsupported code %s...',futcode);
    end
    if isempty(data)
        error('charlotte_loaddata:intraday data load failure,pls check!!!')
    end
    p = data.data;
elseif strcmpi(freq,'1440m')
    nfractal = 2;
    data = cDataFileIO.loadDataFromTxtFile([futcode,'_daily.txt']);
    try
        p = data(:,1:5);
    catch
        error('charlotte_loaddata:daily data load failure,pls check!!!')
    end
end

[resmat,resstruct] = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0);

resmat(:,1) = x2mdate(resmat(:,1));

end