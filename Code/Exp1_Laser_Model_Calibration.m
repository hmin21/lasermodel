%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibrate model parameters of window smoothing model
% last modified on 04/03/2024
% by Min Han
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; 
close all; 
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameter initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_path='..\Data\Model-Calibration\'; 
File_name='1_';
f=[1,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200];
N=6; 
d=200;   %%  Object distance in millimeters
alpha_max=30;
km=2; WL_0=3/(2*km+1); sigma_0=WL_0; 
%%% 5 segments of Linewidth: -2 -1 0 +1 +2
k=-km:1:km; laser_total=sum(exp(-(k*WL_0).^2/2/sigma_0^2)); 
img_width=1440; img_height=1080;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Absolute Phase Retrieval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Path=[root_path,File_name];
[~,Ac,Bc] = Phase_Retrieval(Path,f,N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Window Smoothing Model Calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a1_0=WL_0*pi/d/tand(alpha_max);
a2_0=1/laser_total;
a3_0=2*exp(-WL_0^2/2/sigma_0^2)/laser_total;
a4_0=2*exp(-2*WL_0^2/sigma_0^2)/laser_total;
a_0=[a1_0,a2_0,a3_0,a4_0];
%%% Creating the function to be fitted
Lamda_func=@ (a,f) sin(a(1)*f)./(a(1)*f).*(a(2) + a(3)*cos(2*a(1)*f)+ a(4)*cos(4*a(1)*f)); 
%%% Accelerate the calculation by spacing a certain number of pixels
internal_pixel=10; u_internal=1; v_internal=1;  
f_fit=1:1:200; 
data_id=[1:2:21];
%%% Model fitting
for u=1:internal_pixel:img_width
    for v=1:internal_pixel:img_height
        Lamda=Bc(v,u,:)./Ac(v,u,:);
        Lamda=reshape(Lamda,[1,length(f)]);
        options = optimoptions('lsqcurvefit','Display','off');
        %%% Taking some of the frequencies for fitting
        [a,resnorm,residual] = lsqcurvefit(Lamda_func, a_0, f(data_id), Lamda(data_id),[],[],options);
        Lamda_fit=Lamda_func(a,f_fit);
        %%% 4*height*width
        a_img(:,v_internal,u_internal)=a';      
        fit_residual(v_internal,u_internal)=mean(abs(residual));
        v_internal=v_internal+1;
    end
    u_internal=u_internal+1;
    v_internal=1;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Show Model Calibration Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Show Model Paramerters a1-a4 (Pixel-wise)
for id_a=1:4
    a_draw=squeeze(a_img(id_a,:,:));
    [n,m] = size(a_draw); [xi,yi] = meshgrid(1:0.09:m,1:0.09:n);
    Model_Parameters = interp2(a_draw,xi,yi,'linear');
    figure;imagesc(Model_Parameters);colormap(jet); 
    colorbar;
end