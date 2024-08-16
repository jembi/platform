const { Pool } = require("pg");

const user = process.env.POSTGRES_USER || "postgres";
const host = process.env.POSTGRES_SERVICE || "postgres-1";
const database = process.env.POSTGRES_DATABASE || "postgres";
const password = process.env.POSTGRES_PASSWORD || "instant101";
const port = process.env.POSTGRES_PORT || 5432;
const newDb = process.env.NEW_DATABASE_NAME || "openfn";
const newUser = process.env.NEW_DATABASE_USER || "openfn";
const newUserPassword = process.env.NEW_DATABASE_PASSWORD || "instant101";

const pool = new Pool({
  user,
  host,
  database,
  password,
  port,
});

const tableQueries = [];
const insertQueries = [];

(async () => {
  const client = await pool.connect();

  const createDb = async (db) => {
    //Check db exists before creating

    const result = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = $1",
      [db]
    );

    if (!result.rows.length) {
      await client.query('CREATE DATABASE $1;', [db]);

      console.log(`Database '${db}' created successfully`);
    } else {
      console.log(`Database '${db}' already exists`);
    }
  };

  const createUser = async () => {
    const user = await client.query(
      "SELECT 1 FROM pg_user WHERE usename = $1",
      [newUser]
    );

    if (!user.rows.length) {
      await client.query(
        'CREATE USER $1 WITH ENCRYPTED PASSWORD $2;', [newUser, newUserPassword]
      await client.query(
        `GRANT ALL PRIVILEGES ON DATABASE ${newDb} TO ${newUser};`
      );
      console.log(`User ${newUser} created`);
    }
  };

  try {
    await createDb(newDb);

    await createUser();
    await Promise.all(tableQueries.map((query) => client.query(query)));

    await Promise.all(insertQueries.map((query) => client.query(query)));
  } catch (error) {
    console.error("Error in db operations:", error.message);
  } finally {
    client.release();
    pool.end();
  }
})();
