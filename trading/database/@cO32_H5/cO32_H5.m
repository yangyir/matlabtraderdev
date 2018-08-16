classdef cO32_H5 < cDataSource
    properties
        dsn_ = 'O32_H5';
        ds_
    end
    
    properties( SetAccess = private, Hidden = true, GetAccess = private )
        isconnected_ = 0;
    end
    
    
    methods
        function obj = cO32_H5()
            obj.isconnected_ = 0;
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
        
        function [ret] = login(obj,envDir)
            if ~obj.isconnected_
                mktlogout;
                cur_dir = pwd;
                login_path = [fileparts(mfilename('fullpath')), '\',envDir];
                cd(login_path)
                obj.isconnected_ = mktlogin;
                pause(5);
                cd(cur_dir);
            else
                ret = obj.isconnected_;
            end
        end
        %login
        
        function [] = logout(obj)
            if obj.isconnected_
                mdlogout;
                disp('log out successfully.');
            else
                disp('is connect: ',obj.isconnected_);
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
        % test Env
        test_env_dir('testEnv');
        % production Env
        production_env_dir('productEnv');

    end
end