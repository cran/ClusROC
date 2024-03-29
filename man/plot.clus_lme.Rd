% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clus_lme.R
\name{plot.clus_lme}
\alias{plot.clus_lme}
\title{Plot an clus_lme object.}
\usage{
\method{plot}{clus_lme}(x, file_name = NULL, ...)
}
\arguments{
\item{x}{an object of class "clus_lme", i.e., a result of \code{\link{clus_lme}} call.}

\item{file_name}{File name to create on disk.}

\item{...}{further arguments used with \code{\link{ggexport}} function, for example, \code{width}, \code{height}.}
}
\value{
\code{plot.clus_lme} returns the diagnostic plots for the linear mixed-effect model, fitted by clus_lme.
}
\description{
Diagnostic plots for the linear mixed-effect model, fitted by clus_lme.
}
\details{
\code{plot.clus_lme} provides three diagnostic plots: Q-Q plots for residuals, Fitted vs. Residuals values, and Q-Q plot for cluster effects, based on \code{ggplot()}.
}
\seealso{
\code{\link{clus_lme}}
}
