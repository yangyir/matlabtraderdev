classdef cO32_TD  < handle
    %COUNTERHSO32 恒生O32的柜台，登陆的信息
    % ----------------------------------------------
    % 程刚，20160130，柜台基本功能：login，logout，printInfo
    % 程刚，20160201，重新包装UFX_MATLAB的相关函数，使之成为柜台对象的方法
    % 吴云峰，20170106，新增加期权和期货查询保证金方法
    
    
    %% 柜台连接成功后的核心，无须外部看到
    properties(SetAccess = 'private', Hidden = true , GetAccess = 'public')      
        connection  = [];       % 和柜台的连接
        token       = [];       % 和柜台的token
        heartbeatTimer = [];    % 交易的心跳,保持不动
    end
    
    %% 柜台连接的属性
    properties(SetAccess = 'public', Hidden = false , GetAccess = 'public') 
        % 登录需要利用的Ip和Port值
        serverIp@char       = '10.42.28.148';   % IP值
        serverPort@double   = 9003;             % 端口值
            
        % 基于操作员和密码需要进行登录
        operatorNo@char  = '2038';   % 操作员
        password@char    = '111aaa';      % 密码       
        
        % 交易
        accountCode@char = '202006';         % 用于交易的账户
        combiNo@char     = '820002006-J';    % 用于交易的组合       
        
        % 是否已经登录柜台
        is_Counter_Login = false;    
    end
    
    
    %% 构造函数
    methods
        function self = CounterHSO32( serverIp , serverPort , operatorNo , password , accountCode , combiNo)

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
            
        end
        
    end
    
    
    methods( Hidden = false , Access = 'public' , Static = false )
%% ------------首先进行设置登录----------------------------------
        % 连接、登陆、心跳   
        [ ] = login( self , javapath);
        [ ] = logout( self );       
        % 输出 
        [txt] = printInfo(self);
    
    end
    
    
    %% 在counter里重新包装相关函数
    methods( Hidden = false , Access = 'public' , Static = false )
        %	market_no	交易市场
        % 	"1"	上交所
        % 	"2"	深交所
        % 	"3"	上期所
        % 	"4"	郑商所
        % 	"7"	中金所
        % 	"9"	大商所
        % 	"10"	股转市场
        % 	"35"	港股通
        
        % 	entrust_direction	委托方向
        % 	'1'	买入
        % 	'2'	卖出
        % 	'3'	债券买入
        % 	'4'	债券卖出
        % 	'5'	融资(正)回购
        % 	'6'	融券(逆)回购
        % 	'9'	配股（配债）认购
        % 	'10'	债转股
        % 	'11'	债回售
        % 	'12'	申购
        % 	'13'	基金认购
        % 	'17'	转托管
        % 	'26'	ETF申购
        % 	'27'	ETF赎回
        % 	'28'	行权认购
        % 	'29'	行权认沽
        % 	'30'	提交质押
        % 	'31'	转回质押
        % 	'50'	基金分拆
        % 	'51'	基金合并
        % 	'53'	开基申购
        % 	'54'	开基赎回
        % 	'55'	债券认购
        % 	'63'	保证券锁定（股票期权）
        % 	'64'	保证券解锁（股票期权）
        % 	'67'	融券卖出
        % 	'68'	买券还券
        % 	'69'	直接还款
        % 	'70'	直接还券
        % 	'73'	担保券交存
        % 	'74'	担保券提取
        % 	'75'	融资买入
        % 	'76'	卖券还款
        %% 下单
        [ret] = placeEntrust(self, entrust);
        %% 查询
        [ret] = queryEntrust(self, entrust);
        %% 撤单
        [ret] = withdrawEntrust(self, entrust);

        [errorCode,errorMsg,packet]     = queryAccount(self);
        %% 载入持仓信息
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
        %% 专门针对股票的
        [errorCode,errorMsg,packet]     = queryCombiStock(self,marketNo,stockCode);
        [errorCode,errorMsg,entrustNo]  = entrust(self, marketNo,stockCode,entrustDirection,entrustPrice,entrustAmount)
        [errorCode,errorMsg,packet]     = queryEntrusts(self, entrustNo);
        [errorCode,errorMsg,cancelNo]   = entrustCancel(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryDeals(self, entrustNo);
        
        [cash_t0, cash_t1] = queryCash(self);        
        
        %% 要针对期权专门做函数
        [errorCode,errorMsg,packet]     = queryCombiOpt(self,marketNo,optCode)
        [errorCode,errorMsg,entrustNo]  = optPlaceEntrust(self, marketNo, optCode, entrustDirection, futuresDirection, entrustPrice, entrustAmount, coveredFlag)
        [errorCode,errorMsg,packet]     = queryOptEntrusts(self, entrustNo);
        [errorCode,errorMsg,cancelNo]   = optEntrustCancel(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryOptDeals(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryOptMargin(self);  % 新增期权查询保证金的方法
        
        %% 针对股指期货的
        [errorCode,errorMsg,packet]     = queryCombiFuture(self,marketNo,stockCode)
        [errorCode,errorMsg,entrustNo]  = futPlaceEntrust(self, marketNo,stockCode,entrustDirection,futuresDirection,entrustPrice,entrustAmount)
        [errorCode,errorMsg,packet]     = queryFutEntrusts(self, entrustNo);
        [errorCode,errorMsg,cancelNo]   = futEntrustCancel(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryFutDeals(self, entrustNo);
        [errorCode,errorMsg,packet]     = queryFutMargin(self);   % 新增期货查询保证金的方法
        
        
        %% 批量单
        %准备空批量单
        function [batch_order] = GetNewBatchOrder(self)
            batch_order = COrderList;
            batch_order.optCombiNo = self.combiNo;
            batch_order.accountCode = self.accountCode;
        end
        
        %提交批量单
        [errorCode, errorMsg,entrustNoList, batchNo] = batch_entrusts(self, orderList);
        %撤销批量单
        [errorCode, errorMsg,cancelNo] = batchEntrustCancel(self, batchNo);
        
        %% 大一统，带类型参数
        % TODO： 朱江，不紧急
        
        
        function [px] = get_current_price(self, stockCode, marketNo)
            % 通过HSO32柜台获取个券价格last
            
            % TODO: 根据stockCode推算marketNo
            if ~exist('marketNo' , 'var')
                marketNo = '1';  % 上海SSE
            end
            
            [errorCode,errorMsg,packet] = self.queryCombiStock(marketNo,stockCode);
            
             if errorCode < 0
                disp(['查持仓失败。错误信息为:',errorMsg]);
                return;
             else
%                  disp('-------------获得持仓信息--------------');
%                  PrintPacket2(packet); %打印持仓信息
                 px = packet.getDoubleByIndex(16);
             end
        end
        
    end
    
    
    %% static methods
    methods(Static = true )
        demo;
        demo2;
    end
    
    
    %% 枚举几个常见的柜台设置
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


