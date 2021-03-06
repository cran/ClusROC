####==========================================================================####
## This file consists of functions for estimating covariate-specific VUS        ##
## Date: 26/03/2021																															##
####==========================================================================####

#' @import utils
#' @import numDeriv
#' @import stats

theta_1 <- function(par, z, n_p, n_c, n_k, n, subdivisions = 1000, ...){
  beta_d <- par[1:(3*n_p)]
  sigma_e <- par[(3*n_p + 2):length(par)]
  sigma_c <- par[(3*n_p + 1)]
  mu_est <- z %*% beta_d
  f01 <- function(s){
    dnorm((s - mu_est[2])/sigma_e[2])*pnorm((s - mu_est[1])/sigma_e[1])*
      pnorm((s - mu_est[3])/sigma_e[3], lower.tail = FALSE)/sigma_e[2]
  }
  return(integrate(f01, lower = -Inf, upper = Inf, subdivisions = subdivisions, ...)$value)
}

theta_2 <- function(par, z, n_p, n_c, n_k, n, subdivisions = 1000, ...){
  beta_d <- par[1:(3*n_p)]
  sigma_e <- par[(3*n_p + 2):length(par)]
  sigma_c <- par[(3*n_p + 1)]
  mu_est <- z %*% beta_d
  f02 <- function(s){
    dnorm((s - mu_est[2])/sigma_e[2])*pnorm((s - mu_est[1])/sigma_e[1])*
      pnorm((s - mu_est[3])/sqrt(2*sigma_c^2 + sigma_e[3]^2), lower.tail = FALSE)/sigma_e[2]
  }
  return(integrate(f02, lower = -Inf, upper = Inf, subdivisions = subdivisions, ...)$value)
}

theta_3 <- function(par, z, n_p, n_c, n_k, n, subdivisions = 1000, ...){
  beta_d <- par[1:(3*n_p)]
  sigma_e <- par[(3*n_p + 2):length(par)]
  sigma_c <- par[(3*n_p + 1)]
  mu_est <- z %*% beta_d
  f03 <- function(s){
    dnorm((s - mu_est[2])/sqrt(2*sigma_c^2 + sigma_e[2]^2))*pnorm((s - mu_est[1])/sigma_e[1])*
      pnorm((s - mu_est[3])/sigma_e[3], lower.tail = FALSE)/sqrt(2*sigma_c^2 + sigma_e[2]^2)
  }
  return(integrate(f03, lower = -Inf, upper = Inf, subdivisions = subdivisions, ...)$value)
}

theta_4 <- function(par, z, n_p, n_c, n_k, n, subdivisions = 1000, ...){
  beta_d <- par[1:(3*n_p)]
  sigma_e <- par[(3*n_p + 2):length(par)]
  sigma_c <- par[(3*n_p + 1)]
  mu_est <- z %*% beta_d
  f04 <- function(s){
    dnorm((s - mu_est[2])/sigma_e[2])*pnorm((s - mu_est[1])/sqrt(2*sigma_c^2 + sigma_e[1]^2))*
      pnorm((s - mu_est[3])/sigma_e[3], lower.tail = FALSE)/sigma_e[2]
  }
  return(integrate(f04, lower = -Inf, upper = Inf, subdivisions = subdivisions, ...)$value)
}

theta_5 <- function(par, z, n_p, n_c, n_k, n, subdivisions = 1000, ...){
  beta_d <- par[1:(3*n_p)]
  sigma_e <- par[(3*n_p + 2):length(par)]
  sigma_c <- par[(3*n_p + 1)]
  mu_est <- z %*% beta_d
  f05 <- function(s){
    dnorm((s - mu_est[2])/sqrt(sigma_c^2 + sigma_e[2]^2))*pnorm((s - mu_est[1])/sqrt(sigma_c^2 + sigma_e[1]^2))*
      pnorm((s - mu_est[3])/sqrt(sigma_c^2 + sigma_e[3]^2), lower.tail = FALSE)/sqrt(sigma_c^2 + sigma_e[2]^2)
  }
  return(integrate(f05, lower = -Inf, upper = Inf, subdivisions = subdivisions, ...)$value)
}

