#' bootstrap
#'
#' Tool to do a bootstrap  on a dataset
#'
#' Given a dataset where column 1 specifies the groups and column 2 specifies the observed values for each group, the function makes a bootstrap, the output is a plot of the sample distribut, including confidence interval, mean of obs and sd.
#'
#' @param observations the column of  the dataframe with the observations
#'
#' @param method One of 3 options: "mean" (Defaul), "median" or "selfchoosenmethod". If "selfchoosenmethod" is used, the user has to define the parameter selfchosenmethod as a function that calculates the test-statistic, with the only input being column 2 from the data.
#'
#' @param nboot Number of iterations, Default(10000)
#'
#'
#' @return list of class bootstrap
#'
#' @examples
#'
#' bootstrap(PlantGrowth$weight, method="mean", nboot = 10000)
#'
#' summary(bootstrap)
#'
#' plot(bootstrap, bins = 30)
#'
#' @export

bootstrap<-function(observations, method="mean", nboot=10000){
  sample_teststat<-c()
  if (method=="median"){
    for (i in 1:nboot){
      obs<-median(observations)
      sample <- sample(x = observations, replace = T, size = length(observations))
      sample_teststat[i]<-median(sample)
    }
    firstconf<-((quantile(sample_teststat, 0.025, names= FALSE)[1]))
    lastconf<-((quantile(sample_teststat, 0.975, names= FALSE)[1]))
    SE<-sd(sample_teststat)
    conf_interval<-paste(firstconf, " : ", lastconf)
    fun<-"median"
  }
  else if(method=="mean"){
    for (j in 1:nboot){
      obs<-mean(observations)
      sample <- sample(x = observations, replace = T, size = length(observations))
      sample_teststat[j]<-mean(sample)
    }
    firstconf<-((quantile(sample_teststat, 0.025, names= FALSE)[1]))
    lastconf<-((quantile(sample_teststat, 0.975, names= FALSE)[1]))
    SE<-sd(sample_teststat)
    conf_interval<-paste(firstconf, " : ", lastconf)
    fun<-"mean"
  }
  else if(method=="my_method"){
    for (j in 1:nbootnboot){
      obs<-my_method(observations)
      sample <- sample(x = observations, replace = T, size = length(observations))
      sample_teststat[j]<-my_method(sample)
    }
    firstconf<-((quantile(sample_teststat, 0.025, names= FALSE)[1]))
    lastconf<-((quantile(sample_teststat, 0.975, names= FALSE)[1]))
    SE<-sd(sample_teststat)
    conf_interval<-paste(firstconf, " : ", lastconf)
    fun<-method
  }
  else{
    return(bootclass(Warnings = "Test-statistic method not known for function. See description for further help."))
  }
  sample_test_stat<-sample_teststat
  return(bootclass(SE,
                sample_test_stat,
                conf_interval,
                firstconf,
                lastconf,
                obs,
                fun
  ))
}

#' bootclass
#'
#' @return a output of the class object "bootstrap".
#'
#' @export
#'

bootclass <- function(SE="None",
                   sample_test_stat="None",
                   conf_interval="None",
                   firstconf="None",
                   lastconf="None",
                   obs="None",
                   fun="None",
                   Warnings="None"
)
{
  value <- list(SE=SE,
                bootstrap_estimates=c(sample_test_stat),
                conf_interval=conf_interval,
                first_conf_limit=firstconf,
                last_conf_limit=lastconf,
                obs_estimate=obs,
                Function=fun,
                Warnings=Warnings)
  attr(value,"class") <- "bootstrap"
  value
}


#' summary
#'
#' @return a summary of the class object "bootstrap".
#'
#' @export
#'

# Calling the summary on bootstrap
summary.bootstrap <- function(bootstrap) {
  print(paste("Standard Error:", bootstrap$SE))
  print(paste("confidence interval:", bootstrap$conf_interval))
  print(paste("Observed test statistic:", bootstrap$obs_estimate ))
  print(paste("Testing method:", bootstrap$Function))
  if (bootstrap$Warnings != "None") {
    print(paste("Warnings!!", bootstrap$Warnings))
  }
}

#' plot
#'
#' @return a two plots of the class object "bootstrap".
#'
#' @export
#'


#calling the plot on bootstrap
plot.bootstrap<-function(bootstrap, bins=30) {
  library(grid)
  samples<-data.frame((bootstrap)[3:8])
  df<- data.frame(values=bootstrap$bootstrap_estimates)
  if(nzchar(system.file(package = "ggplot2")) == TRUE){

    library(ggplot2)
    

    grid.rect(gp = gpar(col = "gray"))
    plot(ggplot2::ggplot()+
           ggplot2::geom_histogram(data=df, aes(x=values), fill="darkcyan", alpha=0.4, bins= 30)+
           theme_bw()+
           geom_vline(aes(xintercept=samples$obs_estimate), color="chocolate3")+
           geom_vline(aes(xintercept=c(samples$last_conf_limit)), color="brown")+
           geom_vline(aes(xintercept=c(samples$first_conf_limit)), color="brown"))
    vp2 <- grid::viewport(x = 0.7,y = 0.9, w = 0.3, h = 0.1,
                          just = c("left", "bottom"))
    grid::pushViewport(vp2)
    grid::grid.rect(gp = grid::gpar(col = "grey"))
    grid::grid.lines(y = (c(0.45)), x=(c(0,0.2)),gp=gpar(col="brown"), draw = TRUE, vp = NULL)
    grid::grid.lines(y = (c(0.95)), x=(c(0,0.2)),gp=gpar(col="chocolate"), draw = TRUE, vp = NULL)
    grid::grid.text("", y = 0.25,x=0.75, gp=gpar(fontsize=7, col="red"))
    grid::grid.text(paste("Obs",samples$Function, samples$obs_estimate), y = 0.75, x=0.5, gp=gpar(fontsize=7, col="chocolate"))
    grid::grid.text(paste("conf.interval:", samples$conf_interval), y = 0.25, x=0.5, gp=gpar(fontsize=7, col="brown"))
    grid::popViewport()
  }
  else {
    grid::grid.rect(gp = gpar(col = "gray"))
    hist(x=df$values, main=NA, xlab = "Values", ylab= "Count", breaks = bins )
    abline( v=as.numeric(samples$obs_estimate), col="chocolate")
    abline( v=as.numeric(samples$first_conf_limit), col="brown")
    abline( v=as.numeric(samples$last_conf_limit), col="brown")
    vp2 <- grid::viewport(x = 0.7,y = 0.9, w = 0.3, h = 0.1,
                          just = c("left", "bottom"))
    grid::pushViewport(vp2)
    grid::grid.rect(gp = gpar(col = "grey"))
    grid::grid.lines(y = (c(0.45)), x=(c(0,0.2)),gp=gpar(col="brown"), draw = TRUE, vp = NULL)
    grid::grid.lines(y = (c(0.95)), x=(c(0,0.2)),gp=gpar(col="chocolate"), draw = TRUE, vp = NULL)
    grid::grid.text("", y = 0.25,x=0.75, gp=gpar(fontsize=7, col="red"))
    grid::grid.text(paste("Obs",samples$Function, samples$obs_estimate), y = 0.75, x=0.5, gp=gpar(fontsize=7, col="chocolate"))
    grid::grid.text(paste("conf.interval:", samples$conf_interval), y = 0.25, x=0.5, gp=gpar(fontsize=7, col="brown"))
    grid::popViewport()
    }
  }
