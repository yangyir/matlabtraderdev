function [ ] = login( self , javapath)
%LOGIN 连接、登陆、心跳
% -----------------------------------
% 程刚，20160201
% 朱江，20160821， 增加javapath 变量，可以指定不同的执行路径。


% 判断路径参数：
if ~exist('javapath', 'var')
    javapath = 'D:\intern\optionClass\实盘交易类\UFXdemo_MATLAB\ESBJavaAPI.jar';
end

% 首先将数据赋予给自身
%             self.serverIp   = serverIp;        % 服务器IP
%             self.serverPort = serverPort;    % 服务器的端口
%             self.operatorNo = operatorNo;    % 服务器的操作员
%             self.password   = password;        % 服务器的密码
%             self.accountCode = accountCode;  % 账户
%             self.combiNo    = combiNo;          % 组合

serverIp   = self.serverIp;        % 服务器IP
serverPort = self.serverPort;    % 服务器的端口
operatorNo = self.operatorNo;    % 服务器的操作员
password   = self.password;        % 服务器的密码
accountCode = self.accountCode;  % 账户
combiNo    = self.combiNo;          % 组合

% 其实加入一次就OK了,其作用于全局
javaaddpath(javapath);
% javaaddpath('C:\Users\yp\Desktop\optionMlab\optionClass\实盘交易\O32_matlab\UFXdemo_MATLAB\ESBJavaAPI.jar');
%javaaddpath('D:\intern\optionClass\实盘交易类\UFXdemo_MATLAB\ESBJavaAPI.jar');
% javaaddpath('C:\Users\Rick Zhu\Documents\Synology Cloud\intern\7.朱江\test_code\UFXdemo_test_MATLAB\ESBJavaAPI.jar');

% 连接服务器
[errorCode, errorMsg, connection ] = Connect( serverIp , serverPort );
if errorCode < 0
    disp(['连接服务器失败。错误信息为:',errorMsg]);
    return;
else
    disp('连接成功');
    % 将连接的句柄赋予给自己的数据
    self.connection = connection;
end

% 然后进行登录
[ errorCode , errorMsg , Token ] = Login( self.connection , operatorNo , password );
if errorCode < 0
    disp(['登录失败。错误信息为:',errorMsg]);
    return;
else
    disp('登录成功');
    self.token = Token;
end

% 保持心跳即可用
[ HeartbeatTimer ] = HeartBeat( self.connection , self.token );
self.heartbeatTimer = HeartbeatTimer;

% 柜台已经登录
self.is_Counter_Login = true;


end

