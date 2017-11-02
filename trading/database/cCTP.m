classdef cCTP < cDataSource
    properties
        dsn_ = 'CTP';
        ds_
    end
    
    properties( SetAccess = private, Hidden = true, GetAccess = private )
        isconnected_ = 0
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
                [ret] = mdlogin(obj.addr_,obj.broker_,obj.investor_,obj.pwd_);
                obj.isconnected_ = ret;
            else
                ret = obj.isconnected_;
            end
        end
        %login
        
        function [] = logoff(obj)
            if obj.isconnected_
                mdlogout;
            end
        end
        
    end
    
    
    methods
        function flag = isconnect(obj)
            flag = obj.isconnected_;
        end
        %end of isconnect
        
        function close(obj)
            logoff(obj);
        end
        %end of close
        
        function data = intradaybar(obj,instrument,startdate,enddate,interval,field)
            %this is not availale in CTP
            variablenotused(obj);
            variablenotused(instrument);
            variablenotused(startdate);
            variablenotused(enddate);
            variablenotused(interval);
            variablenotused(field);
            data = [];
        end
        %end of intradaybar
        
        function data = realtime(obj,instruments,fields)
            %note fields are not used here
            variablenotused(fields);
            if ~obj.isconnected_
                data = {};
                return
            end
            
            if isa(instruments,'cInstrument')
                [mkt, level, updatetime] = getoptquote(instruments.code_ctp);
                data = cell(1,1);
                data{1} = struct('mkt',mkt,'level',level,'updatetime',updatetime);
            elseif iscell(instruments)
                n = length(instruments);
                data = cell(n,1);
                for i = 1:n
                    if isa(instruments,'cInstrument')
                        [mkt, level, updatetime] = getoptquote(instruments{i}.code_ctp);
                    else
                        [mkt, level, updatetime] = getoptquote(instruments{i});
                    end
                    data{i} = struct('mkt',mkt,'level',level,'updatetime',updatetime);
                end
            else
                [mkt, level, updatetime] = getoptquote(num2str(instruments));
                data = cell(1,1);
                data{1} = struct('mkt',mkt,'level',level,'updatetime',updatetime);
            end
        end
        %end of realtime
        
        function data = history(obj,instrument,fields,fromdate,todate)
            %this is not available in CTP
            variablenotused(obj);
            variablenotused(instrument);
            variablenotused(fields);
            variablenotused(fromdate);
            variablenotused(todate);
            data =[];
        end
        %end of history
        
    end
    
    %
    enumeration
        %futures only
        citic_kim_fut('tcp://180.169.101.177:41213','66666','101003196','770424');
        %comodoty option
        huaxin_liyang_fut('tcp://180.169.70.179:41213','10001','930490003','204090');

    end
end