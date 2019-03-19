%   Estimador dos mínimos quadrados recursivo

%     aplicado a uma planta de segunda ordem

clear all; clc

nit = input(' Quantas iterações ? ');

for i=1:nit                      
    
    % Gerar sinais de entrada (PRBS) e ruído

if rand>0.5

u(i)=1;

else

u(i)=-1;

end

end

e = u*0.01;

p =1000*eye(4,4);

teta = [0;0;0;0];   % Condições iniciais (NULAS)

for t=1:4

y(i)=0;  erro(t)=0;    

a1(t)=teta(1);  a2(t)=teta(2);  b0(t)=teta(3);  b1(t)=teta(4);

end

v = 1.5144;

for t = 4:nit                                  
    % Iteração da simulação

y(t) = v*y(t-1)-0.5506*y(t-2)+0.599*u(t-1)+0.163*u(t-2) + e(t);  

% Saída

if t > 100,   v = -0.8; end     % Mudança paramétrica (sistema real)

fi=[-y(t-1);-y(t-2);u(t-1);u(t-2)];  % Vetor de regressores

erro(t)=y(t)-teta'*fi;          % Erro de estimação

k=p*fi/(1+fi'*p*fi);          % Vetor de ganho (de Kalman)

teta=teta+k*erro(t);               % Vetor de parâmetros

p=(p-k*fi'*p);                            % Matriz de covariância

P(t) = trace(p);                 

% Soma dos elementos da diag. principal

a1(t)=teta(1);  a2(t)=teta(2); b0(t)=teta(3);  b1(t)=teta(4);

end

t=1:nit;                          

% Fazer o gráfico  dos parâmetros estimados

subplot(231),plot(t,a1(t)),title('a1'),xlabel('amostragem');

subplot(232),plot(t,a2(t)),title('a2'),xlabel('amostragem');

subplot(233),plot(t,b0(t)),title('b0'),xlabel('amostragem');

subplot(234),plot(t,b1(t)),title('b1'),xlabel('amostragem'); 

subplot(235),plot(t,P(t)),title('traço da matriz de cov. P'),xlabel('amostragem');