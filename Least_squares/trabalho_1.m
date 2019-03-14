clear all;  clc; close all

fprintf('Método dos mínimos quadrados em batelada\n\n');

load dryer2;          % lêdados do hairdryer, u2e y

npts = size(u2,1); % número de amostras a considera
u = u2;              % sinal de entrada npts x 1

y  = y2;               % sinal de saída   npts x 
Y   = [ ];  
fi   = [ ];
ordem = 2;