<!--
 * @Author: Chang Liu
 * @Date: 2022-04-01 18:55:26
 * @LastEditors: Chang Liu
 * @LastEditTime: 2022-04-01 19:02:57
 * @FilePath: /snrss/guide.md
 * @Description: Instruction for run this experiment
 * 
 * Copyright (c) 2022 by Chang Liu/USTC, All Rights Reserved. 
-->
# get lambda
run new_two_nine_main.m --> get two_nine_lambda.mat
# get snr
run new_two_nine_main_main --> get embed audio and two_nine_snr_list.mat
# attack audio
do attack and save attacked audio in /public/liuchang/data/fma/test/attacked/
# extract watermark
run new_two_nine_extract_main.m --> extract wateramrk from attacked audio and calculate the accuracy and save in two_nine_acc_list.mat
# about selected audio
just put the testing audio in ../../data/fma/test/test/*.wav --> 100/200 wav files