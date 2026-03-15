
getData = function(mode='b', exp=0, type='main', path = 'D:/') {
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
