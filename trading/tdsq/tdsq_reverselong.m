function [ret] = tdsq_reverselong(candlek,ssnum,macdnum,macdssnum,ptrigger,pshift)
% function to return boolean
% true:to open a long position
% false:not to open a long position
    if nargin == 7
        pshift = 0;
    end
    
    %������������
    %1.���̼۴���ptrigger
    %  ���ߵ����̸߿���ʱ�����㿪�̼۴���ptrigger+pshift
    %2.���macdnumΪ������ͬʱ����ssnum>=1��macdssnum>=1
    %  ��������macdnumΪ������ͬʱ����ssnum>=1��macdssnum>=3
    
    f1 = candlek(5) > ptrigger || candlek(2) > ptrigger + pshift;
    f2 = (macdnum > 0 && ssnum >= 1 && macdssnum >= 1) || ...
        (macdnum < 0 && ssnum >= 3 && macdssnum >= 3);
    ret = f1 && f2;

end