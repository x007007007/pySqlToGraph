lexer grammar GBaseSQLToken;

SCOL : ';';
DOT : '.';
OPEN_PAR : '(';
CLOSE_PAR : ')';
COMMA : ',';
ASSIGN : '=';
STAR : '*';
PLUS : '+';
MINUS : '-';
TILDE : '~';
PIPE2 : '||';
DIV : '/';
MOD : '%';
LT2 : '<<';
GT2 : '>>';
AMP : '&';
AND : '&&';
PIPE : '|';
LT : '<';
LT_EQ : '<=';
GT : '>';
GT_EQ : '>=';
EQ : '==';
NOT_EQ1 : '!=';
NOT_EQ2 : '<>';
NOT_EQ3 : '~=';
NOT_EQ4 : '^=';
HYPHEN : '_';
NOT : '!';
POWER_OP : '^';
EMPTY : ;
LT_EQ_GT:'<=>';
COLON : ':';
AT : '@';

//key word form gbase sql manual
K_DATABASE : D A T A B A S E ;
K_DROP : D R O P ;

K_REPLICATED : R E P L I C A T E D ;
K_DISTRIBUTED : D I S T R I B U T E D ;
K_BY : B Y ;
K_DEFAULT : D E F A U L T ;
K_COMMENT : C O M M E N T ;
K_NOCOPIES : N O C O P I E S ;
K_IF : I F ;
K_NOT : N O T ;
K_EXISTS : E X I S T S ;
K_NULL : N U L L ;
K_CREATE : C R E A T E ;
K_TABLE : T A B L E ;
K_TEMPORARY : T E M P O R A R Y ;
K_KEY : K E Y ;
K_COMPRESS : C O M P R E S S ;
K_ENGINE : E N G I N E  ;
K_GROUPED : G R O U P E D ;

K_ALTER : A L T E R ;
K_ADD : A D D ;
K_COLUMN : C O L U M N ;
K_FIRST : F I R S T ;
K_AFTER : A F T E R  ;
K_CHANGE : C H A N G E ;
K_MODIFY : M O D I F Y ;
K_RENAME : R E N A M E ;
K_TO : T O ;
K_SHRINK : S H R I N K ;
K_SPACE : S P A C E ;
K_AUTOEXTEND: A U T O E X T E N D ;
K_OFF : O F F ;
K_NEXT : N E X T ;

K_CACHE : C A C H E ;

K_TRUNCATE : T R U N C A T E ;

K_INSERT: I N S E R T ;
K_INTO: I N T O ;
K_VALUES: V A L U E S ;

//add by chentie
K_UPDATE : U P D A T E ;
K_SET : S E T ;
K_WHERE : W H E R E ;
K_IS : I S ;
K_LIKE : L I K E ;
K_IN : I N ;
K_GLOB : G L O B ;
K_MATCH : M A T C H ;
K_REGEXP : R E G E X P ;
K_AND : A N D ;
K_OR : O R ;
K_XOR : X O R ;
K_DISTINCT : D I S T I N C T ;
K_CAST : C A S T ;
K_AS : A S ;
K_COLLATE : C O L L A T E ;
K_ESCAPE : E S C A P E ;
//K_ISNULL : I S N U L L ;
K_NOTNULL : N O T N U L L ;
K_BETWEEN : B E T W E E N ;
K_CASE : C A S E ;
K_WHEN : W H E N ;
K_THEN : T H E N ;
K_ELSE : E L S E ;
K_END : E N D ;
K_CURRENT_TIME : C U R R E N T '_' T I M E ;
K_CURRENT_DATE : C U R R E N T '_' D A T E ;
K_CURRENT_TIMESTAMP : C U R R E N T '_' T I M E S T A M P ;
K_RAISE : R A I S E ;
K_IGNORE : I G N O R E ;
K_ROLLBACK : R O L L B A C K ;
K_ABORT : A B O R T ;
K_FAIL : F A I L ;

