import torch
import cv2


def rfdlm(A1_im, A2_im):
    dct_A1_im = cv2.dct(A1_im)
    dct_A2_im = cv2.dct(A2_im)
    
    cv2.idct(img_dct)

    return F1_im, F2_im