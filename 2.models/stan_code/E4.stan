//#include /pre/license.stan
  //TODO: single prec/temp par

data {
  int <lower=1>  N;            //Number of subjects
  int <lower=12> Nstim;        //Number or stimuli
  int <lower=1>  Tmax;         // Max number of trials
  array [N] int Ntrial;   //Individual number of trials

  real <lower=-1, upper=1> fixVAC;                   //fix alpha inc? No -> -1, Yes -> input value
  real <lower=-1, upper=1> fixVAI;                   //fix alpha inc? No -> -1, Yes -> input value

  real <lower=-1, upper=1> fixPAC;                   //fix alpha inc? No -> -1, Yes -> input value
  real <lower=-1, upper=1> fixPAI;                   //fix alpha inc? No -> -1, Yes -> input value

  real <lower=-1, upper=15> fixTEMPV;
  real <lower=-1, upper=50> fixPRECV;
  real <lower=-1, upper=15> fixTEMPP;
  real <lower=-1, upper=50> fixPRECP;
  //ZOIB pars
  real <lower=-1> fixJ0;
  real <lower=-1> fixJDIF;
  real <lower=-1> fixD0;
  real <lower=-1>fixDDIF;
  real <lower=-1> fixJCB;
  //interactions
  real <lower=-1> fixJDXS;
  real <lower=-1> fixJCXS;

  real <lower=-1> fixJCBcon;
  real <lower=-1> fixJCBdom;

  array[N] vector<lower=0, upper=1>[Nstim] initV; // initial value ratings
  array[N]vector <lower=0, upper=1> [Nstim]   initP; // initial size ratings

  array[N, Tmax] int <lower=-2, upper = 2>  choiceLR; //  which stim was chosen in current trial (1 - left, 2 - right)

  array[N, Tmax] int <lower=-2, upper = Nstim>  stimR; // which stimulus was displayed on the right during choice...
  array[N, Tmax] int <lower=-2, upper = Nstim>  stimL;  //... and left side during choice
  array[N, Tmax] int <lower=-2, upper = Nstim>  stimR2; // which stimulus was displayed on the right during judgment
  array[N, Tmax] int <lower=-2, upper = Nstim>  stimL2;  //... and left side during judgment
  array[N, Tmax] int <lower=-2, upper = 2>   dec_type;  //dec type on current trial (-2: missed trial; -1: no choice; 0 - val; 1 - perc)

  //real  conflict   [N, Tmax];  //scaled conflict
  array[N, Tmax] real  <lower=-2, upper=1>   judgement; // judgement (-2 -> NA)
  array[N, Tmax] real  <lower=-2, upper=2>     judge_type; // trial judgement type; -1 -> NA; 0 -> value; 1 -> perc
  array[N, Tmax] real  <lower=-2, upper=1>   stay; // which stimulus stays (-2 -> NA; 0-> left; 1->right)

}

transformed data{
  array[N, Tmax] real judgement_transformed;
  array[N, Tmax] int is_discrete; //whether the value is discrete
  for (r in 1:N) {
    for (c in 1:Tmax) {
      judgement_transformed[r,c] = (judgement[r,c]*.5+.5);
      if (abs(judgement[r,c])==1) {
        is_discrete[r,c]=1;
      } else {
        is_discrete[r,c]=0;
      }

    }//t-loop
  }
}

parameters{

  //Hyper pars
  vector <lower=0> [17] mu_a_raw;
  vector <lower=0> [17] mu_b_raw;

  //Ind pars
  //val
  vector  <lower=0, upper=1>[N] alphaV_con_raw;
  vector  <lower=0, upper=1>[N] alphaV_inc_raw;

  //size
  vector  <lower=0, upper=1>[N] alphaP_con_raw;
  vector  <lower=0, upper=1>[N] alphaP_inc_raw;

  vector  <lower=0, upper=1> [N] tempV_raw;
  vector  <lower=0, upper=1>[N] precV_raw;
 // vector  <lower=0, upper=1>[N] inc_raw;
  //vector  [N] conf_raw;
  vector  <lower=0, upper=1> [N] d0_raw; //discrete interecept
  vector  <lower=0, upper=1>[N] dDIF_raw; //effect of difference on judgment discreteness
  vector  <lower=0, upper=1>[N] j0_raw; //effect of difference on binary ourcome intercept (prolly safe to fix to 0)
  vector  <lower=0, upper=1>[N] jDIF_raw; //effect of difference on binary judgment (prolly HUGE)
  vector <lower=0, upper=1> [N] jCB_raw;
  vector <lower=0, upper=1> [N] jDxS_raw;
  vector <lower=0, upper=1> [N] jCxS_raw;
  //CB regressors
  vector <lower=0, upper=1> [N] jCBdom_raw;
  vector <lower=0, upper=1> [N] jCBcon_raw;

 vector  <lower=0, upper=1> [N] tempP_raw;
  vector  <lower=0, upper=1>[N] precP_raw;
}

