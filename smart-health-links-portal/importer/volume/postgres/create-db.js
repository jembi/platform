const { Pool } = require('pg');

const user = process.env.POSTGRES_USER || 'postgres'
const host = process.env.POSTGRES_SERVICE || 'localhost'
const database = process.env.POSTGRES_DATABASE || 'postgres'
const password = process.env.POSTGRES_PASSWORD || 'instant101'
const port = process.env.POSTGRES_PORT || 5432
const newDbs = process.env.NEW_DATABASE_NAME || 'shlp'
const newUser = process.env.NEW_DATABASE_USER || 'shlp_user'
const newUserPassword = process.env.NEW_DATABASE_PASSWORD || 'shlp_password'

const pool = new Pool({
  user,
  host,
  database,
  password,
  port
});

(async () => {
  const client = await pool.connect()

  const createDb = async db => {
    //Check db exists before creating
    const result = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [db])

    if (!result.rows.length) {
      await client.query(`CREATE DATABASE ${db};`)

      const user = await client.query('SELECT 1 FROM pg_user WHERE usename = $1', [newUser])

      if (!user.rows.length) {
        await client.query(`CREATE USER ${newUser} WITH ENCRYPTED PASSWORD '${newUserPassword}' CREATEDB;`)
        await client.query(`GRANT ALL PRIVILEGES ON DATABASE ${db} TO ${newUser};`)
        console.log(`User ${newUser} created`)
      }

      console.log(`Database '${db}' created successfully`)
    } else {
      console.log(`Database '${db}' already exists`)
    }
  }

  try {
    await Promise.all(newDbs.split(',').map(db => createDb(db)))
  } catch (error) {
    console.error('Error creating database:', error.message)
  } finally {
    client.release()
    pool.end()
  }

  await new Promise(resolve => setTimeout(resolve, 60000));
})();
