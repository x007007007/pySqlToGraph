
from neo4j.exceptions import CypherSyntaxError
import os


class Rule:
    playbook = [
        "mark_root",
        "identify/identify",
        "identify/dotIdentify",
        "identify/dotIdentifyEnd",
        "identify/QualifiedIdentifier",
        "identify/table",
        "identify/select",
        "identify/ColumnRef",
        "frag/table_link",
        "frag/table",
        "frag/expr_link",
        "frag/subquery_table",
        "frag/tables",
        "call/call",
        "select/clean",
        "select/01_shortcut",  # QueryExpressionParensContext loop  add link_query
        "select/out",
        "select/in",
        "select/join_in",
        "select/connect_select",
        "select/subquery_link",
        "create_table/table",
        "merge/before_update",
        "update/update",
        "insert/insert_00_table",
        "insert/insert_00_merge",
        "insert/insert_01_fields",
        "insert/insert_10_insertQuery",
        "insert/insert_10_FromConstructor",
        "insert/insert_10_updateList",
        "merge/clean",
        "merge/merge",
        "proc/proc_line",
        "proc/proc_argc",
        "proc/proc_name",
        "proc/proc_link",
        "root_link"
    ]

    def __init__(self, db=None):
        self._db = db
        self._rule_path = os.path.join(os.path.dirname(__file__), 'neo4j_rule')

    def run(self):
        for book in self.playbook:
            with open(os.path.join(self._rule_path, f"{book}.cypher")) as fp:
                print(f"++++++++++{book}+++++++++")
                for query in fp.read().split(";"):
                    query = query.strip()
                    if query:
                        try:
                            self._db.exec(query)
                        except CypherSyntaxError as e:
                            raise SyntaxError(f"{book}: {e.message}")

