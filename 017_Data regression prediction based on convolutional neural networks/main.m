%%  ��ջ�������
warning off             % �رձ�����Ϣ
close all               % �رտ�����ͼ��
clear                   % ��ձ���
clc                     % ���������

%%  ��������
res = xlsread('���ݼ�.xlsx');

%%  ����ѵ�����Ͳ��Լ�
temp = randperm(103);

P_train = res(temp(1: 80), 1: 7)';
T_train = res(temp(1: 80), 8)';
M = size(P_train, 2);

P_test = res(temp(81: end), 1: 7)';
T_test = res(temp(81: end), 8)';
N = size(P_test, 2);

%%  ����ƽ��
%   ������ƽ�̳�1ά����ֻ��һ�ִ���ʽ
%   Ҳ����ƽ�̳�2ά���ݣ��Լ�3ά���ݣ���Ҫ�޸Ķ�Ӧģ�ͽṹ
%   ����Ӧ��ʼ�պ���������ݽṹ����һ��
p_train =  double(reshape(P_train, 7, 1, 1, M));
p_test  =  double(reshape(P_test , 7, 1, 1, N));
t_train =  double(T_train)';
t_test  =  double(T_test )';

%%  ��������ṹ
layers = [
 imageInputLayer([7, 1, 1])      % ����� �������ݹ�ģ[7, 1, 1]
 
 convolution2dLayer([3, 1], 16)  % ����˴�С 3*1 ����16������ͼ
 batchNormalizationLayer         % ����һ����
 reluLayer                       % Relu�����
 
 convolution2dLayer([3, 1], 32)  % ����˴�С 3*1 ����32������ͼ
 batchNormalizationLayer         % ����һ����
 reluLayer                       % Relu�����

 dropoutLayer(0.2)               % Dropout��
 fullyConnectedLayer(1)          % ȫ���Ӳ�
 regressionLayer];               % �ع��

%%  ��������
options = trainingOptions('sgdm', ...      % SGDM �ݶ��½��㷨
    'MiniBatchSize', 30, ...               % ����С,ÿ��ѵ����������30
    'MaxEpochs', 800, ...                  % ���ѵ������ 800
    'InitialLearnRate', 1e-2, ...          % ��ʼѧϰ��Ϊ0.01
    'LearnRateSchedule', 'piecewise', ...  % ѧϰ���½�
    'LearnRateDropFactor', 0.5, ...        % ѧϰ���½�����
    'LearnRateDropPeriod', 400, ...        % ����400��ѵ���� ѧϰ��Ϊ 0.01 * 0.5
    'Shuffle', 'every-epoch', ...          % ÿ��ѵ���������ݼ�
    'Plots', 'training-progress', ...      % ��������
    'Verbose', false);

%%  ѵ��ģ��
net = trainNetwork(p_train, t_train, layers, options);

%%  ģ��Ԥ��
T_sim1 = predict(net, p_train);
T_sim2 = predict(net, p_test );

%%  ���������
error1 = sqrt(sum((T_sim1' - T_train).^2) ./ M);
error2 = sqrt(sum((T_sim2' - T_test ).^2) ./ N);

%%  �����������ͼ
analyzeNetwork(layers)

%%  ��ͼ
figure
plot(1: M, T_train, 'r-*', 1: M, T_sim1, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'ѵ����Ԥ�����Ա�'; ['RMSE=' num2str(error1)]};
title(string)
xlim([1, M])
grid

figure
plot(1: N, T_test, 'r-*', 1: N, T_sim2, 'b-o', 'LineWidth', 1)
legend('��ʵֵ', 'Ԥ��ֵ')
xlabel('Ԥ������')
ylabel('Ԥ����')
string = {'���Լ�Ԥ�����Ա�'; ['RMSE=' num2str(error2)]};
title(string)
xlim([1, N])
grid

%%  ���ָ�����
%  R2
R1 = 1 - norm(T_train - T_sim1')^2 / norm(T_train - mean(T_train))^2;
R2 = 1 - norm(T_test  - T_sim2')^2 / norm(T_test  - mean(T_test ))^2;

disp(['ѵ�������ݵ�R2Ϊ��', num2str(R1)])
disp(['���Լ����ݵ�R2Ϊ��', num2str(R2)])

%  MAE
mae1 = sum(abs(T_sim1' - T_train)) ./ M ;
mae2 = sum(abs(T_sim2' - T_test )) ./ N ;

disp(['ѵ�������ݵ�MAEΪ��', num2str(mae1)])
disp(['���Լ����ݵ�MAEΪ��', num2str(mae2)])

%  MBE
mbe1 = sum(T_sim1' - T_train) ./ M ;
mbe2 = sum(T_sim2' - T_test ) ./ N ;

disp(['ѵ�������ݵ�MBEΪ��', num2str(mbe1)])
disp(['���Լ����ݵ�MBEΪ��', num2str(mbe2)])