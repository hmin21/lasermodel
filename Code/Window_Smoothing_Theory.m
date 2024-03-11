%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code Function: Window Smoothing Model Calibration & Optimal Fringe Number Calibration
% last modified on 04/03/2024
% by Min Han
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; 
close all; 
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
root_path='..\Data\Pattern\'; 
Distance_name={'1_'};  % Name of working distance (Taking one distance for example)
img_width=1440;        % Width of image
img_height=1080;       % height of image
f=[1,10,20,40,60,80,100,120,140]; % Fringe frequency (fringe number/frame)
f_fit=1:1:200; 
N=6;                   % Number of phase-shifting
%%%%%%% Model Parameter Initialization %%%%%%%
d=200;              % Working distance (mm)
alpha_max=30;       % Maximal scanning angle of laser (°)
km=2;               % Maximal ID of the segment (k=-2,-1,0,1,2)
k=-km:1:km;         % ID of the segment:k=-2,-1,0,1,2
WL_0=3/(2*km+1);    % Linewidth
sigma_0=WL_0;       % Standard deviation of a Gaussian intensity distribution
laser_total=sum(exp(-(k*WL_0).^2/2/sigma_0^2));  % Sum of the intensity proportion
a1_0=WL_0*pi/d/tand(alpha_max);                  % Initialize Model Parameter a1
a2_0=1/laser_total;                              % Initialize Model Parameter a2
a3_0=2*exp(-WL_0^2/2/sigma_0^2)/laser_total;     % Initialize Model Parameter a3
a4_0=2*exp(-2*WL_0^2/sigma_0^2)/laser_total;     % Initialize Model Parameter a4
a_0=[a1_0,a2_0,a3_0,a4_0];                       % Initialized Model Parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Calculate Decay Factor λ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for id_distance=1:length(Distance_name)
    Path=[root_path,Distance_name{id_distance}];
    [~,Ac,Bc] = Phase_Retrieval(Path,f,N);       % 求解背景光强Ac和调制度光强Bc
    Lamda_one=Bc./Ac;
    Lamda(:,:,:,id_distance)=Lamda_one; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Model Fitting and Optimal Fringe Number Search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Creating Fitting Function
Lamda_func=@ (a,f) sin(a(1)*f)./(a(1)*f).*(a(2) + a(3)*cos(2*a(1)*f)+ a(4)*cos(4*a(1)*f)); 
%%% Accelerate Fitting Process by Pixel Spacing
Spacing=20;  
Fill_Spacing=1/Spacing;
LS_Option=optimset('Display','off');
for id_distance=1:length(Distance_name) 
    u_internal=1; v_internal=1; 
    for u=1:Spacing:img_width
        for v=1:Spacing:img_height
            Lamda_pixel=squeeze(Lamda(v,u,:,id_distance));
            %%% Model Fitting (Pixel-wise)
            [a,resnorm,residual] = lsqcurvefit(Lamda_func, a_0, f', Lamda_pixel,[],[],LS_Option);
            %%% Look-Up-Table of Model Parameters (Pixel-wise)
            a_LUT(:,v_internal,u_internal,id_distance)=a';  % Look-uo-table of model parameters a 
            fit_residual(v_internal,u_internal,id_distance)=mean(abs(residual));
            Lamda_fit=Lamda_func(a,f_fit);
            Objective=f_fit.*Lamda_fit;
            %%% Look-Up-Table of Optimal Fring number (Pixel-wise)
            fopt_LUT(v_internal,u_internal,id_distance)=f_fit(Objective==max(Objective)); % Search
            v_internal=v_internal+1;
        end
        u_internal=u_internal+1;
        v_internal=1;
    end
end
model_error=mean(fit_residual,'all');
fopt=mean(fopt_LUT,'all');
disp(['Model Fitting Error: ',num2str(model_error)]);
disp(['Optimal Fringe Number: ',num2str(fopt)]);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Show Model Paramerters a1-a4 (Pixel-wise)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for id_distance=1:length(Distance_name)
figure; 
for id_a=1:4
    %%% Perform 2D Linear Interpolation
    a_draw=squeeze(a_LUT(id_a,:,:,id_distance));
    [n,m] = size(a_draw); 
    [x,y] = meshgrid(1:Fill_Spacing:m,1:Fill_Spacing:n);
    Model_Parameters = interp2(a_draw,x,y,'linear');
    %%% Plot
    subplot(2,2,id_a); 
    imagesc(Model_Parameters);    
    colorbar;
    title(['Model Parameter: a',num2str(id_a)]);
    hold on;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Show Optimal Fringe Number (Pixel-wise)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for id_distance=1:length(Distance_name)
    %%% Perform 2D Linear Interpolation
    fopt_draw=squeeze(fopt_LUT(:,:,id_distance));
    fopt_interp = interp2(fopt_draw,x,y,'linear');
    %%% Plot
    figure;    
    imagesc(fopt_interp);
    colorbar;
    title('Optimal Fringe Number (Pixel-wise)');
end