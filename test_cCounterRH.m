cd('c:\yangyiran\')
%% ��¼�ں��˻�
counter_rh = cCounterRH.rh_demo;
if ~counter_rh.is_Counter_Login,counter_rh.login;end

%% ��ѯ�˻��ʽ����
accountinfo = counter_rh.queryAccount;
fprintf('\n');
fprintf('%8s:%12s\n','ƽӯ',num2str(accountinfo.close_profit));
fprintf('%8s:%12s\n','��ӯ',num2str(accountinfo.position_profit));
fprintf('%s:%12s\n','���ᱣ֤��',num2str(accountinfo.frozen_margin));
fprintf('%7s:%12s\n','��֤��',num2str(accountinfo.current_margin));
fprintf('%6s:%12s\n','�����ʽ�',num2str(accountinfo.available_fund));
fprintf('%6s:%12s\n','��̬Ȩ��',num2str(accountinfo.pre_interest));

%% ί���µ� - ��ࣨ����
entrust = Entrust;
code = 'IC1809';
direction = 1;  %ί�з�����:1����:-1
px = 4585;      %ί�м۸�      
volume = 1;     %ί����
offset = 1;     %��/ƽ�֣�  ��:1��ƽ:-1
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('�������-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));end

%% ί���µ� - ���գ�����
entrust = Entrust;
code = 'rb1901';
direction = -1;
px = 4135;
volume = 1;
offset = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('��������-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));end

%% ί���µ� - ��ࣨƽ��
%ע�ͣ���Ҫ���ֲ���Ϣ��ĿǰqueryPositions�����⣬�豾�ؼ�¼�ֲ�
entrust = Entrust;
code = 'rb1901';
direction = 1;
px = 4130;
volume = 2;
offset = -1;
%ƽ��֣�������ר�ã�
closetodayflag = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
if closetodayflag, entrust.closetodayFlag = 1;end
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('ƽ�����-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));end

%% ί���µ� - ���գ�ƽ��
%ע�ͣ���Ҫ���ֲ���Ϣ��ĿǰqueryPositions�����⣬�豾�ؼ�¼�ֲ�
entrust = Entrust;
code = 'IC1809';
direction = -1;
px = 4585;
volume = 1;
offset = -1;
%ƽ��֣�������ר�ã�
closetodayflag = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
if closetodayflag, entrust.closetodayFlag = 1;end
ret = counter_rh.placeEntrust(entrust);
if ret, fprintf('ƽ������-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));end

%% ��ѯί�����
warning('off')
ret = counter_rh.queryEntrust(entrust);
if ret
    if entrust.is_entrust_closed
        if entrust.dealVolume == entrust.volume && entrust.cancelVolume == 0
            fprintf('������� %s ״̬��ȫ���ɽ�\n',num2str(entrust.entrustNo));
        elseif entrust.dealVolume == 0 && entrust.cancelVolume == entrust.volume
            fprintf('������� %s ״̬��ȫ��ȡ��\n',num2str(entrust.entrustNo));
        elseif entrust.dealVolume > 0 && entrust.dealVolume < entrust.volume && entrust.dealVolume + entrust.cancelVolume == entrust.volume
            fprintf('������� %s ״̬�����ֳɽ���δ�ɽ�����ȫ��ȡ��\n',num2str(entrust.entrustNo));
        end
    else
        if entrust.dealVolume == 0 && entrust.cancelVolume == 0
            fprintf('������� %s ״̬��ȫ��δ�ɽ�\n',num2str(entrust.entrustNo));
        elseif entrust.dealVolume > 0 && entrust.dealVolume < entrust.volume && entrust.cancelVolume == 0
            fprintf('������� %s ״̬�����ֳɽ�\n',num2str(entrust.entrustNo));
        end
    end
end
%% ����ί��
if ~entrust.is_entrust_closed
    ret = counter_rh.withdrawEntrust(entrust);
    if ret
        fprintf('������� %s �����ɹ�\n',num2str(entrust.entrustNo));
    end
end

%% �ǳ��ں�
counter_rh.logout;





