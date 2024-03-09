%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calibrate optimal fringe number using laser model parameters
% last modified on 04/03/2024
% by Min Han
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; 
close all; 
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameter initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_path='..\Data\Optimal-Calibration\'; 
File_name={'22cm\1_','25cm\1_','28cm\1_'};
img_width=1440; img_height=1080;
f_all=[1,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200];
data_id=[1:2:15];   
f=f_all(data_id); 
f_fit=1:1:200; N=6; 
d=200;              % Object distance in millimeters
alpha_max=30;
km=2; WL_0=3/(2*km+1); sigma_0=WL_0;
k=-km:1:km; laser_total=sum(exp(-(k*WL_0).^2/2/sigma_0^2)); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate Decay Factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for id_distance=1:length(File_name)
    Path=[root_path,File_name{id_distance}];
    [~,Ac,Bc] = Phase_Retrieval(Path,f_all,N);
    Lamda_one=Bc./Ac;
    Lamda(:,:,:,id_distance)=Lamda_one(:,:,data_id); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Model calibration and optimal fringe number calibration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a1_0=WL_0*pi/d/tand(alpha_max);
a2_0=1/laser_total;
a3_0=2*exp(-WL_0^2/2/sigma_0^2)/laser_total;
a4_0=2*exp(-2*WL_0^2/sigma_0^2)/laser_total;
a_0=[a1_0,a2_0,a3_0,a4_0];
%%% Creating the function to be fitted
Lamda_func=@ (a,f) sin(a(1)*f)./(a(1)*f).*(a(2) + a(3)*cos(2*a(1)*f)+ a(4)*cos(4*a(1)*f)); 
%%% Accelerate the calculation by spacing a certain number of pixels
u_neg=20; v_neg=20;          
LS_Option=optimset('Display','off');
%%% Model fitting and optimal fringe number selection
for id_distance=1:length(File_name)
    u_internal=1; v_internal=1; 
    for u=1:u_neg:img_width
        for v=1:v_neg:img_height
            Lamda_pixel=squeeze(Lamda(v,u,:,id_distance));
            [a,~,residual] = lsqcurvefit(Lamda_func, a_0, f', Lamda_pixel,[],[],LS_Option);
            fit_residual(v_internal,u_internal,id_distance)=mean(abs(residual));
            Lamda_fit=Lamda_func(a,f_fit);
            Objective=f_fit.*Lamda_fit;
            fopt_LUT(v_internal,u_internal,id_distance)=f_fit(Objective==max(Objective));
            v_internal=v_internal+1;
        end
        u_internal=u_internal+1;
        v_internal=1;
    end
    fopt_distance(id_distance)=mean(fopt_LUT(:,:,id_distance),'all');
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot optimal fringe number (Pixel-wise)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for id_distance=1:length(File_name)
    figure;
    fopt_draw=squeeze(fopt_LUT(:,:,id_distance));
    %%% 0.09 corresponds to a pixel interval of 10
    [n,m] = size(fopt_draw); [xi,yi] = meshgrid(1:0.045:m,1:0.045:n);
    %%% Perform 2D linear interpolation
    fopt_interp = interp2(fopt_draw,xi,yi,'linear');
    imagesc(fopt_interp);colormap(parula);  colorbar;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate the global optimal fringe number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Optimal fringe number:');
disp(mean(fopt_distance));