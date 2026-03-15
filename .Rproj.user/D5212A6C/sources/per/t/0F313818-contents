
getDataR = function(mode='b', exp=0, type='main', path = 'D:/') {
  #loads preprocessed data
  # mode: whether participants whose final scores were not saved
  #        should be returned (b  - for behav analysis) or not (m - for modelling)
  # exp: 0 <- all experiments; 1-5 <- individual ones
  # type: main <- main; rat <- ratings

  if (type=='main') {
    if (mode =='b') {
      a = wztools::loadRData(paste0(path,'/all5.RData'))
    } else if (mode == 'm') {
      a = wztools::loadRData(paste0(path,'/all5m.RData'))
    }
  } else if (type=='rat') {
    if (mode == 'b') {
      a = wztools::loadRData(paste0(path,'/rall5.RData'))
    } else if (mode =='m') {
      a = wztools::loadRData(paste0(path,'/rall5m.RData'))
    }
  }

  if (exp==0) {
    return (a)
  } else {
    return (a[[exp]])
  }

}


getSizeAccR= function (ratings, exp = 2, method = "spearman", path='0.data')
{
  if (exp == 1) {
    ratings$pall = (ratings$ratP1 + ratings$ratP2 + ratings$ratP3)/3
    size_acc = ratings %>% dplyr::group_by(sessionTotal) %>%
      dplyr::summarise(size_est = stats::cor(pall, obj_size,
                                             method = "spearman"), size_pval = stats::cor.test(pall,
                                                                                               obj_size)$p.value, method = method)
  }
  else { #"H:/CB3_code/CB_V1/pics2/Results24.csv"
    size = read_csv(paste0(path, '/objective_sizes_E2345.csv'))
    ratings$obj_size = rep(size$objectsize, length(unique(ratings$subjID)))
    ratings$pall = (ratings$ratP1_pre + ratings$ratP2_pre +
                      ratings$ratP_post)/3
    size_acc = ratings %>% dplyr::filter(!is.na(ratV_post)) %>%
      dplyr::group_by(subjID) %>% dplyr::summarise(size_est = stats::cor(pall,
                                                                         obj_size, method = "spearman"), size_pval = stats::cor.test(pall,
                                                                                                                                     obj_size)$p.value, method = method)
  }
  size_acc$exp = rep(exp, nrow(size_acc))
  return(size_acc)
}

calc_loo_new <- function (draws) {

  if ('draws_array' %in% class(draws)) draws = apply(draws, c(1,3) ,mean) %>% as_tibble()
  loglik = draws %>%
    select(contains("log_lik")) %>%
    select(where(~!any(is.na(.))))
  out = list(loo::loo.array(posterior::as_draws_array(loglik)))
  return(out)
}
