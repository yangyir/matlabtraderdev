myBook = cBook('BookName','Book-RegressionTest');
%%
myBook.addpositions('code','ni1811','price',107827.5,'volume',12,'time','2018-09-03 14:59:00');
myBook.addpositions('code','rb1901','price',4138.5,'volume',4,'time','2018-09-03 14:59:00');
myBook.addpositions('code','zn1901','price',21505.0,'volume',-3,'time','2018-09-03 14:59:00');
myBook.addpositions('code','T1812','price',94.9050,'volume',-1,'time','2018-09-03 14:59:00');
myBook.printpositions;
% 本子-Book-RegressionTest:
% 合约          买卖        持仓       今仓      开仓均价
% ni1811          1         12          0       107827.5
% rb1901          1          4          0         4138.5
% zn1901         -1          3          0          21505
%  T1812         -1          1          0         94.905
%%
myBook.loadpositionsfromcounter;
% 错误使用 cBook/loadpositionsfromcounter (line 4)
% cBook:loadpositionsfromcounter:not allowed any more
%%
fn = 'C:\yangyiran\regressiondata\book_regressiontest.txt';
myBook.savepositionstofile(fn,'time','2018-09-03 15:15:00');
%%
myBookLoadFromFile = cBook;
myBookLoadFromFile.loadpositionsfromfile(fn);
myBookLoadFromFile.printpositions;
% 本子-Book-RegressionTest:
% 合约          买卖        持仓       今仓      开仓均价
% ni1811          1         12          0       107827.5
% rb1901          1          4          0         4138.5
% zn1901         -1          3          0          21505
%  T1812         -1          1          0         94.905
%%
myBookLoadFromFile2 = cBook('BookName','Book-RegressionTest-2');
myBookLoadFromFile2.loadpositionsfromfile(fn);
myBookLoadFromFile2.printpositions;
% 本子-Book-RegressionTest-2:
% empty book......