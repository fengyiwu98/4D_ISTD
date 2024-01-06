clc;
clear;
close all;

addpath('./functions/')
img_path = './datasets/Seq1/';
des_path='./results/Seq1/';

patchSize = 10;
slideStep = 10;
start_idx = 1;
length = 100;
L = 15;

for i = 1:floor(length/L)
    for j=1:L
        cur_idx = (i-1) * L + j + start_idx - 1;   
        img = imread( [img_path num2str(cur_idx,'%04d') '.bmp'] );
        if ndims(img) == 3
            img = rgb2gray(img);
        end
        img = im2double(img);
         D = gen_patch_ten(img, patchSize, slideStep);  
         tensor_4D(:,:,j,:)=D;
    end  
    tic
    [tenBack,tenTar] = TT_RPCA(tensor_4D);
    toc   
     for j = 1: L
        cur_idx = (i-1) * L + j + start_idx - 1;
        
        tarImg = res_patch_ten_mean (tenTar(:,:,j,:), img, patchSize, slideStep);
        bacImg = res_patch_ten_mean (tenBack(:,:,j,:), img, patchSize, slideStep);
        
        T = tarImg / (max(tarImg(:)) + eps);
        B = bacImg / (max(bacImg(:)) + eps);

        tar_res_path = [des_path,'TT_target\', num2str(cur_idx,'%04d'), '.png'];
        back_res_path = [des_path,'TT_background\', num2str(cur_idx,'%04d'), '.png'];
        
        imwrite(T, tar_res_path);
        imwrite(B, back_res_path);
    end
end