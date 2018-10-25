cd('c:\yangyiran\')
%% ��¼�ں��˻�
counter_rh = CounterRH.rh_demo_tf;
if ~counter_rh.is_Counter_Login,counter_rh.login;end
entrustsplaced = EntrustArray;
%% ��ѯ�˻��ʽ����
accountinfo = counter_rh.queryAccount;
fprintf('\n');
fprintf('%8s:%12s\n','ƽӯ',num2str(accountinfo.close_profit));
fprintf('%8s:%12s\n','��ӯ',num2str(accountinfo.position_profit));
fprintf('%s:%12s\n','���ᱣ֤��',num2str(accountinfo.frozen_margin));
fprintf('%7s:%12s\n','��֤��',num2str(accountinfo.current_margin));
fprintf('%6s:%12s\n','�����ʽ�',num2str(accountinfo.available_fund));
fprintf('%6s:%12s\n','��̬Ȩ��',num2str(accountinfo.pre_interest));

%% ��ѯ�ֲֵ����
fprintf('\n��ѯ�ֲ���Ϣ:\n');
posinfo = counter_rh.queryPositions;
npos = length(posinfo);
for i = 1:npos
    volume = posinfo(i).total_position;
    if volume == 0, continue; end
    if posinfo(i).direction == 1
        buysell = '��';
    elseif posinfo(i).direction == -1
        buysell = '��';
    end
    fprintf('%10s%5s%5s\n',posinfo(i).asset_code,buysell,...
        num2str(posinfo(i).total_position));
end
%% ��ѯ�ɽ���¼
fprintf('\n��ѯ�ɽ���¼:\n');
trades = counter_rh.queryTrades;
ntrades = length(trades);
for i = 1:ntrades
    if trades(i).direction == 1
        buysell = '��';
    elseif trades(i).direction == -1
        buysell = '��';
    end
    fprintf('%10s%5s%4s%10s%15s\n',trades(i).asset_code,buysell,num2str(trades(i).volume),...
        num2str(trades(i).trade_price),trades(i).trade_time);
end
%% ��ѯ�г�����
qms = cQMS;
futs = {'cu1812';'zn1812';'ni1901';'rb1901';'T1812';'IH1811'};
for i = 1:size(futs,1)
    instrument = code2instrument(futs{i});
    qms.registerinstrument(instrument);
end
qms.setdatasource('ctp');
qms.ctplogin('countername','ccb_ly_fut');
%% 
fprintf('\n��ѯ�г�����:\n')
qms.refresh
quotes = qms.getquote;
for i = 1:size(futs,1)
    fprintf('%10s%10s%10s%25s\n',quotes{i}.code_ctp,num2str(quotes{i}.bid1),num2str(quotes{i}.ask1),quotes{i}.update_time2);
end

%% ί���µ� - ��ࣨ����
entrust = Entrust;
code = 'cu1812';
spread = 1;
instrument = code2instrument(code);
direction = 1;  %ί�з�����:1����:-1
q = qms.getquote(code);
px = q.ask1 - spread*instrument.tick_size; %ί�м۸�
volume = 1;     %ί����
offset = 1;     %��/ƽ�֣�  ��:1��ƽ:-1
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret
    entrustsplaced.push(entrust);
    fprintf('�������-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));
end

%% ί���µ� - ���գ�����
entrust = Entrust;
code = 'cu1812';
spread = 1;
direction = -1;
q = qms.getquote(code);
px = q.bid1 + spread*instrument.tick_size; %ί�м۸�
volume = 1;
offset = 1;
entrust.fillEntrust(1,code,direction,px,volume,offset,code);
entrust.assetType = 'Future';
ret = counter_rh.placeEntrust(entrust);
if ret
    entrustsplaced.push(entrust);
    fprintf('��������-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));
end


%% ί���µ� - ��ࣨƽ��
code = 'cu1812';
volume = 1;
spread = 0;
closetodayflag = 1; %ƽ��֣�������ר�ã�
positions = counter_rh.queryPositions(code);
if isempty(positions)
    fprintf('��ƽ����δ����%s�ĳֲ֣�����\n',code);
else
    npos = length(positions);
    if npos > 1
        for i = 1:npos
            pos = positions(i);
            if pos.direction == -1
                break
            end
        end
    else
        pos = positions;
    end
    
    if pos.direction ~= -1
        fprintf('��ƽ���󣺽�����%s������ֲ֣�����\n',code);
    else
        if pos.total_position == 0
            fprintf('��ƽ����δ����%s�������ֲ֣�����\n',code);
        else
            available_position = pos.available_position;
            if volume > available_position
                fprintf('��ƽ����ƽ����������ƽ����ֲ���������\n')
            else
                entrust = Entrust;
                q = qms.getquote(code);
                px = q.ask1 - spread*instrument.tick_size; %ί�м۸�
                entrust.fillEntrust(1,code,-pos.direction,px,volume,-1,code);
                entrust.assetType = 'Future';
                if closetodayflag, entrust.closetodayFlag = 1;end
                ret = counter_rh.placeEntrust(entrust);
                if ret
                    entrustsplaced.push(entrust);
                    fprintf('���ƽ��-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));
                end
            end
        end
    end
end

%% ί���µ� - ���գ�ƽ��
code = 'IH1811';
volume = 1;
spread = 0;
closetodayflag = 1; %ƽ��֣�������ר�ã�
positions = counter_rh.queryPositions(code);
if isempty(positions)
    fprintf('��ƽ����δ����%s�ĳֲ֣�����\n',code);
else
    npos = length(positions);
    if npos > 1
        for i = 1:npos
            pos = positions(i);
            if pos.direction == 1
                break
            end
        end
    else
        pos = positions;
    end
    
    if pos.direction ~= 1
        fprintf('��ƽ���󣺽�����%s�������ֲ֣�����\n',code);
    else
        if pos.total_position == 0
            fprintf('��ƽ����δ����%s������ֲ֣�����\n',code);
        else
            available_position = pos.available_position;
            if volume > available_position
                fprintf('��ƽ����ƽ����������ƽ����ֲ���������\n')
            else
                entrust = Entrust;
                q = qms.getquote(code);
                px = q.bid1 + spread*instrument.tick_size; %ί�м۸�
                entrust.fillEntrust(1,code,-pos.direction,px,volume,-1,code);
                entrust.assetType = 'Future';
                if closetodayflag, entrust.closetodayFlag = 1;end
                ret = counter_rh.placeEntrust(entrust);
                if ret
                    entrustsplaced.push(entrust);
                    fprintf('����ƽ��-�������:%s ִ�гɹ�\n',num2str(entrust.entrustNo));
                end
            end
        end
    end
end

%% ��ѯί�����
fprintf('\n��ѯί�����:\n')
nentrust = entrustsplaced.latest;
for i = 1:nentrust
    entrust_i = entrustsplaced.node(i);
    warning('off')
    ret = counter_rh.queryEntrust(entrust_i);
    if ret
        if entrust_i.is_entrust_closed
            if entrust_i.dealVolume == entrust_i.volume && entrust_i.cancelVolume == 0
                fprintf('\t������� %s ״̬��ȫ���ɽ�\n',num2str(entrust_i.entrustNo));
            elseif entrust_i.dealVolume == 0 && entrust_i.cancelVolume == entrust_i.volume
                fprintf('\t������� %s ״̬��ȫ��ȡ��\n',num2str(entrust_i.entrustNo));
            elseif entrust_i.dealVolume > 0 && entrust_i.dealVolume < entrust_i.volume && entrust_i.dealVolume + entrust_i.cancelVolume == entrust_i.volume
                fprintf('\t������� %s ״̬�����ֳɽ���δ�ɽ�����ȫ��ȡ��\n',num2str(entrust_i.entrustNo));
            end
        else
            if entrust_i.dealVolume == 0 && entrust_i.cancelVolume == 0
                fprintf('\t������� %s ״̬��ȫ��δ�ɽ�\n',num2str(entrust_i.entrustNo));
            elseif entrust_i.dealVolume > 0 && entrust.dealVolume < entrust_i.volume && entrust_i.cancelVolume == 0
                fprintf('\t������� %s ״̬�����ֳɽ�\n',num2str(entrust_i.entrustNo));
            end
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





