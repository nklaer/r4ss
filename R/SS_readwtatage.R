#' Read weight-at-age data file
#' 
#' Read in a weight-at-age data file into a data frame in R.
#' 
#' @param file A relative or full path to the weight-at-age file.
#' The default values is \code{wtatage.ss}.
#' @template verbose
#' @export
#' @return Returns a data frame with a variable number of columns based on the
#' number of ages that are included in the file. Though, the first columns
#' will always be Yr, Seas, Sex, Bio_Pattern, BirthSeas, and Fleet.
#' The seventh column will be age zero.
#' The last or next to last column will be the maximum age included
#' in the weight-at-age data. For SS version 3.30 and greater, the last column
#' will be a column of comments.
#' 
SS_readwtatage <- function(file = "wtatage.ss", verbose=TRUE) {
  if(!file.exists(file) | file.info(file)$size==0) {
    if(verbose) message("Skipping weight-at-age file. File missing or empty:",file,"\n")
    return(NULL)
  }
  # read top few lines to figure out how many to skip
  wtatagelines <- readLines(file,n=20)
  accuage <- strsplit(wtatagelines, "\\s")
  accuage <- accuage[!lapply(accuage, "[[", 1) %in% c("#", " ")][[1]]
  accuage <- accuage[!grepl("\\s", accuage)][1]

  # read full file
  wtatage <- read.table(file,header=FALSE,comment.char="",
                        skip=grep("Yr Seas ", wtatagelines, ignore.case=TRUE),
                        stringsAsFactors=FALSE)
  # problems with header so simply manually replacing column names
  wtatage_names <- c("Yr", "Seas", "Sex", "Bio_Pattern", "BirthSeas", "Fleet",
                     0:accuage)
  # new comment line in 3.30
  if(ncol(wtatage)==length(wtatage_names)+1){
    wtatage_names <- c(wtatage_names, "comment")
  }
  names(wtatage) <- wtatage_names
  # Remove terminator line
  wtatage <- wtatage[wtatage$Yr > 0, ]
  return(wtatage)
}
