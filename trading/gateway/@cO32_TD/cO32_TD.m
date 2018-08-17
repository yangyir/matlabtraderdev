classdef cO32_TD  < handle
    %COUNTERHSO32 ����O32�Ĺ�̨����½����Ϣ
    % ----------------------------------------------
    % �̸գ�20160130����̨�������ܣ�login��logout��printInfo
    % �̸գ�20160201�����°�װUFX_MATLAB����غ�����ʹ֮��Ϊ��̨����ķ���
    % ���Ʒ壬20170106����������Ȩ���ڻ���ѯ��֤�𷽷�
    
    
    %% ��̨���ӳɹ���ĺ��ģ������ⲿ����
    properties(SetAccess = 'private', Hidden = true , GetAccess = 'public')      
        connection  = [];       % �͹�̨������
        token       = [];       % �͹�̨��token
        heartbeatTimer = [];    % ���׵�����,���ֲ���
    end
    
    %% ��̨���ӵ�����
    properties(SetAccess = 'public', Hidden = false , GetAccess = 'public') 
        % ��¼��Ҫ���õ�Ip��Portֵ
        serverIp@char       = '10.42.28.148';   % IPֵ
        serverPort@double   = 9003;             % �˿�ֵ
            
        % ���ڲ���Ա��������Ҫ���е�¼
        operatorNo@char  = '2038';   % ����Ա
        password@char    = '111aaa';      % ����       
        
        % ����
        accountCode@char = '202006';         % ���ڽ��׵��˻�
        combiNo@char     = '820002006-J';    % ���ڽ��׵����       
        
        % �Ƿ��Ѿ���¼��̨
        is_Counter_Login = false;    
    end
    
    
    %% ���캯��
    methods
        function self = CounterHSO32( serverIp , serverPort , operatorNo , password , accountCode , combiNo)

            if exist('serverIp', 'var') 
                self.serverIp   = serverIp;        % ������IP 
            end
            
            if exist('serverPort', 'var')
                self.serverPort = serverPort;    % �������Ķ˿�
            end
            
            if exist('operatorNo', 'var')                
                self.operatorNo = operatorNo;    % �������Ĳ���Ա
            end
            
            if exist('password', 'var')
                self.password   = password;        % ������������
            end
            
            if exist('accountCode', 'var')
                self.accountCode = accountCode;  % �˻�
            end
            
            if exist('combiNo','var')
                self.combiNo    = combiNo;          % ���
            end
            
        end
        
    end
    
    
    methods( Hidden = false , Access = 'public' , Static = false )
