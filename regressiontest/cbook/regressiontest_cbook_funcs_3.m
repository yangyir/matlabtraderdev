clc;
book = cBook;
%开空
book.addpositions('code','zn1811','price',21810,'volume',-2,'time','2018-09-25 09:01:01','offset',1);
book.printpositions;
% 本子-:
% 合约          买卖        持仓       今仓      开仓均价
% zn1811         -1          2          0          21810
%%
%同时开多
book.addpositions('code','zn1811','price',21495,'volume',2,'time','2018-09-25 10:01:01','offset',1);
book.printpositions;
% 本子-:
% 合约          买卖        持仓       今仓      开仓均价
% zn1811         -1          2          0          21810
% zn1811          1          2          0          21495
%%
%加开多
book.addpositions('code','zn1811','price',21475,'volume',2,'time','2018-09-25 10:01:01','offset',1);
book.printpositions;
% 本子-:
% 合约          买卖        持仓       今仓      开仓均价
% zn1811         -1          2          0          21810
% zn1811          1          4          0          21485
%%
%平空
book.addpositions('code','zn1811','price',21475,'volume',2,'time','2018-09-25 10:01:01','offset',-1);
book.printpositions;
% 本子-:
% 合约          买卖        持仓       今仓      开仓均价
% zn1811          1          4          0          21485
%%
%继续平空（应该报错）
book.addpositions('code','zn1811','price',21475,'volume',2,'time','2018-09-25 10:01:01','offset',-1);
book.printpositions;
% Error using cBook/addpositions (line 72)
% cBook:addpositions:position not found to close in the portfolio