mysqlsh --js admin@127.0.0.1

JS> util.importTable('bank-full.csv',
             {table: 'bank_marketing', skipRows: 1,
             fieldsTerminatedBy: ';', dialect:  'csv-unix'});

