classdef O32_MD < cDataSource
    properties
        dsn_ = 'QMS_H5';
        ds_
        % copy from QMS_fusion
        regular_timer_ = []; % 定时器，用于定期计算vol surface ? 是否需要？
        
        callQuotes_@M2TK ; % call quote 矩阵
        putQuotes_@M2TK ; % put quote 矩阵
        
        m2cOptOne@M2TK;
        m2pOptOne@M2TK; 
        
        optquotes_ = []; % 行情结构
        futquotes_ = [];
        stkquotes_ = [];
        
        futmap_@QuoteMap;
        stkmap_@QuoteMap;
        
        ready_ = []; % 行情数据有效
        impvol_surface_@VolSurface; % 隐含波动率曲面,% 插值计算波动率，old version,暂时保留，可能会逐步移除        
        timer_interval_@double = 60; % 默认每分钟计算一次
        calc_tau_counter = 10;
        hist_opt_quotes_;
        hist_fut_quotes_;
        hist_stk_quotes_;
        srcType@char = 'L2file';% 'L2file', 'H5', 'DH', 'W'
        stkParser@L2QuoteParser;
        optParser@L2QuoteParser;
        futParser@L2QuoteParser;
        
        historic_call_m2tk_@HistoricQuoteM2TK;
        historic_put_m2tk_@HistoricQuoteM2TK;
        save_to_file;
        eod_handler;
        check_risk_handler;
        
        QMS_path;
        isconnected_ = 0;
    end
    properties (Access = 'public')
        % tau 只对期权最有意义。由于总共有四个交割月份，将所有期权共同的计算放在Qms中
        % 计算一次后，对所有期权赋值来避免重复计算。
        currentDate = today;
        T;            % 1*4 的矩阵。
        tauInterday;  % 年化  1*4 , 每天只更新一次，init时做
        tauIntraday;  % 年化  1*1， 定时更新
        tauPrecise;   % 年化， == tauInterday + tauIntraday,  1*4， 赋值给所有的quoteopt.tau        
        daysOfYear;
    end
    
    properties
        % VolSurf， ATM vol etc
        call_surf_@VolSurf = VolSurf('call'); % Smiles and Termstructure 组成的VolSurf.
        put_surf_@VolSurf = VolSurf('put');
        call_near_atm_ = [];
        put_near_atm_ = [];
        record_time_ = [];
    end
    
    
    
    %% 柜台连接成功后的核心，无须外部看到
    properties( SetAccess = private, Hidden = true, GetAccess = private )
        connection  = 0;       % 和柜台的连接
    end
    
    methods
        function self = cQMS_H5()
            self.impvol_surface_ = VolSurface;
            self.historic_call_m2tk_ = HistoricQuoteM2TK('call');
            self.historic_put_m2tk_ = HistoricQuoteM2TK('put');
            self.save_to_file = false;
        end
        %end of constructor
       %% init_test 先测试通过，再替换原有init函数
        function [] = init_test(obj, opt_fn, fut_fn, stk_fn)
            cd('C:\Users\Rick Zhu\Documents\Synology Cloud\intern\5.吴云峰\optionStraddleTrading\');
            obj.srcType = '';
            [obj.optquotes_, obj.callQuotes_, obj.putQuotes_] = obj.init_call_put_mat(opt_fn);
            [obj.futquotes_, obj.futmap_] = obj.init_fut_map(fut_fn);
            [obj.stkquotes_, obj.stkmap_] = obj.init_stk_map(stk_fn);
            
            % init historic quotes m2tk.
            obj.historic_call_m2tk_.init_by_quote_mat(obj.callQuotes_);
            obj.historic_put_m2tk_.init_by_quote_mat(obj.putQuotes_);
            obj.historic_call_m2tk_.load_from_file;
            obj.historic_put_m2tk_.load_from_file;

            % init OptionOne M2TK for call and put options. 
            obj.init_opt_ones();
            
            % init opt tau
            obj.calc_tau();
            obj.update_opt_tau();
            
            % init vol surface
            obj.impvol_surface_.init_from_qms(obj);
        end
       %% 该init针对H5行情
        function [] = init(obj, opt_fn, fut_fn, stk_fn)
            % login H5 Quote system
            % make sure logout state.
            % init call put opt pricers store.
            [obj.optquotes_, obj.callQuotes_, obj.putQuotes_] = obj.init_call_put_mat(opt_fn);
            [obj.futquotes_, obj.futmap_] = obj.init_fut_map(fut_fn);
            [obj.stkquotes_, obj.stkmap_] = obj.init_stk_map(stk_fn);
        
            % init historic quotes m2tk.
            obj.historic_call_m2tk_.init_by_quote_mat(obj.callQuotes_);
            obj.historic_put_m2tk_.init_by_quote_mat(obj.putQuotes_);
            
            % init OptionOne M2TK for call and put options. 
            try 
                obj.init_opt_ones();
            catch e
                disp(e);
            end
            % init opt tau
            obj.calc_tau();
            obj.update_opt_tau();
            
            % wait quote ready
            obj.wait_quote_ready();
            
            % init vol surface
            obj.impvol_surface_.init_from_qms(obj);
            
            % init timer
            obj.regular_timer_ = timer('Period', obj.timer_interval_,...
                'TimerFcn', @obj.timer_event_function,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,10));
            start(obj.regular_timer_);
        end
        
        %% show infomation
        function [txt] = printinfo(obj)
            txt = sprintf('O32_H5 server info:\n');
            txt = sprintf('%dsn = %s\n',txt, obj.dsn_);
            txt = sprintf('%isConnect = %s\n',txt, obj.connection);
            txt = sprintf('%QmsPath = %s\n',txt, obj.QMS_path);
            if nargout == 0, disp(txt);end
        end
        %end of printinfo
       %% login test environment
        function [ret] = loginTestEnv(obj)
            if ~obj.isconnected_
                % 登录H5测试环境
                obj.isconnected_ = true;
                obj.srcType = 'H5';
                mktlogout;
                cur_dir = pwd;
                obj.QMS_path = [fileparts(mfilename('fullpath')), '\testEnv'];
                cd(obj.QMS_path);            
                pause(3)            
                ret = mktlogin;            
                pause(3)       
                cd(cur_dir);  

            else
                ret = obj.isconnected_;
                
            end
        end
        %login
       %% login to production environment 
        function [ret] = login(obj)
            if ~obj.isconnected_
                % 登录H5测试环境
                obj.isconnected_ = true;
                obj.srcType = 'H5';
                mktlogout;
                cur_dir = pwd;
                obj.QMS_path = fileparts(mfilename('fullpath'));
                cd(obj.QMS_path);            
                pause(3)            
                ret = mktlogin;            
                pause(3)       
                cd(cur_dir);    

            else
                ret = obj.isconnected_;
                
            end
        end
        %login
        
        
        
        %% log out only for H5 api
        function [] = logoff(obj)
            if obj.isconnected_
                if (strcmp(obj.srcType ,'H5'))
                    obj.Stop();
                    mktlogout;
                else
                    disp('srcType is not HS-H5');
                end

            end
        end
        %% 
         function [ret] = set_risk_free_rate(obj, rate)
            % function [ret] = set_risk_free_rate(obj, rate)
            ret = false;
            if isempty(obj.optquotes_)
                disp('QMS 未初始化');
                return;
            end
            flds = fields(obj.optquotes_);
            % 品种总个数为n
            n = length(flds);            
            for i = 1:n
                obj.optquotes_.(char(flds(i))).setRate(rate);                
            end 
            ret = true;
         end
        %% set_src_type_to_quote_structure
        function set_src_type_to_quote_structure(obj, quote, src_type)
            flds = fields(quote); 
            % 品种总个数为n
            n = length(flds);            
            for i = 1:n
                quote.(char(flds(i))).setSrcType(src_type);                
            end            
        end
        %% init_opt_ones
        function [] = init_opt_ones(obj)
            obj.m2cOptOne = obj.callQuotes_.getCopy;
            obj.m2pOptOne = obj.putQuotes_.getCopy;
            nT = length(obj.callQuotes_.yProps);
            nK = length(obj.callQuotes_.xProps);
            
            obj.m2cOptOne.data = OptionOne;
            obj.m2pOptOne.data = OptionOne;
            
            for t = 1:nT
                for k = 1:nK
                    % 取quote出来
                    cquote = obj.callQuotes_.data(t,k);
                    pquote = obj.putQuotes_.data(t,k);
                    
                    % 生成 callOne， putOne， 挂进data里
                    call_one = OptionOne;
                    call_one.quote = cquote;
                    obj.m2cOptOne.data(t,k) = call_one;
                    
                    put_one = OptionOne;
                    put_one.quote = pquote;
                    obj.m2pOptOne.data(t,k) = put_one;
                end
            end
        end
        %% attach_stock
        function [] = attach_stock(obj, code, name, market)
            % code 是股票代码, market是市场信息 ‘sh’'sz'
            if(obj.stkmap_.contains(code))
                return;
            end
            quote = QuoteStock;
            quote.fillStockInfo(code, name, market);
            quote.fillQuote;
            % add to struct
            varname = ['quotestk', code];
            obj.stkquotes_.(varname) = quote;
            % add to map
            obj.stkmap_.add(code, quote);
        end
        %% attach_future
        function [] = attach_future(obj, code, name, T)
            % code 是股票代码, market是市场信息 ‘sh’'sz'
            if(obj.futmap_.contains(code))
                return;
            end
            quote = QuoteFuture;
            quote.fillFutureInfo(code, name, T);
            quote.fillQuote;
            % add to struct
            varname = ['quotefut', code];
            obj.futquotes_.(varname) = quote;
            % add to map
            obj.futmap_.add(code, quote);            
        end
        %% Start
        function [] = Start(obj)
            if isempty(obj.regular_timer_)
                disp('定时器无效')
                return;
            end
            start(obj.regular_timer_);
        end
        %% Stop
        function [] = Stop(obj)
            if isempty(obj.regular_timer_)
                return;
            end            
            stop(obj.regular_timer_);
        end
        %% Update
        function [] = Update(self)
            self.query_quotes(self.optquotes_);
        end
        %% isRunning
        function [running] = isRunning(obj)
            if isempty(obj.regular_timer_)
                running = false;
                return;
            end
            switch obj.regular_timer_.Running
                case 'on'
                    running = true;
                case 'off'
                    running = false;
            end
        end
        %% release
        function [] = release(obj)
            stop(obj.regular_timer_);
            delete(obj.regular_timer_);
            mktlogout
        end
        
        
    end
    
    %% methods
    methods
        flag = isconnect(obj)
        [] = close(obj)
        data = intradaybar(obj,instrument,startdate,enddate,interval,field)
        data = realtime(obj,instruments,fields)
        data = history(obj,instrument,fields,fromdate,todate)
        data = tickdata(obj,instrument,startdate,enddate)
        % nearATM日内分时图 
        [ hFig ] = plot_nearATM_intraDay(obj);
        
        % 输出上一个交易日的call_pre_surf和put_pre_surf
        [call_pre_surf, put_pre_surf] = calc_pre_surf(obj, stkName);
         %% 取行情对象
        function [opt] = getOptQuoteByTK(obj, iT, K, type)
            %function [optquote] = getOptQuoteByTK(obj, iT, K, type)
            if ~exist('type', 'var'), type = 'call'; end
            if ~exist('iT', 'var'), iT = 1;     end
            if ~exist('K','var'), K  = 2;       end
            switch type
                case {'call'}
                    iK  = obj.callQuotes_.getIdxByPropvalue_X( K );
                    opt = obj.callQuotes_.getByIndex(iK, iT);
                case {'put'}
                    iK  = obj.putQuotes_.getIdxByPropvalue_X( K );
                    opt = obj.putQuotes_.getByIndex(iK, iT);
            end
        end
        
        
        
    end
    %% copy from QMS fusion  
    methods (Access = private)
        function [] = store_all_quotes(obj)
            obj.hist_opt_quotes_ = obj.store_quote(obj.optquotes_, obj.hist_opt_quotes_);
            obj.hist_fut_quotes_ = obj.store_quote(obj.futquotes_, obj.hist_fut_quotes_);
            obj.hist_stk_quotes_ = obj.store_quote(obj.stkquotes_, obj.hist_stk_quotes_);
        end
        
        function [stored_quotes] = store_quote(obj, quote, stored_quotes)
            % 记录截面行情            
            flds = fields(quote); 
            % 期权总个数为n
            n = length(flds);
            for i = 1:n
                slice_quote.(char(flds(i))) = quote.(char(flds(i))).getCopy();                
            end
            
            % 历史行情截面个数
            hist_t = length(stored_quotes);
            % 附加截面行情到末尾
            % 若历史为空
            if(hist_t < 1)
                temp(1) = slice_quote;
                stored_quotes = temp;
            else
                stored_quotes(hist_t + 1) = slice_quote;            
            end
        end
        
        function [quotes, m2c, m2p] = init_call_put_mat(obj, file_path)
            % quotes 是一个结构，其成员为['quoteopt','code'] 例：quote510050
            [quotes, m2c, m2p] =  QuoteOpt.init_from_sse_excel( file_path );
            obj.set_src_type_to_quote_structure(quotes, obj.srcType);
            obj.T = obj.init_opt_T(m2c);
            % query opt quote.
            obj.query_m2tk_quotes(m2c);
            % query put opt quote.
            obj.query_m2tk_quotes(m2p);
        end
        
        function [expirationTime] = init_opt_T(obj, optquote_m2tk)
            nK = length(optquote_m2tk.xProps);
            nT = length(optquote_m2tk.yProps);
            expirationTime = zeros(1, nT);
            for t = 1:nT
                for k = 1:nK
                    % 从容器中取出QuoteOpt 元素。
                    optquote_element = optquote_m2tk.data(t, k);
                    if(optquote_element.is_obj_valid())
                        expirationTime(t) = optquote_element.T;
                        break;
                    end                                        
                end
            end
        end
        
        function [futquotes, fut_map] = init_fut_map(obj, file_path)
            [futquotes, fut_map] = QuoteFuture.init_from_excel(file_path);
            obj.set_src_type_to_quote_structure(futquotes, obj.srcType);
            obj.query_quotes(futquotes);
        end
        
        function [stkquotes, stk_map] = init_stk_map(obj, file_path)
            [stkquotes, stk_map] = QuoteStock.init_from_excel(file_path);
            obj.set_src_type_to_quote_structure(stkquotes, obj.srcType);
            obj.query_quotes(stkquotes);
        end
        
        function [] = query_quotes(obj, quotes)
            flds = fields(quotes); 
            % 品种总个数为n
            n = length(flds);            
            for i = 1:n
                quotes.(char(flds(i))).fillQuote();                
            end
        end
        
        function [] = query_m2tk_quotes(obj, optquote_m2tk)
            [~, x_size] = size(optquote_m2tk.xProps);
            [y_size, ~] = size(optquote_m2tk.yProps);
            for indexX = 1:x_size;
                for indexY = 1:y_size;
                    % 从容器中取出QuoteOpt 元素。
                    optquote_element = optquote_m2tk.getByIndex(indexX, indexY);
                    if(optquote_element.is_obj_valid())
                        optquote_element.fillQuote();
                    end                    
                end
            end
            % [mkt, level] = getCurrentPrice(code,marketNo);
            % marketNo: 上海证券交易所='1';深交所='2'; 上交所期权='3';中金所='5'
            % mkt: 3*1数值向量, 依次为最新价,成交量,交易状态(=0表示取到行情;=1表示未取到行情)
            % level: 盘口数据(5*4矩阵), 第1~4列依次为委买价,委买量,委卖价,委卖量
            % [mkt, level] = getCurrentPrice(optquote_element.code, '3');
        end
        
        function [] = wait_quote_ready(obj)
            max_loop_time = 10;
            obj.ready_ = obj.check_opt_quotes();
            loop_time  = 0;
            while(~obj.ready_ && loop_time < max_loop_time)
                pause(3);
                obj.ready_ = obj.check_opt_quotes();
                loop_time = loop_time + 1;
            end
            if(~obj.ready_)
                disp('期权行情不全');
                % for test only
                obj.ready_ = true;
            else
                disp('所有期权行情准备就绪')
            end
        end
        
        function [avaiable ] = check_quote_avaiable_h5(obj)
            [p, mat] = getCurrentPrice('510050', '1');
            if p(1) > 0
                avaiable = 1;
            else
                avaiable = 0;
                disp('行情有问题');
            end
        end
        
        function [is_ready] = check_opt_quotes(obj)
            is_ready = obj.check_m2tk_status(obj.callQuotes_);
            disp('call check result:');
            disp(is_ready);
            if(is_ready)
                is_ready = obj.check_m2tk_status(obj.putQuotes_);
                disp('put check result:');
                disp(is_ready);                
            end
        end
        
        function [is_ready] = check_m2tk_status(obj, optquote_m2tk)
            % check quote status.
            is_ready = true;
            [~, x_size] = size(optquote_m2tk.xProps);
            [y_size, ~] = size(optquote_m2tk.yProps);
            for indexX = 1:x_size;
                for indexY = 1:y_size;
                    % 从容器中取出QuoteOpt 元素。
                    optquote_element = optquote_m2tk.getByIndex(indexX, indexY);
                    % query quote
                    optquote_element.fillQuote();
                    % M2TK 中可能是稀疏矩阵，需要判断元素是否有效
                    if(optquote_element.is_obj_valid())
                        str = sprintf('valid element, x: %d, y: %d\n', indexX, indexY);
                        disp(str);
                        if(~optquote_element.is_quote_valid())
                            str = sprintf('quote invalid element, x: %d, y: %d\n', indexX, indexY);
                            disp(str);
                            is_ready = false;
                            continue;
                        end
                    end
                end
            end        
        end
        
        function [] = calc_m2tk_quote(obj, optquote_m2tk)
            [~, x_size] = size(optquote_m2tk.xProps);
            [y_size, ~] = size(optquote_m2tk.yProps);
            
            calc_num = 0;
            nan_num = 0;
            for indexX = 1:x_size;
                for indexY = 1:y_size;
                    % 从容器中取出QuoteOpt 元素。
                    optquote_element = optquote_m2tk.getByIndex(indexX, indexY);
                    if(optquote_element.is_obj_valid() && optquote_element.is_quote_valid())
                        obj.generate_calc_quote(optquote_element);
                        if(isnan(optquote_element.impvol))
                            nan_num = nan_num + 1;
                        end
                        calc_num = calc_num + 1;
                    end
                end
            end       