## vus_core function
vus_core <- function(par, z, n_p, n_c, n_k, n, p.sss, p.ssk, p.sks, p.skk, p.ijk,
                     subdivisions = 1000, ...){
  theta_est_1 <- theta_1(par = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n,
                         subdivisions = subdivisions, ...)
  theta_est_2 <- theta_2(par = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n,
                         subdivisions = subdivisions, ...)
  theta_est_3 <- theta_3(par = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n,
                         subdivisions = subdivisions, ...)
  theta_est_4 <- theta_4(par = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n,
                         subdivisions = subdivisions, ...)
  theta_est_5 <- theta_5(par = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n,
                         subdivisions = subdivisions, ...)
  vus_est <- theta_est_1*p.sss + theta_est_2*p.ssk + theta_est_3*p.sks + theta_est_4*p.skk + theta_est_5*p.ijk
  return(vus_est)
}

vus_se <- function(par, vcov_par_model, z, n_p, n_c, n_k, n, p.sss, p.ssk, p.sks, p.skk, p.ijk){
  jac_vus <- rbind(jacobian(theta_1, x = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n),
                   jacobian(theta_2, x = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n),
                   jacobian(theta_3, x = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n),
                   jacobian(theta_4, x = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n),
                   jacobian(theta_5, x = par, z = z, n_p = n_p, n_c = n_c, n_k = n_k, n = n))
  Sig_1 <- jac_vus %*% vcov_par_model %*% t(jac_vus)
  pp <- c(p.sss, p.ssk, p.sks, p.skk, p.ijk)
  vus_sd <- as.numeric(sqrt(pp %*% Sig_1 %*% pp))
  return(vus_sd)
}

