myTrades = cTradeOpenArray; 
myTrade1 = cTradeOpen('id','trade1',...
    'countername','citic_kim_fut',...
    'bookname','book-regressiontest',...
    'code','ni1811',...
    'opendatetime',datenum([datestr(getlastbusinessdate),' 14:59:59']),...
    'opendirection',1,...
    'openvolume',1,...
    'openprice',104770);
%
myTrade2 = cTradeOpen('id','trade2',...
    'countername','citic_kim_fut',...
    'bookname','book-regressiontest',...
    'code','ni1811',...
    'opendatetime',datenum([datestr(businessdate(getlastbusinessdate,1)),' 14:59:59']),...
    'opendirection',1,...
    'openvolume',1,...
    'openprice',105770);
myTrades.push(myTrade1);
myTrades.push(myTrade2);
%%
txtfn = 'c:\yangyiran\regressiondata\trades_regressiontest.txt';
myTrades.totxt(txtfn);
xlsfn = 'c:\yangyiran\regressiondata\trades_regressiontest.xlsx';
myTrades.toexcel(xlsfn,'tradesopen');
%%
myBook1 = cBook;
myBook1.loadtradesfromtxt(txtfn);
myBook1.printpositions;
% 本子-book-regressiontest:
% 合约          买卖        持仓       今仓      开仓均价
% ni1811          1          2          1         105270
%%
myBook2 = cBook;
myBook2.loadtradesfromexcel(xlsfn,'tradesopen');
myBook2.printpositions;
%todo:errors
% 未定义与 'double' 类型的输入参数相对应的函数 'regexp'。
% 
% 出错 cTradeOpen/table2tradeopen (line 11)
%             vallist = regexp(data{i},';','split');
% 
% 出错 cTradeOpenArray/fromtable (line 10)
%         anode = anode.table2tradeopen(table(1,:),table(i,:));
% 
% 出错 cTradeOpenArray/fromexcel (line 18)
%     obj = obj.fromtable(raw);
% 
% 出错 cBook/loadtradesfromexcel (line 4)
%     trades.fromexcel(fn,sheetn);