# org.At.tair.db

GO注释, 基因对应文章, 基因对应的SYMBOL, 以及基因对应的功能描述下载自 <https://zenodo.org/record/2530282#.XDLgk1wzaUk>

- ATH_GO_TERM.txt: 该文件来自于`cat ATH_GO_GOSLIM.txt | cut -f 1,6,8,10 > ATH_GO_TERM.txt`, 从原始的文件提取必要的三列
- Locus_Published_20171231.txt: 每个基因所关联的文献
- gene_aliases_20171231.txt: 基因对应的别名
- Araport11_functional_descriptions_20171231.txt: 每个基因的功能说明

创建包的代码见`org.At.tair.db.R`, 我构建GO注释中剔除不可靠的IEA对应GO, 也就是没有审查的电子注释部分。

构建注释包主要借助于`AnnotationForge`包. 如果你要构建属于你自己的物种包的话, 需要注意如下事情

- 每个数据框都必须要有GID列
- 每个数据框不能有重复的行
- PMID不能为空
- 处理数据时, 字符串一定要注意不要被R语言默认转成因子

安装注释包的方法如下:

```{r}
install.packages("https://raw.githubusercontent.com/xuzhougeng/org.At.tair.db/master/org.Atair10.eg.db.tgz",
repos=NULL,type="source")
```

**注**: 和"org.At.tair.db"不同，我

如果安装失败，可能是依赖包没有装好，可以安装旧版本的拟南芥注释，把依赖包装好

```{r}
# 解决依赖包的问题
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("org.At.tair.db", version = "3.8")
```

有问题欢迎在issue中提出。
