
from neo4j.exceptions import CypherSyntaxError
import os


class Rule:
    playbook = [
        "identify/dotIdentify",
        "identify/dotIdentifyEnd",
        "identify/identify",
        "identify/QualifiedIdentifier",
        "identify/table",
        "identify/select",
        "gen/out",
    ]
    def __init__(self, db=None):
        self._db = db
        self._rule_path = os.path.join(os.path.dirname(__file__), 'neo4j_rule')

    def run(self):
        for book in self.playbook:
            with open(os.path.join(self._rule_path, f"{book}.cypher")) as fp:
                for query in fp.read().split(";"):
                    query = query.strip()
                    if query:
                        try:
                            self._db.exec(query)
                        except CypherSyntaxError as e:
                            raise SyntaxError(f"{book}: {e.message}")
