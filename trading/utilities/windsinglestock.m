function [ei,info,trade] = windsinglestock(w,code,varargin)
%utility function to retrieve trade information of input single stock
%input variables:
%   w:cWind
%   code:string
%output variables:
%   ei:struct of all useful variables calculated
%   info:information of single stocks, including market cap, pe,eps,pb and
%   etc
%   trade:last valid trade, generally with long direction only
    if ~isa(w,'cWind'), error('windsinglestock:invalid cWind input');end
    if ~ischar(code),error('windsinglestock:invalid code input');end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('direction','long',@ischar);
    p.addParameter('lasttrade',true,@islogical);
    p.addParameter('plot',true,@islogical);
    p.addParameter('debug',true,@islogical);
    p.parse(varargin{:});
    direction = p.Results.direction;
    plotflag = p.Results.plot;
    debugflag = p.Results.debug;
    if ~(strcmpi(direction,'long') ...
            || strcmpi(direction,'short') ...
            || strcmpi(direction,'both'))
        error('windsinglestock:invalid direction input')
    end
    
    stock = code2instrument(code);
    if isempty(stock.asset_name)
        stock.init(w);
        stock.saveinfo([getenv('DATAPATH'),'info_stock\',code,'_info.txt']);
    end
    %1.first load daily data from driver and check whether the last record
    %is on the last business date
    dailybar = cDataFileIO.loadDataFromTxtFile([code,'_daily.txt']);
    lastbd = getlastbusinessdate;
    lastrd = dailybar(end,1);
    
    if lastrd < lastbd
        savedailybarfromwind2(w,code);
        dailybar = cDataFileIO.loadDataFromTxtFile([code,'_daily.txt']);
        lastrd = dailybar(end,1);
        if lastrd < lastbd
            data_new = w_.ds_.wsq(obj.codes_index_,'rt_date,rt_open,rt_high,rt_low,rt_latest');
            dailybar = [dailybar;data_new];   
        end
    end
    [~,ei] = tools_technicalplot1(dailybar,2,false);
    
    wdata = w.ds_.wss(stock.code_wind,'ev,pe_ttm,eps_ttm,pb_lf');
    industrysw1 = w.ds_.wss(stock.code_wind,'industry_sw',['tradeDate=',datestr(getlastbusinessdate,'yyyymmdd'),';industryType=1']);
    industrysw2 = w.ds_.wss(stock.code_wind,'industry_sw',['tradeDate=',datestr(getlastbusinessdate,'yyyymmdd'),';industryType=2']);
    info = struct('code',code,...
        'assetname',stock.asset_name,...
        'marketcap',wdata(1),...
        'pe',wdata(2),...
        'eps',wdata(3),...
        'pb',wdata(4),...
        'industry1',industrysw1,...
        'industry2',industrysw2);
    
    if strcmpi(direction,'short') || strcmpi(direction,'both')
        fprintf('windsinglestock:not implemented with short or both directions...\n');
        return
    end
    
    trade = fractal_latestposition('code',code,'extrainfo',ei,'usefractalupdate',0);
    if ~isempty(trade)
        if trade.opendirection_ == 1
            fractal_tradeinfo_anyb('code',code,'openid',trade.id_,'extrainfo',ei,'debug',debugflag,'plot',plotflag,'usefractalupdate',0);
        else
            fractal_tradeinfo_anys('code',code,'openid',trade.id_,'extrainfo',ei,'debug',debugflag,'plot',plotflag,'usefractalupdate',0);
        end
    end
    
    
    
end