%             calc_rate = calc_num / total_num;
%             nan_impvol_rate = nan_num / calc_num;
%             str = sprintf('calc rate ； %f\n', calc_rate);
%             disp(str);         
%             str = sprintf('nan impvol / calc rate ； %f, nan nodes: %d, calc nodes:%d. \n', nan_impvol_rate, nan_num, calc_num);
%             disp(str);
        end
        
        function [] = calc_opt_quotes(obj)
            flds = fields(obj.optquotes_); 
            % 品种总个数为n
            n = length(flds);            
            for i = 1:n
                optquote_element = obj.optquotes_.(char(flds(i)));
                if(optquote_element.is_obj_valid() && optquote_element.is_quote_valid())
                    %obj.generate_calc_quote(optquote_element);
                    optquote_element.calcMoneyness;
                end
            end
        end
        
        function [] = generate_calc_quote(obj, optquote_element)
            optquote_element.calc_last_all_greeks();
            optquote_element.calc_ask_all_greeks();
            optquote_element.calc_bid_all_greeks();   
            optquote_element.calcMoneyness;
        end
        
        function [] = timer_event_function(self, obj, event)
            try
            if(self.ready_)
                % 更新期权
                self.query_m2tk_quotes(self.callQuotes_);
                self.query_m2tk_quotes(self.putQuotes_);
                % 更新期货
                %self.query_quotes(self.futquotes_);
                % 更新股票
                self.query_quotes(self.stkquotes_);
                
                
                %lastP = getCurrentPrice('510050','1');
                %disp(['code: 510050, price: ', num2str(lastP)]);
                
                
                
                 self.calc_m2tk_quote(self.callQuotes_);
                self.calc_m2tk_quote(self.putQuotes_);
                
                % 更新Call Put VolSurf
                self.call_surf_.load_data(self.callQuotes_);
                self.put_surf_.load_data(self.putQuotes_);
                self.call_near_atm_(end + 1) = self.call_surf_.nearATM;
                self.put_near_atm_(end + 1) = self.put_surf_.nearATM;
                self.record_time_(end + 1) = now;
                
                nT = length(self.callQuotes_.yProps);
                nK = length(self.callQuotes_.xProps);
                save_to_file = true;
                
                for t = 1:nT
                    for k = 1:nK
                        % store quote to historic quotes.
                        call_quote = self.callQuotes_.data(t,k);
                        put_quote = self.putQuotes_.data(t,k);
                        c = self.historic_call_m2tk_.record_t_k_quote(t,k,call_quote);
                        p = self.historic_put_m2tk_.record_t_k_quote(t,k,put_quote);
                        if (c == 1 || p == 1) 
                            save_to_file = false;
                            self.save_to_file = false;
                        end
                    end
                end
                
                if save_to_file
                    if ~self.save_to_file
