const { Pool } = require('pg');

const user = process.env.POSTGRES_USER || 'postgres'
const host = process.env.POSTGRES_SERVICE || 'localhost'
const database = process.env.POSTGRES_DATABASE || 'postgres'
const password = process.env.POSTGRES_PASSWORD || 'instant101'
const port = process.env.POSTGRES_PORT || 5432
const newDb = process.env.NEW_DATABASE_NAME || 'hapi'
const newUser = process.env.NEW_DATABASE_USER || 'hapi'
const newUserPassword = process.env.NEW_DATABASE_PASSWORD || 'instant101'

const pool = new Pool({
  user,
  host,
  database,
  password,
  port
});

(async () => {
  const client = await pool.connect()

  try {
    // Check db existence before creating
    const result = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [newDb])

    if (!result.rows.length) {
      await client.query(`CREATE USER ${newUser} WITH ENCRYPTED PASSWORD '${newUserPassword}';`)

      console.log(`User ${newUser} created`)

      await client.query(`CREATE DATABASE ${newDb};`)

      console.log(`Database '${newDb}' created successfully`)
    } else {
      console.log(`Database '${newDb}' already exists`)
    }
  } catch (error) {
    console.error('Error creating database:', error.message)
  } finally {
    client.release()
    pool.end()
  }
})();

