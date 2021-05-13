from neo4j import GraphDatabase
from gbase_parser_simple.test_help import read_sql, delimiter_parse
import chardet
from rule_loader import Rule
from antlr4 import ParseTreeWalker

from gbase_parser_simple.pygram.GBaseParser import GBaseParser
from gbase_parser_simple.pygram.GBaseParserListener import GBaseParserListener as SpecSQLListener


class DatabaseExample:

    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        self.driver.close()

    def clean(self):
        with self.driver.session() as session:
            greeting = session.write_transaction(self._clean)
            return greeting

    def exec(self, cypher):
        with self.driver.session() as session:
            session.write_transaction(self._exec, cypher)

    @staticmethod
    def _exec(tx, cypher):
        print(cypher)
        tx.run(cypher)

    def create_end_node(self, name, text):
        with self.driver.session() as session:
            greeting = session.write_transaction(self._create_end_node, name, text)
            print(greeting)
            return greeting

    def create_node(self, name, children):
        with self.driver.session() as session:
            greeting = session.write_transaction(self._create_node, name, children)
            print(greeting)
            return greeting

    @staticmethod
    def _clean(tx):
        tx.run("""match (n) detach delete n""")

    @staticmethod
    def _create_end_node(tx, message, text):
        result = tx.run("""CREATE (a:EndNode) 
                        SET a.message = $message, a.text = $text
                        RETURN id(a)""", message=message, text=text)
        return result.single()[0]

    @staticmethod
    def _create_node(tx, message, children_id):
        result = tx.run("CREATE (a:Node) "
                        "SET a.message = $message "
                        "RETURN id(a)", message=message)
        root_id = result.single()[0]
        print(root_id)
        for order, child in enumerate(children_id):
            relationship = tx.run("""
                MATCH
                  (a),
                  (b)
                WHERE id(a) = $a_id AND id(b) = $b_id
                CREATE (a)-[r:Children {order: $order}]->(b)
                RETURN id(r)
            """, a_id=root_id, b_id=child, order=order)
            print("add relationship")
        return root_id


class CustomMySQLParserListener(SpecSQLListener):

    # def enterEveryRule(self, ctx:ParserRuleContext):
    #     print("enterEveryRule")
    #     print(ctx.getText())
    #     print(ctx.getPayload())


    def enterRoot(self, ctx:GBaseParser.RootContext):

        def rec(node):
            if hasattr(node, 'children') and node.children:
                children_ids = []
                for child in node.children:
                    children_ids.append(rec(child))
                nid = db.create_node(node.__class__.__name__, children_ids)
            else:
                nid = db.create_end_node(node.__class__.__name__, node.getText())
            return nid
        rec(ctx)
        db.close()


def generate_tree(context, db):
    parser = read_sql(context)
    tree = parser.root()
    printer = CustomMySQLParserListener()
    printer.db = db
    walker = ParseTreeWalker()
    walker.walk(printer, tree)


def analysis_tree(db):
    rule = Rule(db)
    rule.run()


if __name__ == "__main__":

    import glob, os

    db = DatabaseExample("neo4j://localhost:7687", "neo4j", "123456")
    db.clean()

    for pth in glob.glob("/home/xxc-dev-machine/workspace/bocwm/pySqlToGraph/test/gbase_sql/test_sql/*.sql"):
        with open(pth, "rb") as fp:
            result = chardet.detect(fp.read())
        with open(pth, encoding=result['encoding']) as fp:
            for context in delimiter_parse(fp.read()):
                if context:
                    print("===========================start===============================")
                    print(context)
                    print("===========================end===============================")
                    generate_tree(context, db)
        # break
    analysis_tree(db)
