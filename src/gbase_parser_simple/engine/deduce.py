from functools import wraps


def context_generete(func):
    @wraps(func)
    def new(self, context=None, *args, **kwargs):
        if context is None:
            kwargs["context"] = dict(
                call_list=[],
                update={},
                insert={},
                delete={}
            )
        else:
            kwargs["context"] = context
        return func(*args, **kwargs)
    return new


class Deduce(object):

    def __init__(self, graphdb):
        self.graphdb = graphdb
        self.session = self.graphdb.driver.session()

    def root(self):
        result = self.session.run("MATCH (root:Root)-[:Deduce]->(:ACTIONS)-[:Children]->(action:ACTION) return action, id(action) as id")
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
            print(context)

    def action_create_procedure(self, record, record_id, record_data):
        # argument
        self.session.run("MATCH (procedure:ACTION)-[:Children]->(argv:Argument) return argv, id(argv) as id")

        # logic
        context = dict(
            type='procedure',
            fun_name=record_data['action']['name'],
            call_list=set(),
            update={},
            insert={},
            delete={}
        )
        res = self.session.run(f"""
                MATCH (procedure:ACTION)
                    -[:Children]->(:ACTIONS)-[:Children]->(action:ACTION)
                where id(procedure) = {record_id}
                return action, id(action) as id
            """)
        for sub_rule in res:
            print(sub_rule)
            sub_rule_data = sub_rule.data()
            sub_rule_id = sub_rule_data['id']
            sub_rule_type = sub_rule_data['action']['type']
            getattr(self, f"action_{sub_rule_type}")(sub_rule, sub_rule_id, sub_rule_data, context)
        return context

    def action_insert(self, record, record_id, record_data, context):
        print(f"{self}, {record}, {record_id}, {record_data}, {context}")


    def action_select(self, record, record_id, record_data, context):
        print(record)

    def _action_update_tables(self, record_id):
        tables_info_res = self.session.run(f"""
            MATCH (update:ACTION)
                -[:Children]->(:TABLES)
                -[:Children]->(table:TABLE)
            where id(update) = {record_id}
            return table, id(table) as id
        """)
        tables_list = []
        update_context = dict(
            fields=[]
        )
        for table in tables_info_res:
            table_data = table.data()
            tables_list.append(table_data['table'])
        return  tables_list

    def action_update(self, record, record_id, record_data, context):
        tables_list = self._action_update_tables(record_id)
        print(tables_list)

        update_fields_result = self.session.run(f"""
            MATCH (update:ACTION)
                -[:Children]->(:TABLES)
                -[:Children]->(table:TABLE)
            where id(update) = {record_id}
            return table, id(table) as id
        """)

        self.session.run(f"""
            MATCH (update:ACTION)
                -[:Children]->(:WRITE)
                -[:Children]->(field:FIELD)
            where id(update) = {record_id}
        """)

    def action_call(self, record, record_id, record_data, context):
        name = record_data['action'].get('name')
        namespace = record_data['action'].get('namespace')
        context["call_list"].add((namespace, name))