### ---- Main function to estimate the covariate-specific VUS ----
#' @title Estimation of the covariate-specific VUS for clustered data.
#'
#' @description This function estimates the covariate-specific VUS of a continuous diagnostic test in the setting of clustered data as described in Xiong et al. (2018). This function allows to estimate covariate-specific VUS at multiple points for covariates.
#'
#' @param out_lme2  an object of class "lme2", a result of \code{\link{lme2}} call.
#' @param newdata   a data frame (containing specific value(s) of covariate(s)) in which to look for variables with which to estimate covariate-specific VUS. In absence of covariate, no values have to be specified.
#' @param apVar  logical value. If set to \code{TRUE} (default), the standard error for (estimated) covariate-specific VUS are estimated.
#' @param subdivisions  the maximum number of subintervals used to approximate integral. Default is 1000.
#' @param ...  additional arguments to be passed to \code{\link[stats]{integrate}}.
#'
#' @details
#' This function implements a method in Xiong et al. (2018) for estimating covariate-specific VUS of a continuous diagnostic test in a clustered design with three ordinal groups. The estimator is based on results from \code{\link{lme2}}, which uses the REML approach. The standard error of the estimated covariate-specific VUS is approximated through the Delta method.
#'
#' Before performing estimation, a check for the monotone ordering assumption is performed. This means that, for the fixed values of covariates, three predicted mean values for test results in three diagnostic groups are compared. If the assumption is not meet, the covariate-specific VUS at the values of covariates are not estimated. In addition, this function also performs the statistical test, \eqn{H_0: VUS = 1/6} versus an alternative of interest.
#'
#'
#' @return \code{VUS} returns an object of class "VUS" which is a list containing at least the following components:
#'
#' \item{call}{the matched call.}
#' \item{vus_est}{a vector containing the estimated covariate-specific VUS.}
#' \item{vus_se}{a vector containing the standard errors.}
#' \item{mess_order}{a diagnostic message from checking the monontone ordering.}
#' \item{newdata}{value(s) of covariate(s).}
#' \item{n_p}{total number of regressors in the model.}
#'
#' Generic functions such as \code{print} is also used to show the results.
#'
#' @references
#' Xiong, C., Luo, J., Chen L., Gao, F., Liu, J., Wang, G., Bateman, R. and Morris, J. C. (2018)
#' ``Estimating diagnostic accuracy for clustered ordinal diagnostic groups in the three-class case -- Application to the early diagnosis of Alzheimer disease''.
#' \emph{Statistical Methods in Medical Research}, \bold{27}, 3, 701-714.
#'
#'
#' @examples
#' data(data_3class)
#' ## One covariate
#' out1 <- lme2(fixed.formula = Y ~ X1, name.class = "D", name.clust = "id_Clus",
#'              data = data_3class)
#'
#' ### Estimate covariate-specific VUS at one value of one covariate
#' out_vus1 <- VUS(out1, newdata = data.frame(X1 = 0.5))
#' ci_VUS(out_vus1, ci.level = 0.95)
#'
#' ### Estimate covariate-specific VUS at multiple values of one covariate
#' out_vus2 <- VUS(out1, newdata = data.frame(X1 = c(-0.5, 0, 0.5)))
#' ci_VUS(out_vus2, ci.level = 0.95)
#'
#' ## Two covariates
#' out2 <- lme2(fixed.formula = Y ~ X1 + X2, name.class = "D", name.clust = "id_Clus",
#'              data = data_3class)
#'
#' ### Estimate covariate-specific VUS at one point
#' out_vus3 <- VUS(out2, newdata = data.frame(X1 = 1.5, X2 = 1))
#' ci_VUS(out_vus3, ci.level = 0.95)
#'
#' ### Estimate covariate-specific VUS at three points
#' out_vus4 <- VUS(out2, newdata = data.frame(X1 = c(-0.5, 0.5, 0.5), X2 = c(0, 0, 1)))
#' ci_VUS(out_vus4, ci.level = 0.95)
#'
#' @export
VUS <- function(out_lme2, newdata, apVar = TRUE, # ci = FALSE, ci.level = ifelse(ci, 0.95, NULL),
                subdivisions = 1000, ...){
  ## Check all conditions
  if(isFALSE(inherits(out_lme2, "lme2"))) stop("out_lme2 was not from lme2()!")
  n_p <- out_lme2$n_p
  if(out_lme2$n_coef/n_p != 3) stop("There is not a case of three-class setting!")
  if(n_p == 1){
    if(!missing(newdata)) {
      if(!is.null(newdata)) warning("Sepecified value(s) of covariate(s) are not used!", call. = FALSE)
    }
    newdata <- NULL
  } else {
    if(missing(newdata)) stop("Please input a data frame including specific value(s) of covariate(s).")
    if(is.null(newdata)) stop("Please input a data frame including specific value(s) of covariate(s).")
    if(!inherits(newdata, "data.frame")) stop("Please input a data frame including specific value(s) of covariate(s).")
    if(any(is.na(newdata))) stop("NA value(s) are not allowed!")
  }
  ##
  if(apVar){
    if(is.null(out_lme2$vcov_sand)) stop("The estimated covariance matrix of parameters was missing!")
    if(any(is.na(out_lme2$vcov_sand))) stop("There are NA values in the estimated covariance matrix of parameters. Unable to estimate standard error.")
    vcov_par_model <- out_lme2$vcov_sand[1:(out_lme2$n_coef + 4), 1:(out_lme2$n_coef + 4)]
  }
  call <- match.call()
  fit <- list()
  fit$call <- call
  ## check if all clusters/families have the same cluster size, if yes, the weight calculation_k is simplified
  n_c <- out_lme2$cls
  n_k <- out_lme2$n_c
  n <- out_lme2$n
  unique.n_k <- unique(n_k)
  equal.n_k.flag <- ifelse(length(unique.n_k) == 1, TRUE, FALSE)
  if(equal.n_k.flag){
    n_k.div.N <- (unique.n_k/n)^3;
    p.sss <- n_c*n_k.div.N;
    p.ssk <- n_c*(n_c - 1)*n_k.div.N
    p.ijk <- n_c*(n_c - 1)*(n_c - 2)*n_k.div.N
  } else{
    n_k3 <- n_k^3
    p.sss <- sum(n_k3)/n^3
    n_k.sqr <- n_k^2
    outer.n_kSQR.n_k <- outer(n_k.sqr, n_k)
    diag(outer.n_kSQR.n_k) <- NA
    p.ssk <- sum(outer.n_kSQR.n_k, na.rm = TRUE)/(n^3)
    combo <- combn(x = 1:n_c, m = 3)
    p.ijk <- sum(apply(combo, 2, function(idx) prod(n_k[idx])))/(n^3)
    p.ijk <- 6*p.ijk
  }
  p.skk <- p.sks <- p.ssk
  par <- out_lme2$est_para[1:(out_lme2$n_coef + 4)]
  Z <- make_data(out_lme2, newdata, n_p)
  ## Check the ordering of means: mu_1 < mu_2 < mu_3
  res_check <- check_mu_order(Z, par, n_p)
  if(all(res_check$status == 0))
    stop("The assumption of montone ordering DOES NOT hold for all the value(s) of the covariate(s)")
  if(any(res_check$status == 0)){
    mess_order <- paste("The assumption of montone ordering DOES NOT hold for some points. The points number:",
                        paste(which(res_check$status == 0), collapse = ", "), "are excluded from analysis!")
    fit$mess_order <- mess_order
    message(mess_order)
  }
  Z <- res_check$Z_new
  ##
  if(n_p == 1){ # without covariate
    fit$newdata <- newdata
    fit$vus_est <- vus_core(par = par, z = Z[[1]], n_p = n_p, n_c = n_c, n_k = n_k, n = n, p.sss = p.sss,
                            p.ssk = p.ssk, p.sks = p.sks, p.skk = p.skk, p.ijk = p.ijk,
                            subdivisions = subdivisions, ...)
    if(apVar){
      fit$vus_se <- vus_se(par = par, vcov_par_model = vcov_par_model, z = Z[[1]], n_p = n_p, n_c = n_c,
                           n_k = n_k, n = n, p.sss = p.sss, p.ssk = p.ssk, p.sks = p.sks, p.skk = p.skk,
                           p.ijk = p.ijk)
    }
  } else { # with covariate
    fit$newdata <- as.data.frame(newdata[res_check$status != 0,])
    names(fit$newdata) <- names(newdata)
    fit$vus_est <- sapply(Z, function(x){
      vus_core(par = par, z = x, n_p = n_p, n_c = n_c, n_k = n_k, n = n, p.sss = p.sss, p.ssk = p.ssk,
               p.sks = p.sks, p.skk = p.skk, p.ijk = p.ijk, subdivisions = subdivisions, ...)
      })
    if(apVar){
      fit$vus_se <- sapply(Z, function(x){
        vus_se(par = par, vcov_par_model = vcov_par_model, z = x, n_p = n_p, n_c = n_c, n_k = n_k, n = n,
               p.sss = p.sss, p.ssk = p.ssk, p.sks = p.sks, p.skk = p.skk, p.ijk = p.ijk)
        })
    }
  }
  fit$n_p <- n_p
  class(fit) <- "VUS"
  return(fit)
}

