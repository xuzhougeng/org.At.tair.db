# org.At.tair.db

GO注释, 基因对应文章, 基因对应的SYMBOL, 以及基因对应的功能描述下载自 <https://zenodo.org/record/2530282#.XDLgk1wzaUk>

- ATH_GO_TERM.txt: 该文件来自于`cat ATH_GO_GOSLIM.txt | cut -f 1,6,8,10 > ATH_GO_TERM.txt`, 从原始的文件提取必要的三列
- Locus_Published_20171231.txt: 每个基因所关联的文献
- gene_aliases_20171231.txt: 基因对应的别名
- Araport11_functional_descriptions_20171231.txt: 每个基因的功能说明

构建注释包主要借助于`AnnotationForge`包. 如果你要构建属于你自己的物种包的话, 需要注意如下事情

- 每个数据框都必须要有GID列
- 每个数据框不能有重复的行
- PMID不能为空
- 处理数据时, 字符串一定要注意不要被R语言默认转成因子

我在构建物种包时用到的代码如下:

```r
library(RSQLite)
library(AnnotationForge)
options(stringsAsFactors = F)

# GENE-GO注释的数据框
go_df <- read.table("F:/Project/org.At.tair.db/ATH_GO_TERM.txt",
                      sep="\t", header = FALSE,
                      as.is = TRUE)
go_df$V3 <- ifelse(go_df$V3 == "C", "CC",
                     ifelse(go_df$V3 == "P", "BP",
                            ifelse(go_df$V3 == "F", "MF", "")))
colnames(go_df) <- c("GID","GO","ONTOLOGY","EVIDENCE")


# GENE-PUB的数据框
pub_df <- read.table("F:/Project/org.At.tair.db/Locus_Published_20171231.txt",
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
symbol_df <- read.table("F:/Project/org.At.tair.db/gene_aliases_20171231.txt",
                        sep = "\t",
                        header = TRUE)
symbol_df <- symbol_df[grepl(pattern = "^AT\\d", symbol_df$name),]
colnames(symbol_df) <- c("GID","SYMBOL","FULL_NAME")


# GENE-FUNCTION
func_df <- read.table("F:/Project/org.At.tair.db/Araport11_functional_descriptions_20171231.txt",
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
```

安装方法

```{r}
install.packages("https://raw.githubusercontent.com/xuzhougeng/org.At.tair.db/master/org.Atair10.eg.db.tgz",
repos=NULL,type="source")
```

如果安装失败，可能是依赖包没有装好，可以安装旧版本的拟南芥注释，把依赖包装好

```{r}
# 解决依赖包的问题
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("org.At.tair.db", version = "3.8")
```

有问题欢迎在issue中提出。