%                         self.historic_call_m2tk_.save_to_file();
%                         self.historic_put_m2tk_.save_to_file();
                        self.save_to_file = true;
                        % 日末执行清理外接清理逻辑
                        if self.is_end_of_day
                            if ~isempty(self.eod_handler)
                                fun = self.eod_handler;
                                fun();
                            end
                        end
                    end
                end
                
                self.impvol_surface_.sync_ImpVol();
                self.calc_tau_counter = self.calc_tau_counter - 1;
                if(self.calc_tau_counter ==  0)
                    self.update_tau;
                    self.calc_tau_counter = 10;
                end
                if ~isempty(self.check_risk_handler)
                    self.check_risk_handler(self.impvol_surface_, self.stkmap_.getQuote('510050').last, 0.05);
                end
            end
            disp('qms timer event');
            catch e
                disp(e)
            end
        end
        
        function [] = replay_timer_function(self, obj, event)
            %更新期权
            if(~isempty(self.optParser))
                self.optParser.parse();
            end
            %更新股票
            if(~isempty(self.stkParser))
                self.stkParser.parse();
            end
            %更新期货
            if(~isempty(self.futParser))
                self.futParser.parse();
            end
            
            nT = length(self.callQuotes_.yProps);
            nK = length(self.callQuotes_.xProps);
            for t = 1:nT
                for k = 1:nK
                    % store quote to historic quotes.
                    call_quote = self.callQuotes_.data(t,k);
                    put_quote = self.putQuotes_.data(t,k);
                    self.historic_call_m2tk_.record_t_k_quote(t,k,call_quote);
                    self.historic_put_m2tk_.record_t_k_quote(t,k,put_quote);
                end
            end
