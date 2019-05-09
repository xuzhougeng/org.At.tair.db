# org.At.tair.db

2019-5-8更新

>**18th public release of TAIR@Phoenix data** **[April 1, 2019]**

> We are pleased to release a set of data files containing information added to TAIR up to and including [March 31, 2018](https://www.arabidopsis.org/download/index-auto.jsp?dir=%2Fdownload_files%2FPublic_Data_Releases%2FTAIR_Data_20180331). These files are freely available to all researchers, including both subscribers and non-subscribers. The data files include GO and PO annotations, Gene Symbol and full name information, links between loci and publications, updated gene descriptions, and phenotype information added to TAIR through March 31, 2018. The 12-month delay before publicly releasing these data files allows us to generate subscription revenue that supports data curation. Without this delay and the subscription support it enables, we would not be able to gather the data and make them available. 

> TAIR subscribers have full access to additional data in the resource that have been added over the last 12 months. The current data are also visible on TAIR web pages for limited viewing by non-subscribers. For more information on subscriptions, please visit our [subscription page](http://www.arabidopsis.org/doc/about/tair_subscriptions/413).

根据TAIR10提供的2018-03-30的注释信息，更新了我的注释包构建代码

**由于** GitHub单文件限制50M，由于我自己版本的构建结果大于50MB，所以要阅读**代码安装**

构建环境信息如下

```R
> sessionInfo()
R version 3.6.0 (2019-04-26)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

Matrix products: default

locale:
[1] LC_COLLATE=Chinese (Simplified)_China.936  LC_CTYPE=Chinese (Simplified)_China.936   
[3] LC_MONETARY=Chinese (Simplified)_China.936 LC_NUMERIC=C                              
[5] LC_TIME=Chinese (Simplified)_China.936    

attached base packages:
[1] stats4    parallel  stats     graphics  grDevices utils     datasets  methods  
[9] base     

other attached packages:
[1] AnnotationForge_1.26.0 AnnotationDbi_1.46.0   IRanges_2.18.0        
[4] S4Vectors_0.22.0       Biobase_2.44.0         BiocGenerics_0.30.0   
[7] RSQLite_2.1.1         

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.1         GO.db_3.8.2        XML_3.98-1.19      digest_0.6.18     
 [5] bitops_1.0-6       DBI_1.0.0          blob_1.1.1         tools_3.6.0       
 [9] bit64_0.9-7        RCurl_1.95-4.12    bit_1.1-14         compiler_3.6.0    
[13] pkgconfig_2.0.2    BiocManager_1.30.4 memoise_1.1.0  
```

-----

## 代码安装

需要打开命令行（Windows用户下载Git）







## 代码说明

GO注释, 基因对应文章, 基因对应的SYMBOL, 以及基因对应的功能描述下载自 <https://zenodo.org/record/2530282#.XDLgk1wzaUk>

- ATH_GO_TERM.txt: 该文件来自于`zcat ATH_GO_GOSLIM.txt | cut -f 1,6,8,10 > ATH_GO_TERM.txt`, 从原始的文件提取必要的三列
- Locus_Published_20180330.txt.gz: 每个基因所关联的文献
- gene_aliases_20180330.txt.gz: 基因对应的别名
- Araport11_functional_descriptions_20180330.txt.gz : 每个基因的功能说明

创建包的代码见`org.At.tair.db.R`, 我构建GO注释中剔除不可靠的IEA对应GO, 也就是没有审查的电子注释部分。

构建注释包主要借助于`AnnotationForge`包. 如果你要构建属于你自己的物种包的话, 需要注意如下事情

- 每个数据框都必须要有GID列
- 每个数据框不能有重复的行
- PMID不能为空
- 处理数据时, 字符串一定要注意不要被R语言默认转成因子

我在构建物种包时用到的代码如下:

**保证**上面提到的4个文件和你代码在同级目录下

```r
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
# remove the following code
# as the IEA is trustbly according to 
# Pathway enrichment analysis and visualization of omics data using g:Profiler, GSEA, Cytoscape and EnrichmentMap
# go_df <- go_df[! go_df$V4 %in% "IEA",]

colnames(go_df) <- c("GID","GO","ONTOLOGY","EVIDENCE")

# GENE-PUB的数据框
pub_df <- read.table("./Locus_Published_20180330.txt.gz",
                     sep="\t",
                     header = TRUE)

## 只选择AT开头的基因
pub_df <- pub_df[grepl(pattern = "^AT\\d", pub_df$name),]
pub_df <- cbind(GID=do.call(rbind,strsplit(pub_df$name, split = "\\."))[,1],
                pub_df)

# convert NA to blank
pub_df$pubmed_id <- ifelse(is.na(pub_df$pubmed_id), "",pub_df$pubmed_id)

colnames(pub_df) <- c("GID","GENEID","REFID",
                      "PMID","PUBYEAR")

# GENE-SYMBOL的注释数据库
symbol_df <- read.table("./gene_aliases_20180330.txt.gz",
                        sep = "\t",
                        header = TRUE)
symbol_df <- symbol_df[grepl(pattern = "^AT\\d", symbol_df$name),]
colnames(symbol_df) <- c("GID","SYMBOL","SYMBOL_NAME")

# GENE-FUNCTION
func_df <- read.table("./Araport11_functional_descriptions_20180330.txt.gz",
                      sep = "\t",
                      header=TRUE)
func_df <- func_df[grepl(pattern = "^AT\\d", func_df$name),]
func_df <- cbind(GID=do.call(rbind,strsplit(func_df$name, split = "\\."))[,1],
                  func_df)
colnames(func_df) <- c("GID","TXID","GENE_MODEL_TYPE",
                       "SHORT_DESCRIPTION",
                       "CURATED_DESCRIPTION",
                       "DESCRIPTION")

## remove duplicated
go_df <- go_df[!duplicated(go_df), ]
go_df <- go_df[,c(1,2,4)]
pub_df <- pub_df[!duplicated(pub_df),]
symbol_df <- symbol_df[!duplicated(symbol_df),]
func_df <- func_df[!duplicated(func_df),]


# no duplicated row
# all GID should be same type, be aware of factor
file_path <- file.path( getwd())
makeOrgPackage(go=go_df,
               pub_info = pub_df,
               symbol_info = symbol_df,
               function_info = func_df,
               version = "0.1",
               maintainer = "xuzhougeng <xuzhougeng@163.com>",
               author="xuzhogueng <xuzhougeng@163.com>",
               outputDir = file_path,
               tax_id = "3702",
               genus = "At",
               species = "tair10",
               goTable = "go"
  
)

install.packages("./org.Atair10.eg.db", repos = NULL,
                 type = "source")
```
