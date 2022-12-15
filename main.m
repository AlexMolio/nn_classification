clear;
close all;
clc;

N = 200; % numder of objects

PN = [];
TN = [];

NN_TN = [];

vpk = 0;

load('net.mat');

for i = 1:N
    % done: select random type of object
    type = randi(3);
    
    % done: set random number of points, width and length
    % done: set random position and rotation angle

    alpha = rand(1)*360;
    R = rand(1)*500+500;
    fi = rand(1)*10;
    x0 = R*sind(fi);
    y0 = R*cosd(fi);

    x1 = [];
    y1 = [];

    switch type
        case 1
            ON = randi(20) + 20;
            OW = randi(5) + 5;
            OL = randi(50) + 50;

            for j = 1:ON
                y = rand(1)*OW;
                x = OL/ON*j;
                x1(j) = x*cosd(alpha)-y*sind(alpha)+y0;
                y1(j) = x*cosd(alpha)+y*cosd(alpha)+x0;
            end

        case 2 
            ON = randi(4) + 1;
            OW = randi(2) + 1;
            OL = randi(2) + 1;

            for j = 1:ON
                y = rand(1)*OW;
                x = OL/ON*j;
                x1(j) = x*cosd(alpha)-y*sind(alpha)+y0;
                y1(j) = x*cosd(alpha)+y*cosd(alpha)+x0;
            end
            
        case 3
            ON = randi(50) + 50;
            OW = randi(20) + 90;
            OL = randi(80) + 70;

            for j = 1:ON
                y = rand(1)*OW;
                x = OL/ON*j;
                x1(j) = x*cosd(alpha)-y*sind(alpha)+y0;
                y1(j) = x*cosd(alpha)+y*cosd(alpha)+x0;
            end
    end

%     figure, plot(y1,x1,'o');
%     axis([-200 200 0 1000]);

    % done: generate echo signal with params: fd = 120 000, fs = 30 000, T = 4

    A = 10+rand(1)*10;
    T = 4;
    fd = 120000;
    fs = 30000;
    num = floor(T*fd);
    t = (1:num)/fd;
    signal = randn(2, num);
    
    for p = 1:length(x1)
    
        p_fi = atand(y1(p)/x1(p));
        r = sqrt((x1((p))^2 + (y1(p))^2));
        i1 = floor(r/1500*fd);
        i2 = floor((r/1500 + 1e-3)*fd);
        d = 1500/(2*fs);
        tau = d*sind(p_fi)/1500;
        signal(1,i1:i2) = signal(1,i1:i2) + A*sin(2*pi*fs*t(i1:i2));
        signal(2,i1:i2) = signal(2,i1:i2) + A*sin(2*pi*fs*(t(i1:i2)+tau));
    
    end

%     figure, plot(signal(1,:));
%     hold on;
%     plot(signal(2,:));

    % done: process input signal

    [x,y] = process_echo(signal);

%     figure, plot(x,y, 'or');
%     axis([-200 200 0 1000]);
%     hold on;
%     plot(y1,x1, 'ob');
%     axis([-200 200 0 1000]);

    % done: calculate width and length
    [ sample ] = calc_params(x, y);

    PN = [PN; sample];

    tt = zeros(1,3);
    tt(type) = 1;

    TN = [TN; tt];


    % done: train NN
    nn_res = net.Network(sample');
    nn_type = find(max(nn_res) == nn_res);

    NN_TN = [NN_TN; nn_type];


    % done: calculate VPK

    if nn_type == type
        vpk = vpk + 1;
    end

end

VPK = vpk/N

function [x,y] = process_echo(s)

    % done: make fft to find band with our signal

    f = zeros(size(s));
    f(1,:) = fft(s(1,:));
    f(2,:) = fft(s(2,:));

%     figure, plot(-pi:1.308999e-5:pi, f)
%     axis([0 pi 0 10000])
    
    fd = 120000;
    fs = 30000;

    % done: filter signal by bandpass

    fmin = floor(0.9*(fs/fd)*size(f,2));
    fmax = floor(1.1*(fs/fd)*size(f,2));
    
    f(1,1:fmin) = 0;
    f(1,fmax:end) = 0;
    f(2, 1:fmin) = 0;
    f(2, fmax:end) = 0;

%     figure, plot(-pi:1.308999e-5:pi, f)
%     axis([0 pi 0 10000])
    
    hr = ifft(f(1,:));
    hl = ifft(f(2,:));
    
    sigma = sqrt(sum((abs(hr)).^2)/length(hr));
    
    phi = angle(exp(1i*(angle(hr)-angle(hl))));

    theta = angle(hr)-angle(hl);

    % done: find peaks
    
    iii = find(abs(hr) > sigma*3);
    
    peak = iii(1);
    
    stop = [];
    
    qqq = 1;
    
    for i = 2:length(iii)
    
        if (iii(i)-iii(i-1)>2) || (i-qqq>fd/1000)
        
            qqq = i;
            peak = [peak iii(i)];
            stop = [stop iii(i-1)];
        
        end
    
    end
    stop = [stop iii(end)];
   

    % done: calculate phase difference in peaks

    for i = 1 : length(peak)
    
        ft(i) = sum(phi(peak(i):stop(i)).*abs(hr(peak(i):stop(i))))/sum(abs(hr(peak(i):stop(i))));
    
    end

    
    
    d = 1500/(2*fs);
    
    alfa = asind(abs(ft * 1500)/(2*pi*fs*d));
    
    % done: calculate distance
    r = peak/fd*1500;
    
    % done: transform to coords
    y = r.*cosd(alfa);
    x = r.*sind(alfa);

end

function [ sample ] = calc_params(x, y)

    Num = length(x);
    
    alpha = atand(sum(x)/sum(y));
    
    x1 = x * cosd(alpha) - y*sind(alpha);
    y1 = x * sind(alpha) + y*cosd(alpha);

%     figure, plot(x1,y1, 'o');
%     axis([-1000 1000 0 1000]);
    
    W = max(y1) - min(y1);
    L = max(x1) - min(x1);
    
    sample = [Num L W];

end