K_DIV : D I V ;
K_MOD : M O D ;
K_BINARY : B I N A R Y ;
K_ROW : R O W ;
//USER_VAR:
//	'@' (USER_VAR_SUBFIX1 | USER_VAR_SUBFIX2 | USER_VAR_SUBFIX3 | USER_VAR_SUBFIX4)
//;
K_CONVERT : C O N V E R T ;
K_AGAINST : A G A I N S T ;
K_INTERVAL : I N T E R V A L ;
K_TRUE : T R U E ;
K_FALSE : F A L S E ;
K_UNKNOWN : U N K N O W N ;
//K_COALESCE : C O A L E S C E ;
//K_GREATEST : G R E A T E S T ;
//K_LEAST : L E A S T ;

K_SECOND : S E C O N D ;
K_MINUTE : M I N U T E ;
K_HOUR : H O U R ;
//K_DAY : D A Y ;
//K_WEEK : W E E K ;
//K_MONTH  : M O N T H ;
//K_QUARTER : Q U A R T E R ;
//K_YEAR : Y E A R ;
K_SECOND_MICROSECOND : S E C O N D '_' M I C R O S E C O N D ;
K_MINUTE_MICROSECOND : M I N U T E '_' M I C R O S E C O N D ;
K_MINUTE_SECOND : M I N U T E '_' S E C O N D ;
K_HOUR_MICROSECOND : H O U R '_' M I C R O S E C O N D  ;
K_HOUR_SECOND : H O U R '_' S E C O N D ;
K_HOUR_MINUTE : H O U R '_' M I N U T E ;
K_DAY_MICROSECOND : D A Y '_' M I C R O S E C O N D ;
K_DAY_SECOND : D A Y '_' S E C O N D ;
K_DAY_MINUTE : D A Y '_' M I N U T E ;
K_DAY_HOUR : D A Y '_' H O U R ;
K_YEAR_MONTH : Y E A R '_' M O N T H ;
//K_AVG : A V G ;
//K_COUNT : C O U N T ;
//K_MAX : M A X ;
//K_MIN : M I N ;
//K_SUM :S U M ;
K_BIT_AND : B I T '_' A N D ;
K_BIT_OR : B I T '_' O R ;
K_BIT_XOR : B I T '_' X O R ;
K_GROUP_CONCAT : G R O U P '_' C O N C A T ;
K_STD : S T D ;
K_STDDEV : S T D D E V ;
K_STDDEV_POP : S T D D E V '_' P O P ;
K_STDDEV_SAMP : S T D D E V '_' S A M P ;
K_VAR_POP : V A R '_' P O P ;
K_VAR_SAMP : V A R '_' S A M P ;
K_VARIANCE : V A R I A N C E ;

K_DELETE : D E L E T E ;
K_FROM : F R O M ;

K_MERGE: M E R G E ;
K_USING: U S I N G ;
K_ON: O N ;
K_MATCHED: M A T C H E D ;

K_ORDER : O R D E R ;
K_LIMIT : L I M I T ;
K_OFFSET : O F F S E T ;
K_SELECT : S E L E C T ;
K_ALL : A L L ;
K_ANY : A N Y ;
K_GROUP : G R O U P ;
K_HAVING : H A V I N G ;
K_UNION : U N I O N ;
K_INTERSECT : I N T E R S E C T ;
K_ASC : A S C ;
K_DESC : D E S C ;
K_INDEXED : I N D E X E D ;
K_NATURAL : N A T U R A L ;
K_LEFT : L E F T ;
K_OUTER : O U T E R ;
K_INNER : I N N E R ;
K_CROSS : C R O S S ;
K_JOIN : J O I N ;
K_MINUS : M I N U S ;
K_OUTFILE : O U T F I L E ;
K_FIELDS : F I E L D S ;
K_COLUMNS : C O L U M N S ;
K_TERMINATED : T E R M I N A T E D ;
K_ENCLOSED : E N C L O S E D ;
K_ESCAPED : E S C A P E D ;
K_LINES : L I N E S ;
K_STARTING : S T A R T I N G ;

K_REPLACE : R E P L A C E ;
K_VIEW : V I E W ;
K_INDEX : I N D E X ;
K_SHOW : S H O W ;
K_HASH : H A S H ;
K_GLOBAL : G L O B A L ;
K_LOCAL : L O C A L ;
K_KEYDCSIZE : K E Y '_' D C '_' S I Z E ;
K_KEYBLOCKSIZE : K E Y '_' B L O C K '_' S I Z E ;

K_LANGUAGE : L A N G U A G E ;
K_MODE_SYM : M O D E '_' S Y M ;
K_WITH : W I T H ;
K_QUERY_SYM : Q U E R Y '_' S Y M ;
K_EXPANSION_SYM : E X P A N S I O N '_' S Y M ;
K_BOOLEAN_SYM : B O O L E A N '_' S Y M ;

K_LATIN1 : L A T I N '1';
K_UTF8 : U T F '8';

K_INTEGER_NUM : I N T E G E R '_' N U M ;
K_DATE_SYM : D A T E '_' S Y M ;
K_DECIMAL_SYM : D E C I M A L '_' S Y M ;
K_SIGNED_SYM : S I G N E D '_' S Y M ;
K_INTEGER_SYM : I N T E G E R '_' S Y M ;
K_TIME_SYM : T I M E '_' S Y M ;
K_UNSIGNED_SYM : U N S I G N E D '_' S Y M ;

//K_ABS : A B S ;
//K_ACOS : A C O S ;
//K_ASIN : A S I N ;
//K_ATAN2 : A T A N '2 ';
//K_ATAN : A T A N ;
//K_CEIL : C E I L;
//K_CEILING : C E I L I N G ;
//K_CONV : C O N V ;
//K_COS : C O S ;
//K_COT : C O T ;
//K_CRC32 : C R C '32 ';
//K_DEGREES : D E G R E E S ;
//K_EXP : E X P ;
//K_FLOOR : F L O O R ;
//K_LN : L N ;
//K_LOG10 : L O G '10 ';
//K_LOG2 : L O G '2 ';
//K_LOG : L O G ;
//K_PI : P I ;
//K_POW : P O W ;
//K_POWER : P O W E R ;
//K_RADIANS : R A D I A N S ;
//K_RAND : R A N D ;
//K_ROUND : R O U N D ;
//K_SIGN : S I G N ;
//K_SIN : S I N ;
//K_SQRT : S Q R T ;
//K_TAN : T A N ;

//K_ASCII_SYM : A S C I I '_' S Y M ;
//K_BIN : B I N ;
//K_BIT_LENGTH : B I T '_' L E N G T H ;
//K_CHAR_LENGTH : C H A R '_' L E N G T H ;
//K_CONCAT_WS : C O N C A T '_' W S ;
//K_CONCAT : C O N C A T ;
//K_ELT : E L T ;
//K_EXPORT_SET : E X P O R T '_' S E T ;
//K_FIELD : F I E L D ;
//K_FIND_IN_SET : F I N D '_' I N '_' S E T ;
//K_FORMAT : F O R M A T ;
//K_FROM_BASE64 : F R O M '_' B A S E '64 ';
//K_HEX : H E X  ;
//K_INSTR : I N S T R ;
//K_LENGTH : L E N G T H ;
//K_LOAD_FILE : L O A D '_' F I L E ;
//K_LOCATE : L O C A T E ;
//K_LOWER : L O W E R ;
//K_LPAD : L P A D ;
//K_LTRIM : L T R I M ;
//K_MAKE_SET : M A K E '_' S E T ;
//K_MID : M I D ;
//K_OCT : O C T ;
//K_ORD : O R D ;
//K_QUOTE : Q U O T E ;
K_REPEAT : R E P E A T ;
//K_REVERSE : R E V E R S E ;
K_RIGHT : R I G H T ;
//K_RPAD  : R P A D ;
//K_RTRIM : R T R I M ;
//K_SOUNDEX : S O U N D E X ;
//K_STRCMP : S T R C M P ;
//K_SUBSTRING_INDEX : S U B S T R I N G '_' I N D E X ;
//K_SUBSTRING : S U B S T R I N G ;
//K_TO_BASE64 : T O '_' B A S E '64 ';
//K_UNHEX : U N H E X ;
//K_UPPER : U P P E R ;
//K_WEIGHT_STRING : W E I G H T '_' S T R I N G ;

K_TRIM : T R I M ;

//K_ADDDATE : A D D D A T E ;
//K_ADDTIME : A D D T I M E ;
K_CONTAINS: C O N T A I N S ;
//K_CONVERT_TZ : C O N V E R T '_' T Z ;
//K_CURDATE : C U R D A T E ;
//K_CURTIME : C U R T I M E ;
K_DATA: D A T A ;
//K_DATE_ADD : D A T E '_' A D D ;
//K_DATE_FORMAT : D A T E '_' F O R M A T ;
//K_DATE_SUB : D A T E '_' S U B ;
//K_DATEDIFF : D A T E D I F F ;
//K_DAYNAME : D A Y N A M E ;
//K_DAYOFMONTH : D A Y O F M O N T H ;
//K_DAYOFWEEK : D A Y O F W E E K ;
//K_DAYOFYEAR : D A Y O F Y E A R ;
K_DEFINER : D E F I N E R ;
K_DELIMITER : D E L I M I T E R ;
K_EXTRACT : E X T R A C T ;
//K_FROM_DAYS : F R O M '_' D A Y S ;
//K_FROM_UNIXTIME : F R O M '_' U N I X T I M E ;
//K_GET_FORMAT : G E T '_' F O R M A T ;
K_INVOKER : I N V O K E R ;
//K_LAST_DAY : L A S T '_' D A Y ;
//K_MAKEDATE : M A K E D A T E ;
//K_MAKETIME : M A K E T I M E ;
K_MICROSECOND : M I C R O S E C O N D ;
//K_MONTHNAME : M O N T H N A M E ;
K_NO : N O ;
//K_NOW : N O W ;
//K_PERIOD_ADD : P E R I O D '_' A D D ;
//K_PERIOD_DIFF :P E R I O D '_' D I F F ;
//K_SEC_TO_TIME : S E T '_' T O '_' T I M E ;
K_SECURITY : S E C U R I T Y ;
//K_STR_TO_DATE : S T R '_' T O '_' D A T E ;
//K_SUBTIME : S U B T I M E ;
//K_SYSDATE : S Y S D A T E ;
//K_TIME_FORMAT : T I M E '_' F O R M A T ;
//K_TIME_TO_SEC : T I M E '_' T O '_' S E C ;
//K_TIMEDIFF : T I M E D I F F ;
//K_TIMESTAMPADD : T I M E S T A M P A D D ;
//K_TIMESTAMPDIFF : T I M E S T A M P D I F F ;
//K_TO_DAYS : T O '_' D A Y S ;
//K_TO_SECONDS : T O '_' S E C O N D S ;
//K_UNIX_TIMESTAMP: U N I X '_' T I M E S T A M P ;
K_UTC_DATE : U T C '_' D A T E ;
K_UTC_TIME : U T C '_' T I M E ;
K_UTC_TIMESTAMP : U T C '_' T I M E S T A M P ;
//K_WEEKDAY : W E E K D A Y ;
//K_WEEKOFYEAR : W E E K O F Y E A R ;
//K_YEARWEEK : Y E A R W E E K ;

//K_IFNULL : I F N U L L ;
//K_AES_ENCRYPT : A E S '_' E N C R Y P T ;
//K_AES_DECRYPT : A E S '_' D E C R Y P T ;
//K_DECODE : D E C O D E ;
//K_ENCODE : E N C O D E ;
//K_DES_DECRYPT : D E S '_' D E C R Y P T ;
//K_DES_ENCRYPT : D E S '_' E N C R Y P T ;
//K_ENCRYPT : E N C R Y P T ;
//K_MD5 : M D '5 ';
//K_OLD_PASSWORD : O L D '_' P A S S W O R D ;
K_PASSWORD : P A S S W O R D ;
//K_BENCHMARK : B E N C H M A R K ;
K_CHARSET : C H A R S E T ;
//K_COERCIBILITY : C O E R C I B I L I T Y ;
//K_COLLATION : C O L L A T I O N ;
//K_CONNECTION_ID : C O N E C T I O N '_' I D ;
K_CURRENT_USER : C U R R E N T '_' U S E R ;
K_SCHEMA : S C H E M A ;
K_USER : U S E R ;
//K_SESSION_USER : S E S S I O N '_' U S E R ;
//K_SYSTEM_USER : S Y S T E M '_' U S E R ;
//K_VERSION_SYM : V E R S I O N '_' S Y M ;
//K_FOUND_ROWS : F O U N D '_' R O W S ;
//K_LAST_INSERT_ID : L A S T '_' I N S E R T '_' I D ;
//K_GET_LOCK : G E T '_' L O C K ;
//K_RELEASE_LOCK : R E L E A S E '_' L O C K ;
//K_IS_FREE_LOCK : I S '_' F R E E '_' L O C K ;
//K_IS_USED_LOCK : I S '_' U S E D '_' L O C K ;
//K_MASTER_POS_WAIT : M A S T E R '_' P O S '_' W A I T ;
//K_INET_ATON : I N E T '_' A T O N ;
//K_INET_NTOA : I N E T '_' N T O A ;
//K_NAME_CONST : N A M E '_' C O N S T ;
//K_SLEEP : S L E E P ;
//K_UUID : U U I D ;
K_ALGORITHM : A L G O R I T H M;
//add GBase key word
K_ACCESSIBLE: A C C E S S I B L E  ;
K_ANALYZE: A N A L Y Z E  ;
K_ASENSITIVE: A S E N S I T I V E ;

K_BEFORE: B E F O R E ;
K_BEGIN: B E G I N ;
//K_BOOLEAN: B O O L E A N ;
K_BOTH: B O T H ;

K_CALL: C A L L  ;
K_CASCADE: C A S C A D E  ;
K_CHARACTER: C H A R A C T E R ;
K_CHECK: C H E C K ;
K_CLOSE : C L O S E ;
//K_CLUSTER: C L U S T E R ;
K_CONDITION: C O N D I T I O N ;
K_CONNECT: C O N N E C T ;
K_CONSTRAINT: C O N S T R A I N T ;
K_CONTINUE: C O N T I N U E ;
K_CURRENT_DATETIME: C U R R E N T '_ 'D A T E T I M E  ;
//K_CURRENT_ROW: C U R R E N T '_' R O W ;
K_CURSOR: C U R S O R ;

K_DATABASES: D A T A B A S E S ;
//K_DATACOPYMAP: D A T A C O P Y M A P ;
//K_DATADIR: D A T A D I R ;
//K_DATASTATE: D A T A S T A T E ;
K_DEALLOCATE : D E A L L O C A T E ;
K_DEC: D E C ;
K_DECLARE: D E C L A R E ;
K_DELAYED: D E L A Y E D ;
K_DENSE_RANK : D E N S E '_' R A N K ;
K_DESCRIBE: D E S C R I B E ;
K_DETERMINISTIC: D E T E R M I N I S T I C ;
K_DISTINCTROW: D I S T I N C T R O W  ;
K_DO : D O ;
K_DUAL: D U A L ;

K_EACH: E A C H ;
K_ELSEIF: E L S E I F ;
K_ENTRY: E N T R Y ;
//K_EXCHANGE: E X C H A N G E ;
K_EXECUTE : E X E C U T E ;
K_EXIT: E X I T ;
K_EXPLAIN: E X P L A I N ;
K_EXT_BAD_FILE: E X T '_' B A D '_' F I L E  ;
//K_EXT_DATA_FILE: E X T '_ 'D A T A '_' F I L E  ;
//K_EXT_ESCAPE_CHARACTER: E X T '_' E S C A P E '_ 'C H A R A C T E R ;
//K_EXT_FLD_DELIM: E X T '_' F L D '_' D E L I M ;
//K_EXT_LOG_FILE: E X T '_' L O G '_' F I L E ;
//K_EXT_STRING_QUALIFIER: E X T '_' S T R I N G '_' Q U A L I F I E R  ;
//K_EXT_TAB_OPT: E X T '_' T A B '_' O P T ;
//K_EXT_TRIM_RIGHT_SPACE: E X T '_' T R I M '_' R I G H T '_' S P A C E  ;

K_FETCH: F E T C H ;
//K_FIRST_ROWS: F I R S T '_' R O W S ;
K_FLOAT4: F L O A T '4'  ;
K_FLOAT8: F L O A T '8' ;
//K_FOLLOWING: F O L L O W I N G ;
K_FOR: F O R ;
K_FORCE: F O R C E ;
K_FOREIGN: F O R E I G N  ;
K_FOUND : F O U N D ;
K_FULL: F U L L  ;
K_FULLTEXT: F U L L T E X T  ;
K_FUNCTION : F U N C T I O N ;

//K_GBASE_ERRNO: G B A S E '_' E R R N O ;
K_GCLOCAL: G C L O C A L ;
K_GCLUSTER: G C L U S T E R ;
K_GCLUSTER_LOCAL: G C L U S T E R '_' L O C A L ;
//K_GCR: G C R ;
K_GET: G E T ;
K_GRANT: G R A N T ;
K_GROUPING: G R O U P I N G ;

K_HANDLER : H A N D L E R ;
K_HIGH_PRIORITY: H I G H '_' P R I O R I T Y ;

//K_INDEX_DATA_PATH: I N D E X '_' D A T A '_' P A T H  ;
K_INFILE: I N F I L E  ;
K_INITNODEDATAMAP: I N I T N O D E D A T A M A P  ;
K_INOUT: I N O U T ;
K_INSENSITIVE: I N S E N S I T I V E ;
K_INT1: I N T '1' ;
K_INT2: I N T '2' ;
K_INT3: I N T '3' ;
K_INT4: I N T '4' ;
K_INT8: I N T '8' ;
K_INTEGER: I N T E G E R  ;
K_ITERATE: I T E R A T E  ;

//K_KEEPS: K E E P S ;
K_KEYS: K E Y S  ;
K_KILL: K I L L ;

K_LAG : L A G  ;
K_LEAD  : L E A D ;
K_LEADING: L E A D I N G ;
K_LEAVE: L E A V E ;
K_LEVEL : L E V E L ;
K_LIMIT_STORAGE_SIZE: L I M I T '_' S T O R A G E '_' S I Z E ;
K_LINEAR: L I N E A R ;
K_LINK: L I N K ;
K_LOAD: L O A D ;
K_LOCALTIME: L O C A L T I M E ;
K_LOCALTIMESTAMP: L O C A L T I M E S T A M P ;
K_LOCK: L O C K ;
K_LONG: L O N G ;
K_LONGBLOB: L O N G B L O B ;
K_LONGTEXT: L O N G T E X T ;
K_LOOP: L O O P ;
K_LOW_PRIORITY: L O W '_' P R I O R I T Y ;

K_MASTER_SSL_VERIFY_SERVER_CERT: M A S T E R '_' S S L '_' V E R I F Y '_' S E R V E R '_' C E R T ;
K_MEDIUMBLOB: M E D I U M B L O B  ;
K_MEDIUMINT: M E D I U M I N T ;
K_MEDIUMTEXT: M E D I U M T E X T ;
K_MIDDLEINT: M I D D L E I N T ;
K_MODIFIES: M O D I F I E S ;
//K_MOVE: M O V E ;

K_NOCACHE: N O C A C H E ;
//K_NODE: N O D E ;
K_NOLOCK: N O L O C K ;
K_NO_WRITE_TO_BINLOG: N O '_' W R I T E '_' T O '_' B I N L O G ;
K_NUMERIC: N U M E R I C ;

K_OPEN :  O P E N ;
K_OPTIMIZE: O P T I M I Z E ;
K_OPTION: O P T I O N ;
K_OPTIONALLY: O P T I O N A L L Y ;
K_ORDERED: O R D E R E D ;
K_OUT: O U T ;
K_OVER: O V E R ;

//K_PARALLEL: P A R A L L E L ;
K_PARTITION : P A R T I T I O N ;
//K_PRECEDING: P R E C E D I N G ;
K_PRECISION: P R E C I S I O N ;
K_PREPARE : P R E P A R E ;
K_PRIMARY: P R I M A R Y ;
K_PRIOR : P R I O R ;
K_PROCEDURE: P R O C E D U R E ;
//K_PUBLIC: P U B L I C ;
K_PURGE: P U R G E ;

