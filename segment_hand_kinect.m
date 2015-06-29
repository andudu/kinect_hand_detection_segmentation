
%% Segments the hand using kinect and saves images 

 stop([vid_rgb,vid_depth]);
clear all;
close all;



vid_rgb = videoinput('kinect',1);
vid_depth = videoinput('kinect',2);
camera_angle = 0;

 srcDepth = getselectedsource(vid_depth);

set(srcDepth, 'BodyPosture','Standing','CameraElevationAngle', camera_angle,'TrackingMode','Skeleton','SkeletonsToTrack',1) % sets the properties of the camera

% set(srcDepth , 'CameraElevationAngle', camera_angle);

% preview(vid_rgb)

% preview(vid_depth)

vid_rgb.FramesPerTrigger = 1;
vid_depth.FramesPerTrigger = 1;

vid_rgb.TriggerRepeat = Inf;
vid_depth.TriggerRepeat = Inf;

triggerconfig([vid_rgb vid_depth],'manual');

start([vid_rgb,vid_depth]);

%% Thresholding based on Distance

THRESH=0;

if THRESH
    
threshold = 1500;
while 1
    trigger([vid_rgb vid_depth]);
    
[img_rgb, ts_rgb, metaData_rgb] = getdata(vid_rgb);
[img_depth , ts_depth, metaData_depth] = getdata(vid_depth);

 [row,col]  = find(img_depth==0);
 
 for i=1:length(row)
 img_rgb(row(i),col(i),:) = 0;
 end
 clear row;
 clear col;
 [row,col]  = find(img_depth>threshold);
 
 for i=1:length(row)
 img_rgb(row(i),col(i),:) = 0;
 end
 
 imagesc(img_rgb);

end

end

%% Segmenting Just the hand

% take the pixel coordinate of the right wrist and right hand.
% Segment the hand based on it.
HAND_SEG = 1;

if HAND_SEG
    img_count=0;
while 1
    
    trigger([vid_rgb vid_depth]);
    [img_rgb, ts_rgb, metaData_rgb] = getdata(vid_rgb);
    [img_depth , ts_depth, metaData_depth] = getdata(vid_depth);
    
    disp('Ye le..')
%     skeleton_joints = metaData_depth.JointImageIndices(:,:,1)

      

% metaData_depth.IsSkeletonTracked

skeleton_depth = metaData_depth.PositionWorldCoordinates(3,:) ; % depth of each skeleton tracked

[~,skeleton_to_track] = min_sparse(skeleton_depth); % id of nearest skeleton 
     
% skeleton_joints = metaData_depth.JointImageIndices(:,:,metaData_depth.IsSkeletonTracked);

skeleton_joints = metaData_depth.JointImageIndices(:,:,skeleton_to_track);

%   skeleton_joints_depth = metaData_depth.JointWorldCoordinates(:,:,metaData_depth.IsSkeletonTracked);

  skeleton_joints_depth = metaData_depth.JointWorldCoordinates(:,:,skeleton_to_track);
    % Wrist index = 11 , hand index = 12;
% %     imagesc(img_depth);
    wrist_coordinates = skeleton_joints(11,:);
    hand_coordinates = skeleton_joints(12,:)
    
    % find hand coordinate depth for seperating the hand from background
    
%      hand_coordinates_depth = skeleton_joints_depth(12,:);
%      wrist_coordinates_depth = skeleton_joints_depth(11,:)


     
    
    
    if ~isempty(hand_coordinates) && ~isempty(wrist_coordinates) && hand_coordinates(1)~=0 && hand_coordinates(1)<640 && hand_coordinates(2) < 480 

       SEPERATE_BACKGROUND =0;
       if SEPERATE_BACKGROUND
       threshold = img_depth(hand_coordinates(2),hand_coordinates(1))
       upper_bound=1.2*threshold
        lower_bound=.8*threshold
       
        
      for i=1:size(img_depth,1)
          for j=1:size(img_depth,2)
              if img_depth(i,j)==0 || img_depth(i,j)>1.2*threshold || img_depth(i,j)<.8*threshold 
                  img_rgb(i,j,:) = 0 ;
              end
          end
      end
      
       imagesc(img_rgb);
                        

           
       end
 
       
         

   
    
    ANNOTATION =1;
    if ANNOTATION
         radius = 1.5*abs( hand_coordinates(2)-wrist_coordinates(2));
         
         
%   circle_pos = [hand_coordinates,radius];
%   circle_wrist=[wrist_coordinates,radius];
%   img_rgb_annotated= insertObjectAnnotation(img_rgb,'circle',circle_pos,'Hand hai yeh!!','color','red');
%   img_rgb_annotated= insertObjectAnnotation(img_rgb_annotated,'circle',circle_wrist,'wrist hai yeh!!','color','red');
   

rectangle_bbox = [hand_coordinates(1)-radius,hand_coordinates(2)-radius,2*radius,2*radius];
img_rgb_annotated= insertObjectAnnotation(img_rgb,'rectangle',rectangle_bbox,'Hand hai yeh!!','color','red');

% Crop the segmented hand image
  cropped_img = imcrop(img_rgb,rectangle_bbox);
  
  subplot(1,2,1)
    imagesc(img_rgb_annotated);
    
    subplot(1,2,2);
    imagesc(cropped_img);
    pause(.2);
    
    img_count = img_count+1;
    
%     img_path = sprintf('%s%d%s','D:\hand\1\Image',img_count,'.jpeg');
      img_path = sprintf('%s%d%s','D:\temp\Image',img_count,'.jpeg');
    cropped_img_gray = rgb2gray(cropped_img);
    cropped_img = imresize(cropped_img_gray,[28,28]);
    imwrite(cropped_img,img_path);
    
    end
    
    
    
    end
    
    
end

end



    



