%%  ��ջ�������
warning off             % �رձ�����Ϣ
close all               % �رտ�����ͼ��
clear                   % ��ձ���
clc                     % ���������

%%  ��������
res = xlsread('���ݼ�.xlsx');

%%  ����ѵ�����Ͳ��Լ�
temp = randperm(357);

P_train = res(temp(1: 240), 1: 12)';
T_train = res(temp(1: 240), 13)';
M = size(P_train, 2);

P_test = res(temp(241: end), 1: 12)';
T_test = res(temp(241: end), 13)';
N = size(P_test, 2);

%%  ���ݹ�һ��
[p_train, ps_input] = mapminmax(P_train, 0, 1);
p_test  = mapminmax('apply', P_test, ps_input);

t_train = ind2vec(T_train);
t_test  = ind2vec(T_test );

%%  ����ģ��
S1 = 5;           %  ���ز�ڵ����                
net = newff(p_train, t_train, S1);

%%  ���ò���
net.trainParam.epochs = 1000;        % ���������� 
net.trainParam.goal   = 1e-6;        % ���������ֵ
net.trainParam.lr     = 0.01;        % ѧϰ��

%%  �����Ż�����
gen = 50;                       % �Ŵ�����
pop_num = 5;                    % ��Ⱥ��ģ
S = size(p_train, 1) * S1 + S1 * size(t_train, 1) + S1 + size(t_train, 1);
                                % �Ż���������
bounds = ones(S, 1) * [-1, 1];  % �Ż������߽�

%%  ��ʼ����Ⱥ
prec = [1e-6, 1];               % epslin Ϊ1e-6, ʵ������
normGeomSelect = 0.09;          % ѡ�����Ĳ���
arithXover = 2;                 % ���溯���Ĳ���
nonUnifMutation = [2 gen 3];    % ���캯���Ĳ���

initPop = initializega(pop_num, bounds, 'gabpEval', [], prec);  

%%  �Ż��㷨
[Bestpop, endPop, bPop, trace] = ga(bounds, 'gabpEval', [], initPop, [prec, 0], 'maxGenTerm', gen,...
                           'normGeomSelect', normGeomSelect, 'arithXover', arithXover, ...
                           'nonUnifMutation', nonUnifMutation);

%%  ��ȡ���Ų���
[val, W1, B1, W2, B2] = gadecod(Bestpop);

%%  ������ֵ
net.IW{1, 1} = W1;
net.LW{2, 1} = W2;
net.b{1}     = B1;
net.b{2}     = B2;

%%  ģ��ѵ��
net.trainParam.showWindow = 1;       % ��ѵ������
net = train(net, p_train, t_train);  % ѵ��ģ��

%%  �������
t_sim1 = sim(net, p_train);
t_sim2 = sim(net, p_test );

%%  ���ݷ���һ��
T_sim1 = vec2ind(t_sim1);
T_sim2 = vec2ind(t_sim2);

%%  ��������
error1 = sum((T_sim1 == T_train)) / M * 100 ;
error2 = sum((T_sim2 == T_test )) / N * 100 ;

%%  ��������
[T_train, index_1] = sort(T_train);
[T_test , index_2] = sort(T_test );

T_sim1 = T_sim1(index_1);
T_sim2 = T_sim2(index_2);

%%  �Ż���������
figure
plot(trace(:, 1), 1 ./ trace(:, 2), 'LineWidth', 1.5);
xlabel('��������');
ylabel('��Ӧ��ֵ');
string = {'��Ӧ�ȱ仯����'};
title(string)
grid on

%%  ��ͼ
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'ѵ����Ԥ�����Ա�'; ['׼ȷ��=' num2str(error1) '%']};
title(string)
grid

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'���Լ�Ԥ�����Ա�'; ['׼ȷ��=' num2str(error2) '%']};
title(string)
grid

%%  ��������
figure
cm = confusionchart(T_train, T_sim1);
cm.Title = 'Confusion Matrix for Train Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
    
figure
cm = confusionchart(T_test, T_sim2);
cm.Title = 'Confusion Matrix for Test Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
