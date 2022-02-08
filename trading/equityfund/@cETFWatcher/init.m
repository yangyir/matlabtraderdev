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
%     obj.codes_index_ = {'510050.SH';...%��֤50
%         '510300.SH';...%����300
%         '510500.SH';...%��֤500
%         '159915.SZ';...%��ҵ��ETF
%         '588000.SH';...%�ƴ�50ETF
%         '588400.SH';...%˫��50ETF
%         '512100.SH';...%��֤1000
%     };
    %
%     obj.codes_sector_ = {'512880.SH';'512000.SH';...%֤ȯETF
%         '515290.SH';'512800.SH';...%����ETF
%         '159928.SZ';...%����ETF
%         '512690.SH';...%��ETF
%         '512170.SH';...%ҽ��ETF
%         '512010.SH';...%ҽҩETF
%         '515030.SH';...%����Դ��ETF
%         '515790.SH';...%���ETF
%         '516160.SH';...%����ԴETF
%         '512400.SH';...%��ɫ����ETF
%         '515050.SH';...%5G ETF
%         '159995.SZ';...%оƬETF
%         '512660.SH';...%����ETF
%         '510880.SH';...%����ETF
%         '512960.SH';...%���ETF
%         '159870.SZ';...%����
%         '515210.SH';...%����
%         '515220.SH';...%ú̿
%         '159930.SZ';...%��Դ
%         '516970.SH';...%����
%         '512980.SH';...%��ý
%         '159865.SZ';...%��ֳETF
%         '159825.SZ';...%ũҵETF 
%     };
%     %
%     obj.codes_stock_ = {'688017.SH';...%�̵�г��
%         '688686.SH';...%������
%         '688305.SH';....%�Ƶ�����
%         '688690.SH';...%��΢�Ƽ�
%         '000661.SZ';...%��������
%     };

    obj.names_index_ = names_index;
    obj.names_sector_ = names_sector;
    obj.names_stock_ = names_stock;
    %
    %
    obj.reload;
    
    
end 