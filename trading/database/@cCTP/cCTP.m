classdef cCTP < cDataSource
    properties
        dsn_ = 'CTP';
        ds_
    end
    
    properties( SetAccess = private, Hidden = true, GetAccess = private )
        isconnected_ = 0
        loginid_
    end
    
    properties( SetAccess = private, Hidden = false , GetAccess = public ) 
        addr_@char
        broker_@char
        investor_@char
        pwd_@char
    end
    
    methods
        function obj = cCTP(addr, broker,investor,pwd)
            if exist('addr', 'var'), obj.addr_ = addr; end
            if exist('broker', 'var'),  obj.broker_ = broker; end
            if exist('investor', 'var'), obj.investor_ = investor; end
            if exist('pwd', 'var'), obj.pwd_ = pwd; end
        end
        %end of constructor
        
        function [txt] = printinfo(obj)
            txt = sprintf('CTP server info:\n');
            txt = sprintf('%sServerAddress = %s\n',txt, obj.addr_);
            txt = sprintf('%sBroker = %s\n',txt, obj.broker_);
            txt = sprintf('%sInvestor = %s:%s\n',txt, obj.investor_, obj.pwd_);
            
            if nargout == 0, disp(txt);end
        end
        %end of printinfo
        
        function [ret] = login(obj)
            if ~obj.isconnected_
                [ret,id] = mdlogin(obj.addr_,obj.broker_,obj.investor_,obj.pwd_);
                obj.isconnected_ = ret;
                obj.loginid_ = id;
            else
                ret = obj.isconnected_;
            end
        end
        %login
        
        function [] = logoff(obj)
            if obj.isconnected_
                try
                    mdlogout(obj.loginid_);
                    obj.isconnected_ = 0;
                catch
                    fprintf('cCTP:logoff failed!!!\n');
                end
                
            end
        end
        
    end
    
    
    methods
        flag = isconnect(obj)
        [] = close(obj)
        data = intradaybar(obj,instrument,startdate,enddate,interval,field)
        data = realtime(obj,instruments,fields)
        data = history(obj,instrument,fields,fromdate,todate)
        data = tickdata(obj,instrument,startdate,enddate)
        
    end
    
    %
    enumeration
        %futures only
%         citic_kim_fut('tcp://180.169.101.177:41213','66666','101003196','770424');
        %commodity option
        huaxin_ly_fut('tcp://180.169.70.179:41213','10001','930490003','204090');
        ccb_ly_fut('tcp://116.236.253.145:42213','95533','52013132','2022Jul10');
%         ccb_yy_fut('tcp://116.236.253.145:41213','95533','52015187','2001Sep29');
%         simnow_test('tcp://180.168.146.187:10011', '9999', '081059', 'zyx5711213');
%         rh_tf6('tcp://10.202.80.71.48213','0001','','');
        gfqh_ctp2358('tcp://112.94.162.110:42413','2358','510510026','gfqh2023');
        gfqh_tgzg('tcp://101.230.102.231:51213','9000','999088081','abc10102');

    end
end