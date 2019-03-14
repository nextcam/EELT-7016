%%%%%%%%%%%%%%%%%%%%%%%% SOJA REAL 5 ANOS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;  clc; close all;

fprintf('Método dos mínimos quadrados em batelada\n\n');

%load robot_arm.dat; %dados - ftp://ftp.esat.kuleuven.be/pub/SISTA/data/mechanical/robot_arm.txt 
load soja_2014-19_dolar.csv
npts = size(soja_2014_19_dolar,1); % número de amostras a considera

temp_u2 = soja_2014_19_dolar(:,1); %robot_arm(:,1);

for n = 1:npts
    if n == 1
        u2(n) = 0;
    else    
        u2(n) = 100*(1 - (temp_u2(n)/temp_u2(n - 1)));
    end
end

y2 = soja_2014_19_dolar(:,1); %robot_arm(:,2);
u = u2;
y = y2;
Y   = [ ];  
fi   = [ ];
ordem = 2;

for j = 1:npts

    if j<=2

        y1=y(2);  y2=y(1);  u1=u(2);  u2=u(1);

    else

        y1=y(j-1);  y2=y(j-2);  u1=u(j-1);  u2=u(j-2);

    end

    Y  = [Y; y(j)];
    fi = [fi;-y1 -y2 u1 u2];

end

%THE BOY
theta = inv(fi'*fi)*fi'*Y;

for i=1:size(theta,1)

    fprintf('theta(%d) = %f\n',i, theta(i));

end

for t=1:ordem

    yest(t) = y(t);     
    yest2(t) = y(t);

end

a1 = theta(1); a2 = theta(2);  
b1 = theta(3); b2 = theta(4);

for t = ordem+1 : npts

    if ordem+1 == 2
        %n passos a frente
        yest(t) = -a1*yest(t-1)+ b1*u(t-1);

        %um passo a frente
        yest2(t) = -a1*y(t-1) + b1*u(t-1);
    
    else
        %n passos a frente
        yest(t) = -a1*yest(t-1)-a2*yest(t-2) + b1*u(t-1)+b2*u(t-2);

        %um passo a frente
        yest2(t) = -a1*y(t-1)-a2*y(t-2) + b1*u(t-1)+b2*u(t-2);
    end

end

fprintf('\nMSE_nstep = %f\n', sum(y(ordem:end,1)-yest(1,ordem:end)').^2/ (size(y,1)-ordem));

fprintf('MSE_1step = %f\n\n', sum(y(ordem:end,1)-yest2(1,ordem:end)').^2 / (size(y,1)-ordem));
figure();
plot(y,'g');hold on;

plot(yest,'r');plot(yest2,'b'); 
hold off;

ylabel ('saída');xlabel ('amostra');

legend('real','prevista n passos à frente','prevista um passo à frente');

DAT = iddata(y, u')

sys = armax(DAT, [2 2 0 0]);
figure();
compare(DAT, sys, 1000);