transformed parameters{

  //un-raw pars
  vector <lower=1> [17] mu_a;
  vector <lower=1> [17] mu_b;

  vector <lower=0, upper=.5>  [N] alphaV_con;
  vector <lower=0, upper=.25>  [N] alphaV_inc;


  vector <lower=0, upper=.5>  [N] alphaP_con;
  vector <lower=0, upper=.25>  [N] alphaP_inc;

  vector <lower=1, upper=15> [N] tempV;
  vector <lower=10, upper=50>[N] precV;
  //vector <lower=0, upper=1>  [N] inc;

  vector  <lower=-5, upper=5> [N] d0;
  vector  <lower=-1, upper=1>[N] j0;
  vector  <lower=0, upper=5>[N] jDIF;
  vector  <lower=0, upper=5>[N] dDIF;
  vector <lower=0, upper=1>  [N] jCB;

  vector <lower=0, upper=5>  [N] jDxS;
  vector <lower=0, upper=5>  [N] jCxS;

  vector <lower=0, upper=5>  [N] jCBcon;
  vector <lower=0, upper=5>  [N] jCBdom;
  //added variabilities
  vector <lower=1, upper=15> [N] tempP;
  vector <lower=10, upper=50>[N] precP;

  // For group level parameters
  real <lower=0, upper=.5> mu_alphaV_con;
  real <lower=0, upper=.25> mu_alphaV_inc;

  real <lower=0, upper=.5> mu_alphaP_con;
  real <lower=0, upper=.25> mu_alphaP_inc;

  real <lower=1, upper=15> mu_tempV;
  real <lower=10, upper=50> mu_precV;

  real <lower=-5, upper=5> mu_d0;
  real <lower=-1, upper=1> mu_j0;
  real <lower=0, upper=5> mu_dDIF;
  real <lower=0, upper=5>mu_jDIF;
  real <lower=0, upper=1> mu_jCB;

  //interactions
  real <lower=0, upper=5> mu_jDxS;
  real <lower=0, upper=5> mu_jCxS;

  //CB regs
  real <lower=0, upper=5> mu_jCBcon;
  real <lower=0, upper=5> mu_jCBdom;
  real <lower=1, upper=15> mu_tempP;
  real <lower=10, upper=50> mu_precP;

  mu_a = mu_a_raw + 1;
  mu_b = mu_b_raw + 1;

  mu_alphaV_con = mu_a[1]/(mu_a[1]+mu_b[1])*.5;
  mu_alphaV_inc = mu_a[2]/(mu_a[2]+mu_b[2])*.25;

  mu_alphaP_con = mu_a[3]/(mu_a[3]+mu_b[3])*.5;
  mu_alphaP_inc = mu_a[4]/(mu_a[4]+mu_b[4])*.25;

  mu_tempV      =  (mu_a[5]/(mu_a[5]+mu_b[5])) *14+1;
  mu_precV      = (mu_a[6]/(mu_a[6]+mu_b[6])) * 40 + 10;

  mu_d0      =  (mu_a[7]/(mu_a[7]+mu_b[7])) *10-5;
  mu_j0      = mu_a[8]/(mu_a[8]+mu_b[8])*2-1;

  mu_dDIF      = (mu_a[9]/(mu_a[9]+mu_b[9])) *5;
  mu_jDIF      = (mu_a[10]/(mu_a[10]+mu_b[10])) *5;
  mu_jCB      = mu_a[11]/(mu_a[11]+mu_b[11]);

  //mu_jSUM =  mu_a[12]/(mu_a[12]+mu_b[12]) * 5;
  mu_jDxS =  mu_a[12]/(mu_a[12]+mu_b[12]) *5;
  mu_jCxS =  mu_a[13]/(mu_a[13]+mu_b[13]) *5;

  mu_jCBcon =  mu_a[14]/(mu_a[14]+mu_b[14]) *5;
  mu_jCBdom =  mu_a[15]/(mu_a[15]+mu_b[15]) *5;

  mu_tempP      =  (mu_a[17]/(mu_a[17]+mu_b[17])) *14+1;
  mu_precP      = (mu_a[16]/(mu_a[16]+mu_b[16])) * 40 + 10;
  for (i in 1:N) {
    //val alpha
    if (fixVAC == -1) alphaV_con[i] = alphaV_con_raw[i]*.5; else alphaV_con[i] = fixVAC;
    if (fixVAI == -1) alphaV_inc[i] = alphaV_inc_raw[i]*.25; else alphaV_inc[i] = fixVAI;
    //perc alpha
    if (fixPAC == -1) alphaP_con[i] = alphaP_con_raw[i]*.5; else alphaP_con[i] = fixPAC;
    if (fixPAI == -1) alphaP_inc[i] = alphaP_inc_raw[i]*.25; else alphaP_inc[i] = fixPAI;
    //xtra
    if (fixTEMPV  == -1) tempV[i] = tempV_raw[i] * 14 + 1; else tempV[i] = fixTEMPV;
    if (fixPRECV  == -1) precV[i] = precV_raw[i] * 40 + 10; else precV[i] = fixPRECV;
  //zoib
    if (fixD0  == -1)   d0[i]   = d0_raw[i]   * 10 - 5; else d0[i] = fixD0;
    if (fixJ0  == -1)   j0[i]   = j0_raw[i]   * 2-1; else j0[i] = fixJ0;
    if (fixDDIF  == -1) dDIF[i] = dDIF_raw[i] * 5;  else dDIF[i] = fixDDIF;
    if (fixJDIF  == -1) jDIF[i] = jDIF_raw[i] * 5;  else jDIF[i] = fixJDIF;
    if (fixJCB == -1)   jCB[i] = jCB_raw[i];  else jCB[i] = fixJCB;
    //interactions
    if (fixJDXS == -1) jDxS[i] = jDxS_raw[i] * 5; else jDxS[i] = fixJDXS;
    if (fixJCXS == -1) jCxS[i] = jCxS_raw[i] * 5; else jCxS[i] = fixJCXS;

    if (fixJCBcon == -1)   jCBcon[i] = jCBcon_raw[i] * 5;  else jCBcon[i] = fixJCBcon;
    if (fixJCBdom == -1)   jCBdom[i] = jCBdom_raw[i] * 5;  else jCBdom[i] = fixJCBdom;

    if (fixTEMPP  == -1) tempP[i] = tempP_raw[i] * 14 + 1; else tempP[i] = fixTEMPP;
    if (fixPRECP  == -1) precP[i] = precP_raw[i] * 40 + 10; else precP[i] = fixPRECP;

  } //N loop

}

