%%%%%%%%%%%%%%%%%%%%%%%% SOJA REAL 5 ANOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;  clc; close all;

fprintf('M�todo dos m�nimos quadrados em batelada\n\n');

%load robot_arm.dat; %dados - ftp://ftp.esat.kuleuven.be/pub/SISTA/data/mechanical/robot_arm.txt 
load soja_2014-19_dolar.csv
npts = size(soja_2014_19_dolar,1); % n�mero de amostras a considera

temp_u2 = soja_2014_19_dolar(:,1); %robot_arm(:,1);

for n = 1:npts
    if n == 1
        u2(n) = 0;
    else    
        u2(n) = 100*(1 - (temp_u2(n)/temp_u2(n - 1)));
    end
end

y_in = soja_2014_19_dolar(:,1); %robot_arm(:,2);
u = u2;
u = u';
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
% b1 = theta(3); b2 = theta(4);
% 
% for t = ordem+1 : npts
% 
%     if ordem+1 == 2
%         %n passos a frente
%         yest(t) = -a1*yest(t-1)+ b1*u(t-1);
% 
%         %um passo a frente
%         yest2(t) = -a1*y(t-1) + b1*u(t-1);
%     
%     else
%         %n passos a frente
%         yest(t) = -a1*yest(t-1)-a2*yest(t-2) + b1*u(t-1)+b2*u(t-2);
% 
%         %um passo a frente
%         yest2(t) = -a1*y(t-1)-a2*y(t-2) + b1*u(t-1)+b2*u(t-2);
%     end
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

y_train = y(1:size(y,1)*0.7);
y_test = y(size(y,1)*0.7: size(y,1));

u_train = u(1:size(u,1)*0.7);
u_test = u(size(u,1)*0.7: size(u,1));

DAT_train = iddata(y_train, u_train);
DAT_test = iddata(y_test, u_test);

systems = [];
best_mse = inf;

for a=1:3
    for b=1:3
        sys = arx(DAT_train, [a b 0]); % Estimate over train set
        %systems = [systems ; sys];
        y_est = sim(sys, DAT_test);
        MSE = goodnessOfFit(y_test, y_est.y,'MSE');
        fprintf("Sistema ARX - P�los = %d; Zeros = %d | MSE = %0.2f %% \n", a, b, MSE*100);
        
        if MSE < best_mse
            best_mse = MSE;
            best_a = a;
            best_b = b;
            best_sys = sys;
        end
    end
    fprintf("\n");
end

fprintf("----------------------------------------------------\n\n");

sys = [];

for a=1:3
    for b=1:3
        sys = armax(DAT_train, [a b 3 0]); % Estimate over train set
        %systems = [systems ; sys];
        y_est = sim(sys, DAT_test);
        MSE = goodnessOfFit(y_test, y_est.y,'MSE');
        fprintf("Sistema ARMAX - P�los = %d; Zeros = %d | MSE = %0.2f %% \n", a, b, MSE*100);
        
        if MSE < best_mse
            best_mse = MSE;
            best_a = a;
            best_b = b;
            best_sys = sys;
        end
    end
    fprintf("\n");
end

 fprintf("Best Error =  %0.2f %% | P�los = %d; Zeros = %d \n", best_mse*100, best_a, best_b);
 fprintf("\nBest System:\n");
 best_sys

%figure();
%compare(DAT_test, best_sys, 1);

best_y_est = sim(best_sys, DAT_test);

[h_lillie, p_lillie] = lillietest(best_y_est.y);
h_jb = jbtest(best_y_est.y);
h_ad = adtest(best_y_est.y);