## ---- The function ci_VUS ----
#' @title Confidence Intervals for Covariate-specific VUS
#'
#' @description Computes confidence intervals for covariate-specific VUS.
#'
#' @param x an object of class "VUS", a result of \code{\link{VUS}} call.
#' @param ci.level a confidence level to be used for constructing the confidence interval; default is 0.95.
#'
#' @details A confidence interval for covariate-specific VUS is given based on normal approximation. If the lower bound (or the upper bound) of the confidence interval is smaller than 0 (or greater than 1), it will be set as 0 (or 1). Also, logit and probit transformations are available if one wants guarantees that confidence limits are inside (0, 1).
#'
#' @return \code{ci_VUS} returns an object of class inheriting from "ci_VUS" class. An object of class "ci_VUS" is a list, containing at least the following components:
#'
#' \item{vus_ci_norm}{the normal approximation-based confidence interval for covariate-specific VUS.}
#' \item{vus_ci_log}{the confidence interval for covariate-specific VUS, after using logit-transformation.}
#' \item{vus_ci_prob}{the confidence interval for covariate-specific VUS, after using probit-transformation.}
#' \item{ci.level}{fixed confidence level.}
#' \item{newdata}{value(s) of covariate(s).}
#' \item{n_p}{total numbers of the regressors in the model.}
#'
#' @seealso \code{\link{VUS}}
#'
#' @export
ci_VUS <- function(x, ci.level = 0.95){
  if(isFALSE(inherits(x, "VUS"))) stop("The object is not VUS!")
  if(is.null(x$vus_se)) stop("Can not compute CI without standard error!")
  n_p <- x$n_p
  fit <- list()
  if(n_p == 1){ # no covariate
    ## Normal-approach with truncated boundary
    temp <- x$vus_est + c(-1, 1)*qnorm((1 + ci.level)/2)* x$vus_se
    if(temp[1] < 0) temp[1] <- 0
    if(temp[2] > 1) temp[2] <- 1
    fit$vus_ci_norm <- matrix(temp, ncol = 2)
    ## logit-transform
    logit_vus <- qlogis(x$vus_est)
    logit_vus_sd <- x$vus_se/(x$vus_est*(1 - x$vus_est))
    fit$vus_ci_log <- matrix(plogis(logit_vus + c(-1, 1)*qnorm((1 + ci.level)/2)*logit_vus_sd), ncol = 2)
    ## probit-transform
    probit_vus <- qnorm(x$vus_est)
    probit_vus_sd <- grad(function(x) qnorm(x), x = x$vus_est)*x$vus_se
    fit$vus_ci_prob <- matrix(pnorm(probit_vus + c(-1, 1)*qnorm((1 + ci.level)/2)*probit_vus_sd), ncol = 2)
  }
  if(n_p == 2){ # 1 covariate
    fit$vus_ci_norm <- t(mapply(FUN = function(x, y) {
      res <- x + c(-1, 1)*qnorm((1 + ci.level)/2)*y
      if(res[1] < 0) res[1] <- 0
      if(res[2] > 1) res[2] <- 1
      return(res)
    }, x = x$vus_est, y = x$vus_se))
    ## logit-transform
    logit_vus <- qlogis(x$vus_est)
    logit_vus_sd <- x$vus_se/(x$vus_est*(1 - x$vus_est))
    fit$vus_ci_log <- t(mapply(FUN = function(x, y) plogis(x + c(-1, 1)*qnorm((1 + ci.level)/2)*y),
                               x = logit_vus, y = logit_vus_sd))
    ## probit-transform
    probit_vus <- qnorm(x$vus_est)
    probit_vus_sd <- grad(function(x) qnorm(x), x = x$vus_est)*x$vus_se
    fit$vus_ci_prob <- t(mapply(FUN = function(x, y) pnorm(x + c(-1, 1)*qnorm((1 + ci.level)/2)*y),
                                x = probit_vus, y = probit_vus_sd))
  }
  if(n_p > 2){ # multiple covariates
    fit$vus_ci_norm <- t(mapply(FUN = function(x, y) {
      res <- x + c(-1, 1)*qnorm((1 + ci.level)/2)*y
      if(res[1] < 0) res[1] <- 0
      if(res[2] > 1) res[2] <- 1
      return(res)
    }, x = x$vus_est, y = x$vus_se))
    ## logit-transform
    logit_vus <- qlogis(x$vus_est)
    logit_vus_sd <- x$vus_se/(x$vus_est*(1 - x$vus_est))
    fit$vus_ci_log <- t(mapply(FUN = function(x, y) plogis(x + c(-1, 1)*qnorm((1 + ci.level)/2)*y),
                               x = logit_vus, y = logit_vus_sd))
    ## probit-transform
    probit_vus <- qnorm(x$vus_est)
    probit_vus_sd <- grad(function(x) qnorm(x), x = x$vus_est)*x$vus_se
    fit$vus_ci_prob <- t(mapply(FUN = function(x, y) pnorm(x + c(-1, 1)*qnorm((1 + ci.level)/2)*y),
                                x = probit_vus, y = probit_vus_sd))
  }
  fit$ci.level <- ci.level
  fit$n_p <- n_p
  fit$newdata <- x$newdata
  class(fit) <- "ci_VUS"
  return(fit)
}

