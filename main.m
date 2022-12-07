clear;
close all;
clc;

N = 1; % numder of objects

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

    switch type
        case 1
            ON = randi(5) + 5;
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
            OW = randi(29) + 1;
            OL = randi(2) + 1;

            for j = 1:ON
                y = rand(1)*OW;
                x = OL/ON*j;
                x1(j) = x*cosd(alpha)-y*sind(alpha)+y0;
                y1(j) = x*cosd(alpha)+y*cosd(alpha)+x0;
            end
            
        case 3
            ON = randi(20) + 30;
            OW = randi(20) + 90;
            OL = randi(80) + 70;

            for j = 1:ON
                y = rand(1)*OW;
                x = OL/ON*j;
                x1(j) = x*cosd(alpha)-y*sind(alpha)+y0;
                y1(j) = x*cosd(alpha)+y*cosd(alpha)+x0;
            end
    end

    figure, plot(y1,x1,'o');
    axis([-200 200 0 1000]);

    % todo: generate echo signal with params: fd = 120 000, fs = 30 000, T = 4

    A = 10+rand(1)*10;
    T = 4;
    fd = 120000;
    fs = 30000;
    num = floor(T*fd);
    t = (1:num)/fd;
    s = randn(2, num);
    
    for p = 1:length(x1)
    
        p_fi = atand(y1(p)/x1(p));
        r = sqrt((x1((p))^2 + (y1(p))^2));
        i1 = floor(r/1500*fd);
        i2 = floor((r/1500 + 1e-3)*fd);
        d = 1500/(2*fs);
        tau = d*sind(p_fi)/1500;
        s(1,i1:i2) = s(1,i1:i2) + A*sin(2*pi*fs*t(i1:i2));
        s(2,i1:i2) = s(2,i1:i2) + A*sin(2*pi*fs*(t(i1:i2)+tau));
    
    end

    figure, plot(s(1,:));
    hold on;
    plot(s(2,:));

    % todo: process input signal
        % todo: make fft to find band with our signal
        % todo: filter signal by bandpass
        % todo: find peaks
        % todo: calculate phase difference in peaks
        % todo: calculate distance
        % todo: transform to coords
    % todo: calculate width and length
    % todo: train NN
    % todo: calculate VPK

end