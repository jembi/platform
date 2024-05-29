const { Pool } = require('pg');

const user = process.env.POSTGRES_USER || 'postgres'
const host = process.env.POSTGRES_SERVICE || 'postgres-1'
const database = process.env.POSTGRES_DATABASE || 'jempi'
const password = process.env.POSTGRES_PASSWORD || 'instant101'
const port = process.env.POSTGRES_PORT || 5432
const newDb = process.env.NEW_DATABASE_NAME || 'jempi'
const newUser = process.env.NEW_DATABASE_USER || 'keycloak'
const newUserPassword = process.env.NEW_DATABASE_PASSWORD || 'instant101'

const pool = new Pool({
  user,
  host,
  database,
  password,
  port
});

const tableQueries = [
  `CREATE TABLE IF NOT EXISTS Notification_Type
  (
      Id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
      Type VARCHAR(50)
  );`,
  `CREATE TABLE IF NOT EXISTS Action_Type
  (
      Id UUID DEFAULT gen_random_uuid() PRIMARY KEY UNIQUE,
      Type VARCHAR(50)
  );,
  `,
  `CREATE TABLE IF NOT EXISTS Notification_State
  (
      Id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      State VARCHAR(50)
  );`,
  `CREATE TABLE IF NOT EXISTS Notification
  (
      Id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
      Type VARCHAR(50),
      Created date,
      Reviewd_By uuid,
      Reviewed_At timestamp without time zone,
      State VARCHAR(50),
      Patient_Id VARCHAR(50),
      Names VARCHAR(100),
      Golden_Id VARCHAR(50),
      Score Numeric
  );`,
  `CREATE TABLE IF NOT EXISTS Action
  (
      Id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
      Notification_Id UUID,
      Action_Type_Id UUID,
      Date date,
      CONSTRAINT FK_Notification
        FOREIGN KEY(Notification_Id) 
        REFERENCES Notification(Id),
      CONSTRAINT FK_Action_Type
        FOREIGN KEY(Action_Type_Id) 
        REFERENCES Action_Type(Id)
  );`,
  `CREATE TABLE IF NOT EXISTS Match
  (
      Notification_Id UUID,
      Score Numeric,
      Golden_Id VARCHAR(50),
      CONSTRAINT FK_Notification
        FOREIGN KEY(Notification_Id) 
        REFERENCES Notification(Id)
  );`,
  `CREATE TABLE IF NOT EXISTS candidates
  (
      Notification_Id UUID,
      Score Numeric,
      Golden_Id VARCHAR(50),
      CONSTRAINT FK_Notification
        FOREIGN KEY(Notification_Id) 
        REFERENCES Notification(Id)
  );`,
  `CREATE TABLE IF NOT EXISTS users
  (
      id UUID DEFAULT gen_random_uuid() PRIMARY KEY UNIQUE,
      given_name VARCHAR(255),
      family_name VARCHAR(255),
      email VARCHAR(255) UNIQUE,
      username VARCHAR(255) UNIQUE
  );`
]
const insertQueries = [`INSERT INTO Notification_State(State)
  VALUES ('New'), ('Seen'), ('Actioned'), ('Accepted'), ('Pending');
  `,
  `INSERT INTO Notification_Type(Type)
  VALUES ('THRESHOLD'), ('MARGIN'), ('UPDATE');`
];

(async () => {
  const client = await pool.connect()

  const createDb = async db => {
    //Check db exists before creating
    
    const result = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [db])

    if (!result.rows.length) {
      await client.query(`CREATE DATABASE ${db};`)

      console.log(`Database '${db}' created successfully`)
    } else {
      console.log(`Database '${db}' already exists`)
    }
  }

  const createUser = async () => {
    const user = await client.query('SELECT 1 FROM pg_user WHERE usename = $1', [newUser])

    if (!user.rows.length) {
      await client.query(`CREATE USER ${newUser} WITH ENCRYPTED PASSWORD '${newUserPassword}';`)
      console.log(`User ${newUser} created`)
    }
  }

  try {
    await createDb(newDb)

    await createUser()
    await Promise.all(tableQueries.map(query => client.query(query)))

    await Promise.all(insertQueries.map(query => client.query(query)))
  } catch (error) {
    console.error('Error in db operations:', error.message)
  } finally {
    client.release()
    pool.end()
  }
})();
