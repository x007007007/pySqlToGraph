import itertools
import pytest
from gbase_parser_simple.test_help import read_sql


@pytest.mark.parametrize("sql,entry_name", itertools.product([
    "CREATE TABLE products(productnum DECIMAL(8,3));",
    "CREATE TABLE t1 (d DECIMAL(10,0));",
    "SELECT DATE_ADD('2010-08-31 23:59:59.000002',INTERVAL '1.999999'\nSECOND_MICROSECOND) AS DATE_ADD FROM t;",
    "SELECT COLLATION(_gb2312 'abc') FROM t;",
    "SELECT SUBSTRING_INDEX(USER(),_utf8'@',1) FROM t;",
    ## 南大通用数据技术股份有限公司 - 271 -
    """SELECT NVL(color_type,'') as
    color_type_show,NVL(DECODE(color_type,NULL,f_YearMonth || '\u5408\u8ba1\n',
    NVL(f_YearMonth,color_type || ' \u5c0f\u8ba1')),'\u603b\u8ba1') AS f_YearMonth_show,
    SUM(color_count) FROM (SELECT\ncolor_type,DATE_FORMAT(in_date, '%Y-%m') as f_YearMonth,color_count FROM t3)
    t GROUP BY CUBE(color_type,f_YearMonth) ORDER BY color_type,f_YearMonth;
    """,
    """
    SELECT NVL(color_type,'') as
    color_type_show,DECODE(NVL(color_type,''),'','\u603b\u8ba1 ',NVL(f_YearMonth,color_type || ' \u5c0f\u8ba1')) AS\nf_YearMonth_show,SUM(color_count) FROM (SELECT
    color_type,DATE_FORMAT(in_date, '%Y-%m') as f_YearMonth,color_count FROM t3)
    t GROUP BY ROLLUP(color_type,f_YearMonth) ORDER BY color_type,f_YearMonth;
    """,
    ## - 276 - 南大通用数据技术股份有限公司
    "SELECT *,RANK() OVER(PARTITION BY i ORDER BY j desc) AS rank FROM t1;",
    ## - 278 - 南大通用数据技术股份有限公司
    "SELECT *,RANK() OVER(PARTITION BY i ORDER BY j DESC) AS rank,DENSE_RANK()\nOVER (partition by i order by j desc) AS dense_rank FROM t1;",
    ##
    "SELECT *,RANK() OVER(PARTITION BY i order by j desc) AS rank,DENSE_RANK()\nOVER(PARTITION BY i order by j desc) AS dense_rank ,ROW_NUMBER() OVER(PARTITION\nBY i order by j desc) AS row_number FROM t1;",
    ## - 280 - 南大通用数据技术股份有限公司
    "SELECT *,SUM(k) OVER(PARTITION BY i ORDER BY j DESC) AS sum FROM t1;",
    "SELECT *,SUM(distinct k) OVER(PARTITION BY i) AS sum FROM t1;",
    ## - 284 - 南大通用数据技术股份有限公司
    "SELECT *,COUNT(k) OVER(PARTITION BY i ORDER BY j DESC) AS sum FROM t2;",
    "SELECT *,COUNT(DISTINCT k) OVER(PARTITION BY i) AS sum FROM t2;",
    ## 288
    "SELECT *,LEAD(result, 1, NULL) OVER(PARTITION BY result ORDER BY area\nDESC) AS LEAD FROM t_olap;",
    #
    "select i,v,grouping(i),grouping(v) from t1 group by grouping sets(i,v);",                        # GBASE SPEC gram
    "select *, var_pop(totalamount) over (partition by uname order by dt)\nas var_pop from tt;",
    "select *, var_samp(totalamount) over (partition by uname order by dt)\nas var_samp from tt;",
    "select *, cume_dist() over (partition by uname order by dt) as cume_dist\nfrom tt;",
    "select *, ntile(2) over (partition by uname order by dt) as ntile from\ntt;",
    "select *, ntile('2') over (partition by uname order by dt) as ntile from\ntt;",
    "select *, ntile(2.1) over (partition by uname order by dt) as ntile from\ntt;",
    "select *, first_value(totalamount) over (partition by uname order by\ndt) as first_value from tt;",
    "select *, first_value('const') over (partition by uname order by dt) as first_value from tt;",
    "select *, first_value(NULL) over (partition by uname order by dt) as\nfirst_value from tt;",
    "select *, last_value(totalamount) over (partition by uname order by dt)\nas last_value from tt;",
    "select *, last_value('const') over (partition by uname order by dt) as\nlast_value from tt;",
    "select *, last_value(NULL) over (partition by uname order by dt) as\nlast_value from tt;",
    "select *, nth_value(totalamount, 2) over (partition by uname order by\ndt) as nth_value from tt;",
    "select *, nth_value(totalamount, NULL) over (partition by uname order\nby dt) as nth_value from tt;",
    "select *, nth_value(totalamount, 0) over (partition by uname order by\ndt) as nth_value from tt;",
    "select *, nth_value('const', 2) over (partition by uname order by dt)\nas nth_value from tt;",
    "CREATE TABLE t2(a int, b int) REPLICATED;",
    "CREATE TABLE t5(a int,b datetime);",
    "CREATE TABLE t1 (a int,b varchar(10)) REPLICATED;",
    "CREATE TEMPORARY TABLE t1 (a int,b varchar(10)) DISTRIBUTED BY ('a');",
    "CREATE TEMPORARY TABLE t1 (a int,b varchar(10)) REPLICATED;",
    "CREATE TABLE t_1 (a int) NOCOPIES;",
    "CREATE TABLE t_2 (a int) NOCOPIES;",
    "CREATE TABLE t_3 (a int) NOCOPIES;",
    "CREATE TABLE t1 (a int) NOCOPIES;",
    "CREATE TABLE t1 (a int,b varchar(10)) DISTRIBUTED BY ('a') NOCOPIES;",
    "CREATE TEMPORARY TABLE t1 (a int,b varchar(10)) DISTRIBUTED BY ('a')\nNOCOPIES;",
    "SELECT NVL(color_type,'') as\ncolor_type_show,NVL(DECODE(color_type,NULL,f_YearMonth || '\u5408\u8ba1\n',NVL(f_YearMonth,color_type || ' \u5c0f\u8ba1')),'\u603b\u8ba1') AS\nf_YearMonth_show,SUM(color_count) FROM (SELECT\ncolor_type,DATE_FORMAT(in_date, '%Y-%m') as f_YearMonth,color_count FROM t3)\nt GROUP BY CUBE(color_type,f_YearMonth) ORDER BY color_type,f_YearMonth into\noutfile '/home/gbase/temp/t3.txt';",
    "CREATE TABLE t5(a int,b datetime) REPLICATED;",
    "CREATE TEMPORARY TABLE t1 (a int,b varchar(10)) REPLICATED;",
    "CREATE TABLE t8 NOCOPIES AS SELECT * FROM t7;",
    "CREATE TABLE t1 (a int) NOCOPIES;",
    "CREATE TABLE b (a decimal(12,5) DEFAULT NULL, KEY idx_a (a) USING HASH\nGLOBAL);",
    "CREATE INDEX idx2 on t1(b) USING HASH GLOBAL;",
    "CREATE INDEX idx3 on t1(b) key_block_size=16384 USING HASH GLOBAL;",
    "CREATE INDEX idx4 on t1(b) key_dc_size=50 USING HASH GLOBAL;",
    "CREATE TABLE t(nameid int, name varchar(50)) AUTOEXTEND ON NEXT 1M;",
    "CREATE TABLE t1(a int) AUTOEXTEND ON NEXT 3G;",
    "CREATE TABLE t1 (a int DEFAULT NULL,b varchar(10) COMPRESS(3));",
    "CREATE TABLE t2 (a int COMPRESS(3),b varchar(10) COMPRESS(5));",
    "ALTER TABLE t1 ALTER a COMPRESS(1);",
    "CREATE TABLE t2 (a int ,b varchar(10) NULL COMPRESS(5));",
    "ALTER TABLE t2 ALTER b COMPRESS(3);",
    "ALTER TABLE t2 ALTER a COMPRESS(4);",
    "CREATE TABLE t1 (a int, b varchar(10)) COMPRESS(0,0) REPLICATED;",
    "CREATE TABLE t2 (a int, b varchar(10)) COMPRESS(1,3);",
    "CREATE TABLE t3 (a int, b varchar(10)) COMPRESS(5,5);",
    "ALTER TABLE t2 ALTER compress(5,5);",
    "CREATE TABLE t(a int,b int,c int,d int,GROUPED a(b,c) COMPRESS(5));",
    "CREATE TABLE t(a int,b int,c int,d int,GROUPED (b,c),GROUPED (d));",
    "DROP USER admin;",
    "start kafka consumer t10;",
    "show kafka consumer t10;",
    "stop kafka consumer t10;",
], [
    'root',
    # 'simpleStatement'
]))
def test_gbase_failed_example(sql, entry_name):
    parser = read_sql(sql)
    tree = getattr(parser, entry_name)()
