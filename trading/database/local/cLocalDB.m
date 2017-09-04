classdef cLocalDB < cDataSource
    properties
        dsn_ = 'local'
        ds_
    end
    
    methods
        function obj = cLocalDB(varargin)
            if nargin == 0
                obj.ds_ = 'C:\traderdev\trading\database\data\';
            else
                obj.ds_ = varargin{1};
            end
        end
    end
    
    
    methods
        function flag = isconnect(obj)
            if isempty(obj.ds_)
                flag = false;
            else
                flag = true;
            end
        end
        %end of isconnect
        
        function close(obj)
            obj.ds_ = '';
        end
        %end of close
        
        
        function data = intradaybar(obj,contract,startdate,enddate,interval,field)
            %some sanity check first
            if ~(strcmpi(field,'trade') || ...
                    strcmpi(field,'bid') || ...
                    strcmpi(field,'ask'))
                error(['cLocalDB:intradaybar:field ',field,' not supported'])
            end
            
            if ~ischar(startdate), error('cLocalDB:intradaybar:startdate must be char'); end
            if ~ischar(enddate), error('cLocalDB:intradaybar:enddate must be char'); end
            
            if ~isnumeric(interval), error('cLocalDB:intradaybar:interval must be scalar'); end
            if isempty(interval), interval = 1; end
            
            if isa(contract,'cFutures')
                code_ctp = contract.code_ctp;
                bds = gendates('fromdate',startdate,'todate',enddate);
                n = size(bds,1);
                
                if n == 1
                    fn_ = [code_ctp,'_',datestr(bds,'yyyymmdd'),'_1m.txt'];
                    fullfn_ = [obj.ds_,fn_];
                    data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                else
                    fn_ = [code_ctp,'_',datestr(bds(1),'yyyymmdd'),'_1m.txt'];
                    fullfn_ = [obj.ds_,fn_];
                    data_raw_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                    for i = 2:n
                        fn_ = [code_ctp,'_',datestr(bds(i),'yyyymmdd'),'_1m.txt'];
                        fullfn_ = [obj.ds_,fn_];
                        data_new_ = cDataFileIO.loadDataFromTxtFile(fullfn_);
                        tmp = data_raw_;
                        data_raw_ = [tmp;data_new_];
                    end
                end
                    
                %the columns in d contain the following:
                %numeric representation of data and time
                %open price
                %high price
                %low price
                %closing price
                %volume of ticks
                %number of ticks
                %total tick value in the bar
                data = timeseries_compress(data_raw_(:,1:5),'tradinghours',contract.trading_hours,...
                    'tradingbreak',contract.trading_break,...
                    'frequency',[num2str(interval),'m']);
            else
                classname = class(contract);
                error(['cLocalDB:intradaybar:not implemented for class ',...
                    classname])
            end
 
            
        end
        %end of intradaybar
        
        function data = realtime(obj,contract,fields)
            data = [];
        end
        %end of realtime
        
        function data = history(obj,contract,fields,fromdate,todate)
        end
    end
    
end