model {

   //Skeptical
  mu_a_raw       ~ gamma(1,1);
  //sceptical on DIRECTIONAL
  mu_b_raw[1:4]   ~ gamma(1,.1); //alphas
  mu_b_raw[9:10]  ~ gamma(1,.1);//diff effects on dec and judge (dDIF, jDIF)
  mu_b_raw[11:15] ~ gamma(1,.1); //jCB, jDxS, jCxS jCBdom jCBcon
  // ambivalent on BIDIRECTIONAL
  mu_b_raw[5:8] ~ gamma(1,1); //temp, prec, d0, j0
  mu_b_raw[16:17] ~ gamma(1,1);

  for (i in 1:N) {

    vector[Nstim]   evV      ; // updated value ratings
    vector[Nstim]   evP      ; // updated size ratings


    alphaV_con_raw [i] ~ beta(mu_a[1],mu_b[1]);
    alphaV_inc_raw [i] ~ beta(mu_a[2],mu_b[2]);


    alphaP_con_raw [i] ~ beta(mu_a[3],mu_b[3]);
    alphaP_inc_raw [i] ~ beta(mu_a[4],mu_b[4]);


    tempV_raw       [i] ~ beta(mu_a[5], mu_b[5]);
    precV_raw       [i] ~ beta(mu_a[6],mu_b[6]);
   // inc_raw       [i] ~ beta(mu_a[15],mu_b[15]);

    d0_raw       [i] ~ beta(mu_a[7], mu_b[7]);
    j0_raw       [i] ~ beta(mu_a[8],mu_b[8]);
    dDIF_raw     [i] ~ beta(mu_a[9],mu_b[9]);
    jDIF_raw     [i] ~ beta(mu_a[10], mu_b[10]);
    jCB_raw      [i] ~ beta(mu_a[11],mu_b[11]);


    jDxS_raw [i] ~ beta(mu_a[12], mu_b[12]);
    jCxS_raw [i] ~ beta(mu_a[13], mu_b[13]);

    jCBcon_raw      [i] ~ beta(mu_a[14],mu_b[14]);
    jCBdom_raw      [i] ~ beta(mu_a[15],mu_b[15]);

   tempP_raw       [i] ~ beta(mu_a[17], mu_b[17]);
   precP_raw       [i] ~ beta(mu_a[16],mu_b[16]);

    evV = initV[i,];
    evP = initP[i,];

    for (t in 1:Ntrial[i]) {
      vector [2] ev;
      real diff;
      real summ;

      //1. choice using updated values
      if (choiceLR[i,t]>0) { // only if choice was made
        if (dec_type[i,t] == 0) {
          ev[1] = evV[stimL[i,t]];
          ev[2] = evV[stimR[i,t]];
          if(dec_type[i,t]<2) choiceLR[i, t] ~ categorical_logit(tempV[i] * ev);
        } else if (dec_type[i,t] == 1) {
          ev[1] = evP[stimL[i,t]];
          ev[2] = evP[stimR[i,t]];
          if(dec_type[i,t]<2) choiceLR[i, t] ~ categorical_logit(tempP[i] * ev);
        }
      }


      //2. Update values based on choice
      if (dec_type[i,t] == 0) {
        if (choiceLR[i,t] == 1) {  //left
          evV[stimL[i,t]] += ((1-evV[stimL[i,t]]) * alphaV_con[i]);
          evV[stimR[i,t]] -= ((evV[stimR[i,t]]) * alphaV_con[i]);
          evP[stimL[i,t]] += ((1-evP[stimL[i,t]]) * alphaP_inc[i]) ;
          evP[stimR[i,t]] -= ((evP[stimR[i,t]]) * alphaP_inc[i])  ;
        } else if (choiceLR[i,t] == 2) {
          evV[stimL[i,t]] -= ((evV[stimL[i,t]]) * alphaV_con[i]) ;
          evV[stimR[i,t]] += ((1-evV[stimR[i,t]]) * alphaV_con[i]);
          evP[stimL[i,t]] -= ((evP[stimL[i,t]]) * alphaP_inc[i])  ;
          evP[stimR[i,t]] += ((1-evP[stimR[i,t]]) * alphaP_inc[i]) ;
        }

      } else if (dec_type[i,t] == 1) {
        if (choiceLR[i,t] == 1) {  //left
          evP[stimL[i,t]] += ((1-evP[stimL[i,t]]) * alphaP_con[i]);
          evP[stimR[i,t]] -= ((evP[stimR[i,t]]) * alphaP_con[i])  ;
          evV[stimL[i,t]] += ((1-evV[stimL[i,t]]) * alphaV_inc[i]) ;
          evV[stimR[i,t]] -= ((evV[stimR[i,t]]) * alphaV_inc[i])  ;
        } else if (choiceLR[i,t] == 2) {
          evP[stimL[i,t]] -= ((evP[stimL[i,t]]) * alphaP_con[i])  ;
          evP[stimR[i,t]] += ((1-evP[stimR[i,t]]) * alphaP_con[i]) ;
          evV[stimL[i,t]] -= ((evV[stimL[i,t]]) * alphaV_inc[i])  ;
          evV[stimR[i,t]] += ((1-evV[stimR[i,t]]) * alphaV_inc[i]) ;
        }
      }

      //judge
      if (judge_type[i,t] == 0) {
        diff = evV[stimR2[i,t]] - evV[stimL2[i,t]];
        summ = evV[stimR2[i,t]] + evV[stimL2[i,t]] -mean(evV)*2;
      } else if (judge_type[i,t] == 1) {
        diff = evP[stimR2[i,t]] - evP[stimL2[i,t]];
        summ = evP[stimR2[i,t]] + evP[stimL2[i,t]] - mean(evP)*2;
      };

      if (judge_type[i,t]>-2 && abs(judgement[i,t])<=1) { // only on judgement trials

        //binary process?
        is_discrete[i,t] ~ bernoulli_logit(d0[i] + dDIF[i]*abs(diff));
        //continuous response?
        if (is_discrete[i,t] == 0) {
          real cbt;
        if (dec_type[i,t]<0) {
          cbt = 0;
        } else {
            cbt = jCB[i] + jCBdom[i] * (judge_type[i,t]==0)+ jCBcon[i] *(dec_type[i,t]==judge_type[i,t]);// + jCBcondom[i] * con_x_judge[i,t]; //trial-specific CB
        }
          real j_mean =  j0[i] +jDIF[i]*diff + jDxS[i]*(diff*summ)+ cbt*(choiceLR[i,t]-1.5) + jCxS[i]*((choiceLR[i,t]-1.5)*summ);
          if (judge_type[i,t]==0) {
            judgement_transformed[i,t] ~ beta_proportion(inv_logit(j_mean), precV[i]);
          } else {
            judgement_transformed[i,t] ~ beta_proportion(inv_logit(j_mean), precP[i]);
          }
        }
      }


    } //T loop
  } //N loop
} //model block