## ---- The function print.VUS ----
#' @title Print summary results from VUS
#'
#' @description \code{print.VUS} displays the results of the output from \code{\link{VUS}}.
#'
#' @method print VUS
#' @param x an object of class "VUS", a result of \code{\link{VUS}} call.
#' @param digits minimal number of significant digits, see \code{\link{print.default}}.
#' @param call logical. If set to \code{TRUE}, the matched call will be printed.
#' @param ... further arguments passed to \code{\link{print}} method.
#'
#' @details \code{print.VUS} shows a summary table for covariate-specific VUS estimates, containing estimates, standard errors, z-values and p-values for the hypothesis testing \eqn{H_0: VUS = 1/6} versus an alternative \eqn{H_A: VUS > 1/6}.
#'
#' @return \code{print.VUS} returns a summary table for covariate-specific VUS estimates.
#'
#' @seealso \code{\link{VUS}}
#'
#' @export
print.VUS <- function(x, digits = 3, call = TRUE, ...){
  if(isFALSE(inherits(x, "VUS"))) stop("The object is not VUS!")
  cat("\n")
  if(call){
    cat("CALL: ", paste(deparse(x$call), sep = "\n", collapse = "\n"), "\n \n", sep = "")
  }
  if(!is.null(x$mess_order)){
    cat("NOTE: ", x$mess_order, "\n \n", sep = "")
  }
  if(x$n_p == 1){
    labels <- "Intercept"
  }
  if(x$n_p == 2) {
    labels <- apply(x$newdata, 1, function(y) paste0(y))
  }
  if(x$n_p > 2) {
    labels <- apply(x$newdata, 1, function(y) paste0("(", paste(y, collapse = ", "), ")"))
  }
  if(!is.null(x$vus_se)){
    z <- (x$vus_est - rep(1/6, length(x$vus_est)))/x$vus_se
    p_val <- pnorm(z, lower.tail = FALSE)
    infer_tab <- data.frame(labels, x$vus_est, x$vus_se, z, p_val) # as.factor(labels),
    infer_tab[,2:4] <- signif(infer_tab[,2:4], digits = digits)
    pv <- as.vector(infer_tab[,5])
    dig.tst <- max(1, min(5, digits - 1))
    infer_tab[,5] <- format.pval(pv, digits = dig.tst, eps = 0.001)
    Signif <- symnum(pv, corr = FALSE, na = FALSE,
                     cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                     symbols = c("***", "**", "*", ".", " "))
    sleg <- attr(Signif, "legend")
    sleg <- strwrap(sleg, width = getOption("width") - 2, prefix = "  ")
    infer_tab <- cbind(infer_tab, format(Signif))
    colnames(infer_tab) <- c("Covariates Values", "Est.", "Std.Error", "z-value", "p-value", "")
    cat("Covariate-specific VUS: \n")
    print(infer_tab, quote = FALSE, right = TRUE, na.print = "--", row.names = FALSE, ...)
    cat("---\nSignif. codes:  ", sleg, sep = "",
        fill = getOption("width") + 4 + max(nchar(sleg, "bytes") - nchar(sleg)))
    cat("z-value and p-value are for testing the null hypothesis H0: VUS = 1/6 vs H1: VUS > 1/6 \n")
  }
  else{
    infer_tab <- data.frame(labels, x$vus_est)
    infer_tab[,2] <- signif(infer_tab[,2], digits = digits)
    colnames(infer_tab) <- c("Covariates Values", "Est.")
    cat("Covariate-specific VUS: \n")
    print(infer_tab, quote = FALSE, right = TRUE, na.print = "--", row.names = FALSE, ...)
  }
  cat("\n")
  invisible(x)
}

