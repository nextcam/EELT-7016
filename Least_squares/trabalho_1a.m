%%%%%%%%%%%%%%%% BRAÇO ROBÓTICO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

clear all;  clc; close all;

fprintf('Método dos mínimos quadrados em batelada\n\n');

load robot_arm.dat; %dados - ftp://ftp.esat.kuleuven.be/pub/SISTA/data/mechanical/robot_arm.txt 

npts = size(robot_arm,1); % número de amostras a considera

u_in = robot_arm(:,1);
y_in = robot_arm(:,2);
u = u_in;
y = y_in;
Y   = [ ];  
fi   = [ ];
ordem = 2;

% for j = 1:npts
% 
%     if j<=2
% 
%         y1=y(2);  y2=y(1);  u1=u(2);  u2=u(1);
% 
%     else
% 
%         y1=y(j-1);  y2=y(j-2);  u1=u(j-1);  u2=u(j-2);
% 
%     end
% 
%     Y  = [Y; y(j)];
%     fi = [fi;-y1 -y2 u1 u2];
% 
% end
% 
% %THE BOY
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
% ylabel ('saída');xlabel ('amostra');
% 
% legend('real','prevista n passos à frente','prevista um passo à frente');

y_train = y(1:size(y,1)*0.7);
y_test = y(size(y,1)*0.7: size(y,1));

u_train = u(1:size(u,1)*0.7);
u_test = u(size(u,1)*0.7: size(u,1));

DAT_train = iddata(y_train, u_train);
DAT_test = iddata(y_test, u_test);

systems = [];
best_mse = 1;

for a=1:3
    for b=1:3
        sys = arx(DAT_train, [a b 0]); % Estimate over train set
        %systems = [systems ; sys];
        y_est = sim(sys, DAT_test);
        MSE = goodnessOfFit(y_test, y_est.y,'MSE');
        fprintf('Sistema ARX - Pólos = %d; Zeros = %d | MSE = %0.2f %% \n', a, b, MSE*100);
        
        if MSE < best_mse
            best_mse = MSE;
            best_a = a;
            best_b = b;
            best_sys = sys;
        end
    end
    fprintf('\n');
end

fprintf('----------------------------------------------------\n\n');

sys = [];

for a=1:3
    for b=1:3
        sys = armax(DAT_train, [a b 3 0]); % Estimate over train set
        %systems = [systems ; sys];
        y_est = sim(sys, DAT_test);
        MSE = goodnessOfFit(y_test, y_est.y,'MSE');
        fprintf('Sistema ARMAX - Pólos = %d; Zeros = %d | MSE = %0.2f %% \n', a, b, MSE*100);
        
        if MSE < best_mse
            best_mse = MSE;
            best_a = a;
            best_b = b;
            best_sys = sys;
        end
    end
    fprintf('\n');
end

 fprintf('Best Error =  %0.2f %% | Pólos = %d; Zeros = %d \n', best_mse*100, best_a, best_b);
 fprintf('Best System:\n');
 best_sys

figure();
compare(DAT_test, best_sys,1);
 % Valdate over test set

 %sys2 = armax(DAT, [3 3 0 0]);
 %figure();
 %compare(DAT, sys2, 1);




