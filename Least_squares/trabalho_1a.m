%%%%%%%%%%%%%%%% BRACO ROBOTICO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

clear all;  clc; close all;

fprintf('Metodo dos minimos quadrados em batelada\n\n');

% Inicializacao dos dados de entrada e saida

load robot_arm.dat; % dados encontrados em ftp://ftp.esat.kuleuven.be/pub/SISTA/data/mechanical/robot_arm.txt 

npts = size(robot_arm,1); % numero de entradas, que representa o numero de amostras

u = robot_arm(:,1); % colocando a primeira coluna dos dados (entrada) na variavel u
y = robot_arm(:,2); % colocando a segunda coluna (saida) na variavel y
Y = [ ]; % vetor das saidas inicialmente vazio
fi = [ ]; % matriz de observacao
ordem = 2; % sistema de segunda ordem

% Encontrando os polos e zeros

% for j = 1:npts
% 
%   if j<=2
% 
%       y1=y(2);  y2=y(1);  u1=u(2);  u2=u(1);
% 
%   else
% 
%       y1=y(j-1);  y2=y(j-2);  u1=u(j-1);  u2=u(j-2);
% 
%   end
% 
%     Y  = [Y; y(j)];
%     fi = [fi;-y1 -y2 u1 u2];
% 
% end
% 
% theta = inv(fi'*fi)*fi'*Y;
% 
% for i=1:size(theta,1)
% 
%     fprintf('theta(%d) = %f\n',i, theta(i));
% 
% end
% 
% for t=1:ordem
% 
%     yest(t) = y(t);     
%     yest2(t) = y(t);
% 
% end
% 
% a1 = theta(1); a2 = theta(2);  
% 
% b1 = theta(3); b2 = theta(4);
% 
% for t = ordem+1 : npts
% 
%     %n passos a frente
%     yest(t) = -a1*yest(t-1)-a2*yest(t-2) + b1*u(t-1)+b2*u(t-2);
% 
%     %um passo a frente
%     yest2(t) = -a1*y(t-1)-a2*y(t-2) + b1*u(t-1)+b2*u(t-2);
% 
% end
% 
% fprintf('\nMSE_nstep = %f\n', sum(y(ordem:end,1)-yest(1,ordem:end)').^2/ (size(y,1)-ordem));
% 
% fprintf('MSE_1step = %f\n\n', sum(y(ordem:end,1)-yest2(1,ordem:end)').^2 / (size(y,1)-ordem));
% figure();
% plot(y,'g');hold on;
% 
% plot(yest,'r');plot(yest2,'b'); 
% hold off;
% 
% ylabel ('sa�da');xlabel ('amostra');
% 
% legend('real','prevista n passos � frente','prevista um passo � frente');



y_train = y(1:round(size(y,1)*0.7)); % Reservando 70% da saida para treinamento
y_test = y(round(size(y,1)*0.7) + 1: size(y,1)); % Reservando o restante para teste

u_train = u(1:round(size(u,1)*0.7)); % Reservando 70% da entrada para treinamento
u_test = u(round(size(u,1)*0.7) + 1: size(u,1)); % Reservando o restante para teste

DAT_train = iddata(y_train, u_train); % Cria um objeto 'iddata' para poder usar na funcao arx e armax
DAT_test = iddata(y_test, u_test); % Cria um objeto 'iddata' para poder usar na funcao 'sim' e estimar a saida
systems = []; % Vetor 'systems' para adicionar todos os sistemas treinados
best_mse = 1; % Para comparar com o MSE do primeiro sistema

fprintf('--------------------ARX--------------------\n\n');

for a=1:3
    for b=1:3
        sys = arx(DAT_train, [a b 0]); % Estimate over train set
        systems = [systems; sys];
        y_est = sim(sys, DAT_test);
        MSE = goodnessOfFit(y_test, y_est.y,'MSE');
        fprintf('Sistema ARX - Polos = %d; Zeros = %d | MSE = %0.2f %% \n', a, b, MSE*100);
        
        if MSE < best_mse
            best_mse = MSE;
            best_a = a;
            best_b = b;
            best_sys = sys;
        end
    end
    fprintf('\n');
end

fprintf('-------------------ARMAX-------------------\n\n');

sys = [];

for a=1:3
    for b=1:3
        sys = armax(DAT_train, [a b 3 0]); % Estimate over train set
        systems = [systems; sys];
        y_est = sim(sys, DAT_test);
        MSE = goodnessOfFit(y_test, y_est.y,'MSE');
        fprintf('Sistema ARMAX - Polos = %d; Zeros = %d | MSE = %0.2f %% \n', a, b, MSE*100);
        
        if MSE < best_mse
            best_mse = MSE;
            best_a = a;
            best_b = b;
            best_sys = sys;
        end
    end
    fprintf('\n');
end

fprintf('-------------------------------------------\n\n');

fprintf('Best Error =  %0.2f %% | Polos = %d; Zeros = %d \n', best_mse*100, best_a, best_b);
fprintf('\nBest System:\n');
best_sys

%figure();
%compare(DAT_test, best_sys, 1);s
best_y_est = sim(best_sys, DAT_test);

[h_lillie, p_lillie] = lillietest(best_y_est.y)
h_jb = jbtest(best_y_est.y)
h_ad = adtest(best_y_est.y)

% Hence all of the three normality test returned 0,
% which means that the null hypotesis CAN`T be discarted
% it is presumable that the systems behavior is close to
% a gaussian distribution.