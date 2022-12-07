clear;
close all;
clc;

N = 100; % numder of objects

for i = 1:N
    % todo: select random type of object
    type = randi(3);
    
    % todo: set random number of points, width and length
    switch type
        case 1
            ON = randi(5) + 5;
            OW = randi(5) + 5;
            OH = randi(50) + 50;

        case 2 
            ON = randi(4) + 1;
            OW = randi(29) + 1;
            OH = randi(2) + 1;
            
        case 3
            ON = randi(20) + 30;
            OW = randi(20) + 90;
            OH = randi(80) + 70;
    end

    % todo: set random position and rotation angle
    % todo: generate echo signal with params: fd = 120 000, fs = 30 000, T = 4
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