%% ------------���Ƚ������õ�¼----------------------------------
        % ���ӡ���½������   
        [ ] = login( self , javapath);
        [ ] = logout( self );       
        % ��� 
        [txt] = printInfo(self);
    
    end
    
    
    %% ��counter�����°�װ��غ���
    methods( Hidden = false , Access = 'public' , Static = false )
        %	market_no	�����г�
        % 	"1"	�Ͻ���
        % 	"2"	���
        % 	"3"	������
        % 	"4"	֣����
        % 	"7"	�н���
        % 	"9"	������
        % 	"10"	��ת�г�
        % 	"35"	�۹�ͨ
        
        % 	entrust_direction	ί�з���
        % 	'1'	����
        % 	'2'	����
        % 	'3'	ծȯ����
        % 	'4'	ծȯ����
        % 	'5'	����(��)�ع�
        % 	'6'	��ȯ(��)�ع�
        % 	'9'	��ɣ���ծ���Ϲ�
        % 	'10'	ծת��
        % 	'11'	ծ����
        % 	'12'	�깺
        % 	'13'	�����Ϲ�
        % 	'17'	ת�й�
        % 	'26'	ETF�깺
        % 	'27'	ETF���
        % 	'28'	��Ȩ�Ϲ�
        % 	'29'	��Ȩ�Ϲ�
        % 	'30'	�ύ��Ѻ
        % 	'31'	ת����Ѻ
        % 	'50'	����ֲ�
        % 	'51'	����ϲ�
        % 	'53'	�����깺
        % 	'54'	�������
        % 	'55'	ծȯ�Ϲ�
        % 	'63'	��֤ȯ��������Ʊ��Ȩ��
        % 	'64'	��֤ȯ��������Ʊ��Ȩ��
        % 	'67'	��ȯ����
        % 	'68'	��ȯ��ȯ
        % 	'69'	ֱ�ӻ���
        % 	'70'	ֱ�ӻ�ȯ
        % 	'73'	����ȯ����
        % 	'74'	����ȯ��ȡ
        % 	'75'	��������
        % 	'76'	��ȯ����
        %% �µ�
        [ret] = placeEntrust(self, entrust);
        %% ��ѯ
        [ret] = queryEntrust(self, entrust);
        %% ����
        [ret] = withdrawEntrust(self, entrust);

        [errorCode,errorMsg,packet]     = queryAccount(self);
        %% ����ֲ���Ϣ
        function [positionArray, ret] = queryOptPositions(self, code)
            %function [positionArray, ret] = queryOptPositions(self, code)
            [positionArray, ret] = self.queryPositions('1', 'Option', code);
        end
        
        function [positionArray, ret] = queryStkPositions(self, code)
            %function [positionArray, ret] = queryStkPositions(self, code)
            [positionArray, ret] = self.queryPositions('1', 'ETF', code);
        end
        
        function [positionArray, ret] = queryFutPositions(self, code)
            %function [positionArray, ret] = queryFutPositions(self, code)
            [positionArray, ret] = self.queryPositions('7', 'Future', code);
        end
        [positionArray, ret] = queryPositions(self, mktno, type, code);
        
        [errorCode,errorMsg,packet] = queryCombiAccount(self);
        %% ר����Թ�Ʊ��
        [errorCode,errorMsg,packet]     = queryCombiStock(self,marketNo,stockCode);
        [errorCode,errorMsg,entrustNo]  = entrust(self, marketNo,stockCode,entrustDirection,entrustPrice,entrustAmount)
        [errorCode,errorMsg,packet]     = queryEntrusts(self, entrustNo);
        [errorCode,errorMsg,cancelNo]   = entrustCancel(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryDeals(self, entrustNo);
        
        [cash_t0, cash_t1] = queryCash(self);        
        
        %% Ҫ�����Ȩר��������
        [errorCode,errorMsg,packet]     = queryCombiOpt(self,marketNo,optCode)
        [errorCode,errorMsg,entrustNo]  = optPlaceEntrust(self, marketNo, optCode, entrustDirection, futuresDirection, entrustPrice, entrustAmount, coveredFlag)
        [errorCode,errorMsg,packet]     = queryOptEntrusts(self, entrustNo);
        [errorCode,errorMsg,cancelNo]   = optEntrustCancel(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryOptDeals(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryOptMargin(self);  % ������Ȩ��ѯ��֤��ķ���
        
        %% ��Թ�ָ�ڻ���
        [errorCode,errorMsg,packet]     = queryCombiFuture(self,marketNo,stockCode)
        [errorCode,errorMsg,entrustNo]  = futPlaceEntrust(self, marketNo,stockCode,entrustDirection,futuresDirection,entrustPrice,entrustAmount)
        [errorCode,errorMsg,packet]     = queryFutEntrusts(self, entrustNo);
        [errorCode,errorMsg,cancelNo]   = futEntrustCancel(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryFutDeals(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryFutMargin(self);   % �����ڻ���ѯ��֤��ķ���
        
        
        %% ������
        %׼����������
        function [batch_order] = GetNewBatchOrder(self)
            batch_order = COrderList;
            batch_order.optCombiNo = self.combiNo;
            batch_order.accountCode = self.accountCode;
        end
        
        %�ύ������
        [errorCode, errorMsg,entrustNoList, batchNo] = batch_entrusts(self, orderList);
        %����������
        [errorCode, errorMsg,cancelNo] = batchEntrustCancel(self, batchNo);
        
        %% ��һͳ�������Ͳ���
        % TODO�� �콭��������
        
        
        function [px] = get_current_price(self, stockCode, marketNo)
            % ͨ��HSO32��̨��ȡ��ȯ�۸�last
            
            % TODO: ����stockCode����marketNo
            if ~exist('marketNo' , 'var')
                marketNo = '1';  % �Ϻ�SSE
            end
            
            [errorCode,errorMsg,packet] = self.queryCombiStock(marketNo,stockCode);
            
             if errorCode < 0
                disp(['��ֲ�ʧ�ܡ�������ϢΪ:',errorMsg]);
                return;
             else
%                  disp('-------------��óֲ���Ϣ--------------');
%                  PrintPacket2(packet); %��ӡ�ֲ���Ϣ
                 px = packet.getDoubleByIndex(16);
             end
        end
        
    end
    
    
    %% static methods
    methods(Static = true )
        demo;
        demo2;
    end
    
    
    %% ö�ټ��������Ĺ�̨����
    enumeration 
        hequn2038_202006 ('10.42.80.167', 9003, '2038', '111aaa', '202006', '820002006-J');
        hequn2038_202006_168 ('10.42.80.168', 9003, '2038', '111aaa', '202006', '820002006-J');
        hequn2038_2034_opt ('10.42.80.167', 9003, '2038', '111aaa', '2034', '82002006');
        hequn2038_2034_opt168 ('10.42.80.168', 9003, '2038', '111aaa', '2034', '82002006');
        hequn2038_2601_opt ('10.42.80.167', 9003, '2038', '111aaa', '2601', '82002001');
        hequn2038_2601_opt168 ('10.42.80.168', 9003, '2038', '111aaa', '2601', '82002001');
        hequn2038_2016_opt  ('10.42.80.167', 9003, '2038', '111aaa', '2016', '82002004');
        hequn2038_2016_opt168 ('10.42.80.168', 9003, '2038', '111aaa', '2016', '82002004');
        hequn2038_2016_fut ('10.42.80.167', 9003, '2038', '111aaa', '2016', '82000016-B');
        hequn2038_2016_fut168 ('10.42.80.168', 9003, '2038', '111aaa', '2016', '82000016-B');
        
%         hequn2038_202006 ('10.42.28.148', 9003, '2038', '111aaa', '202006', '820002006-J');
%         hequn2038_2034_opt ('10.42.28.148', 9003, '2038', '111aaa', '2034', '82002006');
%         hequn2038_2601_opt ('10.42.28.148', 9003, '2038', '111aaa', '2601', '82002001');
%         hequn2038_2016_opt ('10.42.28.148', 9003, '2038', '111aaa', '2016', '82002004');
%         hequn2038_2016_fut ('10.42.28.148', 9003, '2038', '111aaa', '2016', '82000016-B');

        hequntest_2016_fut ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82000016-J');
        hequntest_2038_opt ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82002004');
        hequntest_2038_etf ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82000016-B');
        hequntest_2038_fut ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82000016-B');
        hequntest_2038_test ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82000016');
        hequntest_2038_34test ('192.168.41.93', 9003, '2038', '111aaa', '2034', '82002006');
        hequn2038_2016_opttest ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82002004');
        hequntest_2038_TJ ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82000016-J');
        hequntest_2038_TL ('192.168.41.93', 9003, '2038', '111aaa', '2016', '82000016-L');
        hequntest_2601_TB ('192.168.41.93', 9003, '2038', '111aaa', '2601', '82000601-B');
        hequntest_2601_TJ ('192.168.41.93', 9003, '2038', '111aaa', '2601', '82000601-T');
        hequntest_2601_TL ('192.168.41.93', 9003, '2038', '111aaa', '2601', '82000601-L');
        hequntest_2601_opt ('192.168.41.93', 9003, '2038', '111aaa', '2601', '82002001');
    end
end


