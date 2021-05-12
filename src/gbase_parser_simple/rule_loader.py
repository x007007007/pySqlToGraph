
import glob
import os


class Rule:
    playbook = [
        "identify/dotIdentify",
        "identify/dotIdentifyEnd",
        "identify/identify",
        "QualifiedIdentifier",
        "table",
    ]
    def __init__(self, db=None):
        self._db = db
        self._rule_path = os.path.join(os.path.dirname(__file__), 'neo4j_rule')

    def load(self):
        for book in self.playbook:
            with open(os.path.join(self._rule_path, f"{book}.cypher")) as fp:
                for query in fp.read().split(";"):
                    print(query.strip())


if __name__ == '__main__':
    Rule().load()