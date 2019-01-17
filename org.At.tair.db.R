library(RSQLite)
library(AnnotationForge)
options(stringsAsFactors = F)

# GENE-GO注释的数据框
# ATH_GO_TERM.txt were create 
# by `cat ATH_GO_GOSLIM.txt | cut -f 1,6,8,10 > ATH_GO_TERM.txt`
go_df <- read.table("./ATH_GO_TERM.txt",
                      sep="\t", header = FALSE,
                      as.is = TRUE)
go_df$V3 <- ifelse(go_df$V3 == "C", "CC",
                     ifelse(go_df$V3 == "P", "BP",
                            ifelse(go_df$V3 == "F", "MF", "")))

# http://www.geneontology.org/page/guide-go-evidence-codes
# select high confidence evidence
go_df <- go_df[! go_df$V4 %in% "IEA",]
colnames(go_df) <- c("GID","GO","ONTOLOGY","EVIDENCE")



# GENE-PUB的数据框
pub_df <- read.table("./Locus_Published_20171231.txt",
                     sep="\t",
                     header = TRUE)

## 只选择AT开头的基因
pub_df <- pub_df[grepl(pattern = "^AT\\d", pub_df$name),]
pub_df <- cbind(GID=do.call(rbind,strsplit(pub_df$name, split = "\\."))[,1],
                pub_df)
## pubmed_id 不能为空
pub_df <- pub_df[!is.na(pub_df$PMID),]

colnames(pub_df) <- c("GID","GENEID","REFID",
                      "PMID","PUBYEAR")

# GENE-SYMBOL的注释数据库
symbol_df <- read.table("./gene_aliases_20171231.txt",
                        sep = "\t",
                        header = TRUE)
symbol_df <- symbol_df[grepl(pattern = "^AT\\d", symbol_df$name),]
colnames(symbol_df) <- c("GID","SYMBOL","FULL_NAME")


# GENE-FUNCTION
func_df <- read.table("./Araport11_functional_descriptions_20171231.txt",
                      sep = "\t",
                      header=TRUE)
func_df <- func_df[grepl(pattern = "^AT\\d", func_df$name),]
func_df <- cbind(GID=do.call(rbind,strsplit(func_df$name, split = "\\."))[,1],
                  func_df)
colnames(func_df) <- c("GID","TXID","GENE_MODEL_TYPE",
                       "SHORT_DESCRIPTION",
                       "CURATOR_SUMMARY",
                       "COMPUTATIONAL_DESCRIPTION")
## 去重复行
go_df <- go_df[!duplicated(go_df),]
go_df <- go_df[,c(1,2,4)]
pub_df <- pub_df[!duplicated(pub_df),]
symbol_df <- symbol_df[!duplicated(symbol_df),]
func_df <- func_df[!duplicated(func_df),]


# no duplicated row
# all GID should be same type, be aware of factor

makeOrgPackage(go=go_df,
               pub_info = pub_df,
               symbol_info = symbol_df,
               function_info = func_df,
               version = "0.1",
               maintainer = "xuzhougeng <xuzhougeng@163.com>",
               author="xuzhogueng <xuzhougeng@163.com>",
               outputDir = "F:/Project/org.At.tair.db",
               tax_id = "3702",
               genus = "At",
               species = "tair10",
               goTable = "go"
  
)

#install.packages("./org.Atair10.eg.db", repos = NULL,
#                 type = "source")