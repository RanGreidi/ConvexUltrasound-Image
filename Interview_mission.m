%%
blankImage=zeros(1601,1601); %create blank image
A = imread('zframe29.bmp');

%we calculate the relative raduis (relative to the real pysichal size):
%define 180mm as 1501 pixels, R is 59.739263mm, then initial_radius=498.1590765 pixels.
%next step is to go in a loop, for every pixel with raduis bigger then 498.1590765 and with
%angel alpha, I copy the raw data row to the blank image, then build a wedge
%from it (pizza sllice) to form a continuous image.

initial_radius=498.1590765;  %initial raduis to start with
final_raduis=1501;           
alpha=0.469;                   %degree

for row=1:128                                                               %loop  on the raw data colum
    raw_data_row=A(:,row);
    raw_data_counter=1;                                                     %runnig on the 1024 pixels for each row in the data
    desired_rad=initial_radius;                                             %the changing raduis, grows acording to the raw of the data
    for i=1:size(blankImage)                                                %loop on every pixel of the blankImage
        for j=1:size(blankImage)
            [r,teta]=KartezToRad(i,j);                                      %get raduis and angle
            if   desired_rad-1 <  r && r  < desired_rad+1                   %I take a range of 2 pixels to deal with the rounding problem
               if (0.5*alpha+(63-row)*alpha-0.1) < teta && teta < (0.5*alpha+(63-row)*alpha+0.1)  %range of 0.2 degree to deal with rounding 
                    [x,y] = RadToKartez(r,teta);                            % get kartez coordintaes back        
                    blankImage(y,x)=A(raw_data_counter,row);                %draw the pixel from raw dara in its place
                    %after placing a singal pixel in its place
                    %we now run on a little square around it to
                    % create arc which forms the pizza slice
                    for a=-size(blankImage)/150:size(blankImage)/150        
                        for b=-size(blankImage)/150:size(blankImage)/150
                            [r_wedge,teta_wedge]=KartezToRad(x+a,y+b);
                            if   desired_rad-1 <  r_wedge && r_wedge  < desired_rad+1   %make sure we get the same raduis
                                if (0.5*alpha+(63-row)*alpha-alpha) < teta_wedge && teta_wedge < (0.5*alpha+(63-row)*alpha)  %draw the arc with the right angel alpha
                                    [x_wedge,y_wedge] = RadToKartez(r_wedge,teta_wedge); 
                                    blankImage(y_wedge,x_wedge)=A(raw_data_counter,row);                                                                           
                                end
                            end
                        end
                    end
                    %%%%%%% 
                    if raw_data_counter==1024   %stopping condition to start a new row
                        break
                    else         
                        raw_data_counter=raw_data_counter+1;
                        desired_rad=initial_radius+((raw_data_counter-1)/1023)*(final_raduis-initial_radius);  % increase the raduis accordingly
                    end
                end
            end
        end
    end
end

imshow(blankImage, [0 256])

%Kartezian to Radiel + mideling to coordinate sys
function [R,Teta] = KartezToRad(x,y)
    x_mid=x;
    y_mid=y-800;
    R=(sqrt(x_mid^2+y_mid^2));
    Teta=atand(y_mid/x_mid);
        if x_mid<0
            Teta=(Teta+180);
        else
            Teta=(Teta);
        end
end
%Radiel to Kartizian + demideling to coordinate sys
function [x,y] = RadToKartez(R,Teta)
    x_mid= round(R*cosd(Teta));
    y_mid= round(R*sind(Teta));
    x=x_mid;
    y=y_mid+800;
    if y==0
        y=1;
    end
    if x==0
        x=1;
    end
end