
PSU_domain<- function(df, domain){
  
S = matrix(0,nrow=1, ncol=ncol(df))
SS = matrix(0,nrow=1, ncol=ncol(df))
for (i in 1:nrow(df)) {
  if (df[i,7] == domain) {
    S[1,] = as.matrix(df[i,])
    SS = rbind(SS,S)
  }
}

domain_select <- SS[-1,]


strata_dom1=data.frame(domain_select)
colnames(strata_dom1)= colnames(PSU.GA)
strata_dom1$LABEL <- as.numeric(as.character(strata_dom1$LABEL))
r= as.data.frame(which(table(strata_dom1$LABEL)== 1, arr.ind = TRUE))
strata_dom1<- strata_dom1[!(strata_dom1$LABEL %in% r$dim1),]
return(strata_dom1)  

}

PSU_domain(PSU.GA, 1)
