function [ret] = tdsq_reverseshort(candlek,bsnum,macdnum,macdbsnum,ptrigger,pshift)
% function to return boolean
% true:to open a short position
% false:not to open a short position
    if nargin == 7
        pshift = 0;
    end
    
    %������������
    %1.���̼�С��ptrigger
    %  ���ߵ����̵Ϳ���ʱ�����㿪�̼�С��ptrigger-pshift
    %2.���macdnumΪ������ͬʱ����bsnum>=1��macdbsnum>=1
    %  ��������macdnumΪ������ͬʱ����bsnum>=1��macdbsnum>=3
    
    f1 = candlek(5) < ptrigger || candlek(2) < ptrigger - pshift;
    f2 = (macdnum < 0 && bsnum >= 1 && macdbsnum >= 1) || ...
        (macdnum > 0 && bsnum >= 3 && macdbsnum >= 3);
    ret = f1 && f2;

end