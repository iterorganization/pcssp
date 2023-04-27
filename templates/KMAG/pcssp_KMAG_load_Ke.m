function Ke = pcssp_KMAG_load_Ke()

Ketemp = [-0.2867    0.3491   -1.0960   -0.6198    0.1582    0.0138   -0.7993    0.0500   -0.3375    1.0797
   -0.0430    0.4919    2.6601   -3.2068   -0.8915   -0.1447    2.1376   -2.9411    1.4123   -0.6999
   -0.0823    0.8907   -1.0915    1.2807   -0.9853    0.2303   -0.8045    1.9876   -4.4744    2.9831
    0.6028   -2.0320    3.2532    0.9286    0.1948   -0.2816    2.4655   -1.2723    4.1819   -5.4292
    0.2722   -0.5343    0.8976    0.3824    0.3304   -0.0951    0.5817   -0.4177    1.4952   -1.6529
   -0.6482    0.6238   -4.4803    0.9625    0.7568    0.2061   -3.3588    2.4886   -2.5222    3.5172
   -0.7953    0.2045   -5.2645    1.9030    0.6809    0.3333   -3.7443    3.5930   -3.0418    3.6266
   -0.1411   -1.9565    2.6426    0.1230   -1.4410    0.2874    3.0260   -0.1723    1.9891   -3.3174
    0.3119    1.0856    1.6008   -1.1505   -0.5797    0.3632    1.3689   -0.8082   -0.5942    1.2861
    0.1668    2.1666   -2.9977    0.4547    1.2715    0.3026   -2.7979    1.3641   -2.6723    4.5995
    0.3582    0.7209   -1.1370    0.7614    1.2383    0.0540   -1.3194    0.4742   -0.0194    1.0663]*1e5;

Ke = Simulink.Parameter(Ketemp);