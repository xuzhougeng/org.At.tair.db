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

```bash
git clone https://github.com/xuzhougeng/org.At.tair.db.git
cd org.At.tair.db
Rscripts org.At.tair.db.R
```



## 代码说明

GO注释, 基因对应文章, 基因对应的SYMBOL, 以及基因对应的功能描述下载自 <https://zenodo.org/record/2530282#.XDLgk1wzaUk>

- ATH_GO_TERM.txt: 该文件来自于`zcat ATH_GO_GOSLIM.txt | cut -f 1,6,8,10 > ATH_GO_TERM.txt`, 从原始的文件提取必要的三列
- Locus_Published_20180330.txt.gz: 每个基因所关联的文献
- gene_aliases_20180330.txt.gz: 基因对应的别名
- Araport11_functional_descriptions_20180330.txt.gz : 每个基因的功能说明

创建包的代码见`org.At.tair.db.R`, 我构建GO注释中剔除不可靠的IEA对应GO, 也就是没有审查的电子注释部分。

构建注释包主要借助于`AnnotationForge`包. 如果你要构建属于你自己的物种包的话, 需要注意如下事情

- 每个数据框都必须要有GID列,
- 每个数据框不能有重复的行
- PMID不能为空
- 处理数据时, 字符串一定要注意不要被R语言默认转成因子

我在构建物种包时用到的代码在`org.At.tair.db.R`

## 附赠git永久删除文件

我发现多次更改后，我的本地git内容就特别的大，所以就找了一些资料去删除本地再也不需要的文件

```bash
# 从资料库删除文件
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch 你准备删除的文件名' --prune-empty --tag-name-filter cat -- --all
# 覆盖远程
git push origin master --force 
# 清理和回收空间
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now
git gc --aggressive --prune=now
```

一顿操作之后，原来的180M就只有30M了