generated quantities {

  array [N, Tmax] real log_lik;
  array [N, Tmax] real d_pred; // For posterior predictive check
  array [N, Tmax] real j_pred; // For posterior predictive check

  array [N] vector [Nstim]   evV      ; // updated value ratings
  array [N] vector [Nstim]   evP      ; // updated size ratings

  evV = initV; //initialize at rating values
  evP = initP;

  // Set all posterior predictions to 0 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:Tmax) {
      d_pred[i, t] = -1;
      j_pred[i, t] = -2;
      log_lik[i,t] = 0;
    }
  }




  for (i in 1:N) {
    for (t in 1:Ntrial[i]) {
      vector [2] ev;
      real diff;  //for storing the difference in latent values
      real summ; //for storing sum of latent values
      // 1. choice
      if (choiceLR[i,t]>0) {
        if (dec_type[i,t] == 0) {
          ev[1] = evV[i,stimL[i,t]];
          ev[2] = evV[i,stimR[i,t]];
          if(dec_type[i,t]<2)log_lik[i,t] += categorical_logit_lpmf(choiceLR[i,t] | tempV[i] * ev);
          if(dec_type[i,t]<2) d_pred[i,t] = categorical_rng(softmax(tempV[i] * ev));
        } else if (dec_type[i,t] == 1) {
          ev[1] = evP[i,stimL[i,t]];
          ev[2] = evP[i,stimR[i,t]];
          if(dec_type[i,t]<2)log_lik[i,t] += categorical_logit_lpmf(choiceLR[i,t] | tempP[i] * ev);
          if(dec_type[i,t]<2) d_pred[i,t] = categorical_rng(softmax(tempP[i] * ev));
        }

      }

      //2. Update values based on choice
      if (dec_type[i,t] == 0) {
        if (choiceLR[i,t] == 1) {  //left
          evV[i,stimL[i,t]] += (1-evV[i,stimL[i,t]]) * alphaV_con[i] ;
          evV[i,stimR[i,t]] -= (evV[i,stimR[i,t]]) * alphaV_con[i]  ;
          evP[i,stimL[i,t]] += (1-evP[i,stimL[i,t]]) * alphaP_inc[i]  ;
          evP[i,stimR[i,t]] -= (evP[i,stimR[i,t]]) * alphaP_inc[i]   ;
        } else if (choiceLR[i,t] == 2) {
          evV[i,stimL[i,t]] -= (evV[i,stimL[i,t]]) * alphaV_con[i]  ;
          evV[i,stimR[i,t]] += (1-evV[i,stimR[i,t]]) * alphaV_con[i] ;
          evP[i,stimL[i,t]] -= (evP[i,stimL[i,t]]) * alphaP_inc[i]   ;
          evP[i,stimR[i,t]] += (1-evP[i,stimR[i,t]]) * alphaP_inc[i]  ;
        }

      } else if (dec_type[i,t] == 1) {
        if (choiceLR[i,t] == 1) {  //left
          evP[i,stimL[i,t]] += (1-evP[i,stimL[i,t]]) * alphaP_con[i] ;
          evP[i,stimR[i,t]] -= (evP[i,stimR[i,t]]) * alphaP_con[i]  ;
          evV[i,stimL[i,t]] += (1-evV[i,stimL[i,t]]) * alphaV_inc[i]  ;
          evV[i,stimR[i,t]] -= (evV[i,stimR[i,t]]) * alphaV_inc[i]   ;
        } else if (choiceLR[i,t] == 2) {
          evP[i,stimL[i,t]] -= (evP[i,stimL[i,t]]) * alphaP_con[i] ;
          evP[i,stimR[i,t]] += (1-evP[i,stimR[i,t]]) * alphaP_con[i] ;
          evV[i,stimL[i,t]] -= (evV[i,stimL[i,t]]) * alphaV_inc[i]  ;
          evV[i,stimR[i,t]] += (1-evV[i,stimR[i,t]]) * alphaV_inc[i] ;
        }
      }

      //judge
      if (judge_type[i,t] == 0) {
        diff = evV[i,stimR2[i,t]] - evV[i,stimL2[i,t]];
        summ = (evV[i,stimR2[i,t]] + evV[i,stimL2[i,t]])-mean(evV[i,])*2; //centering
      } else if (judge_type[i,t] == 1) {
        diff = evP[i,stimR2[i,t]] - evP[i,stimL2[i,t]];
        summ = (evP[i,stimR2[i,t]] + evP[i,stimL2[i,t]])-mean(evP[i,])*2;
      }

      if (judge_type[i,t]>-2 && abs(judgement[i,t])<=1) { // only if judgement made on the trial

				//binary process estimation
        real is_discrete_regen = bernoulli_logit_rng(d0[i] + dDIF[i]*abs(diff));
        log_lik[i,t] += bernoulli_logit_lpmf(is_discrete[i,t] | d0[i] + dDIF[i]*abs(diff));
        //continuous process mean

       real cbt;
        if (dec_type[i,t]<0) {
          cbt = 0;
        } else {
            cbt = jCB[i] + jCBdom[i] * (judge_type[i,t]==0)+ jCBcon[i] *(dec_type[i,t]==judge_type[i,t]);// + jCBcondom[i] * con_x_judge[i,t]; //trial-specific CB
        }
        real j_mean =  j0[i] +jDIF[i]*diff + jDxS[i]*(diff*summ)+ cbt*(choiceLR[i,t]-1.5) + jCxS[i]*((choiceLR[i,t]-1.5)*summ);
        if (is_discrete_regen == 1) {
          if (diff>0)j_pred[i,t] = 1; else j_pred[i,t] = -1;

        } else {
          if (judge_type[i,t]==0) {
             j_pred[i,t] = beta_proportion_rng(inv_logit(j_mean), precV[i])*2-1;
          } else {
            j_pred[i,t] = beta_proportion_rng(inv_logit(j_mean), precP[i])*2-1;
          }
        }
        //log-lik separate
        if (is_discrete[i,t]==0) {
          if (judge_type[i,t]==0) {
          log_lik[i,t]  += beta_proportion_lpdf(judgement_transformed[i,t] |inv_logit(j_mean), precV[i]);
          }
          log_lik[i,t]  += beta_proportion_lpdf(judgement_transformed[i,t] |inv_logit(j_mean), precP[i]);
        }
			}

		} //T loop
	} //N loop


} //quantities block
