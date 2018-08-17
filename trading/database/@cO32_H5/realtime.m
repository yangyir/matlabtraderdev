% fields insturment type
% [mkt, level] = getCurrentPrice(code,marketNo);
% marketNo: �Ϻ�֤ȯ������='1';���='2'; �Ͻ�����Ȩ='3';�н���='5'
% mkt: 5*1��ֵ����, ����Ϊ���¼�,�ɽ���,����״̬(=0��ʾȡ������;=1��ʾδȡ������),���׷�����,������
% marketNo: 0 -�Ϻ�L1,����L1,ת���еأ������� 1
% level: �̿�����(5*4����), ��1~4������Ϊί���,ί����,ί����,ί����
function data = realtime(obj,instruments,fields)
    %note fields are not used here
    variablenotused(fields);
    if ~obj.isconnected_
        data = {};
        return
    end
    marketNo = '1';
    if isa(instruments,'cInstrument')
        % getCurrentPrice come from H5Quote �� qtool\option\optionClass\ʵ�̽�����\O32_matlab\H5Quote\H5QUOTE
        if isa(instruments,'cStock')
            marketNo = '1';
        elseif isa(insturments,'cOption')
            marketNo = '3';
        end
        [mkt, level] = getCurrentPrice(instruments.code_H5,marketNo);
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level);
    elseif iscell(instruments)
        n = length(instruments);
        data = cell(n,1);
        for i = 1:n
            if isa(instruments,'cInstrument')
                if isa(instruments,'cStock')
                    marketNo = '1';
                elseif isa(insturments,'cOption')
                    marketNo = '3';
                end
                [mkt, level] = getCurrentPrice(instruments{i}.code_H5,marketNo);
            else
                [mkt, level] = getCurrentPrice(instruments{i},marketNo);
            end
            data{i} = struct('mkt',mkt,'level',level);
        end
    else
        [mkt, level] = getCurrentPrice(num2str(instruments),marketNo);
        data = cell(1,1);
        data{1} = struct('mkt',mkt,'level',level);
    end
end
%end of realtime