####========================================================================####
## This file consists of functions for estimating optimal pair of thresholds  ##
## Based on ctp method                                                        ##
####========================================================================####

ctp_normal <- function(par, par_model, z, n_p) {
  if (par[1] > par[2]) {
    x <- par[1]
    par[1] <- par[2]
    par[2] <- x
  }
  beta_d <- par_model[1:(3 * n_p)]
  sigma_d <- sqrt(par_model[(3 * n_p + 2):length(par_model)]^2 +
                    par_model[(3 * n_p + 1)]^2)
  mu_est <- z %*% beta_d
  res_tcfs <- numeric(3)
  res_tcfs[1] <- pnorm(par[1], mean = mu_est[1], sd = sigma_d[1])
  res_tcfs[2] <- pnorm(par[2], mean = mu_est[2], sd = sigma_d[2]) -
    pnorm(par[1], mean = mu_est[2], sd = sigma_d[2])
  res_tcfs[3] <- 1 - pnorm(par[2], mean = mu_est[3], sd = sigma_d[3])
  return(sqrt(sum((1 - res_tcfs)^2)))
}

ctp_normal_var <- function(opt_ctps, par_model, vcov_par_model, z, n_p) {
  term1 <- grad(ctp_normal, x = par_model, par = opt_ctps, z = z, n_p = n_p)
  term2 <- grad(ctp_normal, x = opt_ctps, par_model = par_model, z = z,
                n_p = n_p)
  grad_tcfs_par <- jacobian(tcf_normal, x = par_model, z = z,
                            thresholds = opt_ctps, n_p = n_p)
  term3 <- hessian(func = function(par, z, n_p) {
    ctp_normal(par = par[1:2], par_model = par[-c(1, 2)], z = z, n_p = n_p)
  }, x = c(opt_ctps, par_model), z = z, n_p = n_p)
  term3_1 <- term3[1:2, 1:2]
  term4 <- jacobian(tcf_normal, x = opt_ctps, z = z, par = par_model, n_p = n_p)
  derv_cpt_para <- -solve(term3_1) %*% term3[1:2, -c(1, 2)]
  derv_ctp_para <- term1 + term2 %*% derv_cpt_para
  derv_tcf_para <- grad_tcfs_par + term4 %*% derv_cpt_para
  vcov_tcfs <- derv_tcf_para %*% vcov_par_model %*% t(derv_tcf_para)
  var_d3 <- as.numeric(derv_ctp_para %*% vcov_par_model %*% t(derv_ctp_para))
  vcov_cpts <- derv_cpt_para %*% vcov_par_model %*% t(derv_cpt_para)
  return(list(var_d3 = var_d3, vcov_cpts = vcov_cpts, vcov_tcfs = vcov_tcfs))
}

ctp_est_fun <- function(par_model, z, n_p, boxcox, par_boxcox, start = NULL,
                        method_optim, maxit, lower, upper) {
  if (is.null(start)) {
    beta_d <- par_model[1:(3 * n_p)]
    mu <- z %*% beta_d
    sigma_d <- sqrt(par_model[(3 * n_p + 2):length(par_model)]^2 +
                      par_model[(3 * n_p + 1)]^2)
    t1_0 <- mu[1] + qnorm(0.3) * sigma_d[1]
    t2_0 <- mu[3] + qnorm(1 - 0.4) * sigma_d[3]
    start <- c(t1_0, t2_0)
  }
  ctp_optim <- optim(par = start, fn = ctp_normal, par_model = par_model, z = z,
                     n_p = n_p, method = method_optim,
                     control = list(maxit = maxit),
                     lower = lower, upper = upper)
  if (ctp_optim$par[1] > ctp_optim$par[2]) {
    cpt_ctp_est <- rev(ctp_optim$par)
  } else {
    cpt_ctp_est <- ctp_optim$par
  }
  if (boxcox) {
    cpt_ctp_est <- boxcox_trans_back(cpt_ctp_est, par_boxcox)
  }
  out <- cpt_ctp_est
  names(out) <- c("threshold_1", "threshold_2")
  return(out)
}
