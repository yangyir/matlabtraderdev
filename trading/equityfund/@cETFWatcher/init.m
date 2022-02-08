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
    
    [~,~,codes_index,codes_sector,codes_stock] = isinequitypool('');
    
    n_index = length(codes_index);codes_index_wind = cell(n_index,1);names_index = cell(n_index,1);
    n_sector = length(codes_sector);codes_sector_wind = cell(n_sector,1);names_sector = cell(n_sector,1);
    n_stock = length(codes_stock);codes_stock_wind = cell(n_stock,1);names_stock = cell(n_stock,1);

    for i = 1:n_index
        if strcmpi(codes_index{i}(1),'5') || strcmpi(codes_index{i}(1),'6') 
            codes_index_wind{i} = [codes_index{i},'.SH'];
        else
            codes_index_wind{i} = [codes_index{i},'.SZ'];
        end
        wdata = obj.conn_.ds_.wss(codes_index_wind{i},'sec_name');
        names_index{i} = wdata{1};
    end

    for i = 1:n_sector
        if strcmpi(codes_sector{i}(1),'5') || strcmpi(codes_sector{i}(1),'6') 
            codes_sector_wind{i} = [codes_sector{i},'.SH'];
        else
            codes_sector_wind{i} = [codes_sector{i},'.SZ'];
        end
        wdata = obj.conn_.ds_.wss(codes_sector_wind{i},'sec_name');
        names_sector{i} = wdata{1};
    end

    for i = 1:n_stock
        if strcmpi(codes_stock{i}(1),'5') || strcmpi(codes_stock{i}(1),'6') 
            codes_stock_wind{i} = [codes_stock{i},'.SH'];
        else
            codes_stock_wind{i} = [codes_stock{i},'.SZ'];
        end
        wdata = obj.conn_.ds_.wss(codes_stock_wind{i},'sec_name');
        names_stock{i} = wdata{1};
    end
    
    obj.codes_index_ = codes_index_wind;
    obj.codes_sector_ = codes_sector_wind;
    obj.codes_stock_ = codes_stock_wind;
%     obj.codes_index_ = {'510050.SH';...%上证50
%         '510300.SH';...%沪深300
%         '510500.SH';...%中证500
%         '159915.SZ';...%创业板ETF
%         '588000.SH';...%科创50ETF
%         '588400.SH';...%双创50ETF
%         '512100.SH';...%中证1000
%     };
    %
%     obj.codes_sector_ = {'512880.SH';'512000.SH';...%证券ETF
%         '515290.SH';'512800.SH';...%银行ETF
%         '159928.SZ';...%消费ETF
%         '512690.SH';...%酒ETF
%         '512170.SH';...%医疗ETF
%         '512010.SH';...%医药ETF
%         '515030.SH';...%新能源车ETF
%         '515790.SH';...%光伏ETF
%         '516160.SH';...%新能源ETF
%         '512400.SH';...%有色金属ETF
%         '515050.SH';...%5G ETF
%         '159995.SZ';...%芯片ETF
%         '512660.SH';...%军工ETF
%         '510880.SH';...%红利ETF
%         '512960.SH';...%央调ETF
%         '159870.SZ';...%化工
%         '515210.SH';...%钢铁
%         '515220.SH';...%煤炭
%         '159930.SZ';...%能源
%         '516970.SH';...%基建
%         '512980.SH';...%传媒
%         '159865.SZ';...%养殖ETF
%         '159825.SZ';...%农业ETF 
%     };
%     %
%     obj.codes_stock_ = {'688017.SH';...%绿的谐波
%         '688686.SH';...%奥普特
%         '688305.SH';....%科德数控
%         '688690.SH';...%纳微科技
%         '000661.SZ';...%长春高新
%     };

    obj.names_index_ = names_index;
    obj.names_sector_ = names_sector;
    obj.names_stock_ = names_stock;
    %
    %
    obj.reload;
    
    
end 