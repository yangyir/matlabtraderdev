function [margin] = cal_option_margin(settlement_future,openprice_option,settlement_option,K,margin_rate,callorput,contract_size)
%       -- ���ױ�֤�� = max��Ȩ���� + ����ڻ���Լ���ױ�֤�� - 1/2 * ��Ȩ��ֵ�Ȩ���� + 1/2 * ����ڻ���Լ���ױ�֤��
%       -- Ȩ���� = max����Ȩ���ּۣ���Ȩ����ۣ� * ��Ȩ��Լ����
%       -- ����ڻ���Լ���ױ�֤�� = ����ڻ���Լ����� * �ڻ���Լ���� * ��֤�����
%       -- ������Ȩ����ֵ�� = Max������Ȩ��Լִ�м۸� - ����ڻ���Լ����ۣ�*��Ȩ��Լ������0��
%       -- ������Ȩ����ֵ�� = Max��������ڻ���Լ����� - ��Ȩ��Լִ�м۸�*��Ȩ��Լ������0��
%       -- �������еĽ��������ȡ�����ۣ������ȡ������
      premium = max(openprice_option, settlement_option) * contract_size;
      margin_future = settlement_future * contract_size * margin_rate;
      if strcmp(callorput,'call')
            outofmoney_option = max((K - settlement_future) * contract_size , 0);
      elseif strcmp(callorput,'put')
            outofmoney_option = max((settlement_future - K) * contract_size , 0);
      end
      margin_left = premium + margin_future -0.5* outofmoney_option;
      margin_right = premium + 0.5 * margin_future;
      margin = max(margin_left, margin_right);
end