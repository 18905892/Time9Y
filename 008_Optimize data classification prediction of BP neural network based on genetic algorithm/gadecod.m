function [val, W1, B1, W2, B2] = gadecod(x)

%%  ��ȡ���ռ����
S1 = evalin('base', 'S1');             % ��ȡ���ز�ڵ����
net = evalin('base', 'net');           % ��ȡ�������
p_train = evalin('base', 'p_train');   % ��ȡ��������
t_train = evalin('base', 't_train');   % ��ȡ�������

%%  ������ʼ��
R2 = size(p_train, 1);                 % ����ڵ��� 
S2 = size(t_train, 1);                 % ����ڵ���

%%  ����Ȩ�ر���
for i = 1 : S1
    for k = 1 : R2
        W1(i, k) = x(R2 * (i - 1) + k);
    end
end

%%  ���Ȩ�ر���
for i = 1 : S2
    for k = 1 : S1
        W2(i, k) = x(S1 * (i - 1) + k + R2 * S1);
    end
end

%%  ����ƫ�ñ���
for i = 1 : S1
    B1(i, 1) = x((R2 * S1 + S1 * S2) + i);
end

%%  ���ƫ�ñ���
for i = 1 : S2
    B2(i, 1) = x((R2 * S1 + S1 * S2 + S1) + i);
end

%%  ��ֵ������
net.IW{1, 1} = W1;
net.LW{2, 1} = W2;
net.b{1}     = B1;
net.b{2}     = B2;

%%  ģ��ѵ��
net.trainParam.showWindow = 0;      % �ر�ѵ������
net = train(net, p_train, t_train);

%%  �������
t_sim1 = sim(net, p_train);

%%  ����һ��
T_train = vec2ind(t_train);
T_sim1  = vec2ind(t_sim1);

%%  ������Ӧ��ֵ
val =  1 ./ (1 - sum(T_sim1 == T_train) ./ size(p_train, 2));
