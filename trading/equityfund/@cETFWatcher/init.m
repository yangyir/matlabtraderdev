function obj = init(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Name','etfwatcher',@ischar);
    p.parse(varargin{:});
    obj.name_ = p.Results.Name;
    %
    %other default values
    obj.conn_ = cWind;
    obj.settimerinterval(60);
    %
    obj.codes_index_ = {'510050.SH';...%上证50
        '510300.SH';...%沪深300
        '510500.SH';...%中证500
        '159915.SZ';...%创业板ETF
        '588000.SH';...%科创50ETF
        '588400.SH';...%双创50ETF
        '512100.SH';...%中证1000
    };
    %
    obj.codes_sector_ = {'512880.SH';'512000.SH';...%证券ETF
        '515290.SH';'512800.SH';...%银行ETF
        '159928.SZ';...%消费ETF
        '512690.SH';...%酒ETF
        '512170.SH';...%医疗ETF
        '512010.SH';...%医药ETF
        '515030.SH';...%新能源车ETF
        '515790.SH';...%光伏ETF
        '516160.SH';...%新能源ETF
        '512400.SH';...%有色金属ETF
        '515050.SH';...%5G ETF
        '159995.SZ';...%芯片ETF
        '512660.SH';...%军工ETF
        '510880.SH';...%红利ETF
        '512960.SH';...%央调ETF
        '159870.SZ';...%化工
        '515210.SH';...%钢铁
        '515220.SH';...%煤炭
        '159930.SZ';...%能源
        '516970.SH';...%基建
        '512980.SH';...%传媒
        '159865.SZ';...%养殖ETF
        '159825.SZ';...%农业ETF 
    };
    %
    obj.codes_stock_ = {'688017.SH';...%绿的谐波
        '688686.SH';...%奥普特
        '688305.SH';....%科德数控
        '688690.SH';...%纳微科技
        '000661.SZ';...%长春高新
    };

    obj.names_index_ = obj.conn_.ds_.wss(obj.codes_index_,'sec_name');
    obj.names_sector_ = obj.conn_.ds_.wss(obj.codes_sector_,'sec_name');
    obj.names_stock_ = obj.conn_.ds_.wss(obj.codes_stock_,'sec_name');
    %
    %
    obj.reload;
    
    
end 