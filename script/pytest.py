import mysqlx


def test():
    mySession = mysqlx.get_session( {
        'host': '10.0.20.97', 'port': 33060,
        'user': 'admin', 'password': 'Welcome#1' } )

    print('Available schemas in this session:\n')

    schemaList = mySession.get_schemas()
    for schema in schemaList:
        print('%s\n' % schema)

    myDb = mySession.get_schema('airportdb')
    myTable = myDb.get_table('airline')
    myDat = myTable.select().execute()

    print(myDat.fetch_all())

    myDat = mySession.sql("show status").execute()
    print(myDat.fetch_one())

    mySession.sql("SET @my_var = ?").bind(10).execute()
    myDat = mySession.sql("SELECT @my_var").execute()
    print(myDat.fetch_one())

    myDat = mySession.sql("select * from airportdb.airline").execute()
    print(myDat.fetch_one())

    mySession.close()

if __name__ == "__main__":
    test()
