%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Absolute phase retrieval using multi-frequency plus phase-shifting
% last modified on 04/03/2024
% by Min Han
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Absolute_Phase,Background,Modulation] = Phase_Retrieval(root_path,Fringe_number,N)
%%%%%%%%%%%%%%%%%%% initialization
Img=imread([root_path,'1_1.bmp']);   [Height,Width]=size(Img);
Wrapped_Phase=zeros(Height,Width,length(Fringe_number));
Absolute_Phase=zeros(Height,Width,length(Fringe_number));
Order=zeros(Height,Width,length(Fringe_number));
Background=zeros(Height,Width,length(Fringe_number));
Modulation=zeros(Height,Width,length(Fringe_number));
%%%%%%%%%%%%%%%%%%% phase extraction
for id_frequency=1:length(Fringe_number)
    numerator=0; denominator=0; A_sum=0;
    for k=1:N
        path=[root_path,num2str(id_frequency), '_', num2str(k),'.bmp'];
        Img=imread(path);
        Img=im2double(Img);
        numerator=numerator+Img*sin(2*(k-1)*pi/N);
        denominator=denominator+Img*cos(2*(k-1)*pi/N);   
        A_sum=A_sum+Img;
    end
    Wrapped_Phase(:,:,id_frequency)=-atan2(numerator,denominator)+pi;   % converted to 0-2*pi Initial phase is -pi
    Background(:,:,id_frequency)=A_sum/N;
    Modulation(:,:,id_frequency)=sqrt(numerator.^2+denominator.^2)*2/N;
end
%%%%%%%%%%%%%%%%%%% phase unwrap
Absolute_Phase(:,:,1)=Wrapped_Phase(:,:,1);  %Absolute phase diagram of the highest frequency
Order(:,:,1)=0;
phl = Wrapped_Phase(:,:,1);
for i=1:length(Fringe_number)-1
    phh = Wrapped_Phase(:,:,i+1);
    ratio=Fringe_number(i+1)/Fringe_number(i);
    kh = round((ratio*phl-phh)/(2*pi));    
    phl = phh + 2*kh*pi;
    Absolute_Phase(:,:,i+1)=phl;
    Order(:,:,i+1)=kh;
end
%%%%%%%%%%%%%%%%%% draft
end

