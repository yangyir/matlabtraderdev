function [ ] = login( self , javapath)
%LOGIN ���ӡ���½������
% -----------------------------------
% �̸գ�20160201
% �콭��20160821�� ����javapath ����������ָ����ͬ��ִ��·����


% �ж�·��������
if ~exist('javapath', 'var')
    javapath = 'D:\intern\optionClass\ʵ�̽�����\UFXdemo_MATLAB\ESBJavaAPI.jar';
end

% ���Ƚ����ݸ��������
%             self.serverIp   = serverIp;        % ������IP
%             self.serverPort = serverPort;    % �������Ķ˿�
%             self.operatorNo = operatorNo;    % �������Ĳ���Ա
%             self.password   = password;        % ������������
%             self.accountCode = accountCode;  % �˻�
%             self.combiNo    = combiNo;          % ���

serverIp   = self.serverIp;        % ������IP
serverPort = self.serverPort;    % �������Ķ˿�
operatorNo = self.operatorNo;    % �������Ĳ���Ա
password   = self.password;        % ������������
accountCode = self.accountCode;  % �˻�
combiNo    = self.combiNo;          % ���

% ��ʵ����һ�ξ�OK��,��������ȫ��
javaaddpath(javapath);
% javaaddpath('C:\Users\yp\Desktop\optionMlab\optionClass\ʵ�̽���\O32_matlab\UFXdemo_MATLAB\ESBJavaAPI.jar');
%javaaddpath('D:\intern\optionClass\ʵ�̽�����\UFXdemo_MATLAB\ESBJavaAPI.jar');
% javaaddpath('C:\Users\Rick Zhu\Documents\Synology Cloud\intern\7.�콭\test_code\UFXdemo_test_MATLAB\ESBJavaAPI.jar');

% ���ӷ�����
[errorCode, errorMsg, connection ] = Connect( serverIp , serverPort );
if errorCode < 0
    disp(['���ӷ�����ʧ�ܡ�������ϢΪ:',errorMsg]);
    return;
else
    disp('���ӳɹ�');
    % �����ӵľ��������Լ�������
    self.connection = connection;
end

% Ȼ����е�¼
[ errorCode , errorMsg , Token ] = Login( self.connection , operatorNo , password );
if errorCode < 0
    disp(['��¼ʧ�ܡ�������ϢΪ:',errorMsg]);
    return;
else
    disp('��¼�ɹ�');
    self.token = Token;
end

% ��������������
[ HeartbeatTimer ] = HeartBeat( self.connection , self.token );
self.heartbeatTimer = HeartbeatTimer;

% ��̨�Ѿ���¼
self.is_Counter_Login = true;


end

