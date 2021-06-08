import warnings
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

    @property
    def alias(self): return self._alias

    @property
    def ref_name(self):
        if self._alias:
            return self._alias
        elif self._source:
            assert len(self._source) == 1, 'unbelievable! without alias meanwhile is expr?'
            if len(self._source) > 0:
                return self._source[0]['name']
        else:
            warnings.warn("wonderful!? surrender!")

    def get_source(self, table):
        res = []
        for s in self._source:
            res.extend(table.find_source_of_name(ns=s['namespace'], name=s['name']))
        return res


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

    @property
    def ref_name(self):
        if self.alias:
            return self.alias.lower()
        elif self.name:
            return self.name.lower()

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

    def find_source_of_name(self, ns, name=None, o=None):
        """
        return source of name
        :param ns:
        :param name:
        :return:
        """
        assert name is not None or o is not None, 'at least have name or order'
        if self.parent:
            return self._query_find_source_of_name(ns, name, o)
        else:
            return self._table_find_source_of_name(ns, name, o)

    def _table_find_source_of_name(self, ns, name=None, o=None):
        print(ns, name, o)
        if ns == self.ref_name:
            return [dict(db=self.dbname, table=self.name, col=name)]
        else:
            raise KeyError(f"{ns}, {name}, {o}")

    def _query_find_source_of_name(self, ns, name=None, o=None) -> list:

        if ns is None:
            ns = self.dbname
        if ns != self.ref_name:
            warnings.warn(f"should't recurse into deep subquery!!!, {self.ref_name}")
            for sub_table in self.parent:  # type: Table
                if res := sub_table.find_source_of_name(ns, name):
                    return res
        field = None
        if name is None:
            field = self.fields[o]
        else:
            for field in self.fields:  # type:Field
                if field.ref_name == name.lower():
                    break
        assert isinstance(field, Field)
        sub_table_set = TableSet(self.parent)
        res = field.get_source(sub_table_set)
        return res


class TableSet:
    def __init__(self, tables):
        self.tables = tables

    def find_source_of_name(self, ns, name=None, o=None):
        for table in self.tables:
            if ns == table.ref_name:
                if res := table.find_source_of_name(ns, name, o):
                    return res
        return None

class Deduce(object):

    def __init__(self, graphdb):
        self.graphdb = graphdb
        self.session = self.graphdb.driver.session()

    def run(self, query):
        # print(query)
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
            pprint.pprint(context)

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

    def _action_update_tables(self, record_id) -> TableSet:
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
        return TableSet(tables_list)

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
        print('_deal_select')
        form_tables_node = self.run(f"""
            MATCH (select:ACTION)-[:from]->(tables:TABLES)-[:Children]->(table:TABLE)
            where id(select) = {record_id}
            return table, id(table) as id
        """)
        table_list = []
        for table_node in form_tables_node:
            table_data = table_node.data()
            table_id = table_data['id']
            res = self._table_reduce(table_node, table_id, table_data, None)
            table_list.append(res)
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
        print(table_list)
        table = Table(fields=cols, parent=table_list)
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
            if node_res := e_data['node']:
                res.append(node_res)

        # print(res)
        return res

    def action_update(self, record, record_id, record_data, context):
        table_set = self._action_update_tables(record_id)
        LOGGER.info(f"action_update: {context} ------- {table_set}")

        write_fields = self.run(f"""
            MATCH (update:ACTION)
                -[:Children]->(:WRITE)
                -[:Children]->(field:FIELD)
            MATCH p=(field)<-[:effect]-(upfield:FIELD)
            where id(update) = {record_id}
            return p, id(field) as fid, id(upfield) as ufid
        """)
        for write_rule in write_fields:
            write_data = write_rule.data()
            modify_field_data, _, source_field_data = write_data['p']

            modify_field = table_set.find_source_of_name(modify_field_data['ref_namespace'], modify_field_data['ref_name'])
            source_field = table_set.find_source_of_name(source_field_data['ref_namespace'], source_field_data['ref_name'])

            if modify_field and source_field:
                source_field = [(k['db'], k['table'], k['col']) for k in source_field]
                ref_key = "{db}.{table}.{col}".format(**(modify_field[0]))
                if ref_key not in context['update']:
                    context['update'][ref_key] = set(source_field)
                else:
                    context['update'][ref_key].update(source_field)

            else:
                warnings.warn(f"search failed {str(write_data['p'])}", UserWarning)


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
