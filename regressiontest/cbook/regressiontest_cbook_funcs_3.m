clc;
book = cBook;
%����
book.addpositions('code','zn1811','price',21810,'volume',-2,'time','2018-09-25 09:01:01','offset',1);
book.printpositions;
% ����-:
% ��Լ          ����        �ֲ�       ���      ���־���
% zn1811         -1          2          0          21810
%%
%ͬʱ����
book.addpositions('code','zn1811','price',21495,'volume',2,'time','2018-09-25 10:01:01','offset',1);
book.printpositions;
% ����-:
% ��Լ          ����        �ֲ�       ���      ���־���
% zn1811         -1          2          0          21810
% zn1811          1          2          0          21495
%%
%�ӿ���
book.addpositions('code','zn1811','price',21475,'volume',2,'time','2018-09-25 10:01:01','offset',1);
book.printpositions;
% ����-:
% ��Լ          ����        �ֲ�       ���      ���־���
% zn1811         -1          2          0          21810
% zn1811          1          4          0          21485
%%
%ƽ��
book.addpositions('code','zn1811','price',21475,'volume',2,'time','2018-09-25 10:01:01','offset',-1);
book.printpositions;
% ����-:
% ��Լ          ����        �ֲ�       ���      ���־���
% zn1811          1          4          0          21485
%%
%����ƽ�գ�Ӧ�ñ���
book.addpositions('code','zn1811','price',21475,'volume',2,'time','2018-09-25 10:01:01','offset',-1);
book.printpositions;
% Error using cBook/addpositions (line 72)
% cBook:addpositions:position not found to close in the portfolio