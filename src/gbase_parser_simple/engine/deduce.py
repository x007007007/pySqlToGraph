from functools import wraps
import logging
import pprint
from gbase_parser_simple.get_window_size import get_terminal_size


LOGGER = logging.getLogger(__name__)


class Field:
    def __init__(self, order, alias, source):
        self._order = order
        self._alias = alias
        self._source = source

    def __repr__(self):
        if self._alias:
            s_name = self._alias
        else:
            s_name = self._source
        return f"<F:{s_name}, {self.order}>"

    def __lt__(self, other):
        assert isinstance(other, Field)
        return self.order < other.order

    def __gt__(self, other):
        assert isinstance(other, Field)
        return self.order > other.order

    def __eq__(self, other):
        assert isinstance(other, Field)
        return self.order == other.order

    @property
    def order(self):
        return self._order


class Table:
    def __init__(self, fields, dbname=None, name=None, alias=None, parent=None):
        self.dbname = dbname
        self.name = name
        self.alias = alias
        self.fields = fields
        self.parent = parent
        self.graph_id = None

    @property
    def short_name(self):
        if self.parent:
            return str(self.graph_id)
        else:
            return f"[T{self.dbname}.{self.name}]"

    def __repr__(self):
        cols, lines = get_terminal_size()
        filed_str = ' | '.join((repr(f) for f in self.fields))
        head = '-' * max((len(filed_str) + 15), cols)
        if self.parent:
            table_name = f"subquery table, from {', '.join(i.short_name for i in self.parent)}"
        else:
            table_name = f"{self.dbname}.{self.name}"
        tail = head
        head = list(head)
        st = len(head)//2-len(table_name)//2
        ed = len(head)//2+len(table_name)//2 + 1
        head[st:ed] = list(table_name)
        head = "".join(head)
        return f"{head}\n   {filed_str}  \n{tail}"


class Deduce(object):

    def __init__(self, graphdb):
        self.graphdb = graphdb
        self.session = self.graphdb.driver.session()

    def run(self, query):
        print(query)
        return self.session.run(query)

    def root(self):
        result = self.run("MATCH (root:Root)-[:Deduce]->(:ACTIONS)-[:Children]->(action:ACTION) return action, id(action) as id")
        for record in result:
            record_data = record.data()
            type_name = record_data['action'].get('type')
            record_id = record.data('id')['id']
            context = {
                'create_procduce': self.action_create_procedure,
            }.get(
                type_name,
                getattr(self, f"action_{type_name}", None)
            )(record, record_id, record_data)
            LOGGER.info(context)

    def action_create_procedure(self, record, record_id, record_data):
        # argument
        self.run("MATCH (procedure:ACTION)-[:Children]->(argv:Argument) return argv, id(argv) as id")

        # logic
        context = dict(
            type='procedure',
            fun_name=record_data['action']['name'],
            call_list=set(),
            update={},
            insert={},
            delete={}
        )
        res = self.run(f"""
                MATCH (procedure:ACTION)
                    -[:Children]->(:ACTIONS)-[:Children]->(action:ACTION)
                where id(procedure) = {record_id}
                return action, id(action) as id
            """)
        for sub_rule in res:
            LOGGER.info(sub_rule)
            sub_rule_data = sub_rule.data()
            sub_rule_id = sub_rule_data['id']
            sub_rule_type = sub_rule_data['action']['type']
            getattr(self, f"action_{sub_rule_type}")(sub_rule, sub_rule_id, sub_rule_data, context)
        return context

    def action_insert(self, record, record_id, record_data, context):
        LOGGER.info(f"action_insert: {self}, {record}, {record_id}, {record_data}, {context}")

    def action_select(self, record, record_id, record_data, context):
        LOGGER.info("action_select")

    def _action_update_tables(self, record_id):
        tables_info_res = self.run(f"""
            MATCH (update:ACTION)
                -[:Children]->(:TABLES)
                -[:Children]->(table:TABLE)
            where id(update) = {record_id}
            return table, id(table) as id
        """)
        tables_list = []
        for table in tables_info_res:
            table_data = table.data()
            table = self._table_reduce(table, table_data['id'], table_data, None)  # type:Table
            tables_list.append(table)
        return tables_list

    def _table_reduce(self, record, record_id, record_data, context) -> Table:
        if record_data['table'].get('type') == 'subquery':
            # analysis select
            select_node = self.run(f"""
                MATCH (table:TABLE)-[:subquery]->(action:ACTION)
                where id(table) = {record_id}
                return action, id(action) as id
            """)
            select_data = select_node.data()
            assert len(select_data) == 1, select_data
            print(select_data[0]['action'])
            select_id = select_data[0]['id']
            table = self._deal_select(select_node, select_id, select_data, None)  # type: Table
            table.alias = record_data['table'].get('alias_name')
            return table
        elif record_data['table']['type'] == 'ref':
            table = Table(
                dbname=record_data['table']['ref_namespace'],
                name=record_data['table']['ref_name'],
                alias=record_data['table'].get('alias_name'),
                fields=[]
            )
            return table
        else:
            raise TypeError(record_data['table']['type'])

    def _deal_select(self, record, record_id, record_data, context) -> Table:
        form_tables_node = self.run(f"""
            MATCH (select:ACTION)-[:from]->(tables:TABLES)-[:Children]->(table:TABLE)
            where id(select) = {record_id}
            return table, id(table) as id
        """)
        table_tree = []
        for table_node in form_tables_node:
            table_data = table_node.data()
            table_id = table_data['id']
            res = self._table_reduce(table_node, table_id, table_data, None)
            table_tree.append(res)
        # pprint.pprint(table_tree)

        out_cols_node = self.run(f"""
            MATCH (select:ACTION)-[:Children]->(:OUTS)-[:Children]->(out:OUT)
            where id(select) = {record_id}
            return out, id(out) as id
        """)
        cols = []
        for out_node in out_cols_node:
            out_data = out_node.data()
            out_id = out_data['id']
            effect_nodes = self._out_analysis(out_node, out_id, out_data, None)
            field = Field(out_data['out']['order'], out_data['out'].get('name'), [dict(
                name=i['name'],
                namespace=i['namespace']
            ) for i in effect_nodes])
            field.out_id = out_id
            cols.append(field)
        cols.sort()
        table = Table(fields=cols, parent=table_tree)
        table.graph_id = record_id
        # print(table)
        return table

    def _out_analysis(self, record, record_id, record_data, context):
        effect_nodes = self.run(f"""
            MATCH (out:OUT)<-[:Effect]-(node:Node)
            where id(out) = {record_id}
            return node, id(node) as id
        """)
        res = []
        for e_node in effect_nodes:
            e_data = e_node.data()
            e_id = e_data['id']
            res.append(e_data['node'])
        # print(res)
        return res

    def action_update(self, record, record_id, record_data, context):
        tables_list = self._action_update_tables(record_id)
        LOGGER.info(f"action_update: {context} ------- {tables_list}")

        update_fields_result = self.run(f"""
            MATCH (update:ACTION)
                -[:Children]->(:TABLES)
                -[:Children]->(table:TABLE)
            where id(update) = {record_id}
            return table, id(table) as id
        """)

        # self.run(f"""
        #     MATCH (update:ACTION)
        #         -[:Children]->(:WRITE)
        #         -[:Children]->(field:FIELD)
        #     where id(update) = {record_id}
        # """)

    def action_call(self, record, record_id, record_data, context):
        name = record_data['action'].get('name')
        namespace = record_data['action'].get('namespace')
        context["call_list"].add((namespace, name))
