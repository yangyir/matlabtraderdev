classdef cO32 < cDataSource
    properties
        dsn_ = 'O32';
        ds_
    end
    %% 柜台连接成功后的核心，无须外部看到
    properties( SetAccess = private, Hidden = true, GetAccess = private )
        connection  = 0;       % 和柜台的连接
       
    end
   %% 柜台连接的属性
    properties( SetAccess = public, Hidden = false , GetAccess = public ) 
        % 登录需要利用的Ip和Port值
        serverIp@char       = '10.42.28.148';   % IP值
        serverPort@double   = 9003;             % 端口值
            
        % 基于操作员和密码需要进行登录
        operatorNo@char  = '2310';   % 操作员
        password@char    = '88888888';      % 密码       
        
        % 交易
        accountCode@char = '202006';         % 用于交易的账户
        combiNo@char     = '820002006-J';    % 用于交易的组合       
        
        % 是否已经登录柜台
        is_Counter_Login = false;
        
        % 连接O32接口 HANDLE
        counterO32 = [];
        
        % javaPath
        javaPath = '';
    end
    
    methods
        function obj = cO32( serverIp , serverPort , operatorNo , password , accountCode , combiNo, javaPath)
            if exist('serverIp', 'var') 
                self.serverIp   = serverIp;        % 服务器IP 
            end
            
            if exist('serverPort', 'var')
                self.serverPort = serverPort;    % 服务器的端口
            end
            
            if exist('operatorNo', 'var')                
                self.operatorNo = operatorNo;    % 服务器的操作员
            end
            
            if exist('password', 'var')
                self.password   = password;        % 服务器的密码
            end
            
            if exist('accountCode', 'var')
                self.accountCode = accountCode;  % 账户
            end
            
            if exist('combiNo','var')
                self.combiNo    = combiNo;          % 组合
            end
            
            if exist('javaPath','var')
                self.javaPath    = javaPath;          % 设置电脑路径 qpool
            end
            
            % 连接O32接口
            self.counterO32 = CounterHSO32(serverIp,serverPort , operatorNo , password , accountCode , combiNo);

            % ---------------initial O32 
        end
        %end of constructor
        
        function [txt] = printinfo(obj)
            txt = sprintf('O32 server info:\n');
            txt = sprintf('%sserverIp = %s\n',txt, obj.serverIp);
            txt = sprintf('%sserverPort = %s\n',txt, obj.serverPort);
            txt = sprintf('%soperatorNo = %s\n',txt, obj.operatorNo);
            txt = sprintf('%spassword = %s\n',txt, obj.password);
            txt = sprintf('%saccountCode = %s\n',txt, obj.accountCode);
            txt = sprintf('%scombiNo = %s\n',txt, obj.combiNo);
            if nargout == 0, disp(txt);end
        end
        %end of printinfo
        
        function [ret] = login(obj)
            if ~obj.isconnected_
                obj.counterO32.login(obj.javaPath);
                obj.isconnected_ = true;
                ret = true;
            else
                ret = obj.isconnected_;
                
            end
        end
        %login
        
        function [] = logoff(obj)
            if obj.isconnected_
                 obj.counterO32.logout(); % logout
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
        liyong2310_202006_168 ('10.42.80.167', 9003, '2038', '111aaa', '202006', '820002006-J');
    
    end
end