%             self.calc_opt_quotes();        
%             self.impvol_surface_.sync_ImpVol();
            self.calc_tau_counter = self.calc_tau_counter - 1;
            if(self.calc_tau_counter ==  0)
                self.update_tau;
                self.calc_tau_counter = 10;
            end
        end
    
        function [] = update_tau(obj)
            ct = Calendar_Test.GetInstance();
            obj.tauIntraday = (1 - ct.trading_fraction_day(now)) / obj.daysOfYear;
            obj.tauPrecise = obj.tauInterday + obj.tauIntraday;
            obj.update_opt_tau();            
        end
        
        function [] = update_opt_tau(obj)
            % 更新期权的剩余时间，QMS负责计算，这里只负责更新
            nK = length(obj.callQuotes_.xProps);
            nT = length(obj.callQuotes_.yProps);
            
            for t = 1:nT;
                for k = 1:nK;
                    % 从容器中取出QuoteOpt 元素。
                    optquote_element = obj.callQuotes_.data(t, k);
                    if(optquote_element.is_obj_valid())
                        optquote_element.tau = obj.tauPrecise(t);
                    end                    
                    optquote_element = obj.putQuotes_.data(t, k);
                    if(optquote_element.is_obj_valid())
                        optquote_element.tau = obj.tauPrecise(t);
                    end
                end
            end            
        end
        
        function [obj] = calc_tau(obj)
            % 计算期权的剩余时间。
