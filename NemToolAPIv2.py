import psycopg2

class NemToolAPI:
    def __init__(self, host, port, database, user, password):
        self.connection = psycopg2.connect(
            host=host,
            port=port,
            database=database,
            user=user,
            password=password
        )
        self.cursor = self.connection.cursor()

    def create_table(self, table_name, columns):
        query = f"CREATE TABLE {table_name} ({', '.join(columns)})"
        self.cursor.execute(query)
        self.connection.commit()

    def insert_data(self, table_name, data):
        columns = ', '.join(data.keys())
        placeholders = ', '.join(['%s'] * len(data))
        query = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders})"
        self.cursor.execute(query, list(data.values()))
        self.connection.commit()

    def select_data(self, table_name, condition=None):
        query = f"SELECT * FROM {table_name}"
        if condition:
            query += f" WHERE {condition}"
        self.cursor.execute(query)
        return self.cursor.fetchall()

    def add_column(self, table_name, column_name, column_type):
        query = f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_type}"
        self.cursor.execute(query)
        self.connection.commit()

    def close_connection(self):
        self.cursor.close()
        self.connection.close()
