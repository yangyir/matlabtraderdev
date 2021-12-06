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
    obj.codes_index_ = {'510050.SH';...%��֤50
        '510300.SH';...%����300
        '510500.SH';...%��֤500
        '159915.SZ';...%��ҵ��ETF
        '588000.SH';...%�ƴ�50ETF
        '588400.SH';...%˫��50ETF
        '512100.SH';...%��֤1000
    };
    %
    obj.codes_sector_ = {'512880.SH';'512000.SH';...%֤ȯETF
        '515290.SH';'512800.SH';...%����ETF
        '159928.SZ';...%����ETF
        '512690.SH';...%��ETF
        '512170.SH';...%ҽ��ETF
        '512010.SH';...%ҽҩETF
        '515030.SH';...%����Դ��ETF
        '515790.SH';...%���ETF
        '516160.SH';...%����ԴETF
        '512400.SH';...%��ɫ����ETF
        '515050.SH';...%5G ETF
        '159995.SZ';...%оƬETF
        '512660.SH';...%����ETF
        '510880.SH';...%����ETF
        '512960.SH';...%���ETF
        '159870.SZ';...%����
        '515210.SH';...%����
        '515220.SH';...%ú̿
        '159930.SZ';...%��Դ
        '516970.SH';...%����
        '512980.SH';...%��ý
        '159865.SZ';...%��ֳETF
        '159825.SZ';...%ũҵETF 
    };
    %
    obj.codes_stock_ = {'688017.SH';...%�̵�г��
        '688686.SH';...%������
        '688305.SH';....%�Ƶ�����
        '688690.SH';...%��΢�Ƽ�
        '000661.SZ';...%��������
    };

    obj.names_index_ = obj.conn_.ds_.wss(obj.codes_index_,'sec_name');
    obj.names_sector_ = obj.conn_.ds_.wss(obj.codes_sector_,'sec_name');
    obj.names_stock_ = obj.conn_.ds_.wss(obj.codes_stock_,'sec_name');
    %
    %
    obj.reload;
    
    
end 