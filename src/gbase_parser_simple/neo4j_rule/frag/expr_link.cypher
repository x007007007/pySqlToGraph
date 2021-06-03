MATCH (ExprIsContext:Node)-[:Children]->(sub:Node)
WHERE (
  ExprIsContext.message = 'ExprIsContext'
) AND (
    sub.message = 'PrimaryExprPredicateContext'
  )
MERGE (ExprIsContext)-[:expr_link]->(sub)
;

MATCH (BitExprContext:Node)
  -[:Children]->(sub:Node)
WHERE (BitExprContext.message = "BitExprContext"
  or
    BitExprContext.message = "DuplicateAsQueryExpressionContext")
  and sub.message in  [
    "BitExprContext",
    "SimpleExprVariableContext",
    "SimpleExprColumnRefContext",
    "SimpleExprRuntimeFunctionContext",
    "SimpleExprFunctionContext",
    "SimpleExprCollateContext",
    "SimpleExprLiteralContext",
    "SimpleExprParamMarkerContext",
    "SimpleExprSumContext",
    "SimpleExprGroupingOperatioContext",
    "SimpleExprWindowingFunctioContext",
    "SimpleExprConcatContext",
    "SimpleExprUnaryContext",
    "SimpleExprNotContext",
    "SimpleExprListContext",
    "SimpleExprSubQueryContext",
    "SimpleExprOdbcContext",
    "SimpleExprMatchContext",
    "SimpleExprBinaryContext",
    "SimpleExprCastContext",
    "SimpleExprCaseContext",
    "SimpleExprConvertContext",
    "SimpleExprConvertUsingContext",
    "SimpleExprDefaultContext",
    "SimpleExprValuesContext",
    "SimpleExprIntervalContext"
]
MERGE (BitExprContext)-[:expr_link]->(sub)
;

MATCH p=(PrimaryExprPredicateContext:Node)
        -[:Children]->(PredicateContext:Node)
        -[:Children]->(BitExprContext:Node)
WHERE PrimaryExprPredicateContext.message = 'PrimaryExprPredicateContext'
  and PredicateContext.message = 'PredicateContext'
  and BitExprContext.message = 'BitExprContext'
MERGE (PrimaryExprPredicateContext)-[:expr_link]->(BitExprContext)
;