%         tauInterday;  % 年化  1*4 , 每天只更新一次，init时做
%         tauIntraday;  % 年化  1*1， 定时更新
%         tauPrecise;   % 年化， == tauInterday + tauIntraday,  1*4， 赋值给所有的quoteopt.tau        
           ct = Calendar_Test.GetInstance();
           obj.daysOfYear = ct.calc_trading_days_of_year(obj.T(1), obj.T(end));
           nT = length(obj.T);
           Interday = zeros(1, nT);
           for i = 1:nT
               t = obj.T(i);
               Interday(i) = ct.trading_days(obj.currentDate, t);
           end
           obj.tauInterday = Interday / obj.daysOfYear;
           obj.tauIntraday = (1 - ct.trading_fraction_day(now)) / obj.daysOfYear;
           obj.tauPrecise = obj.tauInterday + obj.tauIntraday;
        end
        
        function [eod] = is_end_of_day(obj)
            % 检验是否eod，避免搞错
            tm = now - floor(now);
            if (tm>=9.5/24  && tm<=15/24)
                eod = false;
                return;
            end
            eod = true;
        end
    end
     %% static function
    methods (Access = public, Static = true)
        [] = demo;
        [] = quote_file_src_demo;
        function set_quoteopt_ptr_in_position_array(positionArray, quoteOpts)
            % 给position.quote挂上正确的quoteOpt
            % quotes 是一个struct，里面命名如下：quoteopt10000394
            % L = length(positionArray.node);
            L = positionArray.latest;
            for i = 1:L
                p = positionArray.node(i);
                code = p.instrumentCode;
                % 判断code是期权
                if length(code)<8
                    continue;
                end
                try
                    % 这一句： tmp = quoteOpts.quoteopt10000394;
                    eval( [ 'tmp = quoteOpts.quoteopt' code ';' ] ) ;
                    %　在 position上挂quoteopt指针
                    p.quote = tmp;
                    p.instrumentName = tmp.optName;
                catch
                    disp('quote指针赋值失败');
                end
            end
        end
        % 添加截取分钟固定时间段的函数
        val = spliceFixedTimeQuote(data, quoteTime, fixed_time_);
    end
    
    %% look at test.xml
%     enumeration
%        
%         %liyong2310_202006_168 ('10.42.80.167', 9003, '2038', '111aaa', '202006', '820002006-J');
%     
%     end
end