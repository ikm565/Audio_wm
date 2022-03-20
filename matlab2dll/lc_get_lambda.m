function[final_lambda] = lc_get_lambda(audio_file,oup,image_file,attacked,img_output)


THR = 25;
step = 0.005;
lambda_min = 0;
lambda_max = 1;
key = 1;
while key>0.05
   key = lambda_max - lambda_min;
   mid = (lambda_max + lambda_min)/2;
   now_lambda = round(mid,2);
   snr = embed(audio_file,oup,image_file,now_lambda);
   if snr < THR
       lambda_max = now_lambda;
   else
       lambda_min = now_lambda;
   end
end

final_lamda = lambda_min;
max_acc = 0;
now_lambda = lambda_min;
while now_lambda <= lambda_max
    snr = embed(audio_file,oup,image_file,now_lambda)
    if snr > THR
        now_acc = 0;
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack.py');
        acc1 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack2.py');
        acc2 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack3.py');
        acc3 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack5.py');
        acc4 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack6.py');
        acc5 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack7.py');
        acc6 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack8.py');
        acc7 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        [status,cmdout]=system('D:\software\anaconda3\envs\pytorch\python.exe attack9.py');
        acc8 = extract(attacked,audio_file,image_file,img_output,now_lambda);
        now_acc = now_acc+acc1+acc2+acc3+acc4+acc5+acc6+acc7+acc8;
        now_acc = now_acc/8;
        if now_acc > max_acc
            final_lambda = now_lambda;
            max_acc = now_acc;
        end
    end
    now_lambda = now_lambda + step;
end