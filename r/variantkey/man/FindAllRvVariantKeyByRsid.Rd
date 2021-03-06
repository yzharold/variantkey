% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/variantkey.R
\name{FindAllRvVariantKeyByRsid}
\alias{FindAllRvVariantKeyByRsid}
\title{Search for the specified rsID and returns all the associated VariantKeys in the RV file.
NOTE that the output is limited to maximum 10 results.}
\usage{
FindAllRvVariantKeyByRsid(src, first, last, rsid)
}
\arguments{
\item{src}{Address of the memory mapped binary file containing the rsID to VariantKey lookup table (rsvk.bin).}

\item{first}{First element of the range to search (min value = 0).}

\item{last}{Last element of the range to search (max value = nitems - 1).}

\item{rsid}{rsID to search.}
}
\description{
Search for the specified rsID and returns all the associated VariantKeys in the RV file.
NOTE that the output is limited to maximum 10 results.
}