K_RANGE: R A N G E ;
K_RANK: R A N K  ;
//K_RCMAN: R C M A N ;
K_READ: R E A D ;
K_READS: R E A D S ;
K_READ_WRITE: R E A D '_' W R I T E ;
K_REAL: R E A L ;
K_REF : R E F ;
K_REFERENCES: R E F E R E N C E S ;
K_REFRESH: R E F R E S H  ;
K_REFRESHNODEDATAMAP: R E F R E S H N O D E D A T A M A P ;
K_RELEASE: R E L E A S E ;
//K_REMOTE: R E M O T E ;
K_REQUIRE: R E Q U I R E ;
K_RESTRICT: R E S T R I C T ;
K_RETURN: R E T U R N ;
K_RETURNS : R E T U R N S ;
K_REVOKE: R E V O K E ;
K_RLIKE: R L I K E ;
K_ROW_NUMBER : R O W '_' N U M B E R  ;

//K_SAFEGROUPS: S A F E G R O U P S ;
K_SCHEMAS: S C H E M A S ;
K_SCN_NUMBER: S C N '_' N U M B E R ;
K_SELF: S E L F ;
K_SENSITIVE: S E N S I T I V E ;
K_SEPARATOR: S E P A R A T O R ;
K_SETS: S E T S ;
K_SIBLINGS : S I B L I N G S ;
K_SMALLINT: S M A L L I N T ;
K_SPATIAL: S P A T I A L ;
K_SPECIFIC: S P E C I F I C ;
K_SQL: S Q L ;
K_SQLEXCEPTION: S Q L E X C E P T I O N ;
K_SQLSTATE: S Q L S T A T E ;
K_SQLWARNING: S Q L W A R N I N G ;
K_SQL_BIG_RESULT: S Q L '_' B I G '_' R E S U L T ;
K_SQL_CALC_FOUND_ROWS: S Q L '_' C A L C '_' F O U N D '_' R O W S ;
K_SQL_SMALL_RESULT: S Q L '_' S M A L L '_' R E S U L T ;
K_SSL: S S L ;
K_START : S T A R T ;
K_STATUS : S T A T U S ;
K_STRAIGHT_JOIN: S T R A I G H T '_' J O I N ;
//K_SYSTEM: S Y S T E M ;

//K_TABLEID: T A B L E I D ;
//K_TABLE_FIELDS: T A B L E '_' F I E L D S ;
K_TARGET: T A R G E T ;
//K_TID: T I D ;
K_TINYBLOB: T I N Y B L O B ;
K_TINYTEXT: T I N Y T E X T ;
//K_TO_DATE: T O '_' D A T E ;
K_TRAILING: T R A I L I N G ;
//K_TRANSACTION_LOG: T R A N S A C T I O N '_' L O G ;
K_TRIGGER: T R I G G E R ;

//K_UNBOUNDED: U N B O U N D E D ;
K_UNDO: U N D O ;
K_UNIQUE: U N I Q U E ;
K_UNLOCK: U N L O C K ;
K_UNSIGNED: U N S I G N E D ;
K_UNTIL : U N T I L ;
//K_URI: U R I ;
K_USAGE: U S A G E ;
K_USE: U S E ;
//K_USE_HASH: U S E '_' H A S H ;
K_UTC_DATETIME: U T C '_' D A T E T I M E ;

//K_VALIDATION: V A L I D A T I O N ;
K_VALUE : V A L U E ;
K_VARBINARY: V A R B I N A R Y ;
K_VARCHARACTER: V A R C H A R A C T E R ;
K_VARYING: V A R Y I N G ;

K_WHILE: W H I L E ;
//K_WITHOUT: W I T H O U T ;
K_WRITE: W R I T E ;


//data type key word
K_ZEROFILL: Z E R O F I L L ;
K_TINYINT	:	T I N Y I N T ;
K_INT	:	I N T ;
K_BIGINT	:	B I G I N T ;
K_FLOAT	:	F L O A T ;
K_DOUBLE	:	D O U B L E ;
K_DECIMAL	:	D E C I M A L ;
K_CHAR	:	C H A R ;
K_VARCHAR	:	V A R C H A R ;
K_TEXT	:	T E X T ;
K_BLOB	:	B L O B ;
K_DATE	:	D A T E ;
K_DATETIME	:	D A T E T I M E ;
K_TIME	:	T I M E ;
K_TIMESTAMP	:	T I M E S T A M P ;

