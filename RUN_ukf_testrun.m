clc;clear;close all;
% Unscented Kalman Filter,

%%

k = 3;
Tdur = 60;

objarray(1, 1) = ukfclass(2000);

for j = 1:length(objarray)
    for k=3:Tdur
        objarray(1,j).updatefilter(k);
    end
    
end



make1stfig(objarray, Tdur)

make2ndfig(objarray, Tdur)



function make1stfig(objarray, Tdur)
    figure;
    plotplz(objarray(1,1), Tdur)
    hold on;
    for p = 2:length(objarray)
        plotplz(objarray(1,p), Tdur)
    end
    
    
end


function make2ndfig(objarray, Tdur)
    figure;
    plotplz2(objarray(1,1), Tdur)
    hold on;
    for p = 2:length(objarray)
        plotplz2(objarray(1,p), Tdur)
    end
end

function plotplz(ukf2plot, Tdur)
    
    T = 0.5;
    timevec=(1:Tdur)*T;

    
    hold on;
    disp(length(timevec));
    disp(length(ukf2plot.x(1,:)-ukf2plot.x_post(1,:)));
    subplot(3,1,1);plot(timevec,ukf2plot.x(1,:)-ukf2plot.x_post(1,:));grid on;
    legend('Position Error');
    hold on;
    subplot(3,1,2);plot(timevec,ukf2plot.x(2,:)-ukf2plot.x_post(2,:));grid on;
    legend('Speed Error');
    hold on;
    subplot(3,1,3);plot(timevec,ukf2plot.x(3,:)-ukf2plot.x_post(3,:));grid on;
    legend('Balistic Parameter Error');
    xlabel('Time(s)');

end

function plotplz2(ukf2plot, Tdur)
    
    T = 0.5;
    timevec=(1:Tdur)*T;
    hold on;
    subplot(3,1,1);plot(timevec,ukf2plot.x(1,:),timevec,ukf2plot.x_post(1,:),'.');grid on;
    legend('Position (true)','Position (estimated)');
    hold on;
    subplot(3,1,2);plot(timevec,ukf2plot.x(2,:),timevec,ukf2plot.x_post(2,:),'.');grid on;
    legend('Speed (true)','Speed (estimated)');
    hold on;
    subplot(3,1,3);plot(timevec,ukf2plot.x(3,:),timevec,ukf2plot.x_post(3,:),'.');grid on;
    legend('Balistic Parameter (true)','Balistic Parameter (estimated)');
    xlabel('Time(s)');

end

