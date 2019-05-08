# org.At.tair.db

2019-5-8更新

>**18th public release of TAIR@Phoenix data** **[April 1, 2019]**

> We are pleased to release a set of data files containing information added to TAIR up to and including [March 31, 2018](https://www.arabidopsis.org/download/index-auto.jsp?dir=%2Fdownload_files%2FPublic_Data_Releases%2FTAIR_Data_20180331). These files are freely available to all researchers, including both subscribers and non-subscribers. The data files include GO and PO annotations, Gene Symbol and full name information, links between loci and publications, updated gene descriptions, and phenotype information added to TAIR through March 31, 2018. The 12-month delay before publicly releasing these data files allows us to generate subscription revenue that supports data curation. Without this delay and the subscription support it enables, we would not be able to gather the data and make them available. 

> TAIR subscribers have full access to additional data in the resource that have been added over the last 12 months. The current data are also visible on TAIR web pages for limited viewing by non-subscribers. For more information on subscriptions, please visit our [subscription page](http://www.arabidopsis.org/doc/about/tair_subscriptions/413).

根据TAIR10提供的2018-03-30的注释信息，更新了我的注释包构建代码

-----

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

<<<<<<< HEAD
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
# select high confidence evidence
go_df <- go_df[! go_df$V4 %in% "IEA",]
colnames(go_df) <- c("GID","GO","ONTOLOGY","EVIDENCE")



# GENE-PUB的数据框
pub_df <- read.table("./Locus_Published_20180330.txt.gz",
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
symbol_df <- read.table("./gene_aliases_20180330.txt.gz",
                        sep = "\t",
                        header = TRUE)
symbol_df <- symbol_df[grepl(pattern = "^AT\\d", symbol_df$name),]
colnames(symbol_df) <- c("GID","SYMBOL","FULL_NAME")


# GENE-FUNCTION
func_df <- read.table("./Araport11_functional_descriptions_20180330.txt.gz",
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

#install.packages("./org.Atair10.eg.db", repos = NULL,
#                 type = "source")
```

安装方法
=======
安装注释包的方法如下:
>>>>>>> 919ee0fb4b3ac528a49933beef43e9c5686abbfb

```{r}
install.packages("https://raw.githubusercontent.com/xuzhougeng/org.At.tair.db/master/org.Atair10.eg.db.tgz",
repos=NULL,type="source")
```

**注**: 和"org.At.tair.db"不同，你不能用TAIR作为keytype传给cluserProfiler::enrichGO, 而是用GID.

如果安装失败，可能是依赖包没有装好，可以安装旧版本的拟南芥注释，把依赖包装好

```{r}
# 解决依赖包的问题
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("org.At.tair.db")
```

有问题欢迎在issue中提出。