K_CONNECTION : C O N N E C T I O N ;
K_QUERY: Q U E R Y ;
K_SESSION: S E S S I O N ;
K_IDENTIFIED: I D E N T I F I E D ;
K_ERRORS: E R R O R S ;
K_GRANTS: G R A N T S ;
K_PROCESSLIST: P R O C E S S L I S T ;
K_DISTRIBUTION: D I S T R I B U T I O N ;
K_TABLES: T A B L E S ;
K_VARIABLES: V A R I A B L E S ;
K_WARNINGS:  W A R N I N G S ;
K_PRIORITIES: P R I O R I T I E S ;
K_PRIVILEGES: P R I V I L E G E S ;
K_ROUTINE: R O U T I N E ;
K_FILE: F I L E ;
K_PROCESS: P R O C E S S ;
K_RELOAD: R E L O A D ;
K_SHUTDOWN: S H U T D O W N ;
K_SUPPER: S U P P E R ;
K_TASK_PRIORITY: T A S K '_' P R I O R I T Y ;

IDENTIFIER
 : '"' (~'"' | '""')* '"'
 | '`' (~'`' | '``')* '`'
 | '[' ~']'* ']'
 | [a-zA-Z_] [a-zA-Z_0-9]* // TODO check: needs more chars in set
 ;

DEFINER:
	IDENTIFIER'@'IDENTIFIER
;


NUMERIC_LITERAL
 : DIGIT+ ( '.' DIGIT* )? ( E [-+]? DIGIT+ )?
 | '.' DIGIT+ ( E [-+]? DIGIT+ )?
 ;

NUM0X:
	[0] [x] [0-9a-f]+
;
BIND_PARAMETER
 : '?' DIGIT*
 | [:@$] IDENTIFIER
 ;
//2015-06-26 a='\'char\'' 支持对应 modify by tzm
STRING_LITERAL
// : '\'' ( ~'\'' | '\'\'' |'\\\'' )* '\''
:'\''(ESC_SEQ | ~('\\'|'\''))* '\''
 ;
 //20151009 应对select concat('a','\\','b');不能解析的问题
 ESC_SEQ:
 '\\'('b'|'t'|'n'|'f'|'r'|'"'|'\''|'\\')
 ;
//2015-06-26 a='\'char\'' 支持对应 modify by tzm

BLOB_LITERAL
 : X STRING_LITERAL
 ;

SINGLE_LINE_COMMENT
 : '--' ~[\r\n]* -> channel(HIDDEN)
 ;

MULTILINE_COMMENT
 : '/*' .*? ( '*/' | EOF ) -> channel(HIDDEN)
 ;

SPACES
 : [ \u000B\t\r\n] -> channel(HIDDEN)
 ;

UNEXPECTED_CHAR
 : .
 ;

 //中文
 ZW:
	[\u3000-\u9FFF|0-9]+
;

fragment DIGIT : [0-9];

fragment A : [aA];
fragment B : [bB];
fragment C : [cC];
fragment D : [dD];
fragment E : [eE];
fragment F : [fF];
fragment G : [gG];
fragment H : [hH];
fragment I : [iI];
fragment J : [jJ];
fragment K : [kK];
fragment L : [lL];
fragment M : [mM];
fragment N : [nN];
fragment O : [oO];
fragment P : [pP];
fragment Q : [qQ];
fragment R : [rR];
fragment S : [sS];
fragment T : [tT];
fragment U : [uU];
fragment V : [vV];
fragment W : [wW];
fragment X : [xX];
fragment Y : [yY];
fragment Z : [zZ];

fragment USER_VAR_SUBFIX1:	(  '`' (~'`' )+ '`'  ) ;
fragment USER_VAR_SUBFIX2:	( '\'' (~'\'')+ '\'' ) ;
fragment USER_VAR_SUBFIX3:	( '"' (~'"')+ '"' ) ;
fragment USER_VAR_SUBFIX4:	( 'A'..'Z' | 'a'..'z' | '_' | '$' | '0'..'9' | DOT )+ ;