## ---- The function print.ci_VUS ----
#' @title Print summary results from ci_VUS
#'
#' @description \code{print.ci_VUS} displays the results of the output from \code{\link{ci_VUS}}.
#'
#' @method print ci_VUS
#' @param x an object of class "ci_VUS", a result of \code{\link{ci_VUS}} call.
#' @param digits minimal number of significant digits, see \code{\link{print.default}}.
#' @param ... further arguments passed to \code{\link{print}} method.
#'
#' @details \code{print.ci_VUS} shows a summary table for confidence interval limits for covariate-specific VUS.
#'
#' @return \code{print.ci_VUS} shows a summary table for confidence intervals for covariate-specific VUS.
#'
#' @seealso \code{\link{VUS}}
#'
#' @export
print.ci_VUS <- function(x, digits = 3, ...){
  if(isFALSE(inherits(x, "ci_VUS"))) stop("The object is not ci_VUS!")
  if(x$n_p == 1){
    labels <- "Intercept"
  }
  if(x$n_p == 2) {
    labels <- apply(x$newdata, 1, function(y) paste0(y))
  }
  if(x$n_p > 2) {
    labels <- apply(x$newdata, 1, function(y) paste0("(", paste(y, collapse = ", "), ")"))
  }
  ci.tab <- cbind(x$vus_ci_norm, x$vus_ci_log, x$vus_ci_prob)
  ci.tab <- format(round(ci.tab, digits = digits))
  res.ci.tab <- data.frame(labels,
                           apply(matrix(ci.tab[,1:2], ncol = 2, byrow = FALSE), 1,
                                 function(y) paste0("(", paste(y, collapse = ", "), ")")),
                           apply(matrix(ci.tab[,3:4], ncol = 2, byrow = FALSE), 1,
                                 function(y) paste0("(", paste(y, collapse = ", "), ")")),
                           apply(matrix(ci.tab[,5:6], ncol = 2, byrow = FALSE), 1,
                                 function(y) paste0("(", paste(y, collapse = ", "), ")")))
  colnames(res.ci.tab) <- c("Covariates Values", "Normal approximation", "Logit transformation",
                            "Probit transformation")
  cat(paste0("The ", x$ci.level*100, "% confidence intervals for covariate-specific VUS:\n"))
  print(res.ci.tab, quote = FALSE, right = TRUE, na.print = "--", row.names = FALSE, print.gap = 3, ...)
  cat("\n")
  invisible(x)
}
