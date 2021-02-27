clearvars,
close all,
clc,


%llistem imatges de la carpeta
files = dir('highway/input');

%creem una matriu on guardarem les 150 imatges de test
imagesTrain = zeros(240, 320, 151);

n = 1050;
for i=1:151
    %calculem el nom de la imatge
    name = strcat('in00', int2str(n+i), '.jpg');
    %la llegim
    im_color = imread(name);
    %la convertim a escala de grisos
    im_grey = rgb2gray(im_color);
    %i la guardem a la matriu
    imagesTrain(:, :, i) = im_grey;
end

%fem la mitjana sobre la 3a dimensió de la matriu
im_mean = mean(imagesTrain, 3);
stdeviation = std(imagesTrain, 0, 3);
%mostrem el resultat obtingut
%imshow(uint8(im_mean))

%i guardem la imatge
imwrite(uint8(im_mean), 'background.jpg');


%creem una matriu on guardarem les 150 imatges de test
imagesTest = zeros(240, 320, 151);

n = 1050;
for i=151:300
    %calculem el nom de la imatge
    name = strcat('in00', int2str(n+i), '.jpg');
    %la llegim
    im_color = imread(name);
    %la convertim a escala de grisos
    im_grey = rgb2gray(im_color);
    %i la guardem a la matriu
    imagesTest(:, :, i-150) = im_grey;
end

thr = 0.1;
test = (uint8(imagesTest(:,:,1)) - uint8(im_mean)) < thr;
%imshow(test)

alpha = 1;
beta = 35;

answ = zeros(240, 320, 151);
for k=1:151
    im = imagesTest(:,:,k);
    for i=1:240
        for j=1:320
            answ(i,j,k) = (im_mean(i,j) - im(i,j)) > (alpha * stdeviation(i,j) + beta);
        end
    end
end

%imshow(answ(:,:,1))


SE = strel('arbitrary',eye(3));
SQ = strel('square',3);

for i=1:151
    answ(:,:,i) = imerode(answ(:,:,i),SE);
    %answ(:,:,i) = imdilate(answ(:,:,i),SQ);
end

%imshow(answ(:,:,1))

%ho passem a video
video = VideoWriter('resultat.avi');
open(video);
for i=1:151
    writeVideo(video,answ(:,:,i));
end
close(video);

%comprovem resultats
imagesRes = zeros(240, 320, 151);
files = dir('highway/input');

perc = [];

for i=151:300
    %calculem el nom de la imatge
    name = strcat('gt00', int2str(n+i), '.png');
    imagesRes(:,:,i-150) = (uint8(imread(name)) == uint8(answ(:,:,i-150)));
    
    [ua,~,uaidx] = unique(imagesRes(:,:,i-150));
    uapercent = accumarray(uaidx,ones(numel(uaidx),1))/numel(uaidx);
    
    %[ua uapercent]
    perc(end+1)=uapercent(2);
end

disp("precision of " + mean(perc) + '%')

    
%Com calcularia la velocitat?

%Si sabéssim els fps de la càmera, podriem intentar calcular el
%desplaçament dels vehicles en cada frame. D'aquesta manera podriem
%calcular